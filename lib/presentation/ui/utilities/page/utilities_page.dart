import 'dart:async';
import 'package:flutter/material.dart';
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
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_camera/presentation/ui/utilities/page/temperature_stats_page.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TemperatureStatsFilter {
  final List<String>? deviceNames;
  final int? evaluationId;
  final String? comparisonType;
  final String? sortBy;
  final bool sortDescending;

  const TemperatureStatsFilter({
    this.deviceNames,
    this.evaluationId,
    this.comparisonType,
    this.sortBy,
    this.sortDescending = true,
  });

  bool get hasActiveFilters =>
      (deviceNames != null && deviceNames!.isNotEmpty) ||
      evaluationId != null ||
      comparisonType != null ||
      sortBy != null;

  TemperatureStatsFilter copyWith({
    List<String>? deviceNames,
    int? evaluationId,
    String? comparisonType,
    String? sortBy,
    bool? sortDescending,
    bool clearDevices = false,
    bool clearEvaluation = false,
    bool clearComparisonType = false,
    bool clearSort = false,
  }) {
    return TemperatureStatsFilter(
      deviceNames: clearDevices ? null : (deviceNames ?? this.deviceNames),
      evaluationId: clearEvaluation ? null : (evaluationId ?? this.evaluationId),
      comparisonType: clearComparisonType ? null : (comparisonType ?? this.comparisonType),
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
      return MultiBlocProvider(
        providers: [
          BlocProvider<AreaDevicesBloc>(
            create: (context) =>
                getIt<AreaDevicesBloc>()..add(FetchAreaDevices(areaId: widget.selectedArea!.id)),
          ),
          BlocProvider<RealTimeThermalBloc>(create: (context) => getIt<RealTimeThermalBloc>()),
        ],
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
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, String>> _availableTypes = [];
  List<Map<String, dynamic>> _filteredTableData = [];

  void _applyPieChartFilter(int evaluationId, String? comparisonType) {
    setState(() {
      // Toggle: If same filter is clicked again, clear it
      if (_filter.evaluationId == evaluationId && _filter.comparisonType == comparisonType) {
        _filter = _filter.copyWith(clearEvaluation: true, clearComparisonType: true);
      } else {
        _filter = _filter.copyWith(evaluationId: evaluationId, comparisonType: comparisonType);
      }
    });
  }

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
                              // View Details button
                              IconButton(
                                icon: Icon(Icons.table_chart, color: AppColors.secondary),
                                onPressed: () {
                                  // Get current filtered data
                                  final filteredData = _getFilteredTableData();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TemperatureStatsPage(
                                        area: widget.area,
                                        tableData: filteredData,
                                        availableTypes: _availableTypes,
                                        filter: _filter,
                                      ),
                                    ),
                                  );
                                },
                                tooltip: 'Xem chi tiết bảng',
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
                              // View Details button
                              IconButton(
                                icon: Icon(Icons.table_chart, color: AppColors.secondary, size: 20),
                                onPressed: () {
                                  // Get current filtered data
                                  final filteredData = _getFilteredTableData();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TemperatureStatsPage(
                                        area: widget.area,
                                        tableData: filteredData,
                                        availableTypes: _availableTypes,
                                        filter: _filter,
                                      ),
                                    ),
                                  );
                                },
                                tooltip: 'Xem chi tiết bảng',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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
                            onPieChartFilterApplied: _applyPieChartFilter,
                            onDataUpdated: _updateTableData,
                            onFilteredDataUpdated: _updateFilteredTableData,
                            onPageChanged: (pageIndex, comparisonType) {
                              // This will be handled by the pie charts
                            },
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

  void _updateTableData(
    List<Map<String, dynamic>> tableData,
    List<Map<String, String>> availableTypes,
  ) {
    setState(() {
      _tableData = tableData;
      _availableTypes = availableTypes;
    });
  }

  void _updateFilteredTableData(List<Map<String, dynamic>> filteredData) {
    setState(() {
      _filteredTableData = filteredData;
    });
  }

  List<Map<String, dynamic>> _getFilteredTableData() {
    // Return the filtered data if available, otherwise return original data
    return _filteredTableData.isNotEmpty ? _filteredTableData : _tableData;
  }
}

// Temperature Statistics Table
class _TemperatureStatsTable extends StatefulWidget {
  final List<DeviceItem> devices;
  final TemperatureStatsFilter filter;
  final Function(int evaluationId, String? comparisonType) onPieChartFilterApplied;
  final Function(List<Map<String, dynamic>>, List<Map<String, String>>)? onDataUpdated;
  final Function(List<Map<String, dynamic>>)? onFilteredDataUpdated;
  final Function(int pageIndex, String? comparisonType)? onPageChanged;

  const _TemperatureStatsTable({
    required this.devices,
    required this.filter,
    required this.onPieChartFilterApplied,
    this.onDataUpdated,
    this.onFilteredDataUpdated,
    this.onPageChanged,
  });

  @override
  State<_TemperatureStatsTable> createState() => _TemperatureStatsTableState();
}

class _TemperatureStatsTableState extends State<_TemperatureStatsTable> {
  final Map<String, RealTimeThermalBloc> _thermalBlocs = {};
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tableHorizontalController = ScrollController();
  final ScrollController _tableVerticalController = ScrollController();
  Timer? _refreshTimer;
  Timer? _debounceTimer;
  bool _isInitialLoad = true;
  List<Map<String, dynamic>> _cachedTableData = [];
  bool _hasLoggedInitialData = false;
  int _currentPageIndex = 0; // 0 = Tổng hợp, 1+ = specific comparison type
  String? _currentComparisonType; // null for tổng hợp

  @override
  void initState() {
    super.initState();
    _initializeThermalBlocs();
    _startAutoRefresh();
  }

  void _updatePageState(int pageIndex, String? comparisonType) {
    print('🔄 Page changed: index=$pageIndex, comparisonType=$comparisonType');
    setState(() {
      _currentPageIndex = pageIndex;
      _currentComparisonType = comparisonType;
    });
  }

  void _initializeThermalBlocs() {
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

      // Only create new bloc if not exists
      if (!_thermalBlocs.containsKey(device.key)) {
        final bloc = getIt<RealTimeThermalBloc>();
        _thermalBlocs[device.key] = bloc;

        // Listen to bloc state changes
        bloc.stream.listen((state) {
          if (mounted) {
            _onStateChanged(state);
          }
        });
      }

      // Fetch data
      _thermalBlocs[device.key]!.add(
        FetchRealTimeThermalData(
          machineId: device.machineId,
          id: device.id,
          deviceType: device.deviceType,
        ),
      );
    }
  }

  void _startAutoRefresh() {
    // Refresh data every 5 minutes (300 seconds) to reduce API calls
    _refreshTimer = Timer.periodic(const Duration(seconds: 300), (timer) {
      if (mounted) {
        print('🔄 Auto-refreshing thermal data...');
        _refreshData();
      }
    });
  }

  void _refreshData() {
    final machineDevices = widget.devices
        .where((device) => device.deviceType == 'Machine')
        .toList();

    for (final device in machineDevices) {
      final bloc = _thermalBlocs[device.key];
      if (bloc != null) {
        bloc.add(
          FetchRealTimeThermalData(
            machineId: device.machineId,
            id: device.id,
            deviceType: device.deviceType,
          ),
        );
      }
    }
  }

  Future<void> _manualRefresh() async {
    // Manual refresh
    print('🔄 Manual refresh...');
    _refreshData();
  }

  void _onStateChanged(dynamic state) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        if (state is RealTimeThermalLoaded) {
          if (_isInitialLoad) {
            // Initial load - rebuild normally
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isInitialLoad = false;
                });
              }
            });
          } else {
            // Auto-refresh - only rebuild if data actually changed
            final currentData = _getTableData();
            if (currentData.length != _cachedTableData.length) {
              print('🔄 Data changed: ${_cachedTableData.length} → ${currentData.length} rows');
              final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {});
                  // Restore scroll position after rebuild
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(scrollOffset);
                  }
                }
              });
            }
          }
        } else if (state is RealTimeThermalLoading || state is RealTimeThermalError) {
          // Don't rebuild when loading or error to avoid flickering
          // Keep showing cached data
        }
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _tableHorizontalController.dispose();
    _tableVerticalController.dispose();
    for (final bloc in _thermalBlocs.values) {
      bloc.close();
    }
    super.dispose();
  }

  Map<String, dynamic> _calculateStatistics(List<Map<String, dynamic>> tableData) {
    if (tableData.isEmpty) {
      return {'envTemp': '-', 'maxTemp': '-', 'maxDevice': '-', 'minTemp': '-', 'minDevice': '-'};
    }

    // Calculate average environment temperature
    double envTempSum = 0;
    int envCount = 0;
    for (final row in tableData) {
      final envTemp = row['enviromentTemp'];
      if (envTemp != null) {
        envTempSum += double.tryParse(envTemp) ?? 0;
        envCount++;
      }
    }
    final avgEnvTemp = envCount > 0 ? (envTempSum / envCount).toStringAsFixed(1) : '-';

    // Find max and min current temperature with device names
    double maxTemp = double.negativeInfinity;
    double minTemp = double.infinity;
    String maxDevice = '';
    String minDevice = '';

    for (final row in tableData) {
      final current = double.tryParse(row['current'] ?? '0') ?? 0;
      if (current > maxTemp) {
        maxTemp = current;
        maxDevice = row['deviceName'] ?? '';
      }
      if (current < minTemp) {
        minTemp = current;
        minDevice = row['deviceName'] ?? '';
      }
    }

    return {
      'envTemp': avgEnvTemp,
      'maxTemp': maxTemp.toStringAsFixed(1),
      'maxDevice': maxDevice,
      'minTemp': minTemp.toStringAsFixed(1),
      'minDevice': minDevice,
    };
  }

  @override
  Widget build(BuildContext context) {
    var tableData = _getTableData();
    // Remove all build-time logging to reduce spam

    // Check loading/error states
    final hasAnyLoading = _thermalBlocs.values.any((bloc) => bloc.state is RealTimeThermalLoading);
    final hasAnyError = _thermalBlocs.values.any((bloc) => bloc.state is RealTimeThermalError);
    final hasAnyLoaded = _thermalBlocs.values.any((bloc) => bloc.state is RealTimeThermalLoaded);

    // Apply filters
    tableData = _applyFilters(tableData);

    // Notify parent about filtered data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFilteredDataUpdated?.call(tableData);
    });

    // Show loading indicator if we have no data and are loading
    if (tableData.isEmpty && hasAnyLoading && !hasAnyLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.secondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Đang tải dữ liệu nhiệt độ...',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Show error message if we have errors and no cached data
    if (tableData.isEmpty && hasAnyError && !hasAnyLoaded && _cachedTableData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Lỗi tải dữ liệu nhiệt độ',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Vui lòng kiểm tra kết nối mạng và thử lại',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _manualRefresh,
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Show no data message only if we truly have no data (not loading, not error, no cache)
    if (tableData.isEmpty && !hasAnyLoading && !hasAnyError) {
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
            if (widget.filter.hasActiveFilters) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Filter đang active - Nhấn nút filter để clear',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _manualRefresh,
              icon: Icon(Icons.refresh),
              label: Text('Làm mới'),
            ),
          ],
        ),
      );
    }

    // statistics and availableTypes are now calculated inline to use original data
    final originalData = _getTableData();
    final availableTypes = _getAvailableComparisonTypes(originalData);

    // Notify parent about data updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDataUpdated?.call(originalData, availableTypes);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _manualRefresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Statistics Cards
                _StatisticsCards(
                  statistics: _calculateStatistics(originalData),
                ), // Use original data, not filtered
                const SizedBox(height: AppSpacing.md),
                // Pie Charts
                _ComparisonPieCharts(
                  tableData: originalData, // Use original data, not filtered
                  availableTypes: availableTypes, // Use original data
                  onFilterApplied: widget.onPieChartFilterApplied,
                  currentFilter: widget.filter,
                  onPageChanged: (pageIndex, comparisonType) {
                    // Update table state when page changes
                    _updatePageState(pageIndex, comparisonType);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // Temperature Table - fixed height
                SizedBox(
                  height: constraints.maxHeight * 0.8, // 80% of screen height
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                      child: _buildSfDataGridTable(tableData),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSfDataGridTable(List<Map<String, dynamic>> tableData) {
    final availableTypes = _getAvailableComparisonTypes(tableData);
    final dataSource = UtilitiesDataSource(
      tableData,
      availableTypes,
      _currentPageIndex,
      _currentComparisonType,
    );

    return SfDataGrid(
      source: dataSource,
      frozenColumnsCount: 1, // Ghim cột đầu tiên
      columns: _buildSyncfusionColumns(availableTypes),
      stackedHeaderRows: _buildStackedHeaders(availableTypes),
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      rowHeight: 52.0,
      headerRowHeight: 40.0,
      allowColumnsResizing: true,
      columnResizeMode: ColumnResizeMode.onResize,
    );
  }

  List<StackedHeaderRow> _buildStackedHeaders(List<Map<String, String>> availableTypes) {
    final cells = <StackedHeaderCell>[];

    // Điểm đo (always shown)
    cells.add(
      StackedHeaderCell(
        columnNames: ['pointName'],
        child: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            border: Border(
              right: BorderSide(color: AppColors.border, width: 0.5),
              left: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          child: Text(
            'Điểm đo',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // Thiết bị group (always shown)
    cells.add(
      StackedHeaderCell(
        columnNames: ['max', 'min', 'avg'],
        child: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.08),
            border: Border(
              right: BorderSide(color: AppColors.border, width: 0.5),
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Text(
            'Thiết bị',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // Comparison type groups - show based on current page
    if (_currentPageIndex == 0) {
      // Tổng hợp - show all types
      cells.addAll(
        availableTypes.map(
          (type) => StackedHeaderCell(
            columnNames: [
              '${type['key']!.toLowerCase()}Temp',
              '${type['key']!.toLowerCase()}Delta',
              '${type['key']!.toLowerCase()}Eval',
            ],
            child: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                border: Border(
                  right: BorderSide(color: AppColors.border, width: 0.5),
                  bottom: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Text(
                type['displayName'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    } else if (_currentComparisonType != null) {
      // Specific comparison type - show only that type
      final type = availableTypes.firstWhere(
        (t) => t['key']!.toLowerCase() == _currentComparisonType!.toLowerCase(),
        orElse: () => {'key': _currentComparisonType!, 'displayName': _currentComparisonType!},
      );

      cells.add(
        StackedHeaderCell(
          columnNames: [
            '${type['key']!.toLowerCase()}Temp',
            '${type['key']!.toLowerCase()}Delta',
            '${type['key']!.toLowerCase()}Eval',
          ],
          child: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              border: Border(
                right: BorderSide(color: AppColors.border, width: 0.5),
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Text(
              type['displayName'] as String,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return [StackedHeaderRow(cells: cells)];
  }

  List<GridColumn> _buildSyncfusionColumns(List<Map<String, String>> availableTypes) {
    final columns = <GridColumn>[];

    // Cột đầu tiên - Điểm đo (frozen) - always shown
    columns.add(
      GridColumn(
        columnName: 'pointName',
        width: 120.0,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            border: Border(
              right: BorderSide(color: AppColors.border, width: 0.5),
              left: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          child: Text(
            '', // Empty label vì đã có trong stacked header
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // Thiết bị columns - always shown
    // Cột Max
    columns.add(
      GridColumn(
        columnName: 'max',
        width: 100.0,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            'Max (°C)',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD32F2F),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // Cột Min
    columns.add(
      GridColumn(
        columnName: 'min',
        width: 100.0,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            'Min (°C)',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1976D2),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // Cột AVG
    columns.add(
      GridColumn(
        columnName: 'avg',
        width: 100.0,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            'AVG (°C)',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF757575),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // Comparison type columns - show based on current page
    if (_currentPageIndex == 0) {
      // Tổng hợp - show all types
      for (final type in availableTypes) {
        final key = type['key']!;
        _addComparisonTypeColumns(columns, key);
      }
    } else if (_currentComparisonType != null) {
      // Specific comparison type - show only that type
      _addComparisonTypeColumns(columns, _currentComparisonType!);
    }

    return columns;
  }

  void _addComparisonTypeColumns(List<GridColumn> columns, String key) {
    // Nhiệt độ
    columns.add(
      GridColumn(
        columnName: '${key.toLowerCase()}Temp',
        width: 100.0,
        label: InkWell(
          onTap: () => _showColumnInfoPopup(context, 'Nhiệt độ', _getTemperatureDescription(key)),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [Icon(Icons.thermostat, size: 16, color: const Color(0xFFF57C00))],
                  ),
                ],
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );

    // Chênh lệch
    columns.add(
      GridColumn(
        columnName: '${key.toLowerCase()}Delta',
        width: 100.0,
        label: InkWell(
          onTap: () => _showColumnInfoPopup(context, 'Chênh lệch', _getDeltaDescription(key)),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(Icons.compare_arrows, size: 16, color: const Color(0xFF1976D2)),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );

    // Đánh giá
    columns.add(
      GridColumn(
        columnName: '${key.toLowerCase()}Eval',
        width: 120.0,
        label: InkWell(
          onTap: () => _showColumnInfoPopup(context, 'Đánh giá', _getEvaluationDescription(key)),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [Icon(Icons.assessment, size: 16, color: const Color(0xFF2E7D32))],
                  ),
                ],
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
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

  void _showColumnInfoPopup(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getTemperatureDescription(String comparisonType) {
    switch (comparisonType.toLowerCase()) {
      case 'enviroment':
        return 'Chênh lệch nhiệt độ so với môi trường';
      case 'threshold':
        return 'Chênh lệch nhiệt độ so với ngưỡng nhiệt độ';
      case 'minphase':
        return 'Chênh lệch nhiệt độ so với pha min';
      case 'twoarea':
        return 'Chênh lệch nhiệt độ so với phần tử cùng loại';
      case 'globalminphase':
        return 'Chênh lệch nhiệt độ so với pha min toàn trạm';
      case 'globaltwoarea':
        return 'Chênh lệch nhiệt độ so với phần tử cùng loại toàn trạm';
      default:
        return 'Chênh lệch nhiệt độ so với giá trị chuẩn';
    }
  }

  String _getDeltaDescription(String comparisonType) {
    switch (comparisonType.toLowerCase()) {
      case 'enviroment':
        return 'Chênh lệch nhiệt độ so với môi trường';
      case 'threshold':
        return 'Chênh lệch nhiệt độ so với ngưỡng nhiệt độ';
      case 'minphase':
        return 'Chênh lệch nhiệt độ so với pha min';
      case 'twoarea':
        return 'Chênh lệch nhiệt độ so với phần tử cùng loại';
      case 'globalminphase':
        return 'Chênh lệch nhiệt độ so với pha min toàn trạm';
      case 'globaltwoarea':
        return 'Chênh lệch nhiệt độ so với phần tử cùng loại toàn trạm';
      default:
        return 'Chênh lệch nhiệt độ so với giá trị chuẩn';
    }
  }

  String _getEvaluationDescription(String comparisonType) {
    switch (comparisonType.toLowerCase()) {
      case 'enviroment':
        return 'Đánh giá dựa trên so sánh với nhiệt độ môi trường';
      case 'threshold':
        return 'Đánh giá dựa trên so sánh với ngưỡng nhiệt độ';
      case 'minphase':
        return 'Đánh giá dựa trên so sánh với pha min';
      case 'twoarea':
        return 'Đánh giá dựa trên so sánh với phần tử cùng loại';
      case 'globalminphase':
        return 'Đánh giá dựa trên so sánh với pha min toàn trạm';
      case 'globaltwoarea':
        return 'Đánh giá dựa trên so sánh với phần tử cùng loại toàn trạm';
      default:
        return 'Đánh giá dựa trên so sánh với giá trị chuẩn';
    }
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

  List<Map<String, dynamic>> _getTableData() {
    final List<Map<String, dynamic>> data = [];
    final comparisonTypes = _getComparisonTypes();
    bool hasAnyValidData = false;

    // Only log on first successful data load
    bool shouldLog = !_hasLoggedInitialData && data.isNotEmpty;
    if (shouldLog) {
      print('🔍 _getTableData: Processing ${widget.devices.length} devices');
    }

    for (final device in widget.devices) {
      if (device.deviceType != 'Machine') continue;

      final bloc = _thermalBlocs[device.key];
      if (bloc == null) {
        if (shouldLog) print('⚠️ No bloc found for device: ${device.name}');
        continue;
      }

      final state = bloc.state;
      if (state is RealTimeThermalLoaded) {
        hasAnyValidData = true;
        if (shouldLog) print('✅ Device ${device.name}: ${state.data.data.length} components');
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
      } else {
        if (shouldLog) {
          print(
            '⚠️ Device ${device.name}: State is not RealTimeThermalLoaded (${state.runtimeType})',
          );
        }
      }
    }

    // Update cache if we have valid data
    if (hasAnyValidData && data.isNotEmpty) {
      _cachedTableData = List.from(data);
      if (!_hasLoggedInitialData) {
        print('💾 Updated cache with ${_cachedTableData.length} rows');
        _hasLoggedInitialData = true;
      }
    }

    // If no new data but we have cached data, return cached data
    if (data.isEmpty && _cachedTableData.isNotEmpty) {
      if (shouldLog) print('🔄 Using cached data: ${_cachedTableData.length} rows');
      return _cachedTableData;
    }

    if (shouldLog) print('🔍 _getTableData result: ${data.length} rows');
    return data;
  }

  Map<String, dynamic> _getEvaluationConfig(int id) {
    // Map evaluation IDs to colors and icons
    // 1 = Tốt, 2 = Khá, 3 = Trung bình, 4 = Xấu
    switch (id) {
      case 1: // Tốt - Xanh lá đậm
        return {
          'color': const Color(0xFF2E7D32),
          'icon': Icons.check_circle,
          'bgColor': const Color(0xFFE8F5E8),
        };
      case 2: // Khá - Xanh dương
        return {
          'color': const Color(0xFF1976D2),
          'icon': Icons.check_circle_outline,
          'bgColor': const Color(0xFFE3F2FD),
        };
      case 3: // Trung bình - Cam
        return {
          'color': const Color(0xFFF57C00),
          'icon': Icons.warning_amber,
          'bgColor': const Color(0xFFFFF3E0),
        };
      case 4: // Xấu - Đỏ
        return {
          'color': const Color(0xFFD32F2F),
          'icon': Icons.warning,
          'bgColor': const Color(0xFFFFEBEE),
        };
      default: // Không xác định - Xám
        return {
          'color': const Color(0xFF757575),
          'icon': Icons.info_outline,
          'bgColor': const Color(0xFFF5F5F5),
        };
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

    // Filter by evaluation and comparison type
    if (widget.filter.evaluationId != null) {
      Color? targetColor;
      switch (widget.filter.evaluationId!) {
        case 1: // Tốt
          targetColor = const Color(0xFF2E7D32);
          break;
        case 2: // Khá
          targetColor = const Color(0xFF1976D2);
          break;
        case 3: // Trung bình
          targetColor = const Color(0xFFF57C00);
          break;
        case 4: // Xấu
          targetColor = const Color(0xFFD32F2F);
          break;
      }

      filteredData = filteredData.where((row) {
        bool matchesEvaluation = false;

        if (widget.filter.comparisonType != null) {
          // Filter by specific comparison type
          final configKey = '${widget.filter.comparisonType!.toLowerCase()}Config';
          final config = row[configKey] as Map<String, dynamic>?;

          if (config != null && config['color'] == targetColor) {
            matchesEvaluation = true;
          }
        } else {
          // Filter by any comparison type
          final comparisonTypes = _getComparisonTypes();
          for (final type in comparisonTypes) {
            final key = type['key']!;
            final configKey = '${key.toLowerCase()}Config';
            final config = row[configKey] as Map<String, dynamic>?;

            if (config != null && config['color'] == targetColor) {
              matchesEvaluation = true;
              break;
            }
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

// Statistics Cards Widget
class _StatisticsCards extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const _StatisticsCards({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Environment Temperature
          _StatRow(
            title: 'Nhiệt độ môi trường',
            value: '${statistics['envTemp']}°C',
            icon: Icons.thermostat,
            iconColor: Colors.blue,
            bgColor: Colors.blue.shade50,
          ),
          const SizedBox(height: AppSpacing.md),
          // Max Temperature
          _StatRow(
            title: 'Max',
            value: '${statistics['maxTemp']}°C',
            subtitle: statistics['maxDevice'],
            icon: Icons.trending_up,
            iconColor: const Color(0xFFD32F2F),
            bgColor: const Color(0xFFFFEBEE),
          ),
          const SizedBox(height: AppSpacing.md),
          // Min Temperature
          _StatRow(
            title: 'Min',
            value: '${statistics['minTemp']}°C',
            subtitle: statistics['minDevice'],
            icon: Icons.trending_down,
            iconColor: const Color(0xFF2E7D32),
            bgColor: const Color(0xFFE8F5E8),
          ),
        ],
      ),
    );
  }
}

// Single Stat Row Widget
class _StatRow extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _StatRow({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text(
                    value,
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '($subtitle)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Comparison Pie Charts Widget with PageView (Tổng hợp + Từng loại)
class _ComparisonPieCharts extends StatefulWidget {
  final List<Map<String, dynamic>> tableData;
  final List<Map<String, String>> availableTypes;
  final Function(int evaluationId, String? comparisonType) onFilterApplied;
  final TemperatureStatsFilter currentFilter;
  final Function(int pageIndex, String? comparisonType)? onPageChanged;

  const _ComparisonPieCharts({
    required this.tableData,
    required this.availableTypes,
    required this.onFilterApplied,
    required this.currentFilter,
    this.onPageChanged,
  });

  @override
  State<_ComparisonPieCharts> createState() => _ComparisonPieChartsState();
}

class _ComparisonPieChartsState extends State<_ComparisonPieCharts> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, int> _calculateTotalStats() {
    final Map<String, int> stats = {'good': 0, 'fair': 0, 'average': 0, 'bad': 0};
    final processedDevices = <String>{};

    final comparisonTypes = [
      'enviroment',
      'threshold',
      'minphase',
      'twoarea',
      'globalminphase',
      'globaltwoarea',
    ];

    for (final row in widget.tableData) {
      final deviceKey = '${row['pointName']}_${row['deviceName']}';

      // Only count each device once (not multiple times for different monitor points)
      if (processedDevices.contains(deviceKey)) continue;
      processedDevices.add(deviceKey);

      // Find worst (lowest) evaluation across all comparison types for this device
      int worstEvalId = 1; // Default: Tốt (best)

      for (final typeKey in comparisonTypes) {
        final configKey = '${typeKey}Config';
        final config = row[configKey] as Map<String, dynamic>?;

        if (config != null) {
          final color = config['color'];
          int evalId = 1;

          if (color == const Color(0xFFD32F2F)) {
            evalId = 4; // Xấu (worst)
          } else if (color == const Color(0xFFF57C00)) {
            evalId = 3; // Trung bình
          } else if (color == const Color(0xFF1976D2)) {
            evalId = 2; // Khá
          } else if (color == const Color(0xFF2E7D32)) {
            evalId = 1; // Tốt (best)
          }

          // Keep the worst evaluation
          if (evalId > worstEvalId) {
            worstEvalId = evalId;
          }
        }
      }

      // Count based on worst evaluation
      if (worstEvalId == 4) {
        stats['bad'] = (stats['bad'] ?? 0) + 1;
      } else if (worstEvalId == 3) {
        stats['average'] = (stats['average'] ?? 0) + 1;
      } else if (worstEvalId == 2) {
        stats['fair'] = (stats['fair'] ?? 0) + 1;
      } else {
        stats['good'] = (stats['good'] ?? 0) + 1;
      }
    }

    return stats;
  }

  Map<String, int> _calculateStatsForType(String typeKey) {
    final Map<String, int> stats = {'good': 0, 'fair': 0, 'average': 0, 'bad': 0};

    for (final row in widget.tableData) {
      final configKey = '${typeKey.toLowerCase()}Config';
      final config = row[configKey] as Map<String, dynamic>?;

      if (config != null) {
        final color = config['color'];
        if (color == const Color(0xFF2E7D32)) {
          stats['good'] = (stats['good'] ?? 0) + 1;
        } else if (color == const Color(0xFF1976D2)) {
          stats['fair'] = (stats['fair'] ?? 0) + 1;
        } else if (color == const Color(0xFFF57C00)) {
          stats['average'] = (stats['average'] ?? 0) + 1;
        } else if (color == const Color(0xFFD32F2F)) {
          stats['bad'] = (stats['bad'] ?? 0) + 1;
        }
      }
    }

    return stats;
  }

  @override
  Widget build(BuildContext context) {
    // Total count = 1 (Tổng hợp) + availableTypes.length
    final totalPages = 1 + widget.availableTypes.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // PageView with pie charts
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                // Notify parent about page change
                String? comparisonType;
                if (index > 0 && index <= widget.availableTypes.length) {
                  comparisonType = widget.availableTypes[index - 1]['key'];
                }
                widget.onPageChanged?.call(index, comparisonType);
              },
              itemCount: totalPages,
              itemBuilder: (context, index) {
                String? currentComparisonType;
                if (index == 0) {
                  // First page: Tổng hợp
                  final stats = _calculateTotalStats();
                  currentComparisonType = null;
                  return _buildPieChartCard('Tổng hợp', stats, currentComparisonType);
                } else {
                  // Other pages: Từng loại so sánh
                  final type = widget.availableTypes[index - 1];
                  final stats = _calculateStatsForType(type['key']!);
                  currentComparisonType = type['key']!;
                  return _buildPieChartCard(type['displayName']!, stats, currentComparisonType);
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Page Indicator (dots)
          _buildPageIndicator(totalPages),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(String title, Map<String, int> stats, String? comparisonTypeKey) {
    final total = stats.values.fold(0, (sum, count) => sum + count);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê đánh giá - $title',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (total == 0)
            Expanded(
              child: Center(
                child: Text(
                  'Không có dữ liệu',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Expanded(
              child: Row(
                children: [
                  // Pie Chart with tap handler
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(stats),
                        sectionsSpace: 2,
                        centerSpaceRadius: 25,
                        borderData: FlBorderData(show: false),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            if (event is FlTapUpEvent && pieTouchResponse?.touchedSection != null) {
                              final sectionIndex =
                                  pieTouchResponse!.touchedSection!.touchedSectionIndex;
                              _handlePieChartTap(sectionIndex, stats, comparisonTypeKey);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // Legend - clickable
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClickableLegendItem(
                          'Tốt',
                          stats['good'] ?? 0,
                          const Color(0xFF2E7D32),
                          1,
                          comparisonTypeKey,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildClickableLegendItem(
                          'Khá',
                          stats['fair'] ?? 0,
                          const Color(0xFF1976D2),
                          2,
                          comparisonTypeKey,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildClickableLegendItem(
                          'Trung bình',
                          stats['average'] ?? 0,
                          const Color(0xFFF57C00),
                          3,
                          comparisonTypeKey,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildClickableLegendItem(
                          'Xấu',
                          stats['bad'] ?? 0,
                          const Color(0xFFD32F2F),
                          4,
                          comparisonTypeKey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handlePieChartTap(int sectionIndex, Map<String, int> stats, String? comparisonTypeKey) {
    // Map section index to evaluation ID
    final evaluations = [
      if (stats['good']! > 0) 1,
      if (stats['fair']! > 0) 2,
      if (stats['average']! > 0) 3,
      if (stats['bad']! > 0) 4,
    ];

    if (sectionIndex >= 0 && sectionIndex < evaluations.length) {
      final evaluationId = evaluations[sectionIndex];
      widget.onFilterApplied(evaluationId, comparisonTypeKey);
    }
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> stats) {
    final sections = <PieChartSectionData>[];
    final data = [
      {'label': 'Tốt', 'value': stats['good'] ?? 0, 'color': const Color(0xFF2E7D32)},
      {'label': 'Khá', 'value': stats['fair'] ?? 0, 'color': const Color(0xFF1976D2)},
      {'label': 'Trung bình', 'value': stats['average'] ?? 0, 'color': const Color(0xFFF57C00)},
      {'label': 'Xấu', 'value': stats['bad'] ?? 0, 'color': const Color(0xFFD32F2F)},
    ];

    for (final item in data) {
      final value = item['value'] as int;
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            value: value.toDouble(),
            color: item['color'] as Color,
            radius: 30,
            titleStyle: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            title: value.toString(),
          ),
        );
      }
    }

    return sections;
  }

  Widget _buildPageIndicator(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? AppColors.secondary
                : AppColors.secondary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildClickableLegendItem(
    String label,
    int count,
    Color color,
    int evaluationId,
    String? comparisonTypeKey,
  ) {
    // Check if this item is currently filtered
    final isActive =
        widget.currentFilter.evaluationId == evaluationId &&
        widget.currentFilter.comparisonType == comparisonTypeKey;

    if (count == 0) {
      return Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$label: $count',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: () => widget.onFilterApplied(evaluationId, comparisonTypeKey),
      borderRadius: BorderRadius.circular(AppBorderRadius.small),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
                border: Border.all(color: AppColors.secondary, width: 1.5),
              )
            : null,
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
                '$label: $count',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              size: 14,
              color: isActive ? AppColors.secondary : AppColors.secondary.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

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
        return const Color(0xFF2E7D32);
      case 2: // Fair - Khá
        return const Color(0xFF1976D2);
      case 3: // Average - Trung bình
        return const Color(0xFFF57C00);
      case 4: // Bad - Xấu
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF757575);
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

class UtilitiesDataSource extends DataGridSource {
  UtilitiesDataSource(
    this.tableData,
    this.availableTypes,
    this.currentPageIndex,
    this.currentComparisonType,
  ) {
    _buildDataGridRows();
  }

  final List<Map<String, dynamic>> tableData;
  final List<Map<String, String>> availableTypes;
  final int currentPageIndex;
  final String? currentComparisonType;
  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    _dataGridRows = tableData.map<DataGridRow>((data) {
      final cells = <DataGridCell>[];

      // Cột đầu tiên - Điểm đo (always shown)
      cells.add(
        DataGridCell<String>(
          columnName: 'pointName',
          value: '${data['pointName']}\n${data['deviceName']}',
        ),
      );

      // Thiết bị columns (always shown)
      // Cột Max
      cells.add(DataGridCell<String>(columnName: 'max', value: data['max'] ?? '-'));

      // Cột Min
      cells.add(DataGridCell<String>(columnName: 'min', value: data['min'] ?? '-'));

      // Cột AVG
      cells.add(DataGridCell<String>(columnName: 'avg', value: data['avg'] ?? '-'));

      // Comparison type columns - only add cells for visible columns
      if (currentPageIndex == 0) {
        // Tổng hợp - show all types
        for (final type in availableTypes) {
          final key = type['key']!;
          final lowerKey = key.toLowerCase();
          cells.add(
            DataGridCell<String>(
              columnName: '${lowerKey}Temp',
              value: data['${lowerKey}Temp']?.toString() ?? '-',
            ),
          );
          cells.add(
            DataGridCell<String>(
              columnName: '${lowerKey}Delta',
              value: data['${lowerKey}Delta']?.toString() ?? '-',
            ),
          );
          cells.add(
            DataGridCell<String>(
              columnName: '${lowerKey}Eval',
              value: data['${lowerKey}Eval']?.toString() ?? '-',
            ),
          );
        }
      } else if (currentComparisonType != null) {
        // Specific comparison type - show only that type
        final lowerKey = currentComparisonType!.toLowerCase();
        cells.add(
          DataGridCell<String>(
            columnName: '${lowerKey}Temp',
            value: data['${lowerKey}Temp']?.toString() ?? '-',
          ),
        );
        cells.add(
          DataGridCell<String>(
            columnName: '${lowerKey}Delta',
            value: data['${lowerKey}Delta']?.toString() ?? '-',
          ),
        );
        cells.add(
          DataGridCell<String>(
            columnName: '${lowerKey}Eval',
            value: data['${lowerKey}Eval']?.toString() ?? '-',
          ),
        );
      }

      return DataGridRow(cells: cells);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        final columnName = cell.columnName;
        final value = cell.value.toString();
        final isStickyColumn = columnName == 'pointName';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isStickyColumn ? AppColors.primary.withOpacity(0.05) : null,
            border: Border(
              right: BorderSide(color: AppColors.border, width: 0.5),
              bottom: BorderSide(color: AppColors.border, width: 0.5),
              left: isStickyColumn
                  ? BorderSide(color: AppColors.primary, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: Center(child: _buildCellContent(columnName, value, row)),
        );
      }).toList(),
    );
  }

  Widget _buildCellContent(String columnName, String value, DataGridRow row) {
    switch (columnName) {
      case 'pointName':
        final parts = value.split('\n');
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              parts[0],
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              parts.length > 1 ? parts[1] : '',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 'max':
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 14, color: const Color(0xFFD32F2F)),
            const SizedBox(width: 3),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 'min':
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.trending_down, size: 14, color: const Color(0xFF1976D2)),
            const SizedBox(width: 3),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF1976D2),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 'avg':
        return Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        );
      default:
        // Các cột comparison types
        if (columnName.endsWith('Temp')) {
          return Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          );
        } else if (columnName.endsWith('Delta')) {
          return _buildDeltaContent(value);
        } else if (columnName.endsWith('Eval')) {
          return _buildEvaluationContent(value, row);
        }
        return Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
          textAlign: TextAlign.center,
        );
    }
  }

  Widget _buildDeltaContent(String delta) {
    if (delta == '-') {
      return Text(
        '-',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
        textAlign: TextAlign.center,
      );
    }

    final deltaValue = double.tryParse(delta.toString()) ?? 0;
    final isPositive = deltaValue > 0;
    final color = isPositive ? const Color(0xFFD32F2F) : const Color(0xFF1976D2);

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

  Widget _buildEvaluationContent(String text, DataGridRow row) {
    if (text == '-') {
      return Text(
        '-',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
        textAlign: TextAlign.center,
      );
    }

    // Tìm config từ row data
    Map<String, dynamic>? config;
    final rowIndex = _dataGridRows.indexOf(row);
    if (rowIndex >= 0 && rowIndex < tableData.length) {
      final rowData = tableData[rowIndex];

      // Tìm config cho column hiện tại
      for (final cell in row.getCells()) {
        final columnName = cell.columnName;
        if (columnName.endsWith('Eval') && cell.value.toString() == text) {
          // Tìm config tương ứng
          final configKey = columnName.replaceAll('Eval', 'Config');
          config = rowData[configKey] as Map<String, dynamic>?;
          if (config != null) break;
        }
      }
    }

    // Fallback config nếu không tìm thấy - sử dụng màu sắc mới
    config ??= _getEvaluationConfigFromText(text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: config['bgColor'], borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(config['icon'], size: 10, color: config['color']),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: config['color'],
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method để lấy config từ text evaluation
  Map<String, dynamic> _getEvaluationConfigFromText(String text) {
    switch (text.toLowerCase()) {
      case 'tốt':
        return {
          'color': const Color(0xFF2E7D32),
          'icon': Icons.check_circle,
          'bgColor': const Color(0xFFE8F5E8),
        };
      case 'khá':
        return {
          'color': const Color(0xFF1976D2),
          'icon': Icons.check_circle_outline,
          'bgColor': const Color(0xFFE3F2FD),
        };
      case 'trung bình':
        return {
          'color': const Color(0xFFF57C00),
          'icon': Icons.warning_amber,
          'bgColor': const Color(0xFFFFF3E0),
        };
      case 'xấu':
        return {
          'color': const Color(0xFFD32F2F),
          'icon': Icons.warning,
          'bgColor': const Color(0xFFFFEBEE),
        };
      default:
        return {
          'color': const Color(0xFF757575),
          'icon': Icons.info_outline,
          'bgColor': const Color(0xFFF5F5F5),
        };
    }
  }
}
