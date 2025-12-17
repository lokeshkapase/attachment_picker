import 'package:flutter/material.dart';
import '../models/attachment.dart';
import '../pickers/camera_picker.dart';
import '../pickers/gallery_picker.dart';
import '../pickers/document_picker.dart';
import '../pickers/audio_picker.dart';


class UnifiedAttachmentPicker {

  static Future<Attachment?> show({
    required BuildContext context,
    String? title,
    bool showCamera = true,
    bool showGallery = true,
    bool showDocuments = true,
    bool showAudio = true,
    List<String>? allowedDocumentExtensions,
    Color? backgroundColor,
    Color? iconColor,
  }) async {
    return await showModalBottomSheet<Attachment>(
      context: context,
      backgroundColor: backgroundColor ?? Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AttachmentPickerBottomSheet(
        title: title,
        showCamera: showCamera,
        showGallery: showGallery,
        showDocuments: showDocuments,
        showAudio: showAudio,
        allowedDocumentExtensions: allowedDocumentExtensions,
        iconColor: iconColor,
      ),
    );
  }
}

class _AttachmentPickerBottomSheet extends StatefulWidget {
  final String? title;
  final bool showCamera;
  final bool showGallery;
  final bool showDocuments;
  final bool showAudio;
  final List<String>? allowedDocumentExtensions;
  final Color? iconColor;

  const _AttachmentPickerBottomSheet({
    this.title,
    required this.showCamera,
    required this.showGallery,
    required this.showDocuments,
    required this.showAudio,
    this.allowedDocumentExtensions,
    this.iconColor,
  });

  @override
  State<_AttachmentPickerBottomSheet> createState() =>
      _AttachmentPickerBottomSheetState();
}

class _AttachmentPickerBottomSheetState
    extends State<_AttachmentPickerBottomSheet> {
  final CameraPicker _cameraPicker = CameraPicker();
  final GalleryPicker _galleryPicker = GalleryPicker();
  final DocumentPicker _documentPicker = DocumentPicker();
  final AudioPicker _audioPicker = AudioPicker();

  Future<void> _handleCamera() async {
    Navigator.pop(context);
    final attachment = await _cameraPicker.pickImage();
    if (attachment != null && mounted) {
      Navigator.pop(context, attachment);
    }
  }

  Future<void> _handleGallery() async {
    Navigator.pop(context);
    final attachment = await _galleryPicker.pickImage();
    if (attachment != null && mounted) {
      Navigator.pop(context, attachment);
    }
  }

  Future<void> _handleDocuments() async {
    Navigator.pop(context);
    final attachment = await _documentPicker.pickDocument(
      allowedExtensions: widget.allowedDocumentExtensions,
    );
    if (attachment != null && mounted) {
      Navigator.pop(context, attachment);
    }
  }

  Future<void> _handleAudio() async {
    Navigator.pop(context);
    final attachment = await _audioPicker.pickAudioFile();
    if (attachment != null && mounted) {
      Navigator.pop(context, attachment);
    }
  }


  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? Theme.of(context).primaryColor;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (widget.title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            // Options grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                if (widget.showCamera)
                  _AttachmentOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    iconColor: iconColor,
                    onTap: _handleCamera,
                  ),
                if (widget.showGallery)
                  _AttachmentOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    iconColor: iconColor,
                    onTap: _handleGallery,
                  ),
                if (widget.showDocuments)
                  _AttachmentOption(
                    icon: Icons.insert_drive_file,
                    label: 'Documents',
                    iconColor: iconColor,
                    onTap: _handleDocuments,
                  ),
                if (widget.showAudio)
                  _AttachmentOption(
                    icon: Icons.music_note,
                    label: 'Sound',
                    iconColor: iconColor,
                    onTap: _handleAudio,
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

