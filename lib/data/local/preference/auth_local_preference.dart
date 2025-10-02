import 'package:flutter_camera/data/network/model/auth_tokens_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class AuthLocalPreference {
  final SharedPreferences _prefs;

  AuthLocalPreference(this._prefs);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _baseUrlKey = 'base_url';
  static const String _portKey = 'port';
  static const String _streamBaseUrlKey = 'stream_base_url';
  static const String _streamPortKey = 'stream_port';

  Future<void> saveTokens(AuthTokensModel tokens) async {
    await _prefs.setString(_accessTokenKey, tokens.accessToken);
    await _prefs.setString(_refreshTokenKey, tokens.refreshToken);
    await _prefs.setString(_tokenTypeKey, tokens.tokenType);
    await _prefs.setInt(_expiresInKey, tokens.expiresIn);
  }

  AuthTokensModel? getTokens() {
    final accessToken = _prefs.getString(_accessTokenKey);
    final refreshToken = _prefs.getString(_refreshTokenKey);
    final tokenType = _prefs.getString(_tokenTypeKey);
    final expiresIn = _prefs.getInt(_expiresInKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthTokensModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType ?? 'Bearer',
      expiresIn: expiresIn ?? 0,
    );
  }

  Future<void> clearTokens() async {
    print('AuthLocalPreference: Clearing all tokens...');
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_tokenTypeKey);
    await _prefs.remove(_expiresInKey);
    print('AuthLocalPreference: All tokens cleared successfully');
  }

  bool isLoggedIn() {
    final tokens = getTokens();
    return tokens != null && tokens.accessToken.isNotEmpty;
  }

  // Server configuration methods
  Future<void> saveServerConfig({required String baseUrl, required int port}) async {
    await _prefs.setString(_baseUrlKey, baseUrl);
    await _prefs.setInt(_portKey, port);
  }

  String? getBaseUrl() {
    return _prefs.getString(_baseUrlKey);
  }

  int? getPort() {
    return _prefs.getInt(_portKey);
  }

  bool hasServerConfig() {
    return getBaseUrl() != null && getPort() != null;
  }

  String getFullBaseUrl() {
    final baseUrl = getBaseUrl();
    final port = getPort();
    if (baseUrl != null && port != null) {
      // Check if baseUrl already has protocol (http:// or https://)
      if (baseUrl.startsWith('http://') || baseUrl.startsWith('https://')) {
        return '$baseUrl:$port';
      } else {
        // Default to http if no protocol specified
        return 'http://$baseUrl:$port';
      }
    }
    return 'https://thermal.infosysvietnam.com.vn:10253'; // Default fallback with HTTPS
  }

  Future<void> clearServerConfig() async {
    await _prefs.remove(_baseUrlKey);
    await _prefs.remove(_portKey);
  }

  // Stream server configuration methods
  Future<void> saveStreamServerConfig({required String baseUrl, required int port}) async {
    await _prefs.setString(_streamBaseUrlKey, baseUrl);
    await _prefs.setInt(_streamPortKey, port);
  }

  String? getStreamBaseUrl() {
    return _prefs.getString(_streamBaseUrlKey);
  }

  int? getStreamPort() {
    return _prefs.getInt(_streamPortKey);
  }

  bool hasStreamServerConfig() {
    return getStreamBaseUrl() != null && getStreamPort() != null;
  }

  String getStreamServerUrl() {
    final baseUrl = getStreamBaseUrl();
    final port = getStreamPort();
    if (baseUrl != null && port != null) {
      // Check if baseUrl already has protocol (http:// or https://)
      if (baseUrl.startsWith('http://') || baseUrl.startsWith('https://')) {
        return '$baseUrl:$port';
      } else {
        // Default to http if no protocol specified
        return 'http://$baseUrl:$port';
      }
    }
    return 'https://thermal.mtktech.com.vn:1984'; // Default fallback with HTTPS
  }

  Future<void> clearStreamServerConfig() async {
    await _prefs.remove(_streamBaseUrlKey);
    await _prefs.remove(_streamPortKey);
  }

  // Helper methods for URL validation and normalization
  static String normalizeUrl(String url) {
    // Remove trailing slash if present
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    // If no protocol specified, default to http://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    return url;
  }

  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  // Enhanced save methods with URL normalization
  Future<void> saveServerConfigWithNormalization({
    required String baseUrl,
    required int port,
  }) async {
    final normalizedUrl = normalizeUrl(baseUrl);
    await saveServerConfig(baseUrl: normalizedUrl, port: port);
  }

  Future<void> saveStreamServerConfigWithNormalization({
    required String baseUrl,
    required int port,
  }) async {
    final normalizedUrl = normalizeUrl(baseUrl);
    await saveStreamServerConfig(baseUrl: normalizedUrl, port: port);
  }
}