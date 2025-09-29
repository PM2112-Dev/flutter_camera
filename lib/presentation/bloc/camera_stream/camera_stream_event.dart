abstract class CameraStreamEvent {}

class GetCameraStreamEvent extends CameraStreamEvent {
  final int cameraId;

  GetCameraStreamEvent({required this.cameraId});
}
