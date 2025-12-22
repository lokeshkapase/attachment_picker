import '../models/attachment.dart';
import '../platform/attachment_picker_platform.dart';

/// Handles gallery image picking using native intents
class GalleryPicker {
  /// Pick an image from gallery
  /// Returns null if user cancels or permission is denied
  Future<Attachment?> pickImage() async {
    try {
      print('GalleryPicker: Starting pickImage');
      final result = await AttachmentPickerPlatform.pickGalleryImage();
      print('GalleryPicker: Received result from platform: $result');

      if (result == null) {
        print('GalleryPicker: Result is null, returning null');
        return null;
      }

      final filePath = result['filePath'] as String?;
      final fileName = result['fileName'] as String?;
      final fileSize = result['fileSize'] as int?;
      final mimeType = result['mimeType'] as String?;
      
      print('GalleryPicker: Parsed values - filePath: $filePath, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType');

      final attachment = Attachment.fromGallery(
        filePath: filePath ?? '',
        fileName: fileName,
        fileSize: fileSize,
        mimeType: mimeType,
      );
      
      print('GalleryPicker: Created attachment with filePath: ${attachment.filePath}');
      return attachment;
    } catch (e, stackTrace) {
      print('GalleryPicker: Exception in pickImage: $e');
      print('GalleryPicker: Stack trace: $stackTrace');
      return null;
    }
  }
}
