import 'package:flutter_camera/data/network/model/camera_stream_response.dart';
import 'package:flutter_camera/domain/repositories/camera_stream_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCameraStreamUsecase {
  final CameraStreamRepository _repository;

  GetCameraStreamUsecase(this._repository);

  Future<CameraStreamResponse> call({required int cameraId}) async {
    return await _repository.getCameraStream(cameraId: cameraId);
  }
}
