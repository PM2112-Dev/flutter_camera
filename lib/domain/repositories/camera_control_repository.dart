import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/camera_control_request.dart';
import 'package:flutter_camera/domain/model/camera_control_response.dart';

abstract class CameraControlRepository {
  /// Send control command to camera
  ///
  /// [request] Camera control request with cameraId, speed, and command
  /// Returns [CameraControlResponse] on success or [Failure] on error
  Future<Either<Failure, CameraControlResponse>> controlCamera(
    CameraControlRequest request,
  );

  /// Send PTZ control command to camera
  ///
  /// [cameraId] ID of the camera to control
  /// [command] PTZ command (up, down, left, right, zoom in/out, etc.)
  /// [speed] Control speed (1-7, where 1=slow, 7=fast)
  /// Returns [CameraControlResponse] on success or [Failure] on error
  Future<Either<Failure, CameraControlResponse>> sendPTZCommand({
    required int cameraId,
    required int command,
    required int speed,
  });

  /// Stop current PTZ movement
  ///
  /// [cameraId] ID of the camera to stop
  /// Returns [CameraControlResponse] on success or [Failure] on error
  Future<Either<Failure, CameraControlResponse>> stopPTZ({
    required int cameraId,
  });

  /// Set camera to preset position
  ///
  /// [cameraId] ID of the camera
  /// [presetNumber] Preset number (1-3)
  /// Returns [CameraControlResponse] on success or [Failure] on error
  Future<Either<Failure, CameraControlResponse>> setPreset({
    required int cameraId,
    required int presetNumber,
  });

  /// Go to preset position
  ///
  /// [cameraId] ID of the camera
  /// [presetNumber] Preset number (1-3)
  /// Returns [CameraControlResponse] on success or [Failure] on error
  Future<Either<Failure, CameraControlResponse>> gotoPreset({
    required int cameraId,
    required int presetNumber,
  });
}
