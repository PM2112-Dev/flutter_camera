import 'package:flutter/material.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/presentation/ui/utilities/page/utilities_page.dart';
import 'package:flutter_camera/domain/model/area_map.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TemperatureStatsPage extends StatelessWidget {
  final AreaMapItem area;
  final List<Map<String, dynamic>> tableData; // Data từ utilities_page
  final List<Map<String, String>> availableTypes; // Available types từ utilities_page
  final TemperatureStatsFilter filter; // Filter từ utilities_page

  const TemperatureStatsPage({
    super.key,
    required this.area,
    required this.tableData,
    required this.availableTypes,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(area.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _TemperatureStatsTable(
        tableData: tableData,
        availableTypes: availableTypes,
        filter: filter,
      ),
    );
  }
}

class _TemperatureStatsTable extends StatelessWidget {
  final List<Map<String, dynamic>> tableData; // Data từ utilities_page
  final List<Map<String, String>> availableTypes; // Available types từ utilities_page
  final TemperatureStatsFilter filter; // Filter từ utilities_page

  const _TemperatureStatsTable({
    required this.tableData,
    required this.availableTypes,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    print('🔍 TemperatureStatsTable build:');
    print('   - tableData length: ${tableData.length}');
    print('   - availableTypes length: ${availableTypes.length}');
    print('   - filter: ${filter.hasActiveFilters}');
    print(
      '   - filter details: deviceNames=${filter.deviceNames}, evaluationId=${filter.evaluationId}, comparisonType=${filter.comparisonType}',
    );

    if (tableData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không có dữ liệu'),
            SizedBox(height: 8),
            Text(
              'Data từ utilities_page không được truyền đúng',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return _buildSfDataGridTable(context, tableData);
  }

  Widget _buildSfDataGridTable(BuildContext context, List<Map<String, dynamic>> tableData) {
    // For temperature_stats_page, we always show all columns (like "Tổng hợp" view)
    final dataSource = UtilitiesDataSource(tableData, availableTypes, 0, null);

    return SfDataGrid(
      source: dataSource,
      frozenColumnsCount: 1, // Ghim cột đầu tiên
      columns: _buildSyncfusionColumns(context, availableTypes),
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
    return [
      // First stacked header row - Main groups
      StackedHeaderRow(
        cells: [
          // Điểm đo (rowspan 2)
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
          // Thiết bị group (colspan 3)
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
          // Comparison type groups (colspan 3 each)
          ...availableTypes.map(
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
        ],
      ),
    ];
  }

  List<GridColumn> _buildSyncfusionColumns(
    BuildContext context,
    List<Map<String, String>> availableTypes,
  ) {
    final columns = <GridColumn>[];

    // Cột đầu tiên - Điểm đo (frozen) - Label sẽ được hiển thị trong stacked header
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

    // Các cột comparison types (3 cột cho mỗi type: Nhiệt độ, Chênh lệch, Đánh giá)
    for (final type in availableTypes) {
      final key = type['key']!;

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

    return columns;
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
        return 'Chênh lệch nhiệt độ so với phần tử cùng';
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
        return 'Chênh lệch nhiệt độ so với ngưỡng nhiệt';
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
}
