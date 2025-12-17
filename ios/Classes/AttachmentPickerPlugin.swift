import Flutter
import UIKit
import AVFoundation
import Photos
import UniformTypeIdentifiers

public class AttachmentPickerPlugin: NSObject, FlutterPlugin, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate {
    
    private var channel: FlutterMethodChannel
    private var result: FlutterResult?
    private var audioRecorder: AVAudioRecorder?
    private var recordingPath: String?
    private var isRecording = false
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_unified_attachment_picker", binaryMessenger: registrar.messenger())
        let instance = AttachmentPickerPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        
        switch call.method {
        case "pickCameraImage":
            pickCameraImage()
        case "pickGalleryImage":
            pickGalleryImage()
        case "pickDocument":
            let args = call.arguments as? [String: Any]
            let allowedExtensions = args?["allowedExtensions"] as? [String]
            pickDocument(allowedExtensions: allowedExtensions)
        case "pickAudioFile":
            pickAudioFile()
        case "requestPermission":
            let args = call.arguments as? [String: Any]
            let permission = args?["permission"] as? String
            requestPermission(permission: permission, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    private func pickCameraImage() {
        guard let viewController = getRootViewController() else {
            result?(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller found", details: nil))
            return
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            viewController.present(imagePicker, animated: true)
        } else {
            result?(FlutterError(code: "CAMERA_NOT_AVAILABLE", message: "Camera not available", details: nil))
        }
    }
    
    private func pickGalleryImage() {
        guard let viewController = getRootViewController() else {
            result?(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller found", details: nil))
            return
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            viewController.present(imagePicker, animated: true)
        } else {
            result?(FlutterError(code: "GALLERY_NOT_AVAILABLE", message: "Gallery not available", details: nil))
        }
    }
    
    private func pickDocument(allowedExtensions: [String]?) {
        guard let viewController = getRootViewController() else {
            result?(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller found", details: nil))
            return
        }
        
        var documentTypes: [String] = ["public.data"]
        
        if let extensions = allowedExtensions {
            documentTypes = extensions.compactMap { ext -> String? in
                switch ext.lowercased() {
                case "pdf":
                    return "com.adobe.pdf"
                case "doc", "docx":
                    return "com.microsoft.word.doc"
                case "xls", "xlsx":
                    return "com.microsoft.excel.xls"
                case "ppt", "pptx":
                    return "com.microsoft.powerpoint.ppt"
                case "txt":
                    return "public.plain-text"
                default:
                    return "public.data"
                }
            }
        }
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes.map { UTType($0)! })
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        viewController.present(documentPicker, animated: true)
    }
    
    private func pickAudioFile() {
        guard let viewController = getRootViewController() else {
            result?(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller found", details: nil))
            return
        }
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        viewController.present(documentPicker, animated: true)
    }
    
    private func requestPermission(permission: String?, result: @escaping FlutterResult) {
        switch permission {
        case "camera":
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            result(status == .authorized)
        case "storage", "photos":
            let status = PHPhotoLibrary.authorizationStatus()
            result(status == .authorized || status == .limited)
        default:
            result(false)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let imageName = "image_\(Int(Date().timeIntervalSince1970)).jpg"
            let imagePath = documentsPath.appendingPathComponent(imageName)
            
            if let imageData = image.jpegData(compressionQuality: 0.85) {
                do {
                    try imageData.write(to: imagePath)
                    let fileSize = imageData.count
                    
                    result?([
                        "filePath": imagePath.path,
                        "fileName": imageName,
                        "fileSize": fileSize,
                        "mimeType": "image/jpeg"
                    ])
                } catch {
                    result?(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        } else {
            result?(FlutterError(code: "NO_IMAGE", message: "No image selected", details: nil))
        }
        
        result = nil
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        result?(FlutterError(code: "CANCELLED", message: "User cancelled", details: nil))
        result = nil
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            result?(FlutterError(code: "NO_DOCUMENT", message: "No document selected", details: nil))
            result = nil
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = url.lastPathComponent
        let destinationPath = documentsPath.appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: destinationPath.path) {
                try FileManager.default.removeItem(at: destinationPath)
            }
            
            try FileManager.default.copyItem(at: url, to: destinationPath)
            
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: destinationPath.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            
            let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
            
            result?([
                "filePath": destinationPath.path,
                "fileName": fileName,
                "fileSize": fileSize,
                "mimeType": mimeType
            ])
        } catch {
            result?(FlutterError(code: "COPY_ERROR", message: error.localizedDescription, details: nil))
        }
        
        result = nil
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        result?(FlutterError(code: "CANCELLED", message: "User cancelled", details: nil))
        result = nil
    }
}

