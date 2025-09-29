import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/presentation/ui/device/pages/onvif_camera_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/domain/model/area_tree.dart';
import 'package:flutter_camera/domain/model/camera.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_bloc.dart';
import 'package:flutter_camera/presentation/bloc/camera_control/camera_control_bloc.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_event.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_state.dart';
import 'package:flutter_camera/presentation/ui/device/widgets/camera_stream_card.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_selection_provider.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_stream_data_provider.dart';

class DevicePage extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallback;

  const DevicePage({super.key, this.onRefreshCallback});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Register refresh callback with parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRefreshCallback?.call(refreshSelectedCameras);
    });
  }

  // Public method để external components có thể trigger refresh
  void refreshSelectedCameras() {
    debugPrint('DevicePage: refreshSelectedCameras called');
    if (mounted) {
      final selectionProvider = context.read<CameraSelectionProvider>();
      selectionProvider.refreshFromPreference();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      context.read<DeviceBloc>().add(const DeviceStartedEvent());
      _hasInitialized = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _processAreaData(List<AreaTreeWithCameras> areaTrees) {
    // Extract all cameras from all areas recursively
    final allCameras = <Camera>[];

    void extractCamerasRecursively(List<AreaTreeWithCameras> areas) {
      for (final area in areas) {
        allCameras.addAll(area.cameras);
        // Recursively extract from children
        extractCamerasRecursively(area.children);
      }
    }

    extractCamerasRecursively(areaTrees);

    // Set all cameras to selection provider
    if (mounted) {
      final selectionProvider = context.read<CameraSelectionProvider>();
      final streamDataProvider = context.read<CameraStreamDataProvider>();

      selectionProvider.setAllCameras(allCameras);

      // Request stream data for selected cameras
      for (final camera in selectionProvider.selectedCameras) {
        streamDataProvider.requestStreamData(camera);
      }
    }
  }

  @override
  void didUpdateWidget(DevicePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload selected cameras when widget updates
    debugPrint('DevicePage: didUpdateWidget called, refreshing cameras...');
    refreshSelectedCameras();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DeviceBloc>()..add(const DeviceStartedEvent()),
      child: Scaffold(
        body: BlocConsumer<DeviceBloc, DeviceState>(
          listener: (context, state) {
            if (state is DeviceStartedState) {
              _processAreaData(state.areaTrees);
            }
          },
          builder: (context, state) {
            if (state is DeviceLoadingState) {
              return AppWidgets.buildLoadingIndicator(message: 'Loading cameras...');
            }

            if (state is DeviceErrorState) {
              return AppWidgets.buildEmptyState(
                icon: Icons.error_outline,
                title: 'Error loading cameras',
                subtitle: state.message,
                action: ElevatedButton(
                  onPressed: () {
                    context.read<DeviceBloc>().add(const DeviceStartedEvent());
                  },
                  child: const Text('Retry'),
                ),
              );
            }

            return _buildMainContent();
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return _buildAllCamerasView();
  }

  Widget _buildAllCamerasView() {
    return Consumer2<CameraSelectionProvider, CameraStreamDataProvider>(
      builder: (context, selectionProvider, streamDataProvider, child) {
        final camerasToShow = selectionProvider.selectedCameras;

        debugPrint('DevicePage: Building with ${camerasToShow.length} selected cameras');

        // Update selected cameras in provider
        streamDataProvider.updateSelectedCameras(camerasToShow);

        // Request stream data for cameras that don't have it yet
        for (final camera in camerasToShow) {
          final streamData = streamDataProvider.getStreamData(camera.uniqueId);
          if (streamData == null ||
              (!streamData.isLoading && streamData.streamId == null && streamData.error == null)) {
            debugPrint('DevicePage: Requesting stream data for new camera: ${camera.name}');
            streamDataProvider.requestStreamData(camera);
          }
        }

        if (camerasToShow.isEmpty) {
          return AppWidgets.buildEmptyState(
            icon: Icons.videocam_off,
            title: 'Chưa chọn camera nào',
            subtitle: 'Nhấn nút + để chọn camera hiển thị',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh stream data for all selected cameras
            streamDataProvider.refreshAllStreamData(camerasToShow);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            itemCount: camerasToShow.length,
            itemBuilder: (context, index) {
              final camera = camerasToShow[index];

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Consumer<CameraStreamDataProvider>(
                  builder: (context, streamDataProvider, child) {
                    final streamData = streamDataProvider.getStreamData(camera.uniqueId);
                    final streamId = streamData?.streamId;

                    debugPrint('DevicePage: Camera ${camera.name} (${camera.uniqueId})');
                    debugPrint('DevicePage: streamData: $streamData');
                    debugPrint('DevicePage: streamId: $streamId');
                    debugPrint('DevicePage: isLoading: ${streamData?.isLoading}');
                    debugPrint('DevicePage: error: ${streamData?.error}');

                    return CameraStreamCard(
                      camera: camera,
                      showStream: true,
                      isPinned: false,
                      streamId: streamId,
                      isLoadingStreamId: streamData?.isLoading ?? false,
                      onTap: () => _showCameraDetail(camera),
                      onPinToggle: () => _removeSelectedCamera(camera),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _removeSelectedCamera(Camera camera) async {
    final selectionProvider = context.read<CameraSelectionProvider>();
    final streamDataProvider = context.read<CameraStreamDataProvider>();

    await selectionProvider.removeCamera(camera.uniqueId);
    streamDataProvider.clearStreamData(camera.uniqueId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa ${camera.name} khỏi danh sách'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _showCameraDetail(Camera camera) {
    final streamDataProvider = context.read<CameraStreamDataProvider>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: streamDataProvider,
          child: BlocProvider(
            create: (context) => getIt<CameraControlBloc>(),
            child: OnvifCameraPage(
              cameraName: camera.name,
              ptzType: camera.ptzType,
              cameraType: camera.cameraType,
              cameraId: camera.id,
              cameraUniqueId: camera.uniqueId,
            ),
          ),
        ),
      ),
    );
  }
}
