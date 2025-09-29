import 'package:flutter_camera/domain/model/camera_control_response.dart';

abstract class CameraControlState {
  const CameraControlState();
}

/// Initial state
class CameraControlInitial extends CameraControlState {
  const CameraControlInitial();

  @override
  String toString() => 'CameraControlInitial()';
}

/// Loading state when sending command
class CameraControlLoading extends CameraControlState {
  final String? message;

  const CameraControlLoading({this.message});

  @override
  String toString() => 'CameraControlLoading(message: $message)';
}

/// Success state when command executed successfully
class CameraControlSuccess extends CameraControlState {
  final CameraControlResponse response;
  final String? message;

  const CameraControlSuccess({required this.response, this.message});

  @override
  String toString() =>
      'CameraControlSuccess(response: $response, message: $message)';
}

/// Error state when command failed
class CameraControlError extends CameraControlState {
  final String message;
  final String? code;

  const CameraControlError({required this.message, this.code});

  @override
  String toString() => 'CameraControlError(message: $message, code: $code)';
}

/// PTZ movement in progress
class PTZMoving extends CameraControlState {
  final String direction;
  final int speed;

  const PTZMoving({required this.direction, required this.speed});

  @override
  String toString() => 'PTZMoving(direction: $direction, speed: $speed)';
}

/// PTZ stopped
class PTZStopped extends CameraControlState {
  const PTZStopped();

  @override
  String toString() => 'PTZStopped()';
}
