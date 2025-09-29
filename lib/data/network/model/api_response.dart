class ApiResponse<T> {
  final bool isSuccess;
  final String code;
  final String? name;
  final String? message;
  final T? data;

  const ApiResponse({
    required this.isSuccess,
    required this.code,
    this.name,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      isSuccess: json['isSuccess'] as bool? ?? false,
      code: json['code'] as String? ?? '',
      name: json['name'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
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
}