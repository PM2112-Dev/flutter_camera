class CommonEnumsResponse {
  final List<EnumItem> commonStatusList;
  final List<EnumItem> userStatusList;
  final List<EnumItem> mapTypeList;
  final List<EnumItem> deviceStatusList;
  final List<EnumItem> cameraTypeList;
  final List<EnumItem> monitorTypeList;
  final List<EnumItem> monitorPointTypeList;
  final List<EnumItem> temperatureLevelList;
  final List<EnumItem> notificationChannelTypeList;
  final List<EnumItem> notificationChannelStatusList;
  final List<EnumItem> notificationGroupStatusList;
  final List<EnumItem> thresholdTypeList;
  final List<EnumItem> cameraBrandList;
  final List<EnumItem> cameraPtzTypeList;
  final List<EnumItem> notificationStatusList;
  final List<EnumItem> modbusProtocolList;

  const CommonEnumsResponse({
    required this.commonStatusList,
    required this.userStatusList,
    required this.mapTypeList,
    required this.deviceStatusList,
    required this.cameraTypeList,
    required this.monitorTypeList,
    required this.monitorPointTypeList,
    required this.temperatureLevelList,
    required this.notificationChannelTypeList,
    required this.notificationChannelStatusList,
    required this.notificationGroupStatusList,
    required this.thresholdTypeList,
    required this.cameraBrandList,
    required this.cameraPtzTypeList,
    required this.notificationStatusList,
    required this.modbusProtocolList,
  });

  factory CommonEnumsResponse.fromJson(Map<String, dynamic> json) {
    return CommonEnumsResponse(
      commonStatusList:
          (json['commonStatusList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      userStatusList:
          (json['userStatusList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mapTypeList:
          (json['mapTypeList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deviceStatusList:
          (json['deviceStatusList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cameraTypeList:
          (json['cameraTypeList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      monitorTypeList:
          (json['monitorTypeList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      monitorPointTypeList:
          (json['monitorPointTypeList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      temperatureLevelList:
          (json['temperatureLevelList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notificationChannelTypeList:
          (json['notificationChannelTypeList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notificationChannelStatusList:
          (json['notificationChannelStatusList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notificationGroupStatusList:
          (json['notificationGroupStatusList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      thresholdTypeList:
          (json['thresholdTypeList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cameraBrandList:
          (json['cameraBrandList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cameraPtzTypeList:
          (json['cameraPtzTypeList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notificationStatusList:
          (json['notificationStatusList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      modbusProtocolList:
          (json['modbusProtocolList'] as List?)
              ?.map((e) => EnumItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class EnumItem {
  final int id;
  final String code;
  final String name;

  const EnumItem({required this.id, required this.code, required this.name});

  factory EnumItem.fromJson(Map<String, dynamic> json) {
    return EnumItem(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }
}
