class CameraControlRequest {
  final int cameraId;
  final int speed;
  final int command;

  const CameraControlRequest({
    required this.cameraId,
    required this.speed,
    required this.command,
  });

  Map<String, dynamic> toJson() {
    return {'cameraId': cameraId, 'speed': speed, 'command': command};
  }

  factory CameraControlRequest.fromJson(Map<String, dynamic> json) {
    return CameraControlRequest(
      cameraId: json['cameraId'] as int,
      speed: json['speed'] as int,
      command: json['command'] as int,
    );
  }

  @override
  String toString() {
    return 'CameraControlRequest(cameraId: $cameraId, speed: $speed, command: $command)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CameraControlRequest &&
        other.cameraId == cameraId &&
        other.speed == speed &&
        other.command == command;
  }

  @override
  int get hashCode {
    return cameraId.hashCode ^ speed.hashCode ^ command.hashCode;
  }
}
