import '../models/attachment.dart';
import '../platform/attachment_picker_platform.dart';

/// Handles camera image picking using native intents
class CameraPicker {
  /// Pick an image from camera
  /// Returns null if user cancels or permission is denied
  Future<Attachment?> pickImage() async {
    try {
      final result = await AttachmentPickerPlatform.pickCameraImage();

      if (result == null) {
        return null;
      }

      return Attachment.fromCamera(
        filePath: result['filePath'] as String?? '',
        fileName: result['fileName'] as String?,
        fileSize: result['fileSize'] as int?,
        mimeType: result['mimeType'] as String?,
      );
    } catch (e) {
      return null;
    }
  }
}
