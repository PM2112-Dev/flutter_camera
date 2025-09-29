import 'package:flutter_camera/domain/model/area.dart';

class AreaModel {
  final String code;
  final String name;
  final int id;

  const AreaModel({
    required this.code,
    required this.name,
    required this.id,
  });

  const AreaModel.empty()
      : code = '',
        name = '',
        id = 0;

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      id: json['id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'id': id,
    };
  }
}

extension AreaModelExtension on AreaModel {
  Area toEntity() {
    return Area(
      code: code,
      name: name,
      id: id,
    );
  }
}

extension AreaExtension on Area {
  AreaModel toModel() {
    return AreaModel(
      code: code,
      name: name,
      id: id,
    );
  }
}
