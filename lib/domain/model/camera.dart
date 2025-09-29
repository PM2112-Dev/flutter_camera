import 'area.dart';

class Camera {
  final String uniqueId;
  final int? areaId;
  final String cameraType;
  final String cameraLink;
  final String lanIpAddress;
  final String wanIpAddress;
  final double? observationAngle;
  final double? observationArea;
  final int frequency;
  final int? integratedCamId;
  final String deviceStatus;
  final String brand;
  final String username;
  final String password;
  final String ptzType;
  final bool isPined;
  final Area area;
  final String? integratedCam;
  final List<dynamic> presets;
  final String? cameraTypeObject;
  final String? deviceStatusObject;
  final String? brandObject;
  final String? ptzTypeObject;
  final String status;
  final String displayStatus;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? statusObject;
  final String code;
  final String name;
  final int id;

  const Camera({
    required this.uniqueId,
    required this.areaId,
    required this.cameraType,
    required this.cameraLink,
    required this.lanIpAddress,
    required this.wanIpAddress,
    required this.observationAngle,
    required this.observationArea,
    required this.frequency,
    required this.integratedCamId,
    required this.deviceStatus,
    required this.brand,
    required this.username,
    required this.password,
    required this.ptzType,
    required this.isPined,
    required this.area,
    required this.integratedCam,
    required this.presets,
    required this.cameraTypeObject,
    required this.deviceStatusObject,
    required this.brandObject,
    required this.ptzTypeObject,
    required this.status,
    required this.displayStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.statusObject,
    required this.code,
    required this.name,
    required this.id,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Camera && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
