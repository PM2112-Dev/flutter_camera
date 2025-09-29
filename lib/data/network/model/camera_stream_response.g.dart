// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_stream_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraStreamResponse _$CameraStreamResponseFromJson(
  Map<String, dynamic> json,
) => CameraStreamResponse(
  isSuccess: json['isSuccess'] as bool,
  code: json['code'] as String,
  name: json['name'] as String?,
  message: json['message'] as String?,
  data: json['data'] as String?,
);

Map<String, dynamic> _$CameraStreamResponseToJson(
  CameraStreamResponse instance,
) => <String, dynamic>{
  'isSuccess': instance.isSuccess,
  'code': instance.code,
  'name': instance.name,
  'message': instance.message,
  'data': instance.data,
};
