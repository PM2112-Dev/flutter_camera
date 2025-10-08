class NotificationFilter {
  final String? timeRange; // 'today', '7days', '30days', 'custom'
  final DateTime? startDate;
  final DateTime? endDate;
  final String? compareTypeCode;
  final String? areaName;
  final String? statusCode;

  NotificationFilter({
    this.timeRange,
    this.startDate,
    this.endDate,
    this.compareTypeCode,
    this.areaName,
    this.statusCode,
  });

  bool get hasActiveFilters =>
      timeRange != null || compareTypeCode != null || areaName != null || statusCode != null;

  NotificationFilter copyWith({
    String? timeRange,
    DateTime? startDate,
    DateTime? endDate,
    String? compareTypeCode,
    String? areaName,
    String? statusCode,
    bool clearTimeRange = false,
    bool clearCompareType = false,
    bool clearArea = false,
    bool clearStatus = false,
  }) {
    return NotificationFilter(
      timeRange: clearTimeRange ? null : (timeRange ?? this.timeRange),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      compareTypeCode: clearCompareType ? null : (compareTypeCode ?? this.compareTypeCode),
      areaName: clearArea ? null : (areaName ?? this.areaName),
      statusCode: clearStatus ? null : (statusCode ?? this.statusCode),
    );
  }

  @override
  int get hashCode =>
      Object.hash(timeRange, startDate, endDate, compareTypeCode, areaName, statusCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationFilter &&
          runtimeType == other.runtimeType &&
          timeRange == other.timeRange &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          compareTypeCode == other.compareTypeCode &&
          areaName == other.areaName &&
          statusCode == other.statusCode;
}
