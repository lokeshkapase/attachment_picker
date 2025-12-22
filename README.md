# flutter_unified_attachment_picker

⭐ **A unified Flutter package for picking attachments including camera, gallery, documents, and audio recording.**

Perfect for chat apps, diary apps, LMS apps, and any app that needs comprehensive attachment functionality.

## Features

- 📷 **Camera** - Take photos directly from the camera
- 🖼️ **Gallery** - Pick images from device gallery
- 📄 **Documents** - Pick PDF, DOC, DOCX, and other document files
- 🎤 **Audio Recording** - Record audio with duration tracking
- 🎨 **Unified UI** - Beautiful bottom sheet with all options in one place
- 📦 **Single Model** - Returns a unified `Attachment` model for all types

## Why This Package?

No other Flutter package provides **ALL** of these attachment types together in a unified interface. This package eliminates the need to integrate multiple packages and handle different return types.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_unified_attachment_picker: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS

Add the following permissions to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record audio</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select images</string>
```

## Usage

### Basic Usage

```dart
import 'package:flutter_unified_attachment_picker/flutter_unified_attachment_picker.dart';

// Show the unified attachment picker
final attachment = await UnifiedAttachmentPicker.show(
  context: context,
  title: 'Choose Attachment',
);

if (attachment != null) {
  // Handle the selected attachment
  print('Attachment type: ${attachment.type}');
  print('File path: ${attachment.filePath}');
  print('File name: ${attachment.fileName}');
}
```

### Advanced Usage with Options

```dart
final attachment = await UnifiedAttachmentPicker.show(
  context: context,
  title: 'Select Attachment',
  showCamera: true,
  showGallery: true,
  showDocuments: true,
  showAudio: true,
  allowedDocumentExtensions: ['pdf', 'doc', 'docx'],
  backgroundColor: Colors.white,
  iconColor: Colors.blue,
);
```

### Working with Attachments

```dart
if (attachment != null) {
  // Check attachment type
  if (attachment.isImage) {
    // Handle image (camera or gallery)
    final imageFile = File(attachment.filePath!);
    // Display or upload image
  } else if (attachment.isDocument) {
    // Handle document
    final docFile = File(attachment.filePath!);
    // Upload or process document
  } else if (attachment.isAudio) {
    // Handle audio
    final audioFile = File(attachment.filePath!);
    print('Duration: ${attachment.duration} seconds');
    // Play or upload audio
  }
}
```

### Using Individual Pickers

You can also use individual pickers if you need more control:

```dart
// Camera
final cameraPicker = CameraPicker();
final cameraAttachment = await cameraPicker.pickImage();

// Gallery
final galleryPicker = GalleryPicker();
final galleryAttachment = await galleryPicker.pickImage();

// Documents
final documentPicker = DocumentPicker();
final docAttachment = await documentPicker.pickDocument(
  allowedExtensions: ['pdf', 'doc', 'docx'],
);

// Audio
final audioPicker = AudioPicker();
final recordingPath = await audioPicker.startRecording();
// ... wait for user to finish recording ...
final audioAttachment = await audioPicker.stopRecording(recordingPath);

```

## Attachment Model

The `Attachment` class provides a unified model for all attachment types:

```dart
class Attachment {
  final AttachmentType type;        // camera, gallery, document, audio
  final String? filePath;            // Path to the file
  final String? fileName;            // Name of the file
  final int? fileSize;               // Size in bytes
  final String? mimeType;            // MIME type (e.g., 'image/jpeg', 'application/pdf')
  final String? thumbnailPath;       // Thumbnail path (if applicable)
  final int? duration;               // Duration in seconds (for audio)
  
  // Helper getters
  bool get isImage;
  bool get isDocument;
  bool get isAudio;
}
```

## Customization


## Example

See the `example/` directory for a complete example app demonstrating all features.

## Implementation

This package uses **native platform implementations** via MethodChannel:

- **Android**: Uses native Intents for camera, gallery, document picking, and audio recording
- **iOS**: Uses native UIImagePickerController, UIDocumentPickerViewController, and AVAudioRecorder

No external Flutter packages are required - everything is implemented natively for optimal performance and smaller app size.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

If you find this package useful, please consider giving it a ⭐ on GitHub!

---

**Made with ❤️ for the Flutter community**
