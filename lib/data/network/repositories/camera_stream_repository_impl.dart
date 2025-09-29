import 'package:flutter_camera/data/network/api/camera_stream_api_service.dart';
import 'package:flutter_camera/data/network/model/camera_stream_response.dart';
import 'package:flutter_camera/domain/repositories/camera_stream_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: CameraStreamRepository)
class CameraStreamRepositoryImpl implements CameraStreamRepository {
  final CameraStreamApiService _apiService;

  CameraStreamRepositoryImpl(this._apiService);

  @override
  Future<CameraStreamResponse> getCameraStream({required int cameraId}) async {
    return await _apiService.getCameraStream(cameraId: cameraId);
  }
}
