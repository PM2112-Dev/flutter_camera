import 'package:flutter_camera/domain/model/area_devices.dart';

class AreaDevicesResponseModel {
  final List<DeviceItemModel> devices; // item1
  final List<dynamic> results; // item2

  const AreaDevicesResponseModel({required this.devices, required this.results});

  factory AreaDevicesResponseModel.fromJson(Map<String, dynamic> json) {
    return AreaDevicesResponseModel(
      devices:
          (json['item1'] as List<dynamic>?)
              ?.map((e) => DeviceItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      results: json['item2'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'item1': devices.map((e) => e.toJson()).toList(), 'item2': results};
  }
}

// Model for Device/Machine in the diagram
class DeviceItemModel {
  final String key;
  final int machineId;
  final String deviceType; // "Machine" or "Sensor"
  final String deviceTypeName;
  final String monitorPointIcon; // "Camera" or "Sensor"
  final double longitude;
  final double latitude;
  final String level;
  final String code;
  final String name;
  final int id;

  const DeviceItemModel({
    required this.key,
    required this.machineId,
    required this.deviceType,
    required this.deviceTypeName,
    required this.monitorPointIcon,
    required this.longitude,
    required this.latitude,
    required this.level,
    required this.code,
    required this.name,
    required this.id,
  });

  factory DeviceItemModel.fromJson(Map<String, dynamic> json) {
    return DeviceItemModel(
      key: json['key']?.toString() ?? '',
      machineId: json['machineId'] as int? ?? 0,
      deviceType: json['deviceType']?.toString() ?? '',
      deviceTypeName: json['deviceTypeName']?.toString() ?? '',
      monitorPointIcon: json['monitorPointIcon']?.toString() ?? '',
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      level: json['level']?.toString() ?? 'Undefined',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      id: json['id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'machineId': machineId,
      'deviceType': deviceType,
      'deviceTypeName': deviceTypeName,
      'monitorPointIcon': monitorPointIcon,
      'longitude': longitude,
      'latitude': latitude,
      'level': level,
      'code': code,
      'name': name,
      'id': id,
    };
  }

  bool get isMachine => deviceType.toLowerCase() == 'machine';
  bool get isSensor => deviceType.toLowerCase() == 'sensor';
  bool get hasCamera => monitorPointIcon.toLowerCase() == 'camera';
}

// Extension to convert Model to Entity
extension DeviceItemModelExtension on DeviceItemModel {
  DeviceItem toEntity() {
    return DeviceItem(
      key: key,
      machineId: machineId,
      deviceType: deviceType,
      deviceTypeName: deviceTypeName,
      monitorPointIcon: monitorPointIcon,
      longitude: longitude,
      latitude: latitude,
      level: level,
      code: code,
      name: name,
      id: id,
    );
  }
}

extension AreaDevicesResponseModelExtension on AreaDevicesResponseModel {
  AreaDevicesResponse toEntity() {
    return AreaDevicesResponse(
      devices: devices.map((e) => e.toEntity()).toList(),
      results: results,
    );
  }
}
