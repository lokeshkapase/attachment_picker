/// Unified Attachment Picker for Flutter
/// 
/// A comprehensive package that handles all types of attachments:
/// - Camera photos
/// - Gallery images
/// - Documents (PDF, DOC, etc.)
/// - Audio recordings
/// 
/// All through a unified, beautiful bottom sheet UI.
library;

// Export models
export 'src/models/attachment.dart';

// Export platform
export 'src/platform/attachment_picker_platform.dart';

// Export pickers
export 'src/pickers/camera_picker.dart';
export 'src/pickers/gallery_picker.dart';
export 'src/pickers/document_picker.dart';
export 'src/pickers/audio_picker.dart';

// Export widgets
export 'src/widgets/unified_attachment_picker.dart';

