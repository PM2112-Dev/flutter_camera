import 'package:dartz/dartz.dart';
import 'package:flutter_camera/data/network/api/camera_control_api_service.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/camera_control_request.dart';
import 'package:flutter_camera/domain/model/camera_control_response.dart';
import 'package:flutter_camera/domain/model/camera_control_enums.dart';
import 'package:flutter_camera/domain/repositories/camera_control_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CameraControlRepository)
class CameraControlRepositoryImpl implements CameraControlRepository {
  final CameraControlApiService _apiService;

  CameraControlRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, CameraControlResponse>> controlCamera(
    CameraControlRequest request,
  ) async {
    try {
      final response = await _apiService.controlCamera(request: request);

      if (response.isSuccess && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(
          ServerFailure(
            message: response.message ?? 'Camera control failed',
            code: response.code,
          ),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Camera control error: ${e.toString()}',
          code: 'UNKNOWN',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, CameraControlResponse>> sendPTZCommand({
    required int cameraId,
    required int command,
    required int speed,
  }) async {
    print(
      'Repository: sendPTZCommand called with cameraId: $cameraId, command: $command, speed: $speed',
    );

    final request = CameraControlRequest(
      cameraId: cameraId,
      speed: speed,
      command: command,
    );

    print('Repository: Created request: ${request.toJson()}');
    return controlCamera(request);
  }

  @override
  Future<Either<Failure, CameraControlResponse>> stopPTZ({
    required int cameraId,
  }) async {
    final request = CameraControlRequest(
      cameraId: cameraId,
      speed: 0,
      command: CameraControlCommand.stop.value,
    );

    return controlCamera(request);
  }

  @override
  Future<Either<Failure, CameraControlResponse>> setPreset({
    required int cameraId,
    required int presetNumber,
  }) async {
    int command;
    switch (presetNumber) {
      case 1:
        command = CameraControlCommand.setPreset1.value;
        break;
      case 2:
        command = CameraControlCommand.setPreset2.value;
        break;
      case 3:
        command = CameraControlCommand.setPreset3.value;
        break;
      default:
        return Left(
          ValidationFailure(
            'Invalid preset number: $presetNumber. Must be 1, 2, or 3.',
          ),
        );
    }

    final request = CameraControlRequest(
      cameraId: cameraId,
      speed: CameraControlSpeed.medium.value,
      command: command,
    );

    return controlCamera(request);
  }

  @override
  Future<Either<Failure, CameraControlResponse>> gotoPreset({
    required int cameraId,
    required int presetNumber,
  }) async {
    int command;
    switch (presetNumber) {
      case 1:
        command = CameraControlCommand.gotoPreset1.value;
        break;
      case 2:
        command = CameraControlCommand.gotoPreset2.value;
        break;
      case 3:
        command = CameraControlCommand.gotoPreset3.value;
        break;
      default:
        return Left(
          ValidationFailure(
            'Invalid preset number: $presetNumber. Must be 1, 2, or 3.',
          ),
        );
    }

    final request = CameraControlRequest(
      cameraId: cameraId,
      speed: CameraControlSpeed.medium.value,
      command: command,
    );

    return controlCamera(request);
  }
}
