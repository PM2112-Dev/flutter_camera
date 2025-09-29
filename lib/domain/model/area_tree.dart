import 'camera.dart';

class AreaTree {
  final String uniqueId;
  final int? parentId;
  final String mapType;
  final String? photoPath;
  final double longitude;
  final double latitude;
  final int zoom;
  final String? note;
  final String? levelName;
  final List<AreaTree> children;
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

  const AreaTree({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AreaTree && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class AreaTreeWithCameras {
  final String uniqueId;
  final int? parentId;
  final String mapType;
  final String? photoPath;
  final double longitude;
  final double latitude;
  final int zoom;
  final String? note;
  final String? levelName;
  final List<AreaTreeWithCameras> children;
  final List<Camera> cameras;
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

  const AreaTreeWithCameras({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AreaTreeWithCameras && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
