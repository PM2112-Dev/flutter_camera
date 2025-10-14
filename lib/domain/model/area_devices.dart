class AreaDevicesResponse {
  final List<DeviceItem> devices;
  final List<dynamic> results;

  const AreaDevicesResponse({required this.devices, required this.results});
}

class DeviceItem {
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

  const DeviceItem({
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

  bool get isMachine => deviceType.toLowerCase() == 'machine';
  bool get isSensor => deviceType.toLowerCase() == 'sensor';
  bool get hasCamera => monitorPointIcon.toLowerCase() == 'camera';
}
