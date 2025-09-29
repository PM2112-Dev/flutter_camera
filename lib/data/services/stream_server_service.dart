import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:injectable/injectable.dart';

@injectable
class StreamServerService {
  final AuthLocalPreference _authPreference;

  StreamServerService(this._authPreference);

  String getStreamServerUrl() {
    return _authPreference.getStreamServerUrl();
  }

  String getStreamUrl(String streamId) {
    final baseUrl = getStreamServerUrl();
    return '$baseUrl/api/stream.m3u8?src=$streamId';
  }

  bool hasStreamServerConfig() {
    return _authPreference.hasStreamServerConfig();
  }
}
