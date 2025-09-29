import 'package:bloc/bloc.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/usecase/camera_control/camera_control_usecase.dart';
import 'package:injectable/injectable.dart';
import 'camera_control_event.dart';
import 'camera_control_state.dart';

@injectable
class CameraControlBloc extends Bloc<CameraControlEvent, CameraControlState> {
  final CameraControlUseCase _cameraControlUseCase;

  CameraControlBloc(this._cameraControlUseCase)
    : super(const CameraControlInitial()) {
    on<SendPTZCommand>(_onSendPTZCommand);
    on<SendControlCommand>(_onSendControlCommand);
    on<StopPTZCommand>(_onStopPTZCommand);
    on<SetPresetCommand>(_onSetPresetCommand);
    on<GotoPresetCommand>(_onGotoPresetCommand);
    on<ResetCameraControl>(_onResetCameraControl);
  }

  Future<void> _onSendPTZCommand(
    SendPTZCommand event,
    Emitter<CameraControlState> emit,
  ) async {
    emit(
      CameraControlLoading(message: 'Sending ${event.command.description}...'),
    );

    final result = await _cameraControlUseCase.sendPTZCommand(
      cameraId: event.cameraId,
      command: event.command,
      speed: event.speed,
    );

    print('PTZ Command Object: ${event.cameraId}, ${event.command}, ${event.speed.value}');

    result.fold(
      (failure) => emit(
        CameraControlError(
          message: failure.message,
          code: failure is ServerFailure ? failure.code : null,
        ),
      ),
      (response) {
        if (response.isSuccess) {
          emit(
            PTZMoving(
              direction: event.command.description,
              speed: event.speed.value,
            ),
          );
          emit(
            CameraControlSuccess(
              response: response,
              message: '${event.command.description} executed successfully',
            ),
          );
        } else {
          emit(
            CameraControlError(
              message: response.message ?? 'PTZ command failed',
              code: response.code,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSendControlCommand(
    SendControlCommand event,
    Emitter<CameraControlState> emit,
  ) async {
    emit(const CameraControlLoading(message: 'Sending command...'));

    final result = await _cameraControlUseCase.call(event.request);

    result.fold(
      (failure) => emit(
        CameraControlError(
          message: failure.message,
          code: failure is ServerFailure ? failure.code : null,
        ),
      ),
      (response) {
        if (response.isSuccess) {
          emit(
            CameraControlSuccess(
              response: response,
              message: 'Command executed successfully',
            ),
          );
        } else {
          emit(
            CameraControlError(
              message: response.message ?? 'Camera control failed',
              code: response.code,
            ),
          );
        }
      },
    );
  }

  Future<void> _onStopPTZCommand(
    StopPTZCommand event,
    Emitter<CameraControlState> emit,
  ) async {
    emit(const CameraControlLoading(message: 'Stopping PTZ...'));

    final result = await _cameraControlUseCase.stopPTZ(
      cameraId: event.cameraId,
    );

    result.fold(
      (failure) => emit(
        CameraControlError(
          message: failure.message,
          code: failure is ServerFailure ? failure.code : null,
        ),
      ),
      (response) {
        if (response.isSuccess) {
          emit(const PTZStopped());
          emit(
            CameraControlSuccess(
              response: response,
              message: 'PTZ stopped successfully',
            ),
          );
        } else {
          emit(
            CameraControlError(
              message: response.message ?? 'Stop PTZ failed',
              code: response.code,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSetPresetCommand(
    SetPresetCommand event,
    Emitter<CameraControlState> emit,
  ) async {
    emit(
      CameraControlLoading(message: 'Setting preset ${event.presetNumber}...'),
    );

    final result = await _cameraControlUseCase.setPreset(
      cameraId: event.cameraId,
      presetNumber: event.presetNumber,
    );

    result.fold(
      (failure) => emit(
        CameraControlError(
          message: failure.message,
          code: failure is ServerFailure ? failure.code : null,
        ),
      ),
      (response) {
        if (response.isSuccess) {
          emit(
            CameraControlSuccess(
              response: response,
              message: 'Preset ${event.presetNumber} set successfully',
            ),
          );
        } else {
          emit(
            CameraControlError(
              message: response.message ?? 'Set preset failed',
              code: response.code,
            ),
          );
        }
      },
    );
  }

  Future<void> _onGotoPresetCommand(
    GotoPresetCommand event,
    Emitter<CameraControlState> emit,
  ) async {
    emit(
      CameraControlLoading(message: 'Going to preset ${event.presetNumber}...'),
    );

    final result = await _cameraControlUseCase.gotoPreset(
      cameraId: event.cameraId,
      presetNumber: event.presetNumber,
    );

    result.fold(
      (failure) => emit(
        CameraControlError(
          message: failure.message,
          code: failure is ServerFailure ? failure.code : null,
        ),
      ),
      (response) {
        if (response.isSuccess) {
          emit(
            CameraControlSuccess(
              response: response,
              message: 'Moved to preset ${event.presetNumber} successfully',
            ),
          );
        } else {
          emit(
            CameraControlError(
              message: response.message ?? 'Go to preset failed',
              code: response.code,
            ),
          );
        }
      },
    );
  }

  Future<void> _onResetCameraControl(
    ResetCameraControl event,
    Emitter<CameraControlState> emit,
  ) async {
    emit(const CameraControlInitial());
  }
}
