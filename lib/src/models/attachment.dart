
/// Attachment type enumeration
enum AttachmentType {
  /// Image from camera
  camera,
  
  /// Image from gallery
  gallery,
  
  /// Document file (PDF, DOC, etc.)
  document,
  
  /// Audio recording
  audio,
}

/// Unified attachment model that represents any type of attachment
class Attachment {
  /// Type of attachment
  final AttachmentType type;
  
  /// File path (for camera, gallery, document, audio)
  final String? filePath;
  
  /// File name
  final String? fileName;
  
  /// File size in bytes
  final int? fileSize;
  
  /// MIME type (e.g., 'image/jpeg', 'application/pdf', 'audio/m4a')
  final String? mimeType;
  
  /// Thumbnail path (for images and documents)
  final String? thumbnailPath;
  
  /// Duration in seconds (for audio)
  final int? duration;

  const Attachment({
    required this.type,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.thumbnailPath,
    this.duration,
  });

  /// Create attachment from camera image
  factory Attachment.fromCamera({
    required String filePath,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? thumbnailPath,
  }) {
    return Attachment(
      type: AttachmentType.camera,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType ?? 'image/jpeg',
      thumbnailPath: thumbnailPath,
    );
  }

  /// Create attachment from gallery image
  factory Attachment.fromGallery({
    required String filePath,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? thumbnailPath,
  }) {
    return Attachment(
      type: AttachmentType.gallery,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType ?? 'image/jpeg',
      thumbnailPath: thumbnailPath,
    );
  }

  /// Create attachment from document
  factory Attachment.fromDocument({
    required String filePath,
    required String fileName,
    required int fileSize,
    required String mimeType,
    String? thumbnailPath,
  }) {
    return Attachment(
      type: AttachmentType.document,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      thumbnailPath: thumbnailPath,
    );
  }

  /// Create attachment from audio recording
  factory Attachment.fromAudio({
    required String filePath,
    String? fileName,
    int? fileSize,
    String? mimeType,
    int? duration,
  }) {
    return Attachment(
      type: AttachmentType.audio,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType ?? 'audio/m4a',
      duration: duration,
    );
  }

  /// Check if attachment is an image
  bool get isImage => type == AttachmentType.camera || type == AttachmentType.gallery;

  /// Check if attachment is a document
  bool get isDocument => type == AttachmentType.document;

  /// Check if attachment is audio
  bool get isAudio => type == AttachmentType.audio;

  @override
  String toString() {
    return 'Attachment(type: $type, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType)';
  }
}

