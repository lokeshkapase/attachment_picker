import 'package:flutter/services.dart';


class AttachmentPickerPlatform {
  static const MethodChannel _channel = MethodChannel('flutter_unified_attachment_picker');


  static Future<Map<String, dynamic>?> pickAudioFile() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('pickAudioFile');
      return result?.cast<String, dynamic>();
    } on PlatformException {
      return null;
    }
  }


  static Future<Map<String, dynamic>?> pickCameraImage() async {
    try {
      print("camera");
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('pickCameraImage');
      print("result is $result");
      return result?.cast<String, dynamic>();
    } on PlatformException {
      print("1camera");

      return null;
    } catch (e) {
      print("2camera");

      return null;
    }
  }

  /// Pick image from gallery
  static Future<Map<String, dynamic>?> pickGalleryImage() async {
    try {
      print('AttachmentPickerPlatform: Calling pickGalleryImage');
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('pickGalleryImage');
      print('AttachmentPickerPlatform: Received result: $result');
      final castResult = result?.cast<String, dynamic>();
      print('AttachmentPickerPlatform: Cast result: $castResult');
      return castResult;
    } on PlatformException catch (e) {
      print('AttachmentPickerPlatform: PlatformException in pickGalleryImage: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('AttachmentPickerPlatform: Exception in pickGalleryImage: $e');
      return null;
    }
  }

  /// Pick document file
  static Future<Map<String, dynamic>?> pickDocument({
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'pickDocument',
        {'allowedExtensions': allowedExtensions},
      );
      return result?.cast<String, dynamic>();
    } on PlatformException catch (e) {
      throw Exception('Failed to pick document: ${e.message}');
    }
  }

  /// Start audio recording
  static Future<String?> startAudioRecording() async {
    try {
      final result = await _channel.invokeMethod<String>('startAudioRecording');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to start audio recording: ${e.message}');
    }
  }

  /// Stop audio recording
  static Future<Map<String, dynamic>?> stopAudioRecording() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('stopAudioRecording');
      return result?.cast<String, dynamic>();
    } on PlatformException catch (e) {
      throw Exception('Failed to stop audio recording: ${e.message}');
    }
  }

  /// Check if currently recording
  static Future<bool> isRecording() async {
    try {
      final result = await _channel.invokeMethod<bool>('isRecording');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Request permission
  static Future<bool> requestPermission(String permission) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'requestPermission',
        {'permission': permission},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}

