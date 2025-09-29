import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_camera/domain/model/camera.dart';
import 'package:flutter_camera/presentation/bloc/camera_stream/camera_stream_bloc.dart';
import 'package:flutter_camera/presentation/bloc/camera_stream/camera_stream_event.dart';
import 'package:flutter_camera/presentation/bloc/camera_stream/camera_stream_state.dart';
import 'package:flutter_camera/di/injection.dart';

class CameraStreamData {
  final String cameraId;
  final String? streamId;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  const CameraStreamData({
    required this.cameraId,
    this.streamId,
    this.isLoading = false,
    this.error,
    required this.lastUpdated,
  });

  CameraStreamData copyWith({
    String? streamId,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CameraStreamData(
      cameraId: cameraId,
      streamId: streamId ?? this.streamId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class CameraStreamDataProvider extends ChangeNotifier with WidgetsBindingObserver {
  final Map<String, CameraStreamData> _streamData = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, CameraStreamBloc> _blocs = {};
  final List<Camera> _selectedCameras = [];

  CameraStreamDataProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  // Getters
  Map<String, CameraStreamData> get streamData => Map.from(_streamData);
  List<String> get loadingCameras =>
      _streamData.values.where((data) => data.isLoading).map((data) => data.cameraId).toList();
  List<String> get errorCameras =>
      _streamData.values.where((data) => data.error != null).map((data) => data.cameraId).toList();

  /// Get stream data for camera
  CameraStreamData? getStreamData(String cameraId) {
    return _streamData[cameraId];
  }

  /// Get stream ID for camera
  String? getStreamId(String cameraId) {
    return _streamData[cameraId]?.streamId;
  }

  /// Check if camera is loading
  bool isLoading(String cameraId) {
    return _streamData[cameraId]?.isLoading ?? false;
  }

  /// Check if camera has error
  bool hasError(String cameraId) {
    return _streamData[cameraId]?.error != null;
  }

  /// Get error message for camera
  String? getError(String cameraId) {
    return _streamData[cameraId]?.error;
  }

  /// Request stream data for camera
  void requestStreamData(Camera camera) {
    final cameraId = camera.uniqueId;

    // Don't request if already loading or has recent data
    if (_streamData[cameraId]?.isLoading == true) return;

    final lastUpdated = _streamData[cameraId]?.lastUpdated;
    if (lastUpdated != null && DateTime.now().difference(lastUpdated).inMinutes < 5) {
      return; // Don't refresh if data is less than 5 minutes old
    }

    debugPrint('CameraStreamDataProvider: Requesting stream data for camera: ${camera.name}');

    // Create or get existing bloc
    if (!_blocs.containsKey(cameraId)) {
      _blocs[cameraId] = getIt<CameraStreamBloc>();
    }

    final bloc = _blocs[cameraId]!;

    // Cancel existing subscription
    _subscriptions[cameraId]?.cancel();

    // Update state to loading
    _streamData[cameraId] = CameraStreamData(
      cameraId: cameraId,
      isLoading: true,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();

    // Listen to bloc state changes
    _subscriptions[cameraId] = bloc.stream.listen((state) {
      _handleStreamStateChange(cameraId, state);
    });

    // Add event to get stream data
    bloc.add(GetCameraStreamEvent(cameraId: camera.id));
  }

  /// Handle stream state changes
  void _handleStreamStateChange(String cameraId, CameraStreamState state) {
    if (state is CameraStreamLoading) {
      _streamData[cameraId] = CameraStreamData(
        cameraId: cameraId,
        isLoading: true,
        lastUpdated: DateTime.now(),
      );
    } else if (state is CameraStreamSuccess) {
      debugPrint('CameraStreamDataProvider: CameraStreamSuccess for $cameraId');
      debugPrint('CameraStreamDataProvider: Response data: ${state.response.data}');
      debugPrint('CameraStreamDataProvider: Response isSuccess: ${state.response.isSuccess}');
      debugPrint('CameraStreamDataProvider: Response message: ${state.response.message}');

      _streamData[cameraId] = CameraStreamData(
        cameraId: cameraId,
        streamId: state.response.data,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      debugPrint('CameraStreamDataProvider: Got stream ID for $cameraId: ${state.response.data}');
    } else if (state is CameraStreamError) {
      _streamData[cameraId] = CameraStreamData(
        cameraId: cameraId,
        isLoading: false,
        error: state.message,
        lastUpdated: DateTime.now(),
      );
      debugPrint('CameraStreamDataProvider: Error for $cameraId: ${state.message}');
    }

    notifyListeners();
  }

  /// Refresh stream data for camera
  void refreshStreamData(Camera camera) {
    final cameraId = camera.uniqueId;

    // Clear existing data
    _streamData.remove(cameraId);
    _subscriptions[cameraId]?.cancel();
    _subscriptions.remove(cameraId);
    _blocs[cameraId]?.close();
    _blocs.remove(cameraId);

    // Request new data
    requestStreamData(camera);
  }

  /// Refresh all stream data
  void refreshAllStreamData(List<Camera> cameras) {
    debugPrint(
      'CameraStreamDataProvider: Refreshing all stream data for ${cameras.length} cameras',
    );
    _selectedCameras.clear();
    _selectedCameras.addAll(cameras);
    for (final camera in cameras) {
      refreshStreamData(camera);
    }
  }

  void updateSelectedCameras(List<Camera> cameras) {
    _selectedCameras.clear();
    _selectedCameras.addAll(cameras);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App returning to foreground - refresh all stream data
        debugPrint('CameraStreamDataProvider: App resumed, refreshing stream data');
        for (final camera in _selectedCameras) {
          final streamData = _streamData[camera.uniqueId];
          if (streamData == null || streamData.streamId == null) {
            debugPrint('CameraStreamDataProvider: Refreshing stream for ${camera.name}');
            requestStreamData(camera);
          }
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        debugPrint('CameraStreamDataProvider: App backgrounded');
        break;
      default:
        break;
    }
  }

  /// Clear stream data for camera
  void clearStreamData(String cameraId) {
    _streamData.remove(cameraId);
    _subscriptions[cameraId]?.cancel();
    _subscriptions.remove(cameraId);
    _blocs[cameraId]?.close();
    _blocs.remove(cameraId);
    notifyListeners();
  }

  /// Clear all stream data
  void clearAllStreamData() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    for (final bloc in _blocs.values) {
      bloc.close();
    }
    _streamData.clear();
    _subscriptions.clear();
    _blocs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    clearAllStreamData();
    super.dispose();
  }
}
