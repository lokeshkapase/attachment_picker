import '../models/attachment.dart';
import '../platform/attachment_picker_platform.dart';

/// Handles gallery image picking using native intents
class GalleryPicker {
  /// Pick an image from gallery
  /// Returns null if user cancels or permission is denied
  Future<Attachment?> pickImage() async {
    try {
      final result = await AttachmentPickerPlatform.pickGalleryImage();

      if (result == null) {
        return null;
      }

      return Attachment.fromGallery(
        filePath: result['filePath'] as String? ?? '',
        fileName: result['fileName'] as String?,
        fileSize: result['fileSize'] as int?,
        mimeType: result['mimeType'] as String?,
      );
    } catch (e) {
      return null;
    }
  }
}
