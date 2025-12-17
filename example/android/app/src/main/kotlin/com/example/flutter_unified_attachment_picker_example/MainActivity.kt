package com.example.flutter_unified_attachment_picker_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.attachment_picker.AttachmentPickerPlugin

class MainActivity : FlutterActivity() {
    private val attachmentPickerPlugin = AttachmentPickerPlugin()
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(attachmentPickerPlugin)
    }
}
