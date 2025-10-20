abstract class AreaDevicesEvent {
  const AreaDevicesEvent();
}

/// Fetch devices by area ID
class FetchAreaDevices extends AreaDevicesEvent {
  final int areaId;

  const FetchAreaDevices({required this.areaId});

  @override
  String toString() => 'FetchAreaDevices(areaId: $areaId)';
}

/// Refresh devices by area ID
class RefreshAreaDevices extends AreaDevicesEvent {
  final int areaId;

  const RefreshAreaDevices({required this.areaId});

  @override
  String toString() => 'RefreshAreaDevices(areaId: $areaId)';
}
