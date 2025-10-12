import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/presentation/bloc/area_map/area_map_bloc.dart';
import 'package:flutter_camera/presentation/bloc/area_map/area_map_event.dart';
import 'package:flutter_camera/presentation/bloc/area_map/area_map_state.dart';
import 'package:flutter_camera/presentation/bloc/area_devices/area_devices_bloc.dart';
import 'package:flutter_camera/presentation/bloc/area_devices/area_devices_event.dart';
import 'package:flutter_camera/presentation/bloc/area_devices/area_devices_state.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/domain/model/area_map.dart';
import 'package:flutter_camera/domain/model/area_devices.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';

class UtilitiesPage extends StatefulWidget {
  final AreaMapItem? selectedArea;
  final VoidCallback onClearSelection;

  const UtilitiesPage({super.key, this.selectedArea, required this.onClearSelection});

  @override
  State<UtilitiesPage> createState() => _UtilitiesPageState();
}

class _UtilitiesPageState extends State<UtilitiesPage> {
  AreaMapItem? _localSelectedArea;

  @override
  void initState() {
    super.initState();
    _localSelectedArea = widget.selectedArea;
  }

  @override
  void didUpdateWidget(UtilitiesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedArea != oldWidget.selectedArea) {
      setState(() {
        _localSelectedArea = widget.selectedArea;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localSelectedArea == null) {
      return BlocProvider(
        create: (context) => getIt<AreaMapBloc>()..add(const FetchAreaMapData()),
        child: _DiagramListView(
          onAreaSelected: (area) {
            setState(() {
              _localSelectedArea = area;
            });
          },
        ),
      );
    } else {
      return BlocProvider<AreaDevicesBloc>(
        create: (context) =>
            getIt<AreaDevicesBloc>()..add(FetchAreaDevices(areaId: _localSelectedArea!.id)),
        child: _DiagramDetailView(
          area: _localSelectedArea!,
          onBack: () {
            setState(() {
              _localSelectedArea = null;
            });
            widget.onClearSelection();
          },
        ),
      );
    }
  }
}

// Diagram List View - Shows all diagrams
class _DiagramListView extends StatelessWidget {
  final Function(AreaMapItem) onAreaSelected;

  const _DiagramListView({required this.onAreaSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AreaMapBloc, AreaMapState>(
        builder: (context, state) {
          if (state is AreaMapLoading) {
            return AppWidgets.buildLoadingIndicator(message: 'Đang tải sơ đồ...');
          } else if (state is AreaMapError) {
            return _buildErrorView(context, state);
          } else if (state is AreaMapLoaded) {
            // Filter only Picture type (diagrams)
            final diagramAreas = state.data.areas.where((area) => area.isPicture).toList();

            if (diagramAreas.isEmpty) {
              return AppWidgets.buildEmptyState(
                icon: Icons.image_outlined,
                title: 'Không có sơ đồ',
                subtitle: 'Chưa có khu vực nào có sơ đồ 1 sợi',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AreaMapBloc>().add(const RefreshAreaMapData());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: diagramAreas.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final area = diagramAreas[index];
                  return _buildDiagramCard(context, area);
                },
              ),
            );
          }
          return AppWidgets.buildEmptyState(
            icon: Icons.account_tree,
            title: 'Sơ đồ 1 sợi',
            subtitle: 'Chưa có dữ liệu',
          );
        },
      ),
    );
  }

  Widget _buildDiagramCard(BuildContext context, AreaMapItem area) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onAreaSelected(area),
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                  ),
                  child: Icon(Icons.account_tree, color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (area.levelName != null && area.levelName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            area.levelName!,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.zoom_in, color: AppColors.secondary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, AreaMapError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Lỗi tải dữ liệu',
            style: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AreaMapBloc>().add(const FetchAreaMapData());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Diagram Detail View - Shows diagram image with zoom
class _DiagramDetailView extends StatefulWidget {
  final AreaMapItem area;
  final VoidCallback onBack;

  const _DiagramDetailView({required this.area, required this.onBack});

  @override
  State<_DiagramDetailView> createState() => _DiagramDetailViewState();
}

class _DiagramDetailViewState extends State<_DiagramDetailView> {
  final TransformationController _transformationController = TransformationController();
  final GlobalKey _imageKey = GlobalKey();
  double _rotationAngle = 0.0; // 0, 90, 180, 270 degrees
  Size? _imageSize; // Kích thước hiển thị
  Size? _originalImageSize; // Kích thước gốc của ảnh
  DeviceItem? _selectedDevice;
  // Tap to get coordinates
  double? _tapX;
  double? _tapY;

  @override
  void initState() {
    super.initState();
    print('📐 DiagramDetailView initialized');
    print('   Area: ${widget.area.name}');
    print('   PhotoPath: ${widget.area.photoPath}');
    print('   FullURL: ${widget.area.fullPhotoUrl}');
    print('   IsSVG: $_isSvg');

    // Load image dimensions để lấy kích thước gốc
    if (!_isSvg) {
      _loadImageDimensions();
    } else {
      _loadSvgDimensions();
    }

    // Listen for image size after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateImageSize();
    });
  }

  Future<void> _loadImageDimensions() async {
    try {
      final image = NetworkImage(widget.area.fullPhotoUrl);
      final stream = image.resolve(const ImageConfiguration());
      stream.addListener(
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _originalImageSize = Size(info.image.width.toDouble(), info.image.height.toDouble());
            });
            print('🖼️  Original image size: ${info.image.width} x ${info.image.height}');
          }
        }),
      );
    } catch (e) {
      print('❌ Error loading image dimensions: $e');
    }
  }

  Future<void> _loadSvgDimensions() async {
    try {
      final response = await Dio().get(widget.area.fullPhotoUrl);
      final svgContent = response.data.toString();

      // Parse viewBox="0 0 width height"
      final viewBoxPattern = RegExp(r'viewBox="([^"]+)"');
      final viewBoxMatch = viewBoxPattern.firstMatch(svgContent);

      if (viewBoxMatch != null) {
        final viewBoxValue = viewBoxMatch.group(1);
        if (viewBoxValue != null) {
          final viewBox = viewBoxValue.split(' ');
          if (viewBox.length >= 4) {
            final width = double.tryParse(viewBox[2]) ?? 1000;
            final height = double.tryParse(viewBox[3]) ?? 1000;
            if (mounted) {
              setState(() {
                _originalImageSize = Size(width, height);
              });
              print('🖼️  SVG viewBox size: $width x $height');
            }
            return;
          }
        }
      }

      // Fallback: parse width/height attributes
      final widthPattern = RegExp(r'width="(\d+\.?\d*)"');
      final heightPattern = RegExp(r'height="(\d+\.?\d*)"');
      final widthMatch = widthPattern.firstMatch(svgContent);
      final heightMatch = heightPattern.firstMatch(svgContent);

      if (widthMatch != null && heightMatch != null) {
        final width = double.tryParse(widthMatch.group(1)!) ?? 1000;
        final height = double.tryParse(heightMatch.group(1)!) ?? 1000;
        if (mounted) {
          setState(() {
            _originalImageSize = Size(width, height);
          });
          print('🖼️  SVG size from attributes: $width x $height');
        }
      }
    } catch (e) {
      print('❌ Error loading SVG dimensions: $e');
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _updateImageSize() {
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _imageSize = renderBox.size;
      });
      print('📏 Image size: ${_imageSize?.width} x ${_imageSize?.height}');
    }
  }

  bool get _isSvg {
    final url = widget.area.fullPhotoUrl.toLowerCase();
    return url.endsWith('.svg');
  }

  void _rotateImage() {
    setState(() {
      _rotationAngle += 90;
      if (_rotationAngle >= 360) _rotationAngle = 0;
    });
    print('🔄 Rotated to: $_rotationAngle degrees');
  }

  // _onDeviceTap - REMOVED

  @override
  Widget build(BuildContext context) {
    if (widget.area.photoPath == null || widget.area.photoPath!.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 80, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Không có sơ đồ',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.area.name,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AreaDevicesBloc, AreaDevicesState>(
        builder: (context, devicesState) {
          return Stack(
            children: [
              // Image viewer with devices overlay
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.1,
                maxScale: 10.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: Center(
                  child: Transform.rotate(
                    angle: _rotationAngle * 3.14159 / 180,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Base image
                        _isSvg ? _buildSvgImage() : _buildRasterImage(),

                        // Devices overlay
                        if (devicesState is AreaDevicesLoaded && devicesState.devices.isNotEmpty)
                          _buildDevicesOverlay(devicesState.devices),
                      ],
                    ),
                  ),
                ),
              ),

              // Loading overlay
              if (devicesState is AreaDevicesLoading)
                Positioned(
                  top: AppSpacing.md,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppBorderRadius.large),
                        boxShadow: AppShadows.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Đang tải thiết bị...',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Control buttons (floating)
              Positioned(
                bottom: AppSpacing.lg,
                right: AppSpacing.md,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.large),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Reset zoom button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _transformationController.value = Matrix4.identity();
                            });
                          },
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppBorderRadius.large),
                            topRight: Radius.circular(AppBorderRadius.large),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Icon(Icons.fit_screen, color: AppColors.secondary, size: 24),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: AppColors.border),
                      // Rotate button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _rotateImage,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Icon(Icons.rotate_right, color: AppColors.secondary, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tap coordinates display
              if (_tapX != null && _tapY != null)
                Positioned(
                  top: AppSpacing.lg,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tap: X=${_tapX!.toStringAsFixed(1)}, Y=${_tapY!.toStringAsFixed(1)} px',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDevicesOverlay(List<DeviceItem> devices) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lấy kích thước image hiển thị
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _imageKey.currentContext != null) {
            final RenderBox? renderBox = _imageKey.currentContext!.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final displayedSize = renderBox.size;
              if (_imageSize?.width != displayedSize.width ||
                  _imageSize?.height != displayedSize.height) {
                setState(() {
                  _imageSize = displayedSize;
                });
              }
            }
          }
        });

        // Nếu chưa có kích thước, return empty
        if (_imageSize == null || _imageSize!.width == 0) {
          return const SizedBox.shrink();
        }

        print('📍 Devices overlay:');
        print(
          '   Display size: ${_imageSize!.width.toStringAsFixed(1)} x ${_imageSize!.height.toStringAsFixed(1)}',
        );
        print('   Total devices: ${devices.length}');

        return Stack(
          clipBehavior: Clip.none,
          children: devices.map((device) {
            // Tọa độ từ API (pixel coordinates trên hình gốc)
            final originalX = device.longitude;
            final originalY = device.latitude;

            // Sử dụng kích thước ảnh gốc đã load
            final originalImageSize = _originalImageSize ?? const Size(1000, 1000);

            // Quy đổi từ pixel sang dp trước khi tính toán
            final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
            final originalDpWidth = originalImageSize.width / devicePixelRatio;
            final originalDpHeight = originalImageSize.height / devicePixelRatio;

            // BoxFit.contain giữ aspect ratio, nên cần tính scale ĐỒNG NHẤT
            final scaleX = _imageSize!.width / originalDpWidth;
            final scaleY = _imageSize!.height / originalDpHeight;
            final scale = scaleX < scaleY ? scaleX : scaleY;

            // Tính kích thước hình thực sự được hiển thị
            final actualImageWidth = originalDpWidth * scale;
            final actualImageHeight = originalDpHeight * scale;

            // Tính padding (hình được center)
            final paddingX = (_imageSize!.width - actualImageWidth) / 2;
            final paddingY = (_imageSize!.height - actualImageHeight) / 2;

            // Scale tọa độ dựa trên mode
            double scaledX, scaledY;

            // longitude = X pixel, latitude = Y pixel (trên hình gốc 4453x2888 px)
            // Tọa độ gốc (0,0) ở góc dưới cùng bên trái hình
            // Scale tọa độ theo tỷ lệ hình ảnh thực tế hiển thị
            scaledX = (originalX * scale) + paddingX;
            // Convert từ bottom-left sang top-left: Y = originalImageSize.height - originalY
            // Sau đó scale theo tỷ lệ hình
            scaledY = paddingY + ((originalImageSize.height - originalY) * scale);

            if (devices.indexOf(device) == 0) {
              // Log sample để debug
              print(
                '   Original: ${originalImageSize.width.toStringAsFixed(0)} x ${originalImageSize.height.toStringAsFixed(0)} px ${_originalImageSize == null ? "(fallback)" : "(actual)"}',
              );
              print(
                '   Display container: ${_imageSize!.width.toStringAsFixed(1)} x ${_imageSize!.height.toStringAsFixed(1)} dp',
              );
              print('   Device pixel ratio: ${devicePixelRatio.toStringAsFixed(1)}');
              print(
                '   Calculated position: X=${scaledX.toStringAsFixed(1)}, Y=${scaledY.toStringAsFixed(1)}',
              );
            }
            print(
              '   📌 ${device.name}: API(${originalX.toStringAsFixed(1)}, ${originalY.toStringAsFixed(1)}) → Screen(${scaledX.toStringAsFixed(1)}, ${scaledY.toStringAsFixed(1)}) [PX→DP+SCALE+BOTTOM-LEFT]',
            );

            return Positioned(
              left: scaledX - 16, // Center marker (32px / 2)
              top: scaledY - 16,
              child: GestureDetector(
                onTap: () => _onDeviceTap(device),
                child: _buildDeviceMarker(device),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDeviceMarker(DeviceItem device) {
    final bool isSelected = _selectedDevice?.id == device.id;
    final Color markerColor = device.hasCamera ? AppColors.info : AppColors.success;
    final IconData markerIcon = device.hasCamera ? Icons.videocam : Icons.sensors;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: isSelected ? 2 : 1.5),
          boxShadow: [
            BoxShadow(
              color: markerColor.withOpacity(0.4),
              blurRadius: isSelected ? 8 : 6,
              spreadRadius: isSelected ? 1 : 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(child: Icon(markerIcon, color: Colors.white, size: 16)),
            // Device name badge
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onImageTap(Offset localPosition) {
    if (_originalImageSize == null) return;

    // Convert tap position to original image coordinates
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final originalDpWidth = _originalImageSize!.width / devicePixelRatio;
    final originalDpHeight = _originalImageSize!.height / devicePixelRatio;

    // Calculate scale factor
    final scaleX = _imageSize!.width / originalDpWidth;
    final scaleY = _imageSize!.height / originalDpHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate actual image size and padding
    final actualImageWidth = originalDpWidth * scale;
    final actualImageHeight = originalDpHeight * scale;
    final paddingX = (_imageSize!.width - actualImageWidth) / 2;
    final paddingY = (_imageSize!.height - actualImageHeight) / 2;

    // Convert tap position to original image coordinates
    final tapX = (localPosition.dx - paddingX) / scale;
    final tapY = (localPosition.dy - paddingY) / scale;

    // Convert to original pixel coordinates
    final originalPixelX = tapX * devicePixelRatio;
    final originalPixelY = tapY * devicePixelRatio;

    setState(() {
      _tapX = originalPixelX;
      _tapY = originalPixelY;
    });

    print(
      '🎯 Tap at: ${localPosition.dx.toStringAsFixed(1)}, ${localPosition.dy.toStringAsFixed(1)}',
    );
    print(
      '📐 Original pixel: ${originalPixelX.toStringAsFixed(1)}, ${originalPixelY.toStringAsFixed(1)}',
    );
  }

  void _onDeviceTap(DeviceItem device) {
    setState(() {
      _selectedDevice = device;
    });

    // Show device info bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDeviceInfoSheet(device),
    );
  }

  Widget _buildDeviceInfoSheet(DeviceItem device) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: device.hasCamera
                  ? AppColors.info.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.large),
                topRight: Radius.circular(AppBorderRadius.large),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: device.hasCamera ? AppColors.info : AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    device.hasCamera ? Icons.videocam : Icons.sensors,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: AppTextStyles.headline3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        device.deviceTypeName,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildInfoRow('Mã thiết bị', device.code),
                const Divider(height: AppSpacing.lg),
                _buildInfoRow('ID', device.id.toString()),
                const Divider(height: AppSpacing.lg),
                _buildInfoRow('Machine ID', device.machineId.toString()),
                const Divider(height: AppSpacing.lg),
                _buildInfoRow('Loại', device.deviceType),
                const Divider(height: AppSpacing.lg),
                _buildInfoRow(
                  'Tọa độ',
                  '(${device.longitude.toStringAsFixed(1)}, ${device.latitude.toStringAsFixed(1)})',
                ),
                const Divider(height: AppSpacing.lg),
                _buildInfoRow('Cấp độ', device.level),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Chi tiết thiết bị ${device.name}'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Xem chi tiết'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: device.hasCamera ? AppColors.info : AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSvgImage() {
    return GestureDetector(
      onTapDown: (details) {
        _onImageTap(details.localPosition);
      },
      child: SvgPicture.network(
        key: _imageKey,
        widget.area.fullPhotoUrl,
        // Không dùng BoxFit để hình hiển thị đầy đủ kích thước gốc
        placeholderBuilder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.secondary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Đang tải sơ đồ ...',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRasterImage() {
    return Image.network(
      key: _imageKey,
      widget.area.fullPhotoUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.secondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Đang tải sơ đồ...',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: AppColors.error, size: 64),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Không thể tải sơ đồ',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  error.toString(),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
