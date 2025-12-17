import '../models/attachment.dart';
import '../platform/attachment_picker_platform.dart';


class AudioPicker {

  Future<Attachment?> pickAudioFile() async {
    try {
      final result = await AttachmentPickerPlatform.pickAudioFile();
      if (result == null) {
        return null;
      }

      return Attachment.fromAudio(
        filePath: (result['filePath'] as String?) ?? '',
        fileName: result['fileName'] as String?,
        fileSize: result['fileSize'] as int?,
        mimeType: result['mimeType'] as String?,
        duration: result['duration'] as int?,
      );
    } catch (_) {
      return null;
    }
  }
}
