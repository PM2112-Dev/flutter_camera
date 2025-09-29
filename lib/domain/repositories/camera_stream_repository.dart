import 'package:flutter_camera/data/network/model/camera_stream_response.dart';

abstract class CameraStreamRepository {
  Future<CameraStreamResponse> getCameraStream({required int cameraId});
}
