class AreaMapResponse {
  final List<dynamic> machines;
  final List<AreaMapItem> areas;

  const AreaMapResponse({required this.machines, required this.areas});
}

class AreaMapItem {
  final String? uniqueId;
  final int? parentId;
  final String? mapType;
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

  const AreaMapItem({
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

  bool get isMap => mapType?.toLowerCase() == 'map';
  bool get isPicture => mapType?.toLowerCase() == 'picture';
  bool get hasValidCoordinates => longitude != null && latitude != null;

  String get fullPhotoUrl {
    if (photoPath == null || photoPath!.isEmpty) return '';
    if (photoPath!.startsWith('http')) return photoPath!;
    // Assuming base URL, adjust as needed
    return 'https://thermal.infosysvietnam.com.vn:10253$photoPath';
  }
}
