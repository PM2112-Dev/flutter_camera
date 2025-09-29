import 'package:flutter_camera/domain/model/camera.dart';

import 'area_model.dart';

class CameraModel {
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
  final AreaModel area;
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

  const CameraModel({
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

  factory CameraModel.fromJson(Map<String, dynamic> json) {
    return CameraModel(
      uniqueId: json['uniqueId']?.toString() ?? '',
      areaId: json['areaId'] as int?,
      cameraType: json['cameraType']?.toString() ?? '',
      cameraLink: json['cameraLink']?.toString() ?? '',
      lanIpAddress: json['lanIpAddress']?.toString() ?? '',
      wanIpAddress: json['wanIpAddress']?.toString() ?? '',
      observationAngle: json['observationAngle'] != null ? (json['observationAngle'] as num).toDouble() : null,
      observationArea: json['observationArea'] != null ? (json['observationArea'] as num).toDouble() : null,
      frequency: json['frequency'] as int? ?? 0,
      integratedCamId: json['integratedCamId'] as int?,
      deviceStatus: json['deviceStatus']?.toString() ?? 'offline',
      brand: json['brand']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      ptzType: json['ptzType']?.toString() ?? '',
      isPined: json['isPined'] as bool? ?? false,
      area: json['area'] != null ? AreaModel.fromJson(json['area'] as Map<String, dynamic>) : AreaModel.empty(),
      integratedCam: json['integratedCam']?.toString(),
      presets: json['presets'] as List<dynamic>? ?? [],
      cameraTypeObject: json['cameraTypeObject']?.toString(),
      deviceStatusObject: json['deviceStatusObject']?.toString(),
      brandObject: json['brandObject']?.toString(),
      ptzTypeObject: json['ptzTypeObject']?.toString(),
      status: json['status']?.toString() ?? 'inactive',
      displayStatus: json['displayStatus']?.toString() ?? 'Inactive',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString(),
      deletedAt: json['deletedAt']?.toString(),
      statusObject: json['statusObject']?.toString(),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      id: json['id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniqueId': uniqueId,
      'areaId': areaId,
      'cameraType': cameraType,
      'cameraLink': cameraLink,
      'lanIpAddress': lanIpAddress,
      'wanIpAddress': wanIpAddress,
      'observationAngle': observationAngle,
      'observationArea': observationArea,
      'frequency': frequency,
      'integratedCamId': integratedCamId,
      'deviceStatus': deviceStatus,
      'brand': brand,
      'username': username,
      'password': password,
      'ptzType': ptzType,
      'isPined': isPined,
      'area': area.toJson(),
      'integratedCam': integratedCam,
      'presets': presets,
      'cameraTypeObject': cameraTypeObject,
      'deviceStatusObject': deviceStatusObject,
      'brandObject': brandObject,
      'ptzTypeObject': ptzTypeObject,
      'status': status,
      'displayStatus': displayStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'statusObject': statusObject,
      'code': code,
      'name': name,
      'id': id,
    };
  }
}

extension CameraModelExtension on CameraModel {
  Camera toEntity() {
    return Camera(
      uniqueId: uniqueId,
      areaId: areaId,
      cameraType: cameraType,
      cameraLink: cameraLink,
      lanIpAddress: lanIpAddress,
      wanIpAddress: wanIpAddress,
      observationAngle: observationAngle,
      observationArea: observationArea,
      frequency: frequency,
      integratedCamId: integratedCamId,
      deviceStatus: deviceStatus,
      brand: brand,
      username: username,
      password: password,
      ptzType: ptzType,
      isPined: isPined,
      area: area.toEntity(),
      integratedCam: integratedCam,
      presets: presets,
      cameraTypeObject: cameraTypeObject,
      deviceStatusObject: deviceStatusObject,
      brandObject: brandObject,
      ptzTypeObject: ptzTypeObject,
      status: status,
      displayStatus: displayStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      statusObject: statusObject,
      code: code,
      name: name,
      id: id,
    );
  }
}

extension CameraExtension on Camera {
  CameraModel toModel() {
    return CameraModel(
      uniqueId: uniqueId,
      areaId: areaId,
      cameraType: cameraType,
      cameraLink: cameraLink,
      lanIpAddress: lanIpAddress,
      wanIpAddress: wanIpAddress,
      observationAngle: observationAngle,
      observationArea: observationArea,
      frequency: frequency,
      integratedCamId: integratedCamId,
      deviceStatus: deviceStatus,
      brand: brand,
      username: username,
      password: password,
      ptzType: ptzType,
      isPined: isPined,
      area: area.toModel(),
      integratedCam: integratedCam,
      presets: presets,
      cameraTypeObject: cameraTypeObject,
      deviceStatusObject: deviceStatusObject,
      brandObject: brandObject,
      ptzTypeObject: ptzTypeObject,
      status: status,
      displayStatus: displayStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      statusObject: statusObject,
      code: code,
      name: name,
      id: id,
    );
  }
}
