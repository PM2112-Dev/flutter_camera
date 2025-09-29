import 'package:dartz/dartz.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/camera_control_request.dart';
import 'package:flutter_camera/domain/model/camera_control_response.dart';
import 'package:flutter_camera/domain/model/camera_control_enums.dart';
import 'package:flutter_camera/domain/repositories/camera_control_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CameraControlUseCase {
  final CameraControlRepository _repository;

  CameraControlUseCase(this._repository);

  /// Send camera control command
  Future<Either<Failure, CameraControlResponse>> call(
    CameraControlRequest request,
  ) async {
    // Validation
    if (request.cameraId <= 0) {
      return const Left(ValidationFailure('Camera ID must be greater than 0'));
    }

    if (request.speed < 0 || request.speed > 7) {
      return const Left(ValidationFailure('Speed must be between 0 and 7'));
    }

    if (request.command < 0) {
      return const Left(ValidationFailure('Command must be non-negative'));
    }

    return _repository.controlCamera(request);
  }

  /// Send PTZ command with validation
  Future<Either<Failure, CameraControlResponse>> sendPTZCommand({
    required int cameraId,
    required CameraControlCommand command,
    required CameraControlSpeed speed,
  }) async {
    print(
      'UseCase: sendPTZCommand called with cameraId: $cameraId, command: ${command.description} (${command.value}), speed: ${speed.description} (${speed.value})',
    );

    if (cameraId <= 0) {
      print('UseCase: Validation failed - Camera ID must be greater than 0');
      return const Left(ValidationFailure('Camera ID must be greater than 0'));
    }

    return _repository.sendPTZCommand(
      cameraId: cameraId,
      command: command.value,
      speed: speed.value,
    );
  }

  /// Stop PTZ movement
  Future<Either<Failure, CameraControlResponse>> stopPTZ({
    required int cameraId,
  }) async {
    if (cameraId <= 0) {
      return const Left(ValidationFailure('Camera ID must be greater than 0'));
    }

    return _repository.stopPTZ(cameraId: cameraId);
  }

  /// Set camera preset
  Future<Either<Failure, CameraControlResponse>> setPreset({
    required int cameraId,
    required int presetNumber,
  }) async {
    if (cameraId <= 0) {
      return const Left(ValidationFailure('Camera ID must be greater than 0'));
    }

    if (presetNumber < 1 || presetNumber > 3) {
      return const Left(
        ValidationFailure('Preset number must be between 1 and 3'),
      );
    }

    return _repository.setPreset(
      cameraId: cameraId,
      presetNumber: presetNumber,
    );
  }

  /// Go to camera preset
  Future<Either<Failure, CameraControlResponse>> gotoPreset({
    required int cameraId,
    required int presetNumber,
  }) async {
    if (cameraId <= 0) {
      return const Left(ValidationFailure('Camera ID must be greater than 0'));
    }

    if (presetNumber < 1 || presetNumber > 3) {
      return const Left(
        ValidationFailure('Preset number must be between 1 and 3'),
      );
    }

    return _repository.gotoPreset(
      cameraId: cameraId,
      presetNumber: presetNumber,
    );
  }
}
