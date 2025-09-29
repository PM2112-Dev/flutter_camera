import 'package:equatable/equatable.dart';
import 'package:flutter_camera/domain/model/area_tree.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {
  const DeviceInitial();
}

class DeviceStartedState extends DeviceState {
  final List<AreaTreeWithCameras> areaTrees;

  const DeviceStartedState(this.areaTrees);

  @override
  List<Object?> get props => [areaTrees];
}

class DeviceLoadingState extends DeviceState {
  const DeviceLoadingState();
}

class DeviceLoadedState extends DeviceState {
  const DeviceLoadedState();
}

class DeviceErrorState extends DeviceState {
  final String message;

  const DeviceErrorState(this.message);

  @override
  List<Object?> get props => [message];
}