# Debugging Camera and Gallery Issues

## If Camera/Gallery Not Opening

### 1. Check Logs

Run with verbose logging:
```bash
flutter run --verbose
```

Look for these log messages:
- `AttachmentPicker: pickCameraImage called`
- `AttachmentPicker: Activity is null` (if this appears, plugin not registered)
- `AttachmentPicker: Requesting camera permission`
- `AttachmentPicker: Camera permission granted, opening camera`

### 2. Verify Plugin Registration

**Android:**
- Check `MainActivity.kt` has plugin registration
- Verify `AttachmentPickerPlugin` is imported
- Check that `configureFlutterEngine` is called

**iOS:**
- Check `AppDelegate.swift` has plugin registration
- Verify `AttachmentPickerPlugin.register` is called

### 3. Check Permissions

**Android:**
- Verify `AndroidManifest.xml` has permissions:
  - `CAMERA`
  - `READ_EXTERNAL_STORAGE` or `READ_MEDIA_IMAGES` (Android 13+)

**iOS:**
- Verify `Info.plist` has usage descriptions:
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`

### 4. Test Permission Flow

1. First time: Permission dialog should appear
2. Grant permission: Camera/Gallery should open
3. Deny permission: Error should be returned

### 5. Common Issues

**Issue: "Activity is null"**
- Plugin not properly registered
- ActivityAware lifecycle not working
- Solution: Check MainActivity registration

**Issue: Permission denied immediately**
- Permission already denied in system settings
- Solution: Go to Settings > Apps > Your App > Permissions and enable

**Issue: Camera/Gallery opens but crashes**
- FileProvider not configured (Android)
- Solution: Check `file_paths.xml` exists

**Issue: No response from native code**
- MethodChannel name mismatch
- Solution: Verify channel name is `flutter_unified_attachment_picker`

## Quick Fixes

### Rebuild the app:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

### Check device logs:
```bash
# Android
adb logcat | grep AttachmentPicker

# iOS
# Check Xcode console
```

### Test MethodChannel directly:
Add this to your Dart code temporarily:
```dart
try {
  final result = await AttachmentPickerPlatform.pickCameraImage();
  print('Result: $result');
} catch (e) {
  print('Error: $e');
}
```





