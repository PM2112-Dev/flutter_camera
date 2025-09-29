import 'package:flutter_camera/data/network/model/camera_stream_response.dart';

abstract class CameraStreamState {}

class CameraStreamInitial extends CameraStreamState {}

class CameraStreamLoading extends CameraStreamState {}

class CameraStreamSuccess extends CameraStreamState {
  final CameraStreamResponse response;

  CameraStreamSuccess({required this.response});
}

class CameraStreamError extends CameraStreamState {
  final String message;

  CameraStreamError({required this.message});
}
