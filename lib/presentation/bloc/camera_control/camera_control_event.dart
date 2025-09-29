import 'package:flutter_camera/domain/model/camera_control_enums.dart';
import 'package:flutter_camera/domain/model/camera_control_request.dart';

abstract class CameraControlEvent {
  const CameraControlEvent();
}

/// Send PTZ control command
class SendPTZCommand extends CameraControlEvent {
  final int cameraId;
  final CameraControlCommand command;
  final CameraControlSpeed speed;

  const SendPTZCommand({
    required this.cameraId,
    required this.command,
    required this.speed,
  });

  @override
  String toString() =>
      'SendPTZCommand(cameraId: $cameraId, command: $command, speed: $speed)';
}

/// Send custom control command
class SendControlCommand extends CameraControlEvent {
  final CameraControlRequest request;

  const SendControlCommand({required this.request});

  @override
  String toString() => 'SendControlCommand(request: $request)';
}

/// Stop PTZ movement
class StopPTZCommand extends CameraControlEvent {
  final int cameraId;

  const StopPTZCommand({required this.cameraId});

  @override
  String toString() => 'StopPTZCommand(cameraId: $cameraId)';
}

/// Set camera preset
class SetPresetCommand extends CameraControlEvent {
  final int cameraId;
  final int presetNumber;

  const SetPresetCommand({required this.cameraId, required this.presetNumber});

  @override
  String toString() =>
      'SetPresetCommand(cameraId: $cameraId, presetNumber: $presetNumber)';
}

/// Go to camera preset
class GotoPresetCommand extends CameraControlEvent {
  final int cameraId;
  final int presetNumber;

  const GotoPresetCommand({required this.cameraId, required this.presetNumber});

  @override
  String toString() =>
      'GotoPresetCommand(cameraId: $cameraId, presetNumber: $presetNumber)';
}

/// Reset camera control state
class ResetCameraControl extends CameraControlEvent {
  const ResetCameraControl();

  @override
  String toString() => 'ResetCameraControl()';
}
