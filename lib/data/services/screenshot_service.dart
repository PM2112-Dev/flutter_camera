import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';

@injectable
class ScreenshotService {
  /// Take screenshot of a widget
  Future<String?> captureWidget(GlobalKey key) async {
    try {
      print('ScreenshotService: Attempting to capture widget...');

      // Check if key has context
      if (key.currentContext == null) {
        print('ScreenshotService: GlobalKey has no context');
        return null;
      }

      // Get render object
      final RenderObject? renderObject = key.currentContext!.findRenderObject();
      if (renderObject == null) {
        print('ScreenshotService: No render object found');
        return null;
      }

      print('ScreenshotService: Render object type: ${renderObject.runtimeType}');

      // Check if it's a RepaintBoundary
      if (renderObject is! RenderRepaintBoundary) {
        print('ScreenshotService: Render object is not a RepaintBoundary');
        return null;
      }

      final RenderRepaintBoundary boundary = renderObject;

      // Check if boundary is attached
      if (!boundary.attached) {
        print('ScreenshotService: RepaintBoundary is not attached');
        return null;
      }

      print('ScreenshotService: Capturing image...');
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      print('ScreenshotService: Image captured, size: ${image.width}x${image.height}');

      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print('ScreenshotService: Failed to convert image to bytes');
        return null;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      print('ScreenshotService: Image bytes length: ${pngBytes.length}');

      return await _saveImage(pngBytes);
    } catch (e, stackTrace) {
      print('ScreenshotService: Error capturing widget: $e');
      print('ScreenshotService: Stack trace: $stackTrace');
      return null;
    }
  }

  /// Take screenshot of video player (if supported)
  Future<String?> captureVideoPlayer(dynamic controller) async {
    try {
      // For video_player, we can't directly capture frames
      // This is a limitation of the video_player package
      // We'll need to use a different approach or package
      print('ScreenshotService: Direct video frame capture not supported by video_player');
      return null;
    } catch (e) {
      print('ScreenshotService: Error capturing video: $e');
      return null;
    }
  }

  /// Save image to device storage
  Future<String?> _saveImage(Uint8List imageBytes) async {
    try {
      // Check and request permissions
      if (!await _checkPermissions()) {
        return null;
      }

      // Get directory for saving
      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('ScreenshotService: Could not get external storage directory');
        return null;
      }

      // Create screenshots directory
      final String screenshotsDir = '${directory.path}/Screenshots';
      final Directory screenshotsDirectory = Directory(screenshotsDir);
      if (!await screenshotsDirectory.exists()) {
        await screenshotsDirectory.create(recursive: true);
      }

      // Generate filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename = 'camera_screenshot_$timestamp.png';
      final String filePath = '$screenshotsDir/$filename';

      // Write file
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      print('ScreenshotService: Image saved to: $filePath');
      return filePath;
    } catch (e) {
      print('ScreenshotService: Error saving image: $e');
      return null;
    }
  }

  /// Check and request necessary permissions
  Future<bool> _checkPermissions() async {
    try {
      // Check storage permission
      final PermissionStatus storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        final PermissionStatus result = await Permission.storage.request();
        if (!result.isGranted) {
          print('ScreenshotService: Storage permission denied');
          return false;
        }
      }

      // Check GAL permission for Android 13+
      if (Platform.isAndroid) {
        final bool hasGalAccess = await Gal.hasAccess();
        if (!hasGalAccess) {
          await Gal.requestAccess();
          if (!await Gal.hasAccess()) {
            print('ScreenshotService: GAL access denied');
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      print('ScreenshotService: Error checking permissions: $e');
      return false;
    }
  }

  /// Save image to gallery using GAL
  Future<bool> saveToGallery(String imagePath) async {
    try {
      await Gal.putImage(imagePath);
      print('ScreenshotService: Image saved to gallery');
      return true;
    } catch (e) {
      print('ScreenshotService: Error saving to gallery: $e');
      return false;
    }
  }

  /// Create a test image with camera info
  Future<String?> _createTestImage({required String cameraName, required String timestamp}) async {
    try {
      print('ScreenshotService: Creating test image...');

      // Check and request permissions
      if (!await _checkPermissions()) {
        return null;
      }

      // Get directory for saving
      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('ScreenshotService: Could not get external storage directory');
        return null;
      }

      // Create screenshots directory
      final String screenshotsDir = '${directory.path}/Screenshots';
      final Directory screenshotsDirectory = Directory(screenshotsDir);
      if (!await screenshotsDirectory.exists()) {
        await screenshotsDirectory.create(recursive: true);
      }

      // Generate filename with timestamp
      final String filename = 'camera_test_${cameraName.replaceAll(' ', '_')}_$timestamp.png';
      final String filePath = '$screenshotsDir/$filename';

      // Create a simple test image (400x300 pixels)
      final int width = 400;
      final int height = 300;
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Fill background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = Colors.black,
      );

      // Draw camera name
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: 'Camera: $cameraName\nTime: ${DateTime.now().toString()}',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((width - textPainter.width) / 2, (height - textPainter.height) / 2),
      );

      // Convert to image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(width, height);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print('ScreenshotService: Failed to convert test image to bytes');
        return null;
      }

      // Write file
      final File file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      print('ScreenshotService: Test image saved to: $filePath');
      return filePath;
    } catch (e) {
      print('ScreenshotService: Error creating test image: $e');
      return null;
    }
  }
}
