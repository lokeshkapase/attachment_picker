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

      final filePath = result['filePath'] as String?;
      final fileName = result['fileName'] as String?;
      final fileSize = result['fileSize'] as int?;
      final mimeType = result['mimeType'] as String?;
      

      final attachment = Attachment.fromGallery(
        filePath: filePath ?? '',
        fileName: fileName,
        fileSize: fileSize,
        mimeType: mimeType,
      );
      
      return attachment;
    } catch (e, stackTrace) {
      return null;
    }
  }
}
