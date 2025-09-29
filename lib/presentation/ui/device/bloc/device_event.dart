import 'package:equatable/equatable.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class DeviceLoadEvent extends DeviceEvent {
  const DeviceLoadEvent();
}

class DeviceStartedEvent extends DeviceEvent {
  const DeviceStartedEvent();
}