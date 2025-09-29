import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedCamerasPreference {
  static const String _selectedCamerasKey = 'selected_cameras';
  final SharedPreferences _prefs;

  SelectedCamerasPreference(this._prefs);

  /// Save selected camera IDs to preferences
  Future<void> saveSelectedCameraIds(List<String> cameraIds) async {
    final jsonString = jsonEncode(cameraIds);
    await _prefs.setString(_selectedCamerasKey, jsonString);
  }

  /// Get selected camera IDs from preferences
  Future<List<String>> getSelectedCameraIds() async {
    final jsonString = _prefs.getString(_selectedCamerasKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  /// Add a camera to selected list
  Future<void> addSelectedCamera(String cameraId) async {
    final currentIds = await getSelectedCameraIds();
    if (!currentIds.contains(cameraId)) {
      currentIds.add(cameraId);
      await saveSelectedCameraIds(currentIds);
    }
  }

  /// Remove a camera from selected list
  Future<void> removeSelectedCamera(String cameraId) async {
    final currentIds = await getSelectedCameraIds();
    currentIds.remove(cameraId);
    await saveSelectedCameraIds(currentIds);
  }

  /// Check if a camera is selected
  Future<bool> isCameraSelected(String cameraId) async {
    final selectedIds = await getSelectedCameraIds();
    return selectedIds.contains(cameraId);
  }

  /// Clear all selected cameras
  Future<void> clearSelectedCameras() async {
    await _prefs.remove(_selectedCamerasKey);
  }

  /// Get count of selected cameras
  Future<int> getSelectedCamerasCount() async {
    final selectedIds = await getSelectedCameraIds();
    return selectedIds.length;
  }
}
