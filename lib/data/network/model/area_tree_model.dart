import 'package:flutter_camera/data/network/model/camera_model.dart';
import 'package:flutter_camera/domain/model/area_tree.dart';

class AreaTreeModel {
  final String uniqueId;
  final int? parentId;
  final String mapType;
  final String? photoPath;
  final double longitude;
  final double latitude;
  final int zoom;
  final String? note;
  final String? levelName;
  final List<AreaTreeModel> children;
  final String? mapTypeObject;
  final String status;
  final String displayStatus;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? statusObject;
  final String code;
  final String name;
  final int id;

  const AreaTreeModel({
    required this.uniqueId,
    required this.parentId,
    required this.mapType,
    required this.photoPath,
    required this.longitude,
    required this.latitude,
    required this.zoom,
    required this.note,
    required this.levelName,
    required this.children,
    required this.mapTypeObject,
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

  factory AreaTreeModel.fromJson(Map<String, dynamic> json) {
    return AreaTreeModel(
      uniqueId: json['uniqueId']?.toString() ?? '',
      parentId: json['parentId'] as int?,
      mapType: json['mapType']?.toString() ?? '',
      photoPath: json['photoPath']?.toString(),
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : 0.0,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : 0.0,
      zoom: json['zoom'] as int? ?? 1,
      note: json['note']?.toString(),
      levelName: json['levelName']?.toString(),
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => AreaTreeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mapTypeObject: json['mapTypeObject']?.toString(),
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
      'parentId': parentId,
      'mapType': mapType,
      'photoPath': photoPath,
      'longitude': longitude,
      'latitude': latitude,
      'zoom': zoom,
      'note': note,
      'levelName': levelName,
      'children': children.map((e) => e.toJson()).toList(),
      'mapTypeObject': mapTypeObject,
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

class AreaTreeWithCamerasModel {
  final String uniqueId;
  final int? parentId;
  final String mapType;
  final String? photoPath;
  final double longitude;
  final double latitude;
  final int zoom;
  final String? note;
  final String? levelName;
  final List<AreaTreeWithCamerasModel> children;
  final List<CameraModel> cameras;
  final String? mapTypeObject;
  final String status;
  final String displayStatus;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? statusObject;
  final String code;
  final String name;
  final int id;

  const AreaTreeWithCamerasModel({
    required this.uniqueId,
    required this.parentId,
    required this.mapType,
    required this.photoPath,
    required this.longitude,
    required this.latitude,
    required this.zoom,
    required this.note,
    required this.levelName,
    required this.children,
    required this.cameras,
    required this.mapTypeObject,
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

  factory AreaTreeWithCamerasModel.fromJson(Map<String, dynamic> json) {
    // Separate cameras from areas in children
    List<AreaTreeWithCamerasModel> childAreas = [];
    List<CameraModel> cameras = [];

    // First check if cameras is a direct field
    if (json.containsKey('cameras') && json['cameras'] is List) {
      final camerasList = json['cameras'] as List<dynamic>;
      for (var camera in camerasList) {
        try {
          cameras.add(CameraModel.fromJson(camera as Map<String, dynamic>));
        } catch (e) {
          print('Error parsing camera: $e');
        }
      }
    }

    // Then process children for both areas and cameras
    final children = json['children'] as List<dynamic>? ?? [];

    for (var child in children) {
      final childMap = child as Map<String, dynamic>;

      // Check if this child is a camera (has areaId and cameraType) or an area
      if (childMap.containsKey('areaId') &&
          childMap.containsKey('cameraType')) {
        // This is a camera
        try {
          cameras.add(CameraModel.fromJson(childMap));
        } catch (e) {
          print('Error parsing camera from children: $e');
        }
      } else {
        // This is an area
        try {
          childAreas.add(AreaTreeWithCamerasModel.fromJson(childMap));
        } catch (e) {
          print('Error parsing child area: $e');
        }
      }
    }

    return AreaTreeWithCamerasModel(
      uniqueId: json['uniqueId']?.toString() ?? '',
      parentId: json['parentId'] as int?,
      mapType: json['mapType']?.toString() ?? '',
      photoPath: json['photoPath']?.toString(),
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : 0.0,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : 0.0,
      zoom: json['zoom'] as int? ?? 1,
      note: json['note']?.toString(),
      levelName: json['levelName']?.toString(),
      children: childAreas,
      cameras: cameras,
      mapTypeObject: json['mapTypeObject']?.toString(),
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
      'parentId': parentId,
      'mapType': mapType,
      'photoPath': photoPath,
      'longitude': longitude,
      'latitude': latitude,
      'zoom': zoom,
      'note': note,
      'levelName': levelName,
      'children': children.map((e) => e.toJson()).toList(),
      'cameras': cameras.map((e) => e.toJson()).toList(),
      'mapTypeObject': mapTypeObject,
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

extension AreaTreeModelExtension on AreaTreeModel {
  AreaTree toEntity() {
    return AreaTree(
      uniqueId: uniqueId,
      parentId: parentId,
      mapType: mapType,
      photoPath: photoPath,
      longitude: longitude,
      latitude: latitude,
      zoom: zoom,
      note: note,
      levelName: levelName,
      children: children.map((e) => e.toEntity()).toList(),
      mapTypeObject: mapTypeObject,
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

extension AreaTreeWithCamerasModelExtension on AreaTreeWithCamerasModel {
  AreaTreeWithCameras toEntity() {
    return AreaTreeWithCameras(
      uniqueId: uniqueId,
      parentId: parentId,
      mapType: mapType,
      photoPath: photoPath,
      longitude: longitude,
      latitude: latitude,
      zoom: zoom,
      note: note,
      levelName: levelName,
      children: children.map((e) => e.toEntity()).toList(),
      cameras: cameras.map((e) => e.toEntity()).toList(),
      mapTypeObject: mapTypeObject,
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

extension AreaTreeExtension on AreaTree {
  AreaTreeModel toModel() {
    return AreaTreeModel(
      uniqueId: uniqueId,
      parentId: parentId,
      mapType: mapType,
      photoPath: photoPath,
      longitude: longitude,
      latitude: latitude,
      zoom: zoom,
      note: note,
      levelName: levelName,
      children: children.map((e) => e.toModel()).toList(),
      mapTypeObject: mapTypeObject,
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

extension AreaTreeWithCamerasExtension on AreaTreeWithCameras {
  AreaTreeWithCamerasModel toModel() {
    return AreaTreeWithCamerasModel(
      uniqueId: uniqueId,
      parentId: parentId,
      mapType: mapType,
      photoPath: photoPath,
      longitude: longitude,
      latitude: latitude,
      zoom: zoom,
      note: note,
      levelName: levelName,
      children: children.map((e) => e.toModel()).toList(),
      cameras: cameras.map((e) => e.toModel()).toList(),
      mapTypeObject: mapTypeObject,
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
