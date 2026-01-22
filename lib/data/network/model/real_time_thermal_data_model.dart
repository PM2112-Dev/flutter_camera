import 'package:flutter_camera/domain/model/real_time_thermal_data.dart';

class RealTimeThermalDataResponseModel {
  final Map<String, List<ThermalDataItemModel>> data;

  const RealTimeThermalDataResponseModel({required this.data});

  factory RealTimeThermalDataResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<ThermalDataItemModel>> parsedData = {};

    json.forEach((key, value) {
      if (value is List) {
        parsedData[key] = value
            .map((item) => ThermalDataItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    });

    return RealTimeThermalDataResponseModel(data: parsedData);
  }

  Map<String, dynamic> toJson() {
    return data.map((key, value) => MapEntry(key, value.map((item) => item.toJson()).toList()));
  }

  RealTimeThermalDataResponse toEntity() {
    return RealTimeThermalDataResponse(
      data: data.map((key, value) => MapEntry(key, value.map((item) => item.toEntity()).toList())),
    );
  }
}

class ThermalDataItemModel {
  final String dateData;
  final String timeData;
  final String? areaName;
  final String? machineName;
  final double temperature;
  final Map<String, ThermalDataResultModel> dicThermalDataResults;
  final String dataSourceType;
  final double minTemperature;
  final double maxTemperature;
  final double aveTemperature;
  final String machineComponentName;
  final String monitorPointCode;
  final int orderNumber;
  final String? imageData;

  const ThermalDataItemModel({
    required this.dateData,
    required this.timeData,
    this.areaName,
    this.machineName,
    required this.temperature,
    required this.dicThermalDataResults,
    required this.dataSourceType,
    required this.minTemperature,
    required this.maxTemperature,
    required this.aveTemperature,
    required this.machineComponentName,
    required this.monitorPointCode,
    required this.orderNumber,
    this.imageData,
  });

  factory ThermalDataItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, ThermalDataResultModel> results = {};
    final resultsJson = json['dicThermalDataResults'] as Map<String, dynamic>?;

    if (resultsJson != null) {
      resultsJson.forEach((key, value) {
        results[key] = ThermalDataResultModel.fromJson(value as Map<String, dynamic>);
      });
    }

    return ThermalDataItemModel(
      dateData: json['dateData']?.toString() ?? '',
      timeData: json['timeData']?.toString() ?? '',
      areaName: json['areaName']?.toString(),
      machineName: json['machineName']?.toString(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      dicThermalDataResults: results,
      dataSourceType: json['dataSourceType']?.toString() ?? '',
      minTemperature: (json['minTemperature'] as num?)?.toDouble() ?? 0.0,
      maxTemperature: (json['maxTemperature'] as num?)?.toDouble() ?? 0.0,
      aveTemperature: (json['aveTemperature'] as num?)?.toDouble() ?? 0.0,
      machineComponentName: json['machineComponentName']?.toString() ?? '',
      monitorPointCode: json['monitorPointCode']?.toString() ?? '',
      orderNumber: json['orderNumber'] as int? ?? 0,
      imageData: json['imageData']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateData': dateData,
      'timeData': timeData,
      'areaName': areaName,
      'machineName': machineName,
      'temperature': temperature,
      'dicThermalDataResults': dicThermalDataResults.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'dataSourceType': dataSourceType,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'aveTemperature': aveTemperature,
      'machineComponentName': machineComponentName,
      'monitorPointCode': monitorPointCode,
      'orderNumber': orderNumber,
      'imageData': imageData,
    };
  }

  ThermalDataItem toEntity() {
    return ThermalDataItem(
      dateData: dateData,
      timeData: timeData,
      areaName: areaName,
      machineName: machineName,
      temperature: temperature,
      dicThermalDataResults: dicThermalDataResults.map(
        (key, value) => MapEntry(key, value.toEntity()),
      ),
      dataSourceType: dataSourceType,
      minTemperature: minTemperature,
      maxTemperature: maxTemperature,
      aveTemperature: aveTemperature,
      machineComponentName: machineComponentName,
      monitorPointCode: monitorPointCode,
      orderNumber: orderNumber,
      imageData: imageData,
    );
  }
}

class ThermalDataResultModel {
  final double compareValue;
  final double deltaValue;
  final String? compareComponent;
  final String? compareMonitorPoint;
  final String? compareDataTime;
  final double? compareMinTemperature;
  final double? compareMaxTemperature;
  final double? compareAveTemperature;
  final CompareTypeObjectModel compareTypeObject;
  final CompareResultObjectModel compareResultObject;
  final ComparationThermalDataModel? comparationThermalData;

  const ThermalDataResultModel({
    required this.compareValue,
    required this.deltaValue,
    this.compareComponent,
    this.compareMonitorPoint,
    this.compareDataTime,
    this.compareMinTemperature,
    this.compareMaxTemperature,
    this.compareAveTemperature,
    required this.compareTypeObject,
    required this.compareResultObject,
    this.comparationThermalData,
  });

  factory ThermalDataResultModel.fromJson(Map<String, dynamic> json) {
    return ThermalDataResultModel(
      compareValue: (json['compareValue'] as num?)?.toDouble() ?? 0.0,
      deltaValue: (json['deltaValue'] as num?)?.toDouble() ?? 0.0,
      compareComponent: json['compareComponent']?.toString(),
      compareMonitorPoint: json['compareMonitorPoint']?.toString(),
      compareDataTime: json['compareDataTime']?.toString(),
      compareMinTemperature: (json['compareMinTemperature'] as num?)?.toDouble(),
      compareMaxTemperature: (json['compareMaxTemperature'] as num?)?.toDouble(),
      compareAveTemperature: (json['compareAveTemperature'] as num?)?.toDouble(),
      compareTypeObject: CompareTypeObjectModel.fromJson(
        json['compareTypeObject'] as Map<String, dynamic>,
      ),
      compareResultObject: CompareResultObjectModel.fromJson(
        json['compareResultObject'] as Map<String, dynamic>,
      ),
      comparationThermalData: json['comparationThermalData'] != null
          ? ComparationThermalDataModel.fromJson(
              json['comparationThermalData'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'compareValue': compareValue,
      'deltaValue': deltaValue,
      'compareComponent': compareComponent,
      'compareMonitorPoint': compareMonitorPoint,
      'compareDataTime': compareDataTime,
      'compareMinTemperature': compareMinTemperature,
      'compareMaxTemperature': compareMaxTemperature,
      'compareAveTemperature': compareAveTemperature,
      'compareTypeObject': compareTypeObject.toJson(),
      'compareResultObject': compareResultObject.toJson(),
      'comparationThermalData': comparationThermalData?.toJson(),
    };
  }

  ThermalDataResult toEntity() {
    return ThermalDataResult(
      compareValue: compareValue,
      deltaValue: deltaValue,
      compareComponent: compareComponent,
      compareMonitorPoint: compareMonitorPoint,
      compareDataTime: compareDataTime,
      compareMinTemperature: compareMinTemperature,
      compareMaxTemperature: compareMaxTemperature,
      compareAveTemperature: compareAveTemperature,
      compareTypeObject: compareTypeObject.toEntity(),
      compareResultObject: compareResultObject.toEntity(),
      comparationThermalData: comparationThermalData?.toEntity(),
    );
  }
}

class CompareTypeObjectModel {
  final int id;
  final String code;
  final String name;

  const CompareTypeObjectModel({required this.id, required this.code, required this.name});

  factory CompareTypeObjectModel.fromJson(Map<String, dynamic> json) {
    return CompareTypeObjectModel(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }

  CompareTypeObject toEntity() {
    return CompareTypeObject(id: id, code: code, name: name);
  }
}

class CompareResultObjectModel {
  final int id;
  final String code;
  final String name;

  const CompareResultObjectModel({required this.id, required this.code, required this.name});

  factory CompareResultObjectModel.fromJson(Map<String, dynamic> json) {
    return CompareResultObjectModel(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }

  CompareResultObject toEntity() {
    return CompareResultObject(id: id, code: code, name: name);
  }
}

class ComparationThermalDataModel {
  final String comparationType;
  final String comparationComponentName;
  final double minTemperature;
  final double maxTemperature;
  final double aveTemperature;
  final String comparationDataTime;

  const ComparationThermalDataModel({
    required this.comparationType,
    required this.comparationComponentName,
    required this.minTemperature,
    required this.maxTemperature,
    required this.aveTemperature,
    required this.comparationDataTime,
  });

  factory ComparationThermalDataModel.fromJson(Map<String, dynamic> json) {
    return ComparationThermalDataModel(
      comparationType: json['comparationType']?.toString() ?? '',
      comparationComponentName: json['comparationComponentName']?.toString() ?? '',
      minTemperature: (json['minTemperature'] as num?)?.toDouble() ?? 0.0,
      maxTemperature: (json['maxTemperature'] as num?)?.toDouble() ?? 0.0,
      aveTemperature: (json['aveTemperature'] as num?)?.toDouble() ?? 0.0,
      comparationDataTime: json['comparationDataTime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comparationType': comparationType,
      'comparationComponentName': comparationComponentName,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'aveTemperature': aveTemperature,
      'comparationDataTime': comparationDataTime,
    };
  }

  ComparationThermalData toEntity() {
    return ComparationThermalData(
      comparationType: comparationType,
      comparationComponentName: comparationComponentName,
      minTemperature: minTemperature,
      maxTemperature: maxTemperature,
      aveTemperature: aveTemperature,
      comparationDataTime: comparationDataTime,
    );
  }
} 
