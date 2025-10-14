import 'package:equatable/equatable.dart';
import 'package:flutter_camera/domain/model/real_time_thermal_data.dart';

abstract class RealTimeThermalState extends Equatable {
  const RealTimeThermalState();

  @override
  List<Object?> get props => [];
}

class RealTimeThermalInitial extends RealTimeThermalState {}

class RealTimeThermalLoading extends RealTimeThermalState {}

class RealTimeThermalLoaded extends RealTimeThermalState {
  final RealTimeThermalDataResponse data;

  const RealTimeThermalLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class RealTimeThermalError extends RealTimeThermalState {
  final String message;

  const RealTimeThermalError({required this.message});

  @override
  List<Object?> get props => [message];
}
