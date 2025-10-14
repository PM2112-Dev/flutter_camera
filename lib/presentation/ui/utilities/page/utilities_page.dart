import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/presentation/bloc/area_devices/area_devices_bloc.dart';
import 'package:flutter_camera/presentation/bloc/area_devices/area_devices_event.dart';
import 'package:flutter_camera/presentation/bloc/area_devices/area_devices_state.dart';
import 'package:flutter_camera/presentation/bloc/real_time_thermal/real_time_thermal_bloc.dart';
import 'package:flutter_camera/presentation/bloc/real_time_thermal/real_time_thermal_event.dart';
import 'package:flutter_camera/presentation/bloc/real_time_thermal/real_time_thermal_state.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/domain/model/area_map.dart';
import 'package:flutter_camera/domain/model/area_devices.dart';
import 'package:flutter_camera/domain/model/real_time_thermal_data.dart';
import 'package:flutter_camera/data/services/common_enums_service.dart';
import 'package:flutter_camera/data/network/model/common_enums_model.dart';

// Temperature Stats Filter Model
class TemperatureStatsFilter {
  final List<String>? deviceNames; // Multiple device selection
  final int? evaluationId;
  final String? sortBy;
  final bool sortDescending;

  const TemperatureStatsFilter({
    this.deviceNames,
    this.evaluationId,
    this.sortBy,
    this.sortDescending = true,
  });

  bool get hasActiveFilters =>
      (deviceNames != null && deviceNames!.isNotEmpty) || evaluationId != null || sortBy != null;

  TemperatureStatsFilter copyWith({
    List<String>? deviceNames,
    int? evaluationId,
    String? sortBy,
    bool? sortDescending,
    bool clearDevices = false,
    bool clearEvaluation = false,
    bool clearSort = false,
  }) {
    return TemperatureStatsFilter(
      deviceNames: clearDevices ? null : (deviceNames ?? this.deviceNames),
      evaluationId: clearEvaluation ? null : (evaluationId ?? this.evaluationId),
      sortBy: clearSort ? null : (sortBy ?? this.sortBy),
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}

class UtilitiesPage extends StatefulWidget {
  final AreaMapItem? selectedArea;
  final VoidCallback onClearSelection;

  const UtilitiesPage({super.key, this.selectedArea, required this.onClearSelection});

  @override
  State<UtilitiesPage> createState() => _UtilitiesPageState();
}

class _UtilitiesPageState extends State<UtilitiesPage> {
  @override
  Widget build(BuildContext context) {
    // If an area is selected, show the temperature stats
    if (widget.selectedArea != null) {
      return BlocProvider<AreaDevicesBloc>(
        create: (context) =>
            getIt<AreaDevicesBloc>()..add(FetchAreaDevices(areaId: widget.selectedArea!.id)),
        child: _TemperatureStatsView(area: widget.selectedArea!),
      );
    }

    // Otherwise, show empty state prompting to select an area
    return _EmptyStateView();
  }
}

// Empty State View - Shown when no area is selected
class _EmptyStateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.buildEmptyState(
        icon: Icons.analytics_outlined,
        title: 'Bảng thống kê nhiệt độ',
        subtitle: 'Nhấn nút ở góc trên bên phải để chọn khu vực',
      ),
    );
  }
}

// Temperature Stats View - Shows temperature statistics table for selected area
class _TemperatureStatsView extends StatefulWidget {
  final AreaMapItem area;

  const _TemperatureStatsView({required this.area});

  @override
  State<_TemperatureStatsView> createState() => _TemperatureStatsViewState();
}

class _TemperatureStatsViewState extends State<_TemperatureStatsView> {
  TemperatureStatsFilter _filter = const TemperatureStatsFilter();
  final GlobalKey _filterButtonKey = GlobalKey();

  void _showFilterDialog() {
    final RenderBox? renderBox = _filterButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.7;

    // Get devices from AreaDevicesBloc
    final devicesState = context.read<AreaDevicesBloc>().state;
    List<DeviceItem> devices = [];
    if (devicesState is AreaDevicesLoaded) {
      devices = devicesState.devices.where((device) => device.deviceType == 'Machine').toList();
    }

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            Positioned(
              top: position.dy,
              right: 8,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                child: Container(
                  width: 320,
                  constraints: BoxConstraints(maxHeight: dialogHeight),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: _FilterDialog(
                    filter: _filter,
                    devices: devices,
                    onFilterChanged: (newFilter) {
                      setState(() {
                        _filter = newFilter;
                      });
                      Navigator.pop(dialogContext);
                    },
                    onClearAll: () {
                      setState(() {
                        _filter = const TemperatureStatsFilter();
                      });
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          return SafeArea(
            child: BlocBuilder<AreaDevicesBloc, AreaDevicesState>(
              builder: (context, devicesState) {
                if (devicesState is AreaDevicesLoading) {
                  return AppWidgets.buildLoadingIndicator(message: 'Đang tải thiết bị...');
                } else if (devicesState is AreaDevicesError) {
                  return _buildErrorView(context, devicesState.message);
                } else if (devicesState is AreaDevicesLoaded) {
                  if (devicesState.devices.isEmpty) {
                    return AppWidgets.buildEmptyState(
                      icon: Icons.device_thermostat,
                      title: 'Không có thiết bị',
                      subtitle: 'Khu vực này chưa có thiết bị nào',
                    );
                  }

                  return Column(
                    children: [
                      // Area info header - show in portrait, compact in landscape
                      if (!isLandscape)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                ),
                                child: Icon(Icons.analytics, color: AppColors.secondary, size: 24),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  widget.area.name,
                                  style: AppTextStyles.headline3.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Filter button
                              Stack(
                                children: [
                                  IconButton(
                                    key: _filterButtonKey,
                                    icon: Icon(Icons.filter_list, color: AppColors.secondary),
                                    onPressed: _showFilterDialog,
                                    tooltip: 'Lọc dữ liệu',
                                  ),
                                  if (_filter.hasActiveFilters)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.info,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        // Compact header for landscape
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.analytics, color: AppColors.secondary, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  widget.area.name,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Filter button
                              Stack(
                                children: [
                                  IconButton(
                                    key: _filterButtonKey,
                                    icon: Icon(
                                      Icons.filter_list,
                                      color: AppColors.secondary,
                                      size: 20,
                                    ),
                                    onPressed: _showFilterDialog,
                                    tooltip: 'Lọc dữ liệu',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  if (_filter.hasActiveFilters)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.info,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      // Temperature stats table
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<AreaDevicesBloc>().add(
                              FetchAreaDevices(areaId: widget.area.id),
                            );
                          },
                          child: _TemperatureStatsTable(
                            devices: devicesState.devices,
                            filter: _filter,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return AppWidgets.buildEmptyState(
                  icon: Icons.analytics_outlined,
                  title: 'Thống kê nhiệt độ',
                  subtitle: 'Chưa có dữ liệu',
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
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
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AreaDevicesBloc>().add(FetchAreaDevices(areaId: widget.area.id));
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

// Temperature Statistics Table
class _TemperatureStatsTable extends StatefulWidget {
  final List<DeviceItem> devices;
  final TemperatureStatsFilter filter;

  const _TemperatureStatsTable({required this.devices, required this.filter});

  @override
  State<_TemperatureStatsTable> createState() => _TemperatureStatsTableState();
}

class _TemperatureStatsTableState extends State<_TemperatureStatsTable> {
  final Map<String, RealTimeThermalBloc> _thermalBlocs = {};

  @override
  void initState() {
    super.initState();
    // Filter only Machine devices
    final machineDevices = widget.devices
        .where((device) => device.deviceType == 'Machine')
        .toList();
    print(
      '🔥 Initializing thermal blocs for ${machineDevices.length} Machine devices (Total: ${widget.devices.length})',
    );

    for (final device in machineDevices) {
      print(
        '   📡 Fetching thermal data for: ${device.name} (machineId=${device.machineId}, id=${device.id}, type=${device.deviceType})',
      );
      final bloc = getIt<RealTimeThermalBloc>()
        ..add(
          FetchRealTimeThermalData(
            machineId: device.machineId,
            id: device.id,
            deviceType: device.deviceType,
          ),
        );
      _thermalBlocs[device.key] = bloc;

      // Listen to bloc state changes to trigger rebuild
      bloc.stream.listen((state) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    for (final bloc in _thermalBlocs.values) {
      bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tableData = _getTableData();

    // Apply filters
    tableData = _applyFilters(tableData);

    if (tableData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Không có dữ liệu phù hợp',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      minScale: 0.3,
      maxScale: 5.0,
      constrained: false,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: _buildNestedHeaderTable(tableData),
        ),
      ),
    );
  }

  Widget _buildNestedHeaderTable(List<Map<String, dynamic>> tableData) {
    final availableTypes = _getAvailableComparisonTypes(tableData);

    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Multi-level Header (2 rows)
          _buildMultiLevelHeader(availableTypes),
          // Data Rows
          ...tableData.map((row) => _buildDataRow(row, availableTypes)),
        ],
      ),
    );
  }

  Widget _buildMultiLevelHeader(List<Map<String, String>> availableTypes) {
    final headerBgColor = AppColors.secondary.withOpacity(0.08);
    const row1Height = 32.0;
    const row2Height = 32.0;
    const totalHeight = row1Height + row2Height;

    return Column(
      children: [
        // First header row - Main columns with groups
        Container(
          height: row1Height,
          color: headerBgColor,
          child: Row(
            children: [
              // Điểm đo (rowspan 2)
              _buildHeaderCellWithRowSpan('Điểm đo', width: 180, height: totalHeight),
              // Hiện tại (rowspan 2)
              _buildHeaderCellWithRowSpan('Hiện tại (°C)', width: 100, height: totalHeight),
              // Max (rowspan 2)
              _buildHeaderCellWithRowSpan('Cao nhất (°C)', width: 100, height: totalHeight),
              // Min (rowspan 2)
              _buildHeaderCellWithRowSpan('Thấp nhất (°C)', width: 100, height: totalHeight),
              // AVG (rowspan 2)
              _buildHeaderCellWithRowSpan('Trung bình (°C)', width: 100, height: totalHeight),
              // Comparison type groups (colspan 3 each)
              ...availableTypes.map(
                (type) => _buildGroupHeaderCell(
                  type['displayName'] as String,
                  width: 350,
                  height: row1Height,
                ),
              ),
            ],
          ),
        ),
        // Second header row - Sub columns
        Container(
          height: row2Height,
          color: headerBgColor,
          child: Row(
            children: [
              // Empty spacers for rowspan cells (5 columns)
              SizedBox(width: 180, height: row2Height), // Điểm đo
              SizedBox(width: 100, height: row2Height), // Hiện tại
              SizedBox(width: 100, height: row2Height), // Max
              SizedBox(width: 100, height: row2Height), // Min
              SizedBox(width: 100, height: row2Height), // AVG
              // Sub-columns for each comparison type
              ...availableTypes.expand(
                (_) => [
                  _buildSubHeaderCell('Nhiệt độ (°C)', width: 120, height: row2Height),
                  _buildSubHeaderCell('Chênh lệch (°C)', width: 110, height: row2Height),
                  _buildSubHeaderCell('Đánh giá', width: 120, height: row2Height),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getComparisonTypes() {
    // Define all possible comparison types based on thresholdTypeList
    return [
      {'key': 'Enviroment', 'displayName': 'Môi trường'},
      {'key': 'Threshold', 'displayName': 'Ngưỡng nhiệt'},
      {'key': 'MinPhase', 'displayName': 'Pha min'},
      {'key': 'TwoArea', 'displayName': 'Phần tử cùng loại'},
      {'key': 'GlobalMinPhase', 'displayName': 'Pha min toàn trạm'},
      {'key': 'GlobalTwoArea', 'displayName': 'Phần tử cùng loại toàn trạm'},
    ];
  }

  List<Map<String, String>> _getAvailableComparisonTypes(List<Map<String, dynamic>> tableData) {
    if (tableData.isEmpty) return [];

    final allTypes = _getComparisonTypes();
    final availableTypes = <Map<String, String>>[];

    // Check each comparison type to see if it has data
    for (final type in allTypes) {
      final key = type['key']!;
      final configKey = '${key.toLowerCase()}Config';

      // Check if any row has data for this comparison type
      final hasData = tableData.any((row) => row[configKey] != null);

      if (hasData) {
        availableTypes.add(type);
      }
    }

    print(
      '📊 Available comparison types: ${availableTypes.map((t) => t['displayName']).join(", ")}',
    );
    return availableTypes;
  }

  Widget _buildHeaderCellWithRowSpan(String text, {required double width, required double height}) {
    return Container(
      width: width,
      height: height, // Total height for rowspan (2 rows combined)
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontSize: 12,
          height: 1.0, // Giảm line height để text gọn hơn và căn giữa tốt hơn
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGroupHeaderCell(String text, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.border, width: 0.5),
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubHeaderCell(String text, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataRow(Map<String, dynamic> row, List<Map<String, String>> availableTypes) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // Điểm đo
          SizedBox(
            width: 180,
            height: 52,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      row['pointName'] ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row['deviceName'] ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Hiện tại
          _buildDataCell(
            child: Text(
              row['current'] ?? '-',
              style: AppTextStyles.bodySmall.copyWith(
                color: row['currentColor'] ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            width: 100,
          ),
          // Max
          _buildDataCell(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, size: 14, color: Colors.red),
                const SizedBox(width: 3),
                Text(
                  row['max'] ?? '-',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            width: 100,
          ),
          // Min
          _buildDataCell(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.trending_down, size: 14, color: Colors.blue),
                const SizedBox(width: 3),
                Text(
                  row['min'] ?? '-',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            width: 100,
          ),
          // AVG
          _buildDataCell(
            child: Text(
              row['avg'] ?? '-',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            width: 100,
          ),
          // Dynamic comparison type columns
          ...availableTypes.expand((type) {
            final key = type['key']!;
            final tempKey = '${key.toLowerCase()}Temp';
            final deltaKey = '${key.toLowerCase()}Delta';
            final evalKey = '${key.toLowerCase()}Eval';
            final configKey = '${key.toLowerCase()}Config';

            return [
              // Nhiệt độ
              _buildDataCell(
                child: Text(
                  row[tempKey] ?? '-',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                width: 120,
              ),
              // Chênh lệch
              _buildDataCell(child: _buildDeltaCellContent(row[deltaKey]), width: 110),
              // Đánh giá
              _buildDataCell(
                child: _buildEvaluationCellContent(row[evalKey], row[configKey]),
                width: 120,
              ),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildDataCell({required Widget child, required double width}) {
    return SizedBox(
      width: width,
      height: 52, // Fixed height
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildDeltaCellContent(String? delta) {
    if (delta == null) {
      return Text(
        '-',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
      );
    }

    final deltaValue = double.tryParse(delta) ?? 0;
    final isPositive = deltaValue > 0;
    final color = isPositive ? Colors.red : Colors.blue;

    return Text(
      '${isPositive ? '+' : ''}$delta',
      style: AppTextStyles.bodySmall.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEvaluationCellContent(String? text, Map<String, dynamic>? config) {
    if (text == null || config == null) {
      return Text(
        '-',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
        textAlign: TextAlign.center,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: config['bgColor'], borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(config['icon'], size: 11, color: config['color']),
          const SizedBox(width: 3),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: config['color'],
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTableData() {
    final List<Map<String, dynamic>> data = [];
    final comparisonTypes = _getComparisonTypes();

    for (final device in widget.devices) {
      if (device.deviceType != 'Machine') continue;

      final bloc = _thermalBlocs[device.key];
      if (bloc == null) continue;

      final state = bloc.state;
      if (state is RealTimeThermalLoaded) {
        final componentKeys = state.data.data.keys.toList()..sort();

        for (final componentKey in componentKeys) {
          final componentData = state.data.data[componentKey]?.firstOrNull;
          if (componentData == null) continue;

          final status = _getStatusFromData(componentData);

          // Build row data with basic info
          final rowData = <String, dynamic>{
            'pointName': componentData.monitorPointCode,
            'deviceName': device.name,
            'current': componentData.temperature.toStringAsFixed(1),
            'currentColor': _getStatusColor(status),
            'max': componentData.maxTemperature.toStringAsFixed(1),
            'min': componentData.minTemperature.toStringAsFixed(1),
            'avg': componentData.aveTemperature.toStringAsFixed(1),
          };

          // Get comparison data for all types dynamically
          for (final type in comparisonTypes) {
            final key = type['key']!;
            final result = componentData.dicThermalDataResults[key];

            if (result != null) {
              final lowerKey = key.toLowerCase();
              rowData['${lowerKey}Temp'] = result.compareValue.toStringAsFixed(1);
              rowData['${lowerKey}Delta'] = result.deltaValue.toStringAsFixed(1);
              rowData['${lowerKey}Eval'] = result.compareResultObject.name;
              rowData['${lowerKey}Config'] = _getEvaluationConfig(result.compareResultObject.id);
            } else {
              // No data for this comparison type
              final lowerKey = key.toLowerCase();
              rowData['${lowerKey}Temp'] = null;
              rowData['${lowerKey}Delta'] = null;
              rowData['${lowerKey}Eval'] = null;
              rowData['${lowerKey}Config'] = null;
            }
          }

          data.add(rowData);
        }
      }
    }

    return data;
  }

  Map<String, dynamic> _getEvaluationConfig(int id) {
    // Map evaluation IDs to colors and icons
    // 1 = Tốt, 2 = Khá, 3 = Trung bình, 4 = Xấu
    switch (id) {
      case 1: // Tốt
        return {'color': Colors.green, 'icon': Icons.check_circle, 'bgColor': Colors.green.shade50};
      case 2: // Khá
        return {
          'color': Colors.lightGreen,
          'icon': Icons.check_circle_outline,
          'bgColor': Colors.lightGreen.shade50,
        };
      case 3: // Trung bình
        return {
          'color': Colors.orange,
          'icon': Icons.warning_amber,
          'bgColor': Colors.orange.shade50,
        };
      case 4: // Xấu
        return {'color': Colors.red, 'icon': Icons.warning, 'bgColor': Colors.red.shade50};
      default: // Không xác định
        return {'color': Colors.grey, 'icon': Icons.info_outline, 'bgColor': Colors.grey.shade100};
    }
  }

  ThermalStatus _getStatusFromData(ThermalDataItem data) {
    // Determine status based on comparison results
    final envResult = data.dicThermalDataResults['Enviroment'];
    if (envResult != null) {
      final id = envResult.compareResultObject.id;
      if (id == 4) return ThermalStatus.critical;
      if (id == 3) return ThermalStatus.warning;
    }
    return ThermalStatus.normal;
  }

  Color _getStatusColor(ThermalStatus status) {
    switch (status) {
      case ThermalStatus.critical:
        return Colors.red;
      case ThermalStatus.warning:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    var filteredData = data;

    // Filter by device names (multiple selection)
    if (widget.filter.deviceNames != null && widget.filter.deviceNames!.isNotEmpty) {
      filteredData = filteredData.where((row) {
        final deviceName = row['deviceName'] as String?;
        return deviceName != null && widget.filter.deviceNames!.contains(deviceName);
      }).toList();
    }

    // Filter by evaluation (check all comparison types)
    if (widget.filter.evaluationId != null) {
      final comparisonTypes = _getComparisonTypes();

      Color? targetColor;
      switch (widget.filter.evaluationId!) {
        case 1: // Tốt
          targetColor = Colors.green;
          break;
        case 2: // Khá
          targetColor = Colors.lightGreen;
          break;
        case 3: // Trung bình
          targetColor = Colors.orange;
          break;
        case 4: // Xấu
          targetColor = Colors.red;
          break;
      }

      filteredData = filteredData.where((row) {
        bool matchesEvaluation = false;

        for (final type in comparisonTypes) {
          final key = type['key']!;
          final configKey = '${key.toLowerCase()}Config';
          final config = row[configKey] as Map<String, dynamic>?;

          if (config != null && config['color'] == targetColor) {
            matchesEvaluation = true;
            break;
          }
        }

        return matchesEvaluation;
      }).toList();
    }

    // Sort data
    if (widget.filter.sortBy != null) {
      filteredData.sort((a, b) {
        final sortKey = widget.filter.sortBy!;
        final aValue = _getNumericValue(a[sortKey]);
        final bValue = _getNumericValue(b[sortKey]);

        if (widget.filter.sortDescending) {
          return bValue.compareTo(aValue); // Cao đến thấp
        } else {
          return aValue.compareTo(bValue); // Thấp đến cao
        }
      });
    }

    return filteredData;
  }

  double _getNumericValue(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

enum ThermalStatus { normal, warning, critical }

// Filter Dialog Widget
class _FilterDialog extends StatefulWidget {
  final TemperatureStatsFilter filter;
  final List<DeviceItem> devices;
  final Function(TemperatureStatsFilter) onFilterChanged;
  final VoidCallback onClearAll;

  const _FilterDialog({
    required this.filter,
    required this.devices,
    required this.onFilterChanged,
    required this.onClearAll,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late TemperatureStatsFilter _localFilter;
  late List<String> _selectedDevices;
  bool _isDeviceExpanded = true;
  bool _isSortExpanded = true;
  List<EnumItem> _temperatureLevels = [];
  bool _isLoadingEnums = true;

  final List<Map<String, String>> _sortOptions = [
    {'key': 'current', 'name': 'Nhiệt độ hiện tại'},
    {'key': 'max', 'name': 'Nhiệt độ cao nhất'},
    {'key': 'min', 'name': 'Nhiệt độ thấp nhất'},
    {'key': 'avg', 'name': 'Nhiệt độ trung bình'},
    {'key': 'enviromentDelta', 'name': 'Δ Môi trường'},
    {'key': 'thresholdDelta', 'name': 'Δ Ngưỡng nhiệt'},
    {'key': 'minphaseDelta', 'name': 'Δ Pha min'},
    {'key': 'twoareaDelta', 'name': 'Δ Phần tử cùng loại'},
    {'key': 'globalminphaseDelta', 'name': 'Δ Pha min toàn trạm'},
    {'key': 'globaltwoareaDelta', 'name': 'Δ Phần tử cùng loại toàn trạm'},
  ];

  @override
  void initState() {
    super.initState();
    _localFilter = widget.filter;
    _selectedDevices = List.from(_localFilter.deviceNames ?? []);
    _loadEnums();
  }

  Future<void> _loadEnums() async {
    try {
      final enumsService = getIt<CommonEnumsService>();
      final enums = await enumsService.getAllEnums();

      if (mounted) {
        setState(() {
          _temperatureLevels = enums?.temperatureLevelList ?? _getDefaultTemperatureLevels();
          _isLoadingEnums = false;
        });
      }
    } catch (e) {
      print('⚠️ Error loading enums, using defaults: $e');
      if (mounted) {
        setState(() {
          _temperatureLevels = _getDefaultTemperatureLevels();
          _isLoadingEnums = false;
        });
      }
    }
  }

  List<EnumItem> _getDefaultTemperatureLevels() {
    return [
      const EnumItem(id: 1, code: 'Good', name: 'Tốt'),
      const EnumItem(id: 2, code: 'Fair', name: 'Khá'),
      const EnumItem(id: 3, code: 'Average', name: 'Trung bình'),
      const EnumItem(id: 4, code: 'Bad', name: 'Xấu'),
    ];
  }

  Color _getColorForLevel(int id) {
    switch (id) {
      case 1: // Good - Tốt
        return Colors.green;
      case 2: // Fair - Khá
        return Colors.lightGreen;
      case 3: // Average - Trung bình
        return Colors.orange;
      case 4: // Bad - Xấu
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppBorderRadius.medium),
              topRight: Radius.circular(AppBorderRadius.medium),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_alt, size: 20, color: AppColors.info),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Bộ lọc', style: AppTextStyles.headline3.copyWith(color: AppColors.info)),
                ],
              ),
              TextButton(
                onPressed: widget.onClearAll,
                child: Text(
                  'Xóa tất cả',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Scrollable content
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device Filter (Expandable)
                  if (widget.devices.isNotEmpty) ...[
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isDeviceExpanded = !_isDeviceExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.device_thermostat,
                                  size: 18,
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Thiết bị',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (_selectedDevices.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(left: AppSpacing.xs),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.info,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_selectedDevices.length}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textOnPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                if (_selectedDevices.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedDevices.clear();
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Bỏ chọn',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ),
                                AnimatedRotation(
                                  turns: _isDeviceExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: _isDeviceExpanded
                          ? Column(
                              children: [
                                const SizedBox(height: AppSpacing.sm),
                                ...widget.devices.map((device) {
                                  final isSelected = _selectedDevices.contains(device.name);
                                  return _buildDeviceCheckbox(
                                    title: device.name,
                                    selected: isSelected,
                                    onChanged: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedDevices.add(device.name);
                                        } else {
                                          _selectedDevices.remove(device.name);
                                        }
                                      });
                                    },
                                  );
                                }),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const Divider(height: AppSpacing.lg),
                  ],

                  // Sort Options (Expandable)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSortExpanded = !_isSortExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sort, size: 18, color: AppColors.textPrimary),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Sắp xếp',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (_localFilter.sortBy != null)
                                Container(
                                  margin: const EdgeInsets.only(left: AppSpacing.xs),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.info,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _localFilter.sortDescending
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    size: 10,
                                    color: AppColors.textOnPrimary,
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              if (_localFilter.sortBy != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _localFilter = _localFilter.copyWith(clearSort: true);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Xóa',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
                                  ),
                                ),
                              AnimatedRotation(
                                turns: _isSortExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _isSortExpanded
                        ? Column(
                            children: [
                              const SizedBox(height: AppSpacing.sm),
                              ..._sortOptions.map((option) {
                                final isSelected = _localFilter.sortBy == option['key'];
                                return _buildSortOption(
                                  title: option['name']!,
                                  selected: isSelected,
                                  sortKey: option['key']!,
                                  isDescending: isSelected ? _localFilter.sortDescending : true,
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        // Toggle sort direction
                                        _localFilter = _localFilter.copyWith(
                                          sortDescending: !_localFilter.sortDescending,
                                        );
                                      } else {
                                        // Select new sort field
                                        _localFilter = _localFilter.copyWith(
                                          sortBy: option['key'],
                                          sortDescending: true,
                                        );
                                      }
                                    });
                                  },
                                );
                              }),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  const Divider(height: AppSpacing.lg),

                  // Evaluation Filter
                  Text(
                    'Đánh giá',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lọc theo bất kỳ loại đánh giá nào',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_isLoadingEnums)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: CircularProgressIndicator(color: AppColors.info, strokeWidth: 2),
                      ),
                    )
                  else
                    ..._temperatureLevels.map((level) {
                      final color = _getColorForLevel(level.id);
                      return _buildFilterOption(
                        title: level.name,
                        color: color,
                        selected: _localFilter.evaluationId == level.id,
                        onTap: () {
                          setState(() {
                            _localFilter = _localFilter.copyWith(
                              evaluationId: _localFilter.evaluationId == level.id ? null : level.id,
                              clearEvaluation: _localFilter.evaluationId == level.id,
                            );
                          });
                        },
                      );
                    }),
                ],
              ),
            ),
          ),
        ),

        // Apply Button
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Update filter with selected devices
                final updatedFilter = _localFilter.copyWith(
                  deviceNames: _selectedDevices.isEmpty ? null : _selectedDevices,
                  clearDevices: _selectedDevices.isEmpty,
                );
                widget.onFilterChanged(updatedFilter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
              ),
              child: const Text('Áp dụng'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCheckbox({
    required String title,
    required bool selected,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.info.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          border: Border.all(
            color: selected ? AppColors.info.withOpacity(0.3) : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: AppColors.info,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected ? AppColors.info : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String title,
    required bool selected,
    required String sortKey,
    required bool isDescending,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.info.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          border: Border.all(
            color: selected ? AppColors.info.withOpacity(0.3) : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isDescending ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: selected ? AppColors.info : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected ? AppColors.info : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
            if (selected)
              Text(
                isDescending ? 'Cao → Thấp' : 'Thấp → Cao',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.info,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required String title,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.info.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          border: Border.all(
            color: selected ? AppColors.info : AppColors.border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected ? AppColors.info : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check_circle, size: 18, color: AppColors.info),
          ],
        ),
      ),
    );
  }
}
