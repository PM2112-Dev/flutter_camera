import 'package:flutter_camera/domain/model/area_devices.dart';

abstract class AreaDevicesState {
  const AreaDevicesState();
}

/// Initial state
class AreaDevicesInitial extends AreaDevicesState {
  const AreaDevicesInitial();

  @override
  String toString() => 'AreaDevicesInitial()';
}

/// Loading state
class AreaDevicesLoading extends AreaDevicesState {
  final String? message;

  const AreaDevicesLoading({this.message});

  @override
  String toString() => 'AreaDevicesLoading(message: $message)';
}

/// Loaded state with data
class AreaDevicesLoaded extends AreaDevicesState {
  final List<DeviceItem> devices;
  final String? message;

  const AreaDevicesLoaded({required this.devices, this.message});

  @override
  String toString() => 'AreaDevicesLoaded(devices: ${devices.length}, message: $message)';
}

/// Error state
class AreaDevicesError extends AreaDevicesState {
  final String message;
  final String? code;

  const AreaDevicesError({required this.message, this.code});

  @override
  String toString() => 'AreaDevicesError(message: $message, code: $code)';
}
