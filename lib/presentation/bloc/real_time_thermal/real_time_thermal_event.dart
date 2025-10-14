import 'package:equatable/equatable.dart';

abstract class RealTimeThermalEvent extends Equatable {
  const RealTimeThermalEvent();

  @override
  List<Object?> get props => [];
}

class FetchRealTimeThermalData extends RealTimeThermalEvent {
  final int machineId;
  final int id;
  final String deviceType;

  const FetchRealTimeThermalData({
    required this.machineId,
    required this.id,
    required this.deviceType,
  });

  @override
  List<Object?> get props => [machineId, id, deviceType];
}

class RefreshRealTimeThermalData extends RealTimeThermalEvent {
  final int machineId;
  final int id;
  final String deviceType;

  const RefreshRealTimeThermalData({
    required this.machineId,
    required this.id,
    required this.deviceType,
  });

  @override
  List<Object?> get props => [machineId, id, deviceType];
}
