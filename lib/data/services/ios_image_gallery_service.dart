import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class IosImageGalleryService {
  static const MethodChannel _channel = MethodChannel('image_gallery_saver');

  /// Save image to iOS photo library
  static Future<Map<String, dynamic>> saveImageToGallery({
    required Uint8List imageData,
    required String fileName,
  }) async {
    if (!Platform.isIOS) {
      throw UnsupportedError('This service is only supported on iOS');
    }

    try {
      final result = await _channel.invokeMethod('saveImageToGallery', {
        'imageData': imageData,
        'fileName': fileName,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to save image: ${e.message}');
    }
  }

  /// Check photo library permission status
  static Future<Map<String, dynamic>> checkPermission() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('This service is only supported on iOS');
    }

    try {
      final result = await _channel.invokeMethod('checkPermission');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to check permission: ${e.message}');
    }
  }

  /// Request photo library permission
  static Future<Map<String, dynamic>> requestPermission() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('This service is only supported on iOS');
    }

    try {
      final result = await _channel.invokeMethod('requestPermission');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to request permission: ${e.message}');
    }
  }
}
