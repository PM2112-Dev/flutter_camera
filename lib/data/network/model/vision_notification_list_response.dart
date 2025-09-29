class VisionNotificationListResponse {
  final bool? isSuccess;
  final String? code;
  final String? name;
  final String? message;
  final NotificationListData? data;

  VisionNotificationListResponse({
    this.isSuccess,
    this.code,
    this.name,
    this.message,
    this.data,
  });

  factory VisionNotificationListResponse.fromJson(Map<String, dynamic> json) {
    return VisionNotificationListResponse(
      isSuccess: json['isSuccess'] as bool?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? NotificationListData.fromJson(json['data'])
          : null,
    );
  }
}

class NotificationListData {
  final int? totalRow;
  final int? pageSize;
  final int? pageIndex;
  final int? rowIndex;
  final int? lastRowIndex;
  final int? totalPages;
  final List<NotificationItem>? items;

  NotificationListData({
    this.totalRow,
    this.pageSize,
    this.pageIndex,
    this.rowIndex,
    this.lastRowIndex,
    this.totalPages,
    this.items,
  });

  factory NotificationListData.fromJson(Map<String, dynamic> json) {
    return NotificationListData(
      totalRow: json['totalRow'] as int?,
      pageSize: json['pageSize'] as int?,
      pageIndex: json['pageIndex'] as int?,
      rowIndex: json['rowIndex'] as int?,
      lastRowIndex: json['lastRowIndex'] as int?,
      totalPages: json['totalPages'] as int?,
      items: (json['items'] as List?)
          ?.map((e) => NotificationItem.fromJson(e))
          .toList(),
    );
  }
}

class NotificationItem {
  final String? id;
  final String? alertTime;
  final String? imagePath;
  final String? areaName;
  final String? cameraName;
  final String? warningEventName;
  final String? formattedDate;
  final String? dateData;
  final String? timeData;

  NotificationItem({
    this.id,
    this.alertTime,
    this.imagePath,
    this.areaName,
    this.cameraName,
    this.warningEventName,
    this.formattedDate,
    this.dateData,
    this.timeData,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String?,
      alertTime: json['alertTime'] as String?,
      imagePath: json['imagePath'] as String?,
      areaName: json['areaName'] as String?,
      cameraName: json['cameraName'] as String?,
      warningEventName: json['warningEventName'] as String?,
      formattedDate: json['formattedDate'] as String?,
      dateData: json['dateData'] as String?,
      timeData: json['timeData'] as String?,
    );
  }
}
