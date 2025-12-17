# Testing Guide for flutter_unified_attachment_picker

This guide will help you test all features of the unified attachment picker package.

## Prerequisites

1. **Flutter SDK** installed (3.7.2 or higher)
2. **Android Studio** or **Xcode** (for native builds)
3. **Physical device or emulator**:
   - Android: API 21+ (Android 5.0+)
   - iOS: iOS 12.0+

## Setup Steps

### 1. Install Dependencies

```bash
# Navigate to the project root
cd attachment_picker

# Get Flutter dependencies
flutter pub get

# Navigate to example directory
cd example

# Get example app dependencies
flutter pub get
```

### 2. Platform-Specific Setup

#### Android Setup

The Android setup is already configured:
- ✅ Permissions added to `AndroidManifest.xml`
- ✅ FileProvider configured
- ✅ Plugin registered in `MainActivity.kt`

**Verify Android Setup:**
```bash
# Check if Android setup is correct
flutter doctor -v
```

#### iOS Setup

The iOS setup is already configured:
- ✅ Permissions added to `Info.plist`
- ✅ Plugin registered in `AppDelegate.swift`

**Verify iOS Setup:**
```bash
# Check if iOS setup is correct
flutter doctor -v

# For iOS, you may need to run pod install
cd ios
pod install
cd ..
```

## Running the Example App

### On Android

```bash
# From the example directory
cd example

# List available devices
flutter devices

# Run on Android device/emulator
flutter run
```

### On iOS

```bash
# From the example directory
cd example

# Run on iOS device/simulator
flutter run
```

## Testing Each Feature

### 1. Testing Camera 📷

**Steps:**
1. Tap "Pick Attachment" button
2. Select "Camera" option
3. Grant camera permission when prompted (first time only)
4. Take a photo
5. Confirm the photo

**Expected Result:**
- Camera opens
- Photo is captured
- Image preview appears in the app
- File details show: type (camera), file path, file size, MIME type

**Troubleshooting:**
- If camera doesn't open: Check if device has a camera
- If permission denied: Go to device Settings > Apps > Your App > Permissions > Camera

### 2. Testing Gallery 🖼️

**Steps:**
1. Tap "Pick Attachment" button
2. Select "Gallery" option
3. Grant storage/photo permission when prompted (first time only)
4. Select an image from gallery
5. Confirm selection

**Expected Result:**
- Gallery opens
- Image is selected
- Image preview appears in the app
- File details show: type (gallery), file path, file size, MIME type

**Troubleshooting:**
- If gallery doesn't open: Check storage permissions
- On Android 13+: Uses READ_MEDIA_IMAGES permission

### 3. Testing Documents 📄

**Steps:**
1. Tap "Pick Attachment" button
2. Select "Documents" option
3. Browse and select a document (PDF, DOC, DOCX, etc.)
4. Confirm selection

**Expected Result:**
- Document picker opens
- Document is selected
- Document info appears in the app
- File details show: type (document), file name, file size, MIME type

**Troubleshooting:**
- If document picker doesn't open: Check if file manager app is installed
- Supported formats: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, TXT, RTF

### 4. Testing Audio Recording 🎤

**Steps:**
1. Tap "Pick Attachment" button
2. Select "Audio" option
3. Grant microphone permission when prompted (first time only)
4. Start recording (on Android, native recorder opens)
5. Stop recording
6. Confirm the recording

**Expected Result:**
- Audio recording starts
- Recording indicator shows duration
- Recording stops successfully
- Audio file info appears in the app
- File details show: type (audio), file path, file size, MIME type (audio/m4a)

**Troubleshooting:**
- If recording doesn't start: Check microphone permission
- On Android: Uses native audio recorder intent
- On iOS: Uses AVAudioRecorder

## Testing Checklist

Use this checklist to ensure all features work:

- [ ] Camera permission requested and granted
- [ ] Camera photo capture works
- [ ] Gallery permission requested and granted
- [ ] Gallery image selection works
- [ ] Document picker opens
- [ ] Document selection works (test with PDF, DOC)
- [ ] Microphone permission requested and granted
- [ ] Audio recording starts
- [ ] Audio recording stops
- [ ] Audio file is saved
- [ ] All attachment types return correct Attachment model
- [ ] File paths are valid
- [ ] File sizes are correct
- [ ] MIME types are correct

## Testing on Different Devices

### Android Testing

Test on:
- [ ] Android 5.0+ (API 21-22)
- [ ] Android 6.0+ (API 23-28) - Runtime permissions
- [ ] Android 10+ (API 29+) - Scoped storage
- [ ] Android 13+ (API 33+) - Granular media permissions

### iOS Testing

Test on:
- [ ] iOS 12.0+
- [ ] iOS 14.0+ (Photo library permissions)
- [ ] iOS 15.0+ (Window API changes)

## Debugging Tips

### Check Logs

```bash
# Android
flutter run --verbose

# iOS
flutter run --verbose
```

### Common Issues

1. **Plugin not found**
   - Solution: Ensure plugin is registered in MainActivity (Android) and AppDelegate (iOS)

2. **Permission denied**
   - Solution: Check Info.plist (iOS) and AndroidManifest.xml (Android) have correct permissions

3. **File not found**
   - Solution: Check file paths are correct and files exist at those paths

4. **MethodChannel errors**
   - Solution: Verify channel name matches: `flutter_unified_attachment_picker`

### Testing MethodChannel Directly

You can test the platform channel directly:

```dart
import 'package:flutter_unified_attachment_picker/flutter_unified_attachment_picker.dart';

// Test camera
final result = await AttachmentPickerPlatform.pickCameraImage();
print('Camera result: $result');

// Test gallery
final result = await AttachmentPickerPlatform.pickGalleryImage();
print('Gallery result: $result');
```

## Automated Testing

### Unit Tests

Create tests in `test/` directory:

```dart
// test/attachment_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unified_attachment_picker/flutter_unified_attachment_picker.dart';

void main() {
  test('Attachment model creation', () {
    final attachment = Attachment.fromCamera(
      filePath: '/path/to/image.jpg',
      fileName: 'image.jpg',
      fileSize: 1024,
    );
    
    expect(attachment.type, AttachmentType.camera);
    expect(attachment.isImage, true);
    expect(attachment.fileName, 'image.jpg');
  });
}
```

Run tests:
```bash
flutter test
```

## Performance Testing

1. **Memory Usage**: Check memory doesn't spike when picking large files
2. **Response Time**: Test picker opens quickly (< 500ms)
3. **File Size**: Test with large files (10MB+ images, 50MB+ documents)

## Next Steps

After testing:
1. Fix any bugs found
2. Update documentation if needed
3. Create release build
4. Test on multiple devices
5. Prepare for publishing

## Support

If you encounter issues:
1. Check the logs
2. Verify permissions are set correctly
3. Test on a different device
4. Check Flutter and platform versions

