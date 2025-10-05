import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera/presentation/bloc/camera_control/camera_control_bloc.dart';
import 'package:flutter_camera/presentation/bloc/camera_control/camera_control_event.dart';
import 'package:flutter_camera/presentation/bloc/camera_control/camera_control_state.dart';
import 'package:flutter_camera/domain/model/camera_control_enums.dart';
import 'package:flutter_camera/presentation/ui/device/widgets/hls_camera_stream_widget.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_stream_data_provider.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_camera/data/services/ios_image_gallery_service.dart';

class OnvifCameraPage extends StatefulWidget {
  final String cameraName;
  final String ptzType;
  final String cameraType;
  final int cameraId;
  final String cameraUniqueId;

  const OnvifCameraPage({
    super.key,
    required this.cameraName,
    required this.ptzType,
    required this.cameraType,
    required this.cameraId,
    required this.cameraUniqueId,
  });

  @override
  State<OnvifCameraPage> createState() => _OnvifCameraPageState();
}

class _OnvifCameraPageState extends State<OnvifCameraPage> {
  late final String _cameraName;
  late final String _cameraType;
  late final int _cameraId;
  late final String _cameraUniqueId;
  double _speedValue = 3.0; // Default to medium speed (30 out of 63)
  final GlobalKey _videoPlayerKey = GlobalKey();
  bool _showControls = false; // State để ẩn/hiện bảng controls

  @override
  void initState() {
    super.initState();
    _cameraName = widget.cameraName;
    _cameraType = widget.cameraType;
    _cameraId = widget.cameraId;
    _cameraUniqueId = widget.cameraUniqueId;
    print('cameraType: $_cameraType');

    // Force landscape orientation khi vào màn hình
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Ẩn system UI (status bar và navigation bar) để full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore lại orientation về portrait khi thoát
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Restore lại system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    super.dispose();
  }

  void _sendPTZCommand(CameraControlCommand command) {
    final actualSpeed = _speedValue.round();
    print(
      'ONVIF UI: Sending PTZ command: ${command.description} (${command.value}) with camera ID: $_cameraId, speed: $actualSpeed',
    );

    context.read<CameraControlBloc>().add(
      SendPTZCommand(
        cameraId: _cameraId,
        command: command,
        speed: CameraControlSpeed.fromRange(actualSpeed),
      ),
    );
  }

  void _sendStopCommand() {
    print('ONVIF UI: Sending stop command for camera ID: $_cameraId');
    context.read<CameraControlBloc>().add(
      SendPTZCommand(
        cameraId: _cameraId,
        command: CameraControlCommand.stop,
        speed: CameraControlSpeed.stop,
      ),
    );
  }

  Future<void> _captureImage() async {
    try {
      // Show loading
      _showSnackBar('Đang chụp ảnh...');

      // Add a small delay to ensure widget is rendered
      await Future.delayed(const Duration(milliseconds: 500));

      if (Platform.isIOS) {
        // Use native iOS service for better performance and reliability
        await _captureImageForIOS();
      } else {
        // Use GAL for Android
        await _captureImageForAndroid();
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chụp ảnh: $e');
    }
  }

  Future<void> _captureImageForIOS() async {
    try {
      // Check permission first
      final permissionResult = await IosImageGalleryService.checkPermission();
      if (!permissionResult['isGranted']) {
        final requestResult = await IosImageGalleryService.requestPermission();
        if (!requestResult['isGranted']) {
          _showSnackBar('Cần quyền truy cập thư viện ảnh để lưu ảnh');
          return;
        }
      }

      // Try to capture the video player widget first
      final Uint8List? imageBytes = await _captureVideoScreenshotBytes();

      if (imageBytes != null) {
        // Save using native iOS service
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final fileName = 'camera_${_cameraName.replaceAll(' ', '_')}_$timestamp.png';

        final result = await IosImageGalleryService.saveImageToGallery(
          imageData: imageBytes,
          fileName: fileName,
        );

        if (result['isSuccess'] == true) {
          _showSnackBar('Đã lưu ảnh vào thư viện');
        } else {
          _showSnackBar('Không thể lưu ảnh: ${result['message']}');
        }
      } else {
        // Fallback: Create a test image
        _showSnackBar('Đang tạo ảnh test...');
        await _createTestImageForIOS();
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chụp ảnh iOS: $e');
    }
  }

  Future<void> _captureImageForAndroid() async {
    try {
      // Check if gal has permission
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
        if (!await Gal.hasAccess()) {
          _showSnackBar('Cần quyền truy cập bộ nhớ để lưu ảnh');
          return;
        }
      }

      // Try to capture the video player widget
      final String? imagePath = await _captureVideoScreenshot();

      if (imagePath != null) {
        // Save to gallery
        await Gal.putImage(imagePath);
        _showSnackBar('Đã lưu ảnh vào thư viện');
      } else {
        // Fallback: Create a test image
        _showSnackBar('Đang tạo ảnh test...');
        await _createTestImage();
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chụp ảnh Android: $e');
    }
  }

  Future<String?> _captureVideoScreenshot() async {
    try {
      // Check if key has context
      if (_videoPlayerKey.currentContext == null) {
        return null;
      }

      // Get render object
      final RenderObject? renderObject = _videoPlayerKey.currentContext!.findRenderObject();
      if (renderObject == null) {
        return null;
      }

      // Check if it's a RepaintBoundary
      if (renderObject is! RenderRepaintBoundary) {
        return null;
      }

      final RenderRepaintBoundary boundary = renderObject;

      // Check if boundary is attached
      if (!boundary.attached) {
        return null;
      }

      // Capture image
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return null;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      return await _saveImage(pngBytes);
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> _captureVideoScreenshotBytes() async {
    try {
      // Check if key has context
      if (_videoPlayerKey.currentContext == null) {
        return null;
      }

      // Get render object
      final RenderObject? renderObject = _videoPlayerKey.currentContext!.findRenderObject();
      if (renderObject == null) {
        return null;
      }

      // Check if it's a RepaintBoundary
      if (renderObject is! RenderRepaintBoundary) {
        return null;
      }

      final RenderRepaintBoundary boundary = renderObject;

      // Check if boundary is attached
      if (!boundary.attached) {
        return null;
      }

      // Capture image
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<String?> _saveImage(Uint8List imageBytes) async {
    try {
      // Check permissions
      if (!await _checkPermissions()) {
        return null;
      }

      // For Android 13+, we can save directly to app's cache directory
      // and then use GAL to save to gallery
      final Directory directory = await getTemporaryDirectory();

      // Create screenshots directory in cache
      final String screenshotsDir = '${directory.path}/Screenshots';
      final Directory screenshotsDirectory = Directory(screenshotsDir);
      if (!await screenshotsDirectory.exists()) {
        await screenshotsDirectory.create(recursive: true);
      }

      // Generate filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename = 'camera_${_cameraName.replaceAll(' ', '_')}_$timestamp.png';
      final String filePath = '$screenshotsDir/$filename';

      // Write file
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _checkPermissions() async {
    try {
      // For Android 13+ (API 33+), we don't need storage permission
      // We only need GAL permission
      if (Platform.isAndroid) {
        final bool hasGalAccess = await Gal.hasAccess();
        if (!hasGalAccess) {
          await Gal.requestAccess();
          final bool finalGalAccess = await Gal.hasAccess();
          if (!finalGalAccess) {
            return false;
          }
        }
        return true;
      } else {
        // For iOS, check photos permission
        final PermissionStatus photosStatus = await Permission.photos.status;
        if (!photosStatus.isGranted) {
          final PermissionStatus result = await Permission.photos.request();
          if (!result.isGranted) {
            return false;
          }
        }
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> _createTestImage() async {
    try {
      // Create a simple test image with camera info
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String? testImagePath = await _createTestImageFile(timestamp);

      if (testImagePath != null) {
        await Gal.putImage(testImagePath);
        _showSnackBar('Đã lưu ảnh test vào thư viện');
      } else {
        _showSnackBar('Không thể tạo ảnh test');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi tạo ảnh test: $e');
    }
  }

  Future<void> _createTestImageForIOS() async {
    try {
      // Create a test image with camera info
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final Uint8List? imageBytes = await _createTestImageBytes(timestamp);

      if (imageBytes != null) {
        final fileName = 'camera_test_${_cameraName.replaceAll(' ', '_')}_$timestamp.png';

        final result = await IosImageGalleryService.saveImageToGallery(
          imageData: imageBytes,
          fileName: fileName,
        );

        if (result['isSuccess'] == true) {
          _showSnackBar('Đã lưu ảnh test vào thư viện');
        } else {
          _showSnackBar('Không thể lưu ảnh test: ${result['message']}');
        }
      } else {
        _showSnackBar('Không thể tạo ảnh test');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi tạo ảnh test iOS: $e');
    }
  }

  Future<String?> _createTestImageFile(String timestamp) async {
    try {
      // Check permissions
      if (!await _checkPermissions()) {
        return null;
      }

      // Get directory for saving
      final Directory directory = await getTemporaryDirectory();

      // Create screenshots directory
      final String screenshotsDir = '${directory.path}/Screenshots';
      final Directory screenshotsDirectory = Directory(screenshotsDir);
      if (!await screenshotsDirectory.exists()) {
        await screenshotsDirectory.create(recursive: true);
      }

      // Generate filename with timestamp
      final String filename = 'camera_test_${_cameraName.replaceAll(' ', '_')}_$timestamp.png';
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
          text: 'Camera: $_cameraName\nTime: ${DateTime.now().toString()}',
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
        return null;
      }

      // Write file
      final File file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      return filePath;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> _createTestImageBytes(String timestamp) async {
    try {
      // Create a simple test image (800x600 pixels for better quality)
      final int width = 800;
      final int height = 600;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Fill background with dark theme
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = const Color(0xFF1a1a1a),
      );

      // Add a border
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Draw camera icon (simple representation)
      final Paint iconPaint = Paint()..color = const Color(0xFF4CAF50);
      canvas.drawCircle(Offset(width * 0.5, height * 0.3), 40, iconPaint);

      // Draw camera lens
      canvas.drawCircle(
        Offset(width * 0.5, height * 0.3),
        20,
        Paint()..color = const Color(0xFF2E2E2E),
      );

      // Draw camera info text
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '📹 $_cameraName\n',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            TextSpan(
              text: '🕒 ${DateTime.now().toString().split('.')[0]}\n',
              style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 18, height: 1.4),
            ),
            TextSpan(
              text: '📍 Camera ID: $_cameraId\n',
              style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 16, height: 1.4),
            ),
            TextSpan(
              text: '🎯 Type: $_cameraType\n',
              style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 16, height: 1.4),
            ),
            TextSpan(
              text: '⚡ PTZ: ${widget.ptzType}\n',
              style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 16, height: 1.4),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: width * 0.8);
      textPainter.paint(canvas, Offset((width - textPainter.width) / 2, height * 0.45));

      // Draw footer
      final TextPainter footerPainter = TextPainter(
        text: const TextSpan(
          text: 'Flutter Camera App',
          style: TextStyle(color: Color(0xFF666666), fontSize: 14, fontStyle: FontStyle.italic),
        ),
        textDirection: TextDirection.ltr,
      );
      footerPainter.layout();
      footerPainter.paint(canvas, Offset((width - footerPainter.width) / 2, height - 40));

      // Convert to image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(width, height);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.small)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CameraControlBloc>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.only(top: 16.0),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, spreadRadius: 1),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        body: BlocListener<CameraControlBloc, CameraControlState>(
          listener: (context, state) {
            if (state is CameraControlError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            } else if (state is CameraControlSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message ?? 'Command executed'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          child: Stack(
            children: [
              // Video player
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: Center(
                  child: RepaintBoundary(
                    key: _videoPlayerKey,
                    child: Consumer<CameraStreamDataProvider>(
                      builder: (context, streamDataProvider, child) {
                        final streamData = streamDataProvider.getStreamData(_cameraUniqueId);
                        final streamId = streamData?.streamId;
                        final isLoading = streamData?.isLoading ?? false;
                        final hasError = streamData?.error != null;

                        if (isLoading) {
                          return _buildLoadingPlaceholder();
                        } else if (hasError) {
                          return _buildErrorPlaceholder(streamData!.error!);
                        } else if (streamId != null) {
                          // Không truyền width để video tự fit theo aspect ratio
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width,
                              maxHeight: MediaQuery.of(context).size.height,
                            ),
                            child: HlsCameraStreamWidget(streamId: streamId),
                          );
                        } else {
                          return _buildVideoPlaceholder();
                        }
                      },
                    ),
                  ),
                ),
              ),

              // PTZ Control Panel (góc dưới bên trái)
              if (_showControls && widget.ptzType.toLowerCase() == 'ptz')
                Positioned(bottom: 80, left: 80, child: _buildPTZControl()),

              // Speed Control Panel (góc dưới bên phải) - dịch xuống để tránh camera icon
              if (_showControls && widget.ptzType.toLowerCase() == 'ptz')
                Positioned(bottom: 80, right: 80, child: _buildSpeedControl()),

              // Bottom toolbar
              _buildBottomToolbar(),
            ],
          ),
          // Đã ẩn tạm thời phần điều khiển PTZ và chụp ảnh
          // child: SingleChildScrollView(
          //   child: Column(
          //     children: [
          //       // Video Player
          //       RepaintBoundary(...),
          //       // Control Panel
          //       Container(
          //         padding: const EdgeInsets.all(16),
          //         child: Column(
          //           children: [
          //             if (widget.ptzType.toLowerCase() == 'ptz') ...[
          //               _buildPTZControl(),
          //               _buildSpeedControl(),
          //             ],
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Controls (ẩn/hiện bảng điều khiển) - chỉ hiển thị nếu là PTZ camera
            if (widget.ptzType.toLowerCase() == 'ptz')
              _buildToolbarButton(
                icon: _showControls
                    ? Icon(Icons.control_camera, color: Colors.blue)
                    : Icon(Icons.control_camera, color: Colors.white),
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                },
              ),

            // Icon Camera (chụp ảnh)
            _buildToolbarButton(
              icon: Icon(Icons.camera_alt, color: Colors.white),
              onTap: _captureImage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({required Icon icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [icon], // icon đã là Icon widget rồi, không cần wrap lại
        ),
      ),
    );
  }

  Widget _buildSpeedControl() {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon tốc độ
          const Icon(Icons.speed, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          // Giá trị tốc độ hiện tại
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${_speedValue.round()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Min/Max labels (trên cùng - Max)
          Text(
            'Max',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text('63', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9)),
          const SizedBox(height: 4),
          // Slider dọc - giảm chiều cao
          SizedBox(
            height: 140,
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  thumbColor: Colors.white,
                  overlayColor: AppColors.primary.withOpacity(0.3),
                ),
                child: Slider(
                  value: _speedValue, // Giá trị thực: kéo lên = tăng, kéo xuống = giảm
                  min: 0.0,
                  max: 63.0,
                  divisions: 63,
                  onChanged: (value) {
                    setState(() {
                      _speedValue = value; // Lưu giá trị trực tiếp
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Min/Max labels (dưới cùng - Min)
          Text(
            'Min',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text('0', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildPTZControl() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        children: [
          Image.asset('assets/img_d_pad.png'),
          Positioned(
            top: 0,
            left: 55,
            height: 50,
            width: 50,
            child: GestureDetector(
              onTapDown: (_) => _sendPTZCommand(CameraControlCommand.up),
              onTapUp: (_) => _sendStopCommand(),
              child: Container(color: Colors.transparent),
            ),
          ),
          //bottom
          Positioned(
            bottom: 0,
            left: 55,
            height: 50,
            width: 50,
            child: GestureDetector(
              onTapDown: (_) => _sendPTZCommand(CameraControlCommand.down),
              onTapUp: (_) => _sendStopCommand(),
              child: Container(color: Colors.transparent),
            ),
          ),
          //left
          Positioned(
            top: 55,
            left: 0,
            height: 50,
            width: 50,
            child: GestureDetector(
              onTapDown: (_) => _sendPTZCommand(CameraControlCommand.left),
              onTapUp: (_) => _sendStopCommand(),
              child: Container(color: Colors.transparent),
            ),
          ),
          //right
          Positioned(
            top: 55,
            right: 0,
            height: 50,
            width: 50,
            child: GestureDetector(
              onTapDown: (_) => _sendPTZCommand(CameraControlCommand.right),
              onTapUp: (_) => _sendStopCommand(),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Đang tải stream...',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(String error) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Lỗi: $error',
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Note: refreshStreamData needs Camera object, not just uniqueId
              // This would need to be implemented differently or pass Camera object
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng thử lại đang được phát triển')),
              );
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, color: Colors.white.withOpacity(0.7), size: 48),
          const SizedBox(height: 8),
          Text(
            'Không có stream',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
