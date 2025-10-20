import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/common_enums_api_service.dart';
import 'package:flutter_camera/data/network/model/common_enums_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CommonEnumsService {
  final CommonEnumsApiService _apiService;
  final AuthLocalPreference _authLocalPreference;

  CommonEnumsResponse? _cachedEnums;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(hours: 24); // Cache for 24 hours

  CommonEnumsService(this._apiService, this._authLocalPreference);

  /// Get all enums (with caching)
  Future<CommonEnumsResponse?> getAllEnums({bool forceRefresh = false}) async {
    try {
      // Return cached data if available and not expired
      if (!forceRefresh &&
          _cachedEnums != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        print('📦 Using cached enums data');
        return _cachedEnums;
      }

      // Fetch from API
      final tokens = _authLocalPreference.getTokens();
      if (tokens?.accessToken == null) {
        print('⚠️ No access token available');
        return null;
      }

      print('🌐 Fetching enums from API...');
      final response = await _apiService.getAllEnums(accessToken: tokens!.accessToken);

      if (response.isSuccess && response.data != null) {
        _cachedEnums = response.data;
        _lastFetchTime = DateTime.now();
        print('✅ Enums fetched and cached successfully');
        return _cachedEnums;
      }

      print('⚠️ Failed to fetch enums: ${response.message}');
      return null;
    } catch (e) {
      print('❌ Error fetching enums: $e');
      return _cachedEnums; // Return cached data if available
    }
  }

  /// Get temperature level list
  List<EnumItem> getTemperatureLevels() {
    return _cachedEnums?.temperatureLevelList ?? [];
  }

  /// Get threshold type list
  List<EnumItem> getThresholdTypes() {
    return _cachedEnums?.thresholdTypeList ?? [];
  }

  /// Clear cache
  void clearCache() {
    _cachedEnums = null;
    _lastFetchTime = null;
    print('🗑️ Enums cache cleared');
  }

  /// Check if cache is valid
  bool get hasCachedData => _cachedEnums != null;
}
