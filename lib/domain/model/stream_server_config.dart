class StreamServerConfig {
  final String baseUrl;
  final int port;

  const StreamServerConfig({required this.baseUrl, required this.port});

  String get fullUrl => 'https://$baseUrl:$port';

  String get streamUrl => '$fullUrl/api/stream.m3u8';

  Map<String, dynamic> toJson() => {'baseUrl': baseUrl, 'port': port};

  factory StreamServerConfig.fromJson(Map<String, dynamic> json) =>
      StreamServerConfig(baseUrl: json['baseUrl'] as String, port: json['port'] as int);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamServerConfig &&
          runtimeType == other.runtimeType &&
          baseUrl == other.baseUrl &&
          port == other.port;

  @override
  int get hashCode => baseUrl.hashCode ^ port.hashCode;

  @override
  String toString() => 'StreamServerConfig(baseUrl: $baseUrl, port: $port)';
}
