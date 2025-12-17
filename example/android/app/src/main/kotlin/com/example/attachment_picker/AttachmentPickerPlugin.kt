package com.example.attachment_picker

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.OpenableColumns
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class AttachmentPickerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingMethod: String? = null
    private var recordingPath: String? = null
    private var isRecording = false

    companion object {
        private const val CHANNEL_NAME = "flutter_unified_attachment_picker"
        private const val REQUEST_CAMERA = 1001
        private const val REQUEST_GALLERY = 1002
        private const val REQUEST_DOCUMENT = 1003
        private const val REQUEST_AUDIO = 1004
        private const val REQUEST_PERMISSION_CAMERA = 2001
        private const val REQUEST_PERMISSION_STORAGE = 2002
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        pendingResult = result
        pendingMethod = call.method
        when (call.method) {
            "pickCameraImage" -> pickCameraImage(result)
            "pickGalleryImage" -> pickGalleryImage(result)
            "pickDocument" -> {
                val allowedExtensions = call.argument<List<String>>("allowedExtensions")
                pickDocument(result, allowedExtensions)
            }
            "pickAudioFile" -> pickAudioFile(result)
            "requestPermission" -> {
                val permission = call.argument<String>("permission")
                requestPermission(permission, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun pickCameraImage(result: MethodChannel.Result) {
        val activity = this.activity ?: run {
            android.util.Log.e("AttachmentPicker", "Activity is null")
            result.error("NO_ACTIVITY", "Activity is null", null)
            return
        }

        android.util.Log.d("AttachmentPicker", "pickCameraImage called")

        if (ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.CAMERA
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            android.util.Log.d("AttachmentPicker", "Requesting camera permission")
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.CAMERA),
                REQUEST_PERMISSION_CAMERA
            )
            // Don't return error here - wait for permission result
            // Store result to handle after permission is granted
            return
        }

        android.util.Log.d("AttachmentPicker", "Camera permission granted, opening camera")
        try {
            val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            val photoFile = File(activity.getExternalFilesDir(null), "camera_${System.currentTimeMillis()}.jpg")
            recordingPath = photoFile.absolutePath

            val photoURI = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                FileProvider.getUriForFile(
                    activity,
                    "${activity.packageName}.fileprovider",
                    photoFile
                )
            } else {
                Uri.fromFile(photoFile)
            }

            intent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
            intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            activity.startActivityForResult(intent, REQUEST_CAMERA)
        } catch (e: Exception) {
            android.util.Log.e("AttachmentPicker", "Error opening camera: ${e.message}")
            result.error("ERROR", "Failed to open camera: ${e.message}", null)
        }
    }

    private fun pickGalleryImage(result: MethodChannel.Result) {
        val activity = this.activity ?: run {
            android.util.Log.e("AttachmentPicker", "Activity is null")
            result.error("NO_ACTIVITY", "Activity is null", null)
            return
        }

        android.util.Log.d("AttachmentPicker", "pickGalleryImage called")

        val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_IMAGES
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }

        if (ContextCompat.checkSelfPermission(activity, permission) != PackageManager.PERMISSION_GRANTED) {
            android.util.Log.d("AttachmentPicker", "Requesting storage permission")
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(permission),
                REQUEST_PERMISSION_STORAGE
            )
            // Don't return error here - wait for permission result
            return
        }

        android.util.Log.d("AttachmentPicker", "Storage permission granted, opening gallery")
        try {
            val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
            activity.startActivityForResult(intent, REQUEST_GALLERY)
        } catch (e: Exception) {
            android.util.Log.e("AttachmentPicker", "Error opening gallery: ${e.message}")
            result.error("ERROR", "Failed to open gallery: ${e.message}", null)
        }
    }

    private fun pickDocument(result: MethodChannel.Result, allowedExtensions: List<String>?) {
        val activity = this.activity ?: run {
            result.error("NO_ACTIVITY", "Activity is null", null)
            return
        }

        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "*/*"
        intent.addCategory(Intent.CATEGORY_OPENABLE)

        if (allowedExtensions != null && allowedExtensions.isNotEmpty()) {
            val mimeTypes = allowedExtensions.map { getMimeType(it) }.filterNotNull()
            if (mimeTypes.isNotEmpty()) {
                intent.type = mimeTypes[0]
                if (mimeTypes.size > 1) {
                    intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes.toTypedArray())
                }
            }
        }

        try {
            activity.startActivityForResult(Intent.createChooser(intent, "Select Document"), REQUEST_DOCUMENT)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to open document picker: ${e.message}", null)
        }
    }

    private fun pickAudioFile(result: MethodChannel.Result) {
        val activity = this.activity ?: run {
            result.error("NO_ACTIVITY", "Activity is null", null)
            return
        }

        val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }

        if (ContextCompat.checkSelfPermission(activity, permission) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(permission),
                REQUEST_PERMISSION_STORAGE
            )
            return
        }

        try {
            val intent = Intent(Intent.ACTION_GET_CONTENT)
            intent.type = "audio/*"
            intent.addCategory(Intent.CATEGORY_OPENABLE)
            activity.startActivityForResult(Intent.createChooser(intent, "Select Audio"), REQUEST_AUDIO)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to open audio picker: ${e.message}", null)
        }
    }

    private fun requestPermission(permission: String?, result: MethodChannel.Result) {
        val activity = this.activity ?: run {
            result.success(false)
            return
        }

        val androidPermission = when (permission) {
            "camera" -> Manifest.permission.CAMERA
            "microphone" -> Manifest.permission.RECORD_AUDIO
            "storage" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                Manifest.permission.READ_MEDIA_IMAGES
            } else {
                Manifest.permission.READ_EXTERNAL_STORAGE
            }
            else -> {
                result.success(false)
                return
            }
        }

        val granted = ContextCompat.checkSelfPermission(activity, androidPermission) == PackageManager.PERMISSION_GRANTED
        result.success(granted)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (pendingResult == null) return false

        when (requestCode) {
            REQUEST_CAMERA -> {
                if (resultCode == Activity.RESULT_OK && recordingPath != null) {
                    val file = File(recordingPath!!)
                    if (file.exists()) {
                        val fileSize = file.length()
                        pendingResult?.success(mapOf(
                            "filePath" to recordingPath,
                            "fileName" to file.name,
                            "fileSize" to fileSize,
                            "mimeType" to "image/jpeg"
                        ))
                    } else {
                        pendingResult?.error("ERROR", "Camera file not found", null)
                    }
                } else {
                    pendingResult?.error("CANCELLED", "User cancelled camera", null)
                }
                recordingPath = null
                pendingResult = null
                return true
            }
            REQUEST_GALLERY -> {
                if (resultCode == Activity.RESULT_OK && data?.data != null) {
                    handleGalleryResult(data.data!!)
                } else {
                    pendingResult?.error("CANCELLED", "User cancelled gallery", null)
                    pendingResult = null
                }
                return true
            }
            REQUEST_DOCUMENT -> {
                if (resultCode == Activity.RESULT_OK && data?.data != null) {
                    handleDocumentResult(data.data!!)
                } else {
                    pendingResult?.error("CANCELLED", "User cancelled document picker", null)
                    pendingResult = null
                }
                return true
            }
            REQUEST_AUDIO -> {
                if (resultCode == Activity.RESULT_OK && data?.data != null) {
                    handleAudioResult(data.data!!)
                } else {
                    pendingResult?.error("CANCELLED", "User cancelled audio picker", null)
                    pendingResult = null
                }
                return true
            }
        }
        return false
    }

    private fun handleGalleryResult(uri: Uri) {
        val activity = this.activity ?: run {
            pendingResult?.error("NO_ACTIVITY", "Activity is null", null)
            return
        }

        try {
            val inputStream: InputStream? = activity.contentResolver.openInputStream(uri)
            val file = File(activity.getExternalFilesDir(null), "gallery_${System.currentTimeMillis()}.jpg")
            val outputStream = FileOutputStream(file)

            inputStream?.use { input ->
                outputStream.use { output ->
                    input.copyTo(output)
                }
            }

            val fileSize = file.length()
            val cursor = activity.contentResolver.query(uri, null, null, null, null)
            var fileName = "image.jpg"
            cursor?.use {
                if (it.moveToFirst()) {
                    val nameIndex = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (nameIndex != -1) {
                        fileName = it.getString(nameIndex)
                    }
                }
            }

            pendingResult?.success(mapOf(
                "filePath" to file.absolutePath,
                "fileName" to fileName,
                "fileSize" to fileSize,
                "mimeType" to "image/jpeg"
            ))
        } catch (e: Exception) {
            pendingResult?.error("ERROR", "Failed to process gallery image: ${e.message}", null)
        }
        pendingResult = null
    }

    private fun handleDocumentResult(uri: Uri) {
        val activity = this.activity ?: run {
            pendingResult?.error("NO_ACTIVITY", "Activity is null", null)
            return
        }

        try {
            val inputStream: InputStream? = activity.contentResolver.openInputStream(uri)
            val cursor = activity.contentResolver.query(uri, null, null, null, null)
            var fileName = "document"
            var fileSize = 0L

            cursor?.use {
                if (it.moveToFirst()) {
                    val nameIndex = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    val sizeIndex = it.getColumnIndex(OpenableColumns.SIZE)
                    if (nameIndex != -1) {
                        fileName = it.getString(nameIndex)
                    }
                    if (sizeIndex != -1) {
                        fileSize = it.getLong(sizeIndex)
                    }
                }
            }

            val file = File(activity.getExternalFilesDir(null), fileName)
            val outputStream = FileOutputStream(file)

            inputStream?.use { input ->
                outputStream.use { output ->
                    input.copyTo(output)
                }
            }

            val mimeType = activity.contentResolver.getType(uri) ?: "application/octet-stream"

            pendingResult?.success(mapOf(
                "filePath" to file.absolutePath,
                "fileName" to fileName,
                "fileSize" to file.length(),
                "mimeType" to mimeType
            ))
        } catch (e: Exception) {
            pendingResult?.error("ERROR", "Failed to process document: ${e.message}", null)
        }
        pendingResult = null
    }

    private fun getMimeType(extension: String): String? {
        return when (extension.lowercase()) {
            "pdf" -> "application/pdf"
            "doc" -> "application/msword"
            "docx" -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            "xls" -> "application/vnd.ms-excel"
            "xlsx" -> "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            "ppt" -> "application/vnd.ms-powerpoint"
            "pptx" -> "application/vnd.openxmlformats-officedocument.presentationml.presentation"
            "txt" -> "text/plain"
            "rtf" -> "application/rtf"
            "mp3" -> "audio/mpeg"
            "wav" -> "audio/wav"
            "m4a" -> "audio/mp4"
            else -> null
        }
    }

    private fun handleAudioResult(uri: Uri) {
        val activity = this.activity ?: run {
            pendingResult?.error("NO_ACTIVITY", "Activity is null", null)
            return
        }

        try {
            val inputStream: InputStream? = activity.contentResolver.openInputStream(uri)
            val cursor = activity.contentResolver.query(uri, null, null, null, null)
            var fileName = "audio"
            var fileSize = 0L

            cursor?.use {
                if (it.moveToFirst()) {
                    val nameIndex = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    val sizeIndex = it.getColumnIndex(OpenableColumns.SIZE)
                    if (nameIndex != -1) {
                        fileName = it.getString(nameIndex)
                    }
                    if (sizeIndex != -1) {
                        fileSize = it.getLong(sizeIndex)
                    }
                }
            }

            val file = File(activity.getExternalFilesDir(null), fileName)
            val outputStream = FileOutputStream(file)

            inputStream?.use { input ->
                outputStream.use { output ->
                    input.copyTo(output)
                }
            }

            val mimeType = activity.contentResolver.getType(uri) ?: "audio/*"

            pendingResult?.success(mapOf(
                "filePath" to file.absolutePath,
                "fileName" to fileName,
                "fileSize" to file.length(),
                "mimeType" to mimeType
            ))
        } catch (e: Exception) {
            pendingResult?.error("ERROR", "Failed to process audio: ${e.message}", null)
        }
        pendingResult = null
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        android.util.Log.d("AttachmentPicker", "onRequestPermissionsResult: requestCode=$requestCode")
        
        if (grantResults.isEmpty() || grantResults[0] != PackageManager.PERMISSION_GRANTED) {
            android.util.Log.d("AttachmentPicker", "Permission denied")
            pendingResult?.error("PERMISSION_DENIED", "Permission not granted", null)
            pendingResult = null
            pendingMethod = null
            return true
        }

        android.util.Log.d("AttachmentPicker", "Permission granted, retrying method: $pendingMethod")
        
        when (requestCode) {
            REQUEST_PERMISSION_CAMERA -> {
                if (pendingMethod == "pickCameraImage") {
                    pickCameraImage(pendingResult!!)
                }
            }
            REQUEST_PERMISSION_STORAGE -> {
                when (pendingMethod) {
                    "pickGalleryImage" -> pickGalleryImage(pendingResult!!)
                    "pickAudioFile" -> pickAudioFile(pendingResult!!)
                }
            }
        }
        
        return true
    }
}


