import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class NotificationPreference {
  final SharedPreferences _prefs;

  NotificationPreference(this._prefs);

  // Keys for notification settings
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _quietHoursEnabledKey = 'quiet_hours_enabled';
  static const String _quietStartHourKey = 'quiet_start_hour';
  static const String _quietStartMinuteKey = 'quiet_start_minute';
  static const String _quietEndHourKey = 'quiet_end_hour';
  static const String _quietEndMinuteKey = 'quiet_end_minute';

  // Default values
  static const bool _defaultNotificationsEnabled = true;
  static const bool _defaultSoundEnabled = true;
  static const bool _defaultVibrationEnabled = true;
  static const bool _defaultQuietHoursEnabled = false;
  static const int _defaultQuietStartHour = 22;
  static const int _defaultQuietStartMinute = 0;
  static const int _defaultQuietEndHour = 7;
  static const int _defaultQuietEndMinute = 0;

  // Getters
  bool get notificationsEnabled =>
      _prefs.getBool(_notificationsEnabledKey) ?? _defaultNotificationsEnabled;

  bool get soundEnabled => _prefs.getBool(_soundEnabledKey) ?? _defaultSoundEnabled;

  bool get vibrationEnabled => _prefs.getBool(_vibrationEnabledKey) ?? _defaultVibrationEnabled;

  bool get quietHoursEnabled => _prefs.getBool(_quietHoursEnabledKey) ?? _defaultQuietHoursEnabled;

  int get quietStartHour => _prefs.getInt(_quietStartHourKey) ?? _defaultQuietStartHour;

  int get quietStartMinute => _prefs.getInt(_quietStartMinuteKey) ?? _defaultQuietStartMinute;

  int get quietEndHour => _prefs.getInt(_quietEndHourKey) ?? _defaultQuietEndHour;

  int get quietEndMinute => _prefs.getInt(_quietEndMinuteKey) ?? _defaultQuietEndMinute;

  // Setters
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundEnabledKey, enabled);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_vibrationEnabledKey, enabled);
  }

  Future<void> setQuietHoursEnabled(bool enabled) async {
    await _prefs.setBool(_quietHoursEnabledKey, enabled);
  }

  Future<void> setQuietStartTime(int hour, int minute) async {
    await _prefs.setInt(_quietStartHourKey, hour);
    await _prefs.setInt(_quietStartMinuteKey, minute);
  }

  Future<void> setQuietEndTime(int hour, int minute) async {
    await _prefs.setInt(_quietEndHourKey, hour);
    await _prefs.setInt(_quietEndMinuteKey, minute);
  }

  // Check if current time is within quiet hours
  bool isQuietHours() {
    if (!quietHoursEnabled) return false;

    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    final startTime = quietStartHour * 60 + quietStartMinute;
    final endTime = quietEndHour * 60 + quietEndMinute;

    // Handle overnight quiet hours (e.g., 22:00 to 07:00)
    if (startTime > endTime) {
      return currentTime >= startTime || currentTime <= endTime;
    } else {
      return currentTime >= startTime && currentTime <= endTime;
    }
  }

  // Clear all notification settings
  Future<void> clearAll() async {
    await _prefs.remove(_notificationsEnabledKey);
    await _prefs.remove(_soundEnabledKey);
    await _prefs.remove(_vibrationEnabledKey);
    await _prefs.remove(_quietHoursEnabledKey);
    await _prefs.remove(_quietStartHourKey);
    await _prefs.remove(_quietStartMinuteKey);
    await _prefs.remove(_quietEndHourKey);
    await _prefs.remove(_quietEndMinuteKey);
  }
}
