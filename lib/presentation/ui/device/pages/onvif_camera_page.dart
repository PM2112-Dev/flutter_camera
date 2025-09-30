import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _cameraName = widget.cameraName;
    _cameraType = widget.cameraType;
    _cameraId = widget.cameraId;
    _cameraUniqueId = widget.cameraUniqueId;
    print('cameraType: $_cameraType');
  }

  @override
  void dispose() {
    // ExoPlayer widget handles its own disposal
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
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: const BoxDecoration(gradient: AppGradients.primary),
            child: AppBar(
              title: Text(_cameraName),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: AppColors.textOnPrimary,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Video Player (no rounded corners, 8px spacing from top)
                const SizedBox(height: 8),
                RepaintBoundary(
                  key: _videoPlayerKey,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: 200,
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    color: Colors.black,
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
                          return HlsCameraStreamWidget(streamId: streamId, width: double.infinity);
                        } else {
                          return _buildVideoPlaceholder();
                        }
                      },
                    ),
                  ),
                ),

                // Control Panel
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Capture Button (tapping the whole button triggers capture)
                      // Row(children: [_buildCaptureButton()]),
                      const SizedBox(height: 24),
                      // PTZ controls shown only when ptzType == 'Ptz'
                      if (widget.ptzType.toLowerCase() == 'ptz') ...[
                        _buildPTZControl(),
                        const SizedBox(height: 16),
                        _buildSpeedControl(),
                        const SizedBox(height: 24),
                      ],

                      // Speed control: hide when cameraType == 'Fix'
                      if (widget.cameraType.toLowerCase() != 'fix') ...[],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Điều khiển Tốc độ',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              // Text(
              //   _currentSpeed.description,
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: Colors.blue[700],
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('0', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              Expanded(
                child: Slider(
                  value: _speedValue,
                  min: 0.0,
                  max: 63.0,
                  divisions: 63,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _speedValue = value;
                    });
                  },
                ),
              ),
              Text('63', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          // Center(
          //   child: Text(
          //     'Speed: ${_speedValue.round()}',
          //     style: TextStyle(
          //       fontSize: 14,
          //       color: Colors.blue[700],
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildPTZControl() {
    // return Container(
    //   padding: const EdgeInsets.all(16),
    //   decoration: BoxDecoration(
    //     color: AppColors.surface,
    //     borderRadius: BorderRadius.circular(AppBorderRadius.medium),
    //     border: Border.all(color: AppColors.border),
    //     boxShadow: AppShadows.cardShadow,
    //   ),
    //   child: Column(
    //     children: [
    //       Text(
    //         'Điều khiển Camera',
    //         style: AppTextStyles.bodyLarge.copyWith(
    //           fontWeight: FontWeight.bold,
    //           color: AppColors.textPrimary,
    //         ),
    //       ),
    //       const SizedBox(height: 16),
    //       SizedBox(
    //         width: size,
    //         height: size,
    //         child: Stack(
    //           alignment: Alignment.center,
    //           children: [
    //             // Outer D-pad circle (gradient)
    //             Container(
    //               width: size,
    //               height: size,
    //               decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.primary),
    //             ),
    //             // Up
    //             Positioned(
    //               top: 8,
    //               child: _dpadTouchArea(
    //                 onTap: () => _sendPTZCommand(CameraControlCommand.up),
    //                 size: btnSize,
    //               ),
    //             ),
    //             // Down
    //             Positioned(
    //               bottom: 8,
    //               child: _dpadTouchArea(
    //                 onTap: () => _sendPTZCommand(CameraControlCommand.down),
    //                 size: btnSize,
    //               ),
    //             ),
    //             // Left
    //             Positioned(
    //               left: 8,
    //               child: _dpadTouchArea(
    //                 onTap: () => _sendPTZCommand(CameraControlCommand.left),
    //                 size: btnSize,
    //               ),
    //             ),
    //             // Right
    //             Positioned(
    //               right: 8,
    //               child: _dpadTouchArea(
    //                 onTap: () => _sendPTZCommand(CameraControlCommand.right),
    //                 size: btnSize,
    //               ),
    //             ),
    //             // Up-Left
    //             Positioned(
    //               top: 28,
    //               left: 28,
    //               child: _dpadTouchArea(
    //                 onTap: () => _sendPTZCommand(CameraControlCommand.upLeft),
    //                 size: btnSize * 0.85,
    //               ),
    //             ),
    //             // Up-Right
    //             Positioned(
    //               top: 28,
    //               right: 28,
    //               child: _dpadTouchArea(
    //                 onTap: () => _sendPTZCommand(CameraControlCommand.upRight),
    //                 size: btnSize * 0.85,
    //               ),
    //             ),
    //             // Down-Left
    //             Positioned(
    //               bottom: 28,
    //               left: 28,
    //               child: _dpadTouchArea(
    //                 onTap: () => _sendPTZCommand(CameraControlCommand.downLeft),
    //                 size: btnSize * 0.85,
    //               ),
    //             ),
    //             // Down-Right
    //             Positioned(
    //               bottom: 28,
    //               right: 28,
    //               child: _dpadTouchArea(
    //                 onTap: () => _sendPTZCommand(CameraControlCommand.downRight),
    //                 size: btnSize * 0.85,
    //               ),
    //             ),
    //             // Center OK/STOP button
    //             GestureDetector(
    //               onTap: _stopPTZ,
    //               child: Container(
    //                 width: centerSize,
    //                 height: centerSize,
    //                 decoration: BoxDecoration(
    //                   color: centerColor,
    //                   shape: BoxShape.circle,
    //                   border: Border.all(color: Colors.white, width: 2),
    //                   boxShadow: [
    //                     BoxShadow(
    //                       color: Colors.white.withOpacity(0.08),
    //                       blurRadius: 8,
    //                       offset: const Offset(0, 4),
    //                     ),
    //                   ],
    //                 ),
    //                 child: Center(
    //                   child: Text(
    //                     'OK',
    //                     style: AppTextStyles.bodyLarge.copyWith(
    //                       color: centerTextColor,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          Image.asset('assets/img_d_pad.png'),
          Positioned(
            top: 70,
            left: 70,
            height: 60,
            width: 60,
            child: InkWell(
              onTap: () => _captureImage(),
              child: Image.asset('assets/ic_take_screen.png', width: 60, height: 60),
            ),
          ),
          //top
          Positioned(
            top: 0,
            left: 70,
            height: 60,
            width: 60,
            child: GestureDetector(
              onTapDown: (_) => _sendPTZCommand(CameraControlCommand.up),
              onTapUp: (_) => _sendStopCommand(),
              child: Container(color: Colors.transparent),
            ),
          ),
          //bottom
          Positioned(
            bottom: 0,
            left: 70,
            height: 60,
            width: 60,
            child: GestureDetector(
              onTapDown: (_) => _sendPTZCommand(CameraControlCommand.down),
              onTapUp: (_) => _sendStopCommand(),
              child: Container(color: Colors.transparent),
            ),
          ),
          //left
          Positioned(
            top: 70,
            left: 0,
            height: 60,
            width: 60,
            child: GestureDetector(
              onTapDown: (_) => _sendPTZCommand(CameraControlCommand.left),
              onTapUp: (_) => _sendStopCommand(),
              child: Container(color: Colors.transparent),
            ),
          ),
          //right
          Positioned(
            top: 70,
            right: 0,
            height: 60,
            width: 60,
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

  // Widget _buildCaptureButton() {
  //   return GestureDetector(
  //     onTap: _captureImage,
  //     child: Container(
  //       padding: const EdgeInsets.all(8),
  //       decoration: BoxDecoration(
  //         color: AppColors.surface,
  //         borderRadius: BorderRadius.circular(AppBorderRadius.medium),
  //         border: Border.all(color: AppColors.border),
  //         boxShadow: AppShadows.cardShadow,
  //       ),
  //       child: Row(
  //         children: [
  //           Center(
  //             child: Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: AppColors.success,
  //                 shape: BoxShape.circle,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: AppColors.success.withOpacity(0.3),
  //                     blurRadius: 8,
  //                     offset: const Offset(0, 4),
  //                   ),
  //                 ],
  //               ),
  //               child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
  //             ),
  //           ),
  //           const SizedBox(width: 16),
  //           Text(
  //             'Lưu ảnh',
  //             style: AppTextStyles.bodyLarge.copyWith(
  //               fontWeight: FontWeight.bold,
  //               color: AppColors.textPrimary,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
