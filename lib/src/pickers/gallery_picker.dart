import '../models/attachment.dart';
import '../platform/attachment_picker_platform.dart';

/// Handles gallery image picking using native intents
class GalleryPicker {
  /// Pick an image from gallery
  /// Returns null if user cancels or permission is denied
  Future<Attachment?> pickImage() async {
    try {
      print('GalleryPicker: Starting gallery pick');
      final result = await AttachmentPickerPlatform.pickGalleryImage();
      print('GalleryPicker: Got result: $result');
      
      if (result == null) {
        print('GalleryPicker: Result is null');
        return null;
      }

      return Attachment.fromGallery(
        filePath: result['filePath'] as String? ?? '',
        fileName: result['fileName'] as String?,
        fileSize: result['fileSize'] as int?,
        mimeType: result['mimeType'] as String?,
      );
    } catch (e) {
      print('GalleryPicker: Exception: $e');
      return null;
    }
  }
}
