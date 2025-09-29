class CameraControlResponse {
  final bool isSuccess;
  final String code;
  final String? name;
  final String? message;
  final dynamic data;

  const CameraControlResponse({
    required this.isSuccess,
    required this.code,
    this.name,
    this.message,
    this.data,
  });

  factory CameraControlResponse.fromJson(Map<String, dynamic> json) {
    return CameraControlResponse(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      name: json['name'] as String?,
      message: json['message'] as String?,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'code': code,
      'name': name,
      'message': message,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'CameraControlResponse(isSuccess: $isSuccess, code: $code, name: $name, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CameraControlResponse &&
        other.isSuccess == isSuccess &&
        other.code == code &&
        other.name == name &&
        other.message == message &&
        other.data == data;
  }

  @override
  int get hashCode {
    return isSuccess.hashCode ^
        code.hashCode ^
        name.hashCode ^
        message.hashCode ^
        data.hashCode;
  }
}
