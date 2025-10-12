import 'package:flutter_camera/domain/model/area_map.dart';

abstract class AreaMapState {
  const AreaMapState();
}

/// Initial state
class AreaMapInitial extends AreaMapState {
  const AreaMapInitial();

  @override
  String toString() => 'AreaMapInitial()';
}

/// Loading state
class AreaMapLoading extends AreaMapState {
  final String? message;

  const AreaMapLoading({this.message});

  @override
  String toString() => 'AreaMapLoading(message: $message)';
}

/// Loaded state with data
class AreaMapLoaded extends AreaMapState {
  final AreaMapResponse data;
  final String? message;

  const AreaMapLoaded({required this.data, this.message});

  @override
  String toString() => 'AreaMapLoaded(areas: ${data.areas.length}, message: $message)';
}

/// Error state
class AreaMapError extends AreaMapState {
  final String message;
  final String? code;

  const AreaMapError({required this.message, this.code});

  @override
  String toString() => 'AreaMapError(message: $message, code: $code)';
}
