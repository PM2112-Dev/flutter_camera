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

class TemperatureStatsPage extends StatefulWidget {
  final AreaMapItem area;

  const TemperatureStatsPage({super.key, required this.area});

  @override
  State<TemperatureStatsPage> createState() => _TemperatureStatsPageState();
}

class _TemperatureStatsPageState extends State<TemperatureStatsPage> {
  @override
  void initState() {
    super.initState();
    // Enable all orientations for this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore portrait-only when leaving this page
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AreaDevicesBloc>(
      create: (context) => getIt<AreaDevicesBloc>()..add(FetchAreaDevices(areaId: widget.area.id)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.area.name,
                style: AppTextStyles.headline3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.border, height: 1),
          ),
        ),
        body: SafeArea(
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

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<AreaDevicesBloc>().add(FetchAreaDevices(areaId: widget.area.id));
                  },
                  child: _TemperatureStatsTable(devices: devicesState.devices),
                );
              }
              return AppWidgets.buildEmptyState(
                icon: Icons.analytics_outlined,
                title: 'Thống kê nhiệt độ',
                subtitle: 'Chưa có dữ liệu',
              );
            },
          ),
        ),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
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

  const _TemperatureStatsTable({required this.devices});

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
          setState(() {
            // Trigger rebuild when any bloc state changes
          });
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
    final tableData = _getTableData();

    if (tableData.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    return InteractiveViewer(
      boundaryMargin: EdgeInsets.zero,
      minScale: 0.1,
      maxScale: 5.0,
      constrained: false,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.secondary.withOpacity(0.05)),
        headingRowHeight: 56,
        dataRowHeight: 64,
        columnSpacing: 16,
        horizontalMargin: 16,
        border: TableBorder.all(color: AppColors.border, width: 0.5),
        columns: [
          DataColumn(
            label: Text(
              'Điểm đo',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Hiện tại\n(°C)',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'Max\n(°C)',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'Min\n(°C)',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'AVG\n(°C)',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'MT\nΔ (°C)',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'MT\nĐánh giá',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          DataColumn(
            label: Text(
              'Pha min\nΔ (°C)',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'Pha min\nĐánh giá',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          DataColumn(
            label: Text(
              'Toàn trạm\nΔ (°C)',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'Toàn trạm\nĐánh giá',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        rows: tableData.map((row) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      row['pointName'] ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      row['deviceName'] ?? '',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  row['current'] ?? '-',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: row['currentColor'] ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      row['max'] ?? '-',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_down, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      row['min'] ?? '-',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  row['avg'] ?? '-',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Environment delta
              DataCell(_buildDeltaCellContent(row['envDelta'])),
              // Environment evaluation
              DataCell(_buildEvaluationCellContent(row['envEval'], row['envConfig'])),
              // MinPhase delta
              DataCell(_buildDeltaCellContent(row['minPhaseDelta'])),
              // MinPhase evaluation
              DataCell(_buildEvaluationCellContent(row['minPhaseEval'], row['minPhaseConfig'])),
              // GlobalMinPhase delta
              DataCell(_buildDeltaCellContent(row['globalDelta'])),
              // GlobalMinPhase evaluation
              DataCell(_buildEvaluationCellContent(row['globalEval'], row['globalConfig'])),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeltaCellContent(String? delta) {
    if (delta == null) {
      return Text('-', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary));
    }

    final deltaValue = double.tryParse(delta) ?? 0;
    final isPositive = deltaValue > 0;
    final color = isPositive ? Colors.red : Colors.blue;

    return Text(
      '${isPositive ? '+' : ''}$delta',
      style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEvaluationCellContent(String? text, Map<String, dynamic>? config) {
    if (text == null || config == null) {
      return Text('-', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: config['bgColor'], borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'], size: 12, color: config['color']),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: config['color'],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTableData() {
    final List<Map<String, dynamic>> data = [];

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

          // Get Environment comparison
          final envResult = componentData.dicThermalDataResults['Enviroment'];
          final envDelta = envResult?.deltaValue.toStringAsFixed(1);
          final envEval = envResult?.compareResultObject.name;
          final envConfig = envResult != null
              ? _getEvaluationConfig(envResult.compareResultObject.id)
              : null;

          // Get MinPhase comparison
          final minPhaseResult = componentData.dicThermalDataResults['MinPhase'];
          final minPhaseDelta = minPhaseResult?.deltaValue.toStringAsFixed(1);
          final minPhaseEval = minPhaseResult?.compareResultObject.name;
          final minPhaseConfig = minPhaseResult != null
              ? _getEvaluationConfig(minPhaseResult.compareResultObject.id)
              : null;

          // Get GlobalMinPhase comparison
          final globalResult = componentData.dicThermalDataResults['GlobalMinPhase'];
          final globalDelta = globalResult?.deltaValue.toStringAsFixed(1);
          final globalEval = globalResult?.compareResultObject.name;
          final globalConfig = globalResult != null
              ? _getEvaluationConfig(globalResult.compareResultObject.id)
              : null;

          data.add({
            'pointName': componentData.monitorPointCode,
            'deviceName': device.name,
            'current': componentData.temperature.toStringAsFixed(1),
            'currentColor': _getStatusColor(status),
            'max': componentData.maxTemperature.toStringAsFixed(1),
            'min': componentData.minTemperature.toStringAsFixed(1),
            'avg': componentData.aveTemperature.toStringAsFixed(1),
            // Environment
            'envDelta': envDelta,
            'envEval': envEval,
            'envConfig': envConfig,
            // MinPhase
            'minPhaseDelta': minPhaseDelta,
            'minPhaseEval': minPhaseEval,
            'minPhaseConfig': minPhaseConfig,
            // GlobalMinPhase
            'globalDelta': globalDelta,
            'globalEval': globalEval,
            'globalConfig': globalConfig,
          });
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
}

enum ThermalStatus { normal, warning, critical }
