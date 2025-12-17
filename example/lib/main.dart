import 'package:flutter/material.dart';
import 'package:flutter_unified_attachment_picker/flutter_unified_attachment_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unified Attachment Picker Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Attachment? _selectedAttachment;

  Future<void> _showAttachmentPicker() async {
    final attachment = await UnifiedAttachmentPicker.show(
      context: context,
      title: 'Choose Attachment',
      showCamera: true,
      showGallery: true,
      showDocuments: true,
      showAudio: true,
    );

    if (attachment != null) {
      // Log the selected file path and details to the console for quick verification.
      debugPrint('=== Attachment Selected ===');
      debugPrint('File Path: ${attachment.filePath}');
      debugPrint('File Name: ${attachment.fileName}');
      debugPrint('File Size: ${attachment.fileSize} bytes');
      debugPrint('MIME Type: ${attachment.mimeType}');
      debugPrint('Attachment Type: ${attachment.type.name}');
      debugPrint('===========================');
      setState(() {
        _selectedAttachment = attachment;
      });
    } else {
      debugPrint('No attachment selected (user cancelled)');
    }
  }

  Widget _buildAttachmentPreview() {
    if (_selectedAttachment == null) {
      return const Center(
        child: Text(
          'No attachment selected',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachment Type: ${_selectedAttachment!.type.name}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedAttachment!.filePath != null)
          Text('File Path: ${_selectedAttachment!.filePath}'),
        if (_selectedAttachment!.fileName != null)
          Text('File Name: ${_selectedAttachment!.fileName}'),
        if (_selectedAttachment!.fileSize != null)
          Text(
            'File Size: ${(_selectedAttachment!.fileSize! / 1024).toStringAsFixed(2)} KB',
          ),
        if (_selectedAttachment!.mimeType != null)
          Text('MIME Type: ${_selectedAttachment!.mimeType}'),
        if (_selectedAttachment!.duration != null)
          Text('Duration: ${_selectedAttachment!.duration} seconds'),
        const SizedBox(height: 16),
        // Preview based on type
        if (_selectedAttachment!.isImage)
          _buildImagePreview()
        else if (_selectedAttachment!.isDocument)
          _buildDocumentPreview()
        else if (_selectedAttachment!.isAudio)
          _buildAudioPreview(),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_selectedAttachment!.filePath == null) {
      return const Text('No image path available');
    }

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_selectedAttachment!.filePath!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedAttachment!.fileName ?? 'Document',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedAttachment!.mimeType != null)
                  Text(
                    _selectedAttachment!.mimeType!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.audiotrack, size: 48, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedAttachment!.fileName ?? 'Audio Recording',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedAttachment!.duration != null)
                  Text(
                    'Duration: ${_selectedAttachment!.duration} seconds',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // Play audio - implement with audio player package
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audio playback not implemented in example'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Attachment Picker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _showAttachmentPicker,
              icon: const Icon(Icons.add_circle),
              label: const Text('Pick Attachment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            _buildAttachmentPreview(),
          ],
        ),
      ),
    );
  }
}

