import 'package:flutter_camera/domain/model/area_map.dart';

class AreaMapResponseModel {
  final List<dynamic> machines; // item1
  final List<AreaMapItemModel> areas; // item2

  const AreaMapResponseModel({required this.machines, required this.areas});

  factory AreaMapResponseModel.fromJson(Map<String, dynamic> json) {
    return AreaMapResponseModel(
      machines: json['item1'] as List<dynamic>? ?? [],
      areas:
          (json['item2'] as List<dynamic>?)
              ?.map((e) => AreaMapItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'item1': machines, 'item2': areas.map((e) => e.toJson()).toList()};
  }
}

class AreaMapItemModel {
  final String? uniqueId;
  final int? parentId;
  final String? mapType; // "Map" or "Picture"
  final String? photoPath;
  final double? longitude;
  final double? latitude;
  final int? zoom;
  final String? note;
  final String? levelName;
  final List<dynamic> children;
  final String? status;
  final String? displayStatus;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? code;
  final String name;
  final int id;

  const AreaMapItemModel({
    this.uniqueId,
    this.parentId,
    this.mapType,
    this.photoPath,
    this.longitude,
    this.latitude,
    this.zoom,
    this.note,
    this.levelName,
    required this.children,
    this.status,
    this.displayStatus,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.code,
    required this.name,
    required this.id,
  });

  factory AreaMapItemModel.fromJson(Map<String, dynamic> json) {
    return AreaMapItemModel(
      uniqueId: json['uniqueId']?.toString(),
      parentId: json['parentId'] as int?,
      mapType: json['mapType']?.toString(),
      photoPath: json['photoPath']?.toString(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      zoom: json['zoom'] as int?,
      note: json['note']?.toString(),
      levelName: json['levelName']?.toString(),
      children: json['children'] as List<dynamic>? ?? [],
      status: json['status']?.toString(),
      displayStatus: json['displayStatus']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      deletedAt: json['deletedAt']?.toString(),
      code: json['code']?.toString(),
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
      'children': children,
      'status': status,
      'displayStatus': displayStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'code': code,
      'name': name,
      'id': id,
    };
  }

  bool get isMap => mapType?.toLowerCase() == 'map';
  bool get isPicture => mapType?.toLowerCase() == 'picture';
  bool get hasValidCoordinates => longitude != null && latitude != null;
}

// Extension to convert Model to Entity
extension AreaMapItemModelExtension on AreaMapItemModel {
  AreaMapItem toEntity() {
    return AreaMapItem(
      uniqueId: uniqueId,
      parentId: parentId,
      mapType: mapType,
      photoPath: photoPath,
      longitude: longitude,
      latitude: latitude,
      zoom: zoom,
      note: note,
      levelName: levelName,
      children: children,
      status: status,
      displayStatus: displayStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      code: code,
      name: name,
      id: id,
    );
  }
}

extension AreaMapResponseModelExtension on AreaMapResponseModel {
  AreaMapResponse toEntity() {
    return AreaMapResponse(machines: machines, areas: areas.map((e) => e.toEntity()).toList());
  }
}
