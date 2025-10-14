class RealTimeThermalDataResponse {
  final Map<String, List<ThermalDataItem>> data;

  const RealTimeThermalDataResponse({required this.data});
}

class ThermalDataItem {
  final String dateData;
  final String timeData;
  final String? areaName;
  final String? machineName;
  final double temperature;
  final Map<String, ThermalDataResult> dicThermalDataResults;
  final String dataSourceType;
  final double minTemperature;
  final double maxTemperature;
  final double aveTemperature;
  final String machineComponentName;
  final String monitorPointCode;
  final int orderNumber;
  final String? imageData;

  const ThermalDataItem({
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
}

class ThermalDataResult {
  final double compareValue;
  final double deltaValue;
  final String? compareComponent;
  final String? compareMonitorPoint;
  final String? compareDataTime;
  final double? compareMinTemperature;
  final double? compareMaxTemperature;
  final double? compareAveTemperature;
  final CompareTypeObject compareTypeObject;
  final CompareResultObject compareResultObject;
  final ComparationThermalData? comparationThermalData;

  const ThermalDataResult({
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
}

class CompareTypeObject {
  final int id;
  final String code;
  final String name;

  const CompareTypeObject({required this.id, required this.code, required this.name});
}

class CompareResultObject {
  final int id;
  final String code;
  final String name;

  const CompareResultObject({required this.id, required this.code, required this.name});
}

class ComparationThermalData {
  final String comparationType;
  final String comparationComponentName;
  final double minTemperature;
  final double maxTemperature;
  final double aveTemperature;
  final String comparationDataTime;

  const ComparationThermalData({
    required this.comparationType,
    required this.comparationComponentName,
    required this.minTemperature,
    required this.maxTemperature,
    required this.aveTemperature,
    required this.comparationDataTime,
  });
}
