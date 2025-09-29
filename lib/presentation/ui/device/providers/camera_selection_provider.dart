import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_camera/domain/model/camera.dart';
import 'package:flutter_camera/data/local/preference/selected_cameras_preference.dart';
import 'package:flutter_camera/di/injection.dart';

class CameraSelectionProvider extends ChangeNotifier {
  final Set<String> _selectedCameraIds = {};
  final List<Camera> _allCameras = [];
  final List<Camera> _selectedCameras = [];
  SelectedCamerasPreference? _preference;
  bool _isInitialized = false;

  // Getters
  Set<String> get selectedCameraIds => Set.from(_selectedCameraIds);
  List<Camera> get selectedCameras => List.from(_selectedCameras);
  List<Camera> get allCameras => List.from(_allCameras);
  bool get isInitialized => _isInitialized;
  int get selectedCount => _selectedCameraIds.length;

  /// Initialize provider with preference
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _preference = getIt<SelectedCamerasPreference>();
      final savedIds = await _preference!.getSelectedCameraIds();
      _selectedCameraIds.addAll(savedIds);
      debugPrint('CameraSelectionProvider: Loaded ${savedIds.length} selected cameras');
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('CameraSelectionProvider: Error initializing: $e');
    }
  }

  /// Set all available cameras and update selected cameras list
  void setAllCameras(List<Camera> cameras) {
    _allCameras.clear();
    _allCameras.addAll(cameras);
    _updateSelectedCameras();
    debugPrint('CameraSelectionProvider: Set ${cameras.length} total cameras');
    notifyListeners();
  }

  /// Toggle camera selection
  Future<void> toggleCameraSelection(Camera camera) async {
    if (_selectedCameraIds.contains(camera.uniqueId)) {
      await removeCamera(camera.uniqueId);
    } else {
      await addCamera(camera.uniqueId);
    }
  }

  /// Add camera to selection
  Future<void> addCamera(String cameraId) async {
    if (_selectedCameraIds.contains(cameraId)) return;

    _selectedCameraIds.add(cameraId);
    _updateSelectedCameras();
    await _saveToPreference();
    debugPrint('CameraSelectionProvider: Added camera $cameraId');
    notifyListeners();
  }

  /// Remove camera from selection
  Future<void> removeCamera(String cameraId) async {
    if (!_selectedCameraIds.contains(cameraId)) return;

    _selectedCameraIds.remove(cameraId);
    _updateSelectedCameras();
    await _saveToPreference();
    debugPrint('CameraSelectionProvider: Removed camera $cameraId');
    notifyListeners();
  }

  /// Clear all selections
  Future<void> clearAll() async {
    _selectedCameraIds.clear();
    _selectedCameras.clear();
    await _saveToPreference();
    debugPrint('CameraSelectionProvider: Cleared all selections');
    notifyListeners();
  }

  /// Check if camera is selected
  bool isCameraSelected(String cameraId) {
    return _selectedCameraIds.contains(cameraId);
  }

  /// Get camera by ID
  Camera? getCameraById(String cameraId) {
    try {
      return _allCameras.firstWhere((camera) => camera.uniqueId == cameraId);
    } catch (e) {
      return null;
    }
  }

  /// Update selected cameras list based on current IDs
  void _updateSelectedCameras() {
    _selectedCameras.clear();
    for (final cameraId in _selectedCameraIds) {
      final camera = getCameraById(cameraId);
      if (camera != null) {
        _selectedCameras.add(camera);
      }
    }
  }

  /// Save current selection to preference
  Future<void> _saveToPreference() async {
    if (_preference != null) {
      await _preference!.saveSelectedCameraIds(_selectedCameraIds.toList());
    }
  }

  /// Refresh selection from preference
  Future<void> refreshFromPreference() async {
    if (_preference != null) {
      final savedIds = await _preference!.getSelectedCameraIds();
      _selectedCameraIds.clear();
      _selectedCameraIds.addAll(savedIds);
      _updateSelectedCameras();
      debugPrint('CameraSelectionProvider: Refreshed from preference');
      notifyListeners();
    }
  }
}
