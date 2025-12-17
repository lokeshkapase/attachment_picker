import '../models/attachment.dart';
import '../platform/attachment_picker_platform.dart';

/// Handles camera image picking using native intents
class CameraPicker {
  /// Pick an image from camera
  /// Returns null if user cancels or permission is denied
  Future<Attachment?> pickImage() async {
    try {
      print('CameraPicker: Starting camera pick');
      final result = await AttachmentPickerPlatform.pickCameraImage();
      print('CameraPicker: Got result: $result');
      
      if (result == null) {
        print('CameraPicker: Result is null');
        return null;
      }

      return Attachment.fromCamera(
        filePath: result['filePath'] as String?? '',
        fileName: result['fileName'] as String?,
        fileSize: result['fileSize'] as int?,
        mimeType: result['mimeType'] as String?,
      );
    } catch (e) {
      print('CameraPicker: Exception: $e');
      return null;
    }
  }
}
