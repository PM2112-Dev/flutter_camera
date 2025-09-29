import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/domain/model/area_tree.dart';
import 'package:flutter_camera/domain/model/camera.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_bloc.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_event.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_state.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_selection_provider.dart';

class CameraSelectionPage extends StatefulWidget {
  const CameraSelectionPage({super.key});

  @override
  State<CameraSelectionPage> createState() => _CameraSelectionPageState();
}

class _CameraSelectionPageState extends State<CameraSelectionPage> {
  List<AreaTreeWithCameras> _areaTrees = [];
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';
  final String _filterStatus = 'ALL'; // ALL, ONLINE, OFFLINE
  final Set<String> _expandedAreas = <String>{}; // Track expanded areas

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleCameraSelection(Camera camera) async {
    final selectionProvider = context.read<CameraSelectionProvider>();
    await selectionProvider.toggleCameraSelection(camera);
  }

  void _toggleAreaExpansion(String areaId) {
    setState(() {
      if (_expandedAreas.contains(areaId)) {
        _expandedAreas.remove(areaId);
      } else {
        _expandedAreas.add(areaId);
      }
    });
  }

  List<Camera> _getAllCameras() {
    List<Camera> allCameras = [];

    void extractCamerasRecursively(List<AreaTreeWithCameras> areas) {
      for (final area in areas) {
        allCameras.addAll(area.cameras);
        extractCamerasRecursively(area.children);
      }
    }

    extractCamerasRecursively(_areaTrees);
    return allCameras;
  }

  List<Camera> _getFilteredCameras() {
    final allCameras = _getAllCameras();
    if (_searchQuery.isEmpty && _filterStatus == 'ALL') {
      return [];
    }

    debugPrint('CameraSelection: Filtering with status: $_filterStatus');
    debugPrint('CameraSelection: Total cameras: ${allCameras.length}');

    // Debug camera statuses
    for (final camera in allCameras) {
      debugPrint('CameraSelection: Camera ${camera.name} has status: "${camera.deviceStatus}"');
    }

    return allCameras.where((camera) {
      // Search filter
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch =
            camera.name.toLowerCase().contains(query) ||
            camera.area.name.toLowerCase().contains(query);
      }

      // Status filter
      bool matchesStatus = true;
      if (_filterStatus != 'ALL') {
        matchesStatus = camera.deviceStatus == _filterStatus;
        debugPrint(
          'CameraSelection: Camera ${camera.name} status "${camera.deviceStatus}" matches $_filterStatus: $matchesStatus',
        );
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DeviceBloc>()..add(const DeviceStartedEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chọn Camera'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          actions: [
            Consumer<CameraSelectionProvider>(
              builder: (context, selectionProvider, child) {
                return TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Xong (${selectionProvider.selectedCount})',
                    style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<DeviceBloc, DeviceState>(
          listener: (context, state) {
            if (state is DeviceStartedState) {
              setState(() {
                _areaTrees = state.areaTrees;
              });

              // Set all cameras to selection provider
              final allCameras = <Camera>[];
              void extractCamerasRecursively(List<AreaTreeWithCameras> areas) {
                for (final area in areas) {
                  allCameras.addAll(area.cameras);
                  extractCamerasRecursively(area.children);
                }
              }

              extractCamerasRecursively(state.areaTrees);

              final selectionProvider = context.read<CameraSelectionProvider>();
              selectionProvider.setAllCameras(allCameras);
            }
          },
          builder: (context, state) {
            if (state is DeviceLoadingState) {
              return AppWidgets.buildLoadingIndicator(message: 'Đang tải camera...');
            }

            if (state is DeviceErrorState) {
              return AppWidgets.buildEmptyState(
                icon: Icons.error_outline,
                title: 'Lỗi tải camera',
                subtitle: state.message,
                action: ElevatedButton(
                  onPressed: () {
                    context.read<DeviceBloc>().add(const DeviceStartedEvent());
                  },
                  child: const Text('Thử lại'),
                ),
              );
            }

            return _buildContentWithSearch();
          },
        ),
      ),
    );
  }

  Widget _buildContentWithSearch() {
    return Column(
      children: [
        // Search and Filter bar
        // Container(
        //   padding: const EdgeInsets.all(AppSpacing.md),
        //   child: Column(
        //     children: [
        //       // Search field
        //       // TextField(
        //       //   controller: _searchController,
        //       //   onChanged: _onSearchChanged,
        //       //   decoration: InputDecoration(
        //       //     hintText: 'Tìm kiếm camera...',
        //       //     prefixIcon: const Icon(Icons.search),
        //       //     suffixIcon: _searchQuery.isNotEmpty
        //       //         ? IconButton(
        //       //             icon: const Icon(Icons.clear),
        //       //             onPressed: () {
        //       //               _searchController.clear();
        //       //               _onSearchChanged('');
        //       //             },
        //       //           )
        //       //         : null,
        //       //     border: OutlineInputBorder(
        //       //       borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        //       //     ),
        //       //   ),
        //       // ),
        //       // const SizedBox(height: AppSpacing.sm),
        //       // Filter row
        //       // Row(
        //       //   children: [
        //       //     const Icon(Icons.filter_list, size: 20),
        //       //     const SizedBox(width: AppSpacing.sm),
        //       //     const Text('Lọc theo:', style: AppTextStyles.bodyMedium),
        //       //     const SizedBox(width: AppSpacing.sm),
        //       //     Expanded(
        //       //       child: DropdownButtonFormField<String>(
        //       //         value: _filterStatus,
        //       //         decoration: InputDecoration(
        //       //           contentPadding: const EdgeInsets.symmetric(
        //       //             horizontal: AppSpacing.sm,
        //       //             vertical: 8,
        //       //           ),
        //       //           border: OutlineInputBorder(
        //       //             borderRadius: BorderRadius.circular(
        //       //               AppBorderRadius.small,
        //       //             ),
        //       //           ),
        //       //         ),
        //       //         items: const [
        //       //           DropdownMenuItem(value: 'ALL', child: Text('Tất cả')),
        //       //           DropdownMenuItem(value: 'On', child: Text('Online')),
        //       //           DropdownMenuItem(value: 'Off', child: Text('Offline')),
        //       //         ],
        //       //         onChanged: _onFilterChanged,
        //       //       ),
        //       //     ),
        //       //     const SizedBox(width: AppSpacing.sm),
        //       //     // Selected count
        //       //     Container(
        //       //       padding: const EdgeInsets.symmetric(
        //       //         horizontal: AppSpacing.sm,
        //       //         vertical: 8,
        //       //       ),
        //       //       decoration: BoxDecoration(
        //       //         color: AppColors.primary.withOpacity(0.1),
        //       //         borderRadius: BorderRadius.circular(
        //       //           AppBorderRadius.small,
        //       //         ),
        //       //         border: Border.all(
        //       //           color: AppColors.primary.withOpacity(0.3),
        //       //         ),
        //       //       ),
        //       //       child: Text(
        //       //         'Đã chọn: ${_selectedCameraIds.length}',
        //       //         style: AppTextStyles.caption.copyWith(
        //       //           color: AppColors.primary,
        //       //           fontWeight: FontWeight.w500,
        //       //         ),
        //       //       ),
        //       //     ),
        //       //   ],
        //       // ),
        //     ],
        //   ),
        // ),
        // Content area
        Expanded(
          child: (_searchQuery.isNotEmpty || _filterStatus != 'ALL')
              ? _buildFilteredCamerasList()
              : _buildAreaList(),
        ),
      ],
    );
  }

  Widget _buildFilteredCamerasList() {
    final filteredCameras = _getFilteredCameras();

    if (filteredCameras.isEmpty) {
      return AppWidgets.buildEmptyState(
        icon: Icons.search_off,
        title: 'Không tìm thấy camera',
        subtitle: 'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Kết quả tìm kiếm (${filteredCameras.length} camera)',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: filteredCameras.length,
            itemBuilder: (context, index) {
              final camera = filteredCameras[index];
              return _buildCameraItem(camera);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAreaList() {
    if (_areaTrees.isEmpty) {
      return AppWidgets.buildEmptyState(
        icon: Icons.location_off,
        title: 'Không có khu vực nào',
        subtitle: 'Không tìm thấy khu vực nào trong hệ thống',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _areaTrees.length,
      itemBuilder: (context, index) {
        final area = _areaTrees[index];
        return _buildAreaSection(area, 0);
      },
    );
  }

  Widget _buildAreaSection(AreaTreeWithCameras areaTree, int level) {
    final indentPadding = level * 16.0;
    final areaId = areaTree.id.toString();
    final isExpanded = _expandedAreas.contains(areaId);
    final hasChildren = areaTree.children.isNotEmpty || areaTree.cameras.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Area Header
        GestureDetector(
          onTap: hasChildren ? () => _toggleAreaExpansion(areaId) : null,
          child: Container(
            margin: EdgeInsets.only(
              left: indentPadding,
              bottom: AppSpacing.sm,
              top: level > 0 ? AppSpacing.sm : 0,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: level == 0
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              border: Border.all(
                color: level == 0
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.secondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  level == 0 ? Icons.location_city : Icons.business,
                  color: level == 0 ? AppColors.primary : AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    areaTree.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: level == 0 ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                ),
                if (areaTree.cameras.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                    ),
                    child: Text(
                      '${areaTree.cameras.length} camera',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (hasChildren) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: level == 0 ? AppColors.primary : AppColors.secondary,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Cameras in this area - only show when expanded
        if (isExpanded && areaTree.cameras.isNotEmpty)
          ...areaTree.cameras.map(
            (camera) => Container(
              margin: EdgeInsets.only(left: indentPadding + AppSpacing.md, bottom: AppSpacing.xs),
              child: _buildCameraItem(camera),
            ),
          ),

        // Child areas (stations) - only show when expanded
        if (isExpanded && areaTree.children.isNotEmpty)
          ...areaTree.children.map((childArea) => _buildAreaSection(childArea, level + 1)),
      ],
    );
  }

  Widget _buildCameraItem(Camera camera) {
    return Consumer<CameraSelectionProvider>(
      builder: (context, selectionProvider, child) {
        final isSelected = selectionProvider.isCameraSelected(camera.uniqueId);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.videocam,
                color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            title: Text(
              camera.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Trạm: ${camera.area.name}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: camera.deviceStatus == 'On'
                    ? AppColors.online.withOpacity(0.1)
                    : AppColors.offline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
                border: Border.all(
                  color: camera.deviceStatus == 'On' ? AppColors.online : AppColors.offline,
                  width: 1,
                ),
              ),
              child: Text(
                camera.deviceStatus == 'On' ? 'Online' : 'Offline',
                style: AppTextStyles.caption.copyWith(
                  color: camera.deviceStatus == 'On' ? AppColors.online : AppColors.offline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () => _toggleCameraSelection(camera),
          ),
        );
      },
    );
  }
}
