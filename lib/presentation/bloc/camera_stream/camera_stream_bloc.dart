import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/domain/usecase/get_camera_stream_usecase.dart';
import 'package:flutter_camera/presentation/bloc/camera_stream/camera_stream_event.dart';
import 'package:flutter_camera/presentation/bloc/camera_stream/camera_stream_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CameraStreamBloc extends Bloc<CameraStreamEvent, CameraStreamState> {
  final GetCameraStreamUsecase _getCameraStreamUsecase;

  CameraStreamBloc(this._getCameraStreamUsecase) : super(CameraStreamInitial()) {
    on<GetCameraStreamEvent>(_onGetCameraStream);
  }

  Future<void> _onGetCameraStream(
    GetCameraStreamEvent event,
    Emitter<CameraStreamState> emit,
  ) async {
    emit(CameraStreamLoading());

    try {
      print('CameraStreamBloc: Getting stream for camera ID: ${event.cameraId}');
      final response = await _getCameraStreamUsecase(cameraId: event.cameraId);

      print('CameraStreamBloc: API Response received');
      print('CameraStreamBloc: isSuccess: ${response.isSuccess}');
      print('CameraStreamBloc: data: ${response.data}');
      print('CameraStreamBloc: message: ${response.message}');
      print('CameraStreamBloc: code: ${response.code}');

      if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
        // response.data chính là streamId
        print('CameraStreamBloc: Stream ID found: ${response.data}');
        emit(CameraStreamSuccess(response: response));
      } else {
        print(
          'CameraStreamBloc: No valid stream ID - isSuccess: ${response.isSuccess}, data: ${response.data}',
        );
        emit(CameraStreamError(message: response.message ?? 'No stream ID available'));
      }
    } catch (e) {
      print('CameraStreamBloc: Exception occurred: $e');
      emit(CameraStreamError(message: 'Unexpected error: $e'));
    }
  }
}
