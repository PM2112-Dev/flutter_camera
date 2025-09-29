import 'package:shared_preferences/shared_preferences.dart';

class PinCameraPreference {
  static const String _pinnedCamerasKey = 'pinned_cameras';
  final SharedPreferences _preferences;

  PinCameraPreference(this._preferences);

  // Get list of pinned camera IDs
  List<String> getPinnedCameraIds() {
    return _preferences.getStringList(_pinnedCamerasKey) ?? [];
  }

  // Add camera to pinned list
  Future<bool> pinCamera(String cameraId) async {
    final pinnedIds = getPinnedCameraIds();
    if (!pinnedIds.contains(cameraId)) {
      pinnedIds.add(cameraId);
      return await _preferences.setStringList(_pinnedCamerasKey, pinnedIds);
    }
    return true;
  }

  // Remove camera from pinned list
  Future<bool> unpinCamera(String cameraId) async {
    final pinnedIds = getPinnedCameraIds();
    pinnedIds.remove(cameraId);
    return await _preferences.setStringList(_pinnedCamerasKey, pinnedIds);
  }

  // Check if camera is pinned
  bool isCameraPinned(String cameraId) {
    return getPinnedCameraIds().contains(cameraId);
  }

  // Toggle pin status of camera
  Future<bool> toggleCameraPin(String cameraId) async {
    if (isCameraPinned(cameraId)) {
      return await unpinCamera(cameraId);
    } else {
      return await pinCamera(cameraId);
    }
  }

  // Clear all pinned cameras
  Future<bool> clearAllPinnedCameras() async {
    return await _preferences.remove(_pinnedCamerasKey);
  }
}
