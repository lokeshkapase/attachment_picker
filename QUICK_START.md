# Quick Start Testing Guide

## Fastest Way to Test

### 1. Run the Example App

```bash
# From project root
cd example
flutter pub get
flutter run
```

### 2. Test All Features

1. **Tap "Pick Attachment"** button
2. **Test each option:**
   - 📷 Camera - Take a photo
   - 🖼️ Gallery - Pick an image
   - 📄 Documents - Select a PDF/DOC
   - 🎤 Audio - Record audio

### 3. Verify Results

After selecting each attachment type, verify:
- ✅ Attachment info is displayed
- ✅ File path exists
- ✅ File size is shown
- ✅ Preview works (for images)

## Quick Troubleshooting

**If something doesn't work:**

1. **Check permissions:**
   - Android: Settings > Apps > Your App > Permissions
   - iOS: Settings > Privacy > Camera/Microphone/Photos

2. **Check logs:**
   ```bash
   flutter run --verbose
   ```

3. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Platform-Specific Notes

### Android
- First run: Grant camera, storage, and microphone permissions
- Camera uses FileProvider (already configured)
- Audio uses native recorder intent

### iOS
- First run: Grant camera, microphone, and photo library permissions
- All permissions are in Info.plist (already configured)

That's it! The package should work out of the box. 🚀

