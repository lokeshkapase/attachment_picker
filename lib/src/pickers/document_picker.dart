import '../models/attachment.dart';
import '../platform/attachment_picker_platform.dart';

/// Handles document file picking using native intents
class DocumentPicker {
  /// Pick a document file
  /// Returns null if user cancels or permission is denied
  Future<Attachment?> pickDocument({
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await AttachmentPickerPlatform.pickDocument(
        allowedExtensions: allowedExtensions,
      );
      
      if (result == null) {
        return null;
      }

      return Attachment.fromDocument(
        filePath: result['filePath'] as String,
        fileName: result['fileName'] as String,
        fileSize: result['fileSize'] as int,
        mimeType: result['mimeType'] as String,
      );
    } catch (e) {
      return null;
    }
  }
}
