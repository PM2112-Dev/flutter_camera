class ServerConfig {
  final String baseUrl;
  final int port;

  const ServerConfig({required this.baseUrl, required this.port});

  String get fullUrl => '$baseUrl:$port';

  ServerConfig copyWith({String? baseUrl, int? port}) {
    return ServerConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      port: port ?? this.port,
    );
  }

  @override
  String toString() {
    return 'ServerConfig(baseUrl: $baseUrl, port: $port)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServerConfig &&
        other.baseUrl == baseUrl &&
        other.port == port;
  }

  @override
  int get hashCode => baseUrl.hashCode ^ port.hashCode;
}
