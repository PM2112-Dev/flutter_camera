class NotificationDetailResponse {
  final bool? isSuccess;
  final String? code;
  final String? name;
  final String? message;
  final NotificationDetailData? data;

  NotificationDetailResponse({
    this.isSuccess,
    this.code,
    this.name,
    this.message,
    this.data,
  });

  factory NotificationDetailResponse.fromJson(Map<String, dynamic> json) {
    return NotificationDetailResponse(
      isSuccess: json['isSuccess'] as bool?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? NotificationDetailData.fromJson(json['data'])
          : null,
    );
  }
}

class NotificationDetailData {
  final String? formattedDate;
  final String? dateData;
  final String? timeData;
  final String? areaName;
  final String? machineName;
  final double? componentValue;
  final String? warningEventName;
  final CompareTypeObject? compareTypeObject;
  final CompareResultObject? compareResultObject;
  final StatusObject? statusObject;
  final String? id;
  final String? dataTime;
  final double? compareValue;
  final double? deltaValue;
  final String? monitorPointCode;
  final String? machineComponentName;
  final String? resolveTime;
  final String? compareComponent;
  final String? compareMonitorPoint;
  final String? compareDataTime;
  final double? compareMinTemperature;
  final double? compareMaxTemperature;
  final double? compareAveTemperature;
  final String? imagePath;

  NotificationDetailData({
    this.formattedDate,
    this.dateData,
    this.timeData,
    this.areaName,
    this.machineName,
    this.componentValue,
    this.warningEventName,
    this.compareTypeObject,
    this.compareResultObject,
    this.statusObject,
    this.id,
    this.dataTime,
    this.compareValue,
    this.deltaValue,
    this.monitorPointCode,
    this.machineComponentName,
    this.resolveTime,
    this.compareComponent,
    this.compareMonitorPoint,
    this.compareDataTime,
    this.compareMinTemperature,
    this.compareMaxTemperature,
    this.compareAveTemperature,
    this.imagePath,
  });

  factory NotificationDetailData.fromJson(Map<String, dynamic> json) {
    return NotificationDetailData(
      formattedDate: json['formattedDate'] as String?,
      dateData: json['dateData'] as String?,
      timeData: json['timeData'] as String?,
      areaName: json['areaName'] as String?,
      machineName: json['machineName'] as String?,
      componentValue: (json['componentValue'] as num?)?.toDouble(),
      warningEventName: json['warningEventName'] as String?,
      compareTypeObject: json['compareTypeObject'] != null
          ? CompareTypeObject.fromJson(json['compareTypeObject'])
          : null,
      compareResultObject: json['compareResultObject'] != null
          ? CompareResultObject.fromJson(json['compareResultObject'])
          : null,
      statusObject: json['statusObject'] != null
          ? StatusObject.fromJson(json['statusObject'])
          : null,
      id: json['id'] as String?,
      dataTime: json['dataTime'] as String?,
      compareValue: (json['compareValue'] as num?)?.toDouble(),
      deltaValue: (json['deltaValue'] as num?)?.toDouble(),
      monitorPointCode: json['monitorPointCode'] as String?,
      machineComponentName: json['machineComponentName'] as String?,
      resolveTime: json['resolveTime'] as String?,
      compareComponent: json['compareComponent'] as String?,
      compareMonitorPoint: json['compareMonitorPoint'] as String?,
      compareDataTime: json['compareDataTime'] as String?,
      compareMinTemperature: (json['compareMinTemperature'] as num?)
          ?.toDouble(),
      compareMaxTemperature: (json['compareMaxTemperature'] as num?)
          ?.toDouble(),
      compareAveTemperature: (json['compareAveTemperature'] as num?)
          ?.toDouble(),
      imagePath: json['imagePath'] as String?,
    );
  }
}

class CompareTypeObject {
  final int? id;
  final String? code;
  final String? name;

  CompareTypeObject({this.id, this.code, this.name});

  factory CompareTypeObject.fromJson(Map<String, dynamic> json) {
    return CompareTypeObject(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }
}

class CompareResultObject {
  final int? id;
  final String? code;
  final String? name;

  CompareResultObject({this.id, this.code, this.name});

  factory CompareResultObject.fromJson(Map<String, dynamic> json) {
    return CompareResultObject(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }
}

class StatusObject {
  final int? id;
  final String? code;
  final String? name;

  StatusObject({this.id, this.code, this.name});

  factory StatusObject.fromJson(Map<String, dynamic> json) {
    return StatusObject(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }
}
