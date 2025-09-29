import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_camera/domain/model/camera.dart';

class CameraStreamManager {
  static final CameraStreamManager _instance = CameraStreamManager._internal();
  factory CameraStreamManager() => _instance;
  CameraStreamManager._internal();

  final Map<String, StreamController<CameraStreamState>> _streamControllers = {};
  final Map<String, int> _streamReferences = {};
  final Set<String> _activeStreams = {};
  final Set<String> _pausedStreams = {}; // Track paused streams

  // Giới hạn số stream đồng thời để tránh quá tải
  static const int maxConcurrentStreams =
      2; // Set to 4 for better performance with multiple cameras

  StreamController<CameraStreamState> getStreamController(String cameraId) {
    if (!_streamControllers.containsKey(cameraId)) {
      _streamControllers[cameraId] = StreamController<CameraStreamState>.broadcast();
      _streamReferences[cameraId] = 0;
    }

    _streamReferences[cameraId] = _streamReferences[cameraId]! + 1;
    return _streamControllers[cameraId]!;
  }

  void releaseStreamController(String cameraId) {
    if (_streamReferences.containsKey(cameraId)) {
      _streamReferences[cameraId] = _streamReferences[cameraId]! - 1;

      if (_streamReferences[cameraId]! <= 0) {
        // Cleanup sau một khoảng thời gian delay
        Timer(const Duration(seconds: 5), () {
          if (_streamReferences[cameraId] != null && _streamReferences[cameraId]! <= 0) {
            _streamControllers[cameraId]?.close();
            _streamControllers.remove(cameraId);
            _streamReferences.remove(cameraId);
            _activeStreams.remove(cameraId);

            if (kDebugMode) {
              print('Cleaned up stream controller for camera: $cameraId');
            }
          }
        });
      }
    }
  }

  bool canStartNewStream() {
    return _activeStreams.length < maxConcurrentStreams;
  }

  Future<void> startStream(Camera camera) async {
    final cameraId = camera.uniqueId;

    if (_activeStreams.contains(cameraId)) {
      // Stream đã đang chạy, chỉ cần resume nếu bị pause
      if (_pausedStreams.contains(cameraId)) {
        resumeStream(cameraId);
      }
      return;
    }

    // Không cần check maxConcurrentStreams nữa vì ta dùng pause/resume
    // Streams sẽ tự động pause khi scroll ra khỏi view

    _activeStreams.add(cameraId);

    final controller = getStreamController(cameraId);

    try {
      // Emit loading state
      controller.add(CameraStreamState.loading());

      // Mô phỏng việc khởi tạo stream với delay nhỏ hơn - reduce delay for better responsiveness
      await Future.delayed(Duration(milliseconds: 100 + (camera.id % 200)));

      if (_activeStreams.contains(cameraId)) {
        // Emit success state
        controller.add(CameraStreamState.loaded(camera));

        debugPrint('CameraStreamManager: Started stream for camera: ${camera.name}');
        debugPrint(
          'CameraStreamManager: Active streams: ${_activeStreams.length}, Playing: $activePlayingStreamCount',
        );
      }
    } catch (e) {
      // Emit error state
      controller.add(CameraStreamState.error(e.toString()));
      _activeStreams.remove(cameraId);

      debugPrint(
        'CameraStreamManager: Failed to start stream for camera: ${camera.name}, error: $e',
      );
    }
  }

  /// Resume all paused streams when app returns to foreground
  void resumeAllPausedStreams() {
    debugPrint('CameraStreamManager: Resuming all paused streams');
    for (final cameraId in _pausedStreams.toList()) {
      resumeStream(cameraId);
    }
  }

  /// Pause all active streams when app goes to background
  void pauseAllActiveStreams() {
    debugPrint('CameraStreamManager: Pausing all active streams');
    for (final cameraId in _activeStreams.toList()) {
      pauseStream(cameraId);
    }
  }

  Future<void> stopStream(String cameraId) async {
    _activeStreams.remove(cameraId);
    _pausedStreams.remove(cameraId); // Also remove from paused streams

    if (_streamControllers.containsKey(cameraId)) {
      final controller = _streamControllers[cameraId]!;
      controller.add(CameraStreamState.stopped());

      if (kDebugMode) {
        print('Stopped stream for camera: $cameraId');
      }
    }
  }

  void pauseStream(String cameraId) {
    if (_activeStreams.contains(cameraId)) {
      _pausedStreams.add(cameraId);
      debugPrint('Paused stream for camera: $cameraId');
    }
  }

  void resumeStream(String cameraId) {
    _pausedStreams.remove(cameraId);
    debugPrint('Resumed stream for camera: $cameraId');
  }

  void stopAllStreams() {
    for (final cameraId in _activeStreams.toList()) {
      stopStream(cameraId);
    }
    _pausedStreams.clear();
  }

  List<String> get activeStreamIds => _activeStreams.toList();
  List<String> get pausedStreamIds => _pausedStreams.toList();
  int get activeStreamCount => _activeStreams.length;
  int get activePlayingStreamCount => _activeStreams.length - _pausedStreams.length;
  bool isStreamActive(String cameraId) => _activeStreams.contains(cameraId);
  bool isStreamPaused(String cameraId) => _pausedStreams.contains(cameraId);

  // Get appropriate delay for new camera to avoid conflicts
  int getNewCameraDelay() {
    // Base delay + (active streams count * 200ms) to stagger new additions
    return 100 + (_activeStreams.length * 200);
  }
}

class CameraStreamState {
  final CameraStreamStatus status;
  final Camera? camera;
  final String? error;

  const CameraStreamState._({required this.status, this.camera, this.error});

  factory CameraStreamState.initial() =>
      const CameraStreamState._(status: CameraStreamStatus.initial);
  factory CameraStreamState.loading() =>
      const CameraStreamState._(status: CameraStreamStatus.loading);
  factory CameraStreamState.loaded(Camera camera) =>
      CameraStreamState._(status: CameraStreamStatus.loaded, camera: camera);
  factory CameraStreamState.error(String error) =>
      CameraStreamState._(status: CameraStreamStatus.error, error: error);
  factory CameraStreamState.stopped() =>
      const CameraStreamState._(status: CameraStreamStatus.stopped);
}

enum CameraStreamStatus { initial, loading, loaded, error, stopped }
