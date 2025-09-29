import 'package:json_annotation/json_annotation.dart';

part 'camera_stream_response.g.dart';

@JsonSerializable()
class CameraStreamResponse {
  final bool isSuccess;
  final String code;
  final String? name;
  final String? message;
  final String? data;

  const CameraStreamResponse({
    required this.isSuccess,
    required this.code,
    this.name,
    this.message,
    this.data,
  });

  factory CameraStreamResponse.fromJson(Map<String, dynamic> json) =>
      _$CameraStreamResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CameraStreamResponseToJson(this);
}
