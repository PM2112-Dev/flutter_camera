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

    return Expanded(child: _buildStickyTable(tableData, availableTypes));
  }

  Widget _buildStickyTable(
    List<Map<String, dynamic>> tableData,
    List<Map<String, String>> availableTypes,
  ) {
    print('🔍 _buildStickyTable:');
    print('   - tableData length: ${tableData.length}');
    print('   - availableTypes length: ${availableTypes.length}');

    final dataSource = TemperatureDataSource(tableData, availableTypes);
    final columns = _buildSyncfusionColumns(availableTypes);
    final stackedHeaders = _buildStackedHeaders(availableTypes);

    print('   - columns count: ${columns.length}');
    print('   - stackedHeaders count: ${stackedHeaders.length}');

    return Container(
      height: 400, // Fixed height để test
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2), // Debug border
      ),
      child: SfDataGrid(
        source: dataSource,
        frozenColumnsCount: 1, // Ghim cột đầu tiên
        columns: columns,
        stackedHeaderRows: stackedHeaders,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        rowHeight: 52.0,
        headerRowHeight: 40.0,
        allowColumnsResizing: true,
        columnResizeMode: ColumnResizeMode.onResize,
      ),
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

  List<GridColumn> _buildSyncfusionColumns(List<Map<String, String>> availableTypes) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up, size: 16, color: AppColors.secondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Max (°C)',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_down, size: 16, color: AppColors.secondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Min (°C)',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, size: 16, color: AppColors.secondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'AVG (°C)',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thermostat, size: 16, color: AppColors.secondary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Nhiệt độ',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
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
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.compare_arrows, size: 16, color: AppColors.secondary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Chênh lệch',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
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
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assessment, size: 16, color: AppColors.secondary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Đánh giá',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return columns;
  }
}

class TemperatureDataSource extends DataGridSource {
  TemperatureDataSource(this.tableData, this.availableTypes) {
    _buildDataGridRows();
  }

  final List<Map<String, dynamic>> tableData;
  final List<Map<String, String>> availableTypes;
  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    print('🔍 TemperatureDataSource._buildDataGridRows:');
    print('   - tableData length: ${tableData.length}');
    print('   - availableTypes length: ${availableTypes.length}');

    _dataGridRows = tableData.map<DataGridRow>((data) {
      print('   - Processing row: ${data['pointName']} - ${data['deviceName']}');
      final cells = <DataGridCell>[];

      // Cột đầu tiên - Điểm đo
      cells.add(
        DataGridCell<String>(
          columnName: 'pointName',
          value: '${data['pointName']}\n${data['deviceName']}',
        ),
      );

      // Cột Max
      cells.add(DataGridCell<String>(columnName: 'max', value: data['max'] ?? '-'));

      // Cột Min
      cells.add(DataGridCell<String>(columnName: 'min', value: data['min'] ?? '-'));

      // Cột AVG
      cells.add(DataGridCell<String>(columnName: 'avg', value: data['avg'] ?? '-'));

      // Các cột comparison types
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

      return DataGridRow(cells: cells);
    }).toList();

    print('🔍 TemperatureDataSource._buildDataGridRows result: ${_dataGridRows.length} rows');
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
            Icon(Icons.trending_up, size: 14, color: Colors.red),
            const SizedBox(width: 3),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.red,
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
            Icon(Icons.trending_down, size: 14, color: Colors.blue),
            const SizedBox(width: 3),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.blue,
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
    for (final cell in row.getCells()) {
      final columnName = cell.columnName;
      if (columnName.endsWith('Config')) {
        final evalColumnName = columnName.replaceAll('Config', 'Eval');
        final evalCell = row.getCells().firstWhere(
          (c) => c.columnName == evalColumnName,
          orElse: () => DataGridCell<String>(columnName: '', value: ''),
        );
        if (evalCell.value.toString() == text) {
          // Tìm config tương ứng trong tableData
          final rowIndex = _dataGridRows.indexOf(row);
          if (rowIndex >= 0 && rowIndex < tableData.length) {
            final rowData = tableData[rowIndex];
            config = rowData[columnName] as Map<String, dynamic>?;
            break;
          }
        }
      }
    }

    // Fallback config nếu không tìm thấy
    config ??= {'bgColor': Colors.grey.shade100, 'color': Colors.grey, 'icon': Icons.help};

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
}
