class VisionNotificationListRequest {
  final String? fromTime;
  final String? toTime;
  final int? areaId;
  final int? cameraId;
  final int? warningEventId;
  final int page;
  final int pageSize;

  VisionNotificationListRequest({
    this.fromTime,
    this.toTime,
    this.areaId,
    this.cameraId,
    this.warningEventId,
    this.page = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'fromTime': fromTime,
      'toTime': toTime,
      if (areaId != null) 'areaId': areaId,
      if (cameraId != null) 'cameraId': cameraId,
      if (warningEventId != null) 'warningEventId': warningEventId,
      'page': page,
      'pageSize': pageSize,
    }..removeWhere((key, value) => value == null);
  }

  factory VisionNotificationListRequest.fromJson(Map<String, dynamic> json) {
    return VisionNotificationListRequest(
      fromTime: json['fromTime'] as String?,
      toTime: json['toTime'] as String?,
      areaId: json['areaId'] as int?,
      cameraId: json['cameraId'] as int?,
      warningEventId: json['warningEventId'] as int?,
      page: (json['page'] as int?) ?? 1,
      pageSize: (json['pageSize'] as int?) ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromTime': fromTime,
      'toTime': toTime,
      'areaId': areaId,
      'cameraId': cameraId,
      'warningEventId': warningEventId,
      'page': page,
      'pageSize': pageSize,
    }..removeWhere((key, value) => value == null);
  }

  // copyWith method for easy cloning with modifications
  VisionNotificationListRequest copyWith({
    String? fromTime,
    String? toTime,
    int? areaId,
    int? cameraId,
    int? warningEventId,
    int? page,
    int? pageSize,
  }) {
    return VisionNotificationListRequest(
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      areaId: areaId ?? this.areaId,
      cameraId: cameraId ?? this.cameraId,
      warningEventId: warningEventId ?? this.warningEventId,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
