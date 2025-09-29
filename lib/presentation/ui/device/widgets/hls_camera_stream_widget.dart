import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_camera/data/services/stream_server_service.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/di/injection.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class HlsCameraStreamWidget extends StatefulWidget {
  final String? streamId;
  final double width;
  final double? height;
  final bool isLoadingStreamId; // Add this parameter

  const HlsCameraStreamWidget({
    super.key,
    this.streamId,
    this.width = double.infinity,
    this.height,
    this.isLoadingStreamId = false, // Default to false
  });

  @override
  State<HlsCameraStreamWidget> createState() => _HlsCameraStreamWidgetState();
}

class _HlsCameraStreamWidgetState extends State<HlsCameraStreamWidget> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  // String? _hlsUrl; // Unused in direct HLS test mode
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  late final StreamServerService _streamServerService;
  bool _wasPlayingBeforeBackground = false;

  @override
  void initState() {
    super.initState();
    // Temporary fix: create StreamServerService directly until build_runner is run
    final authPreference = getIt<AuthLocalPreference>();
    _streamServerService = StreamServerService(authPreference);
    WidgetsBinding.instance.addObserver(this);
    _initializeStream();
  }

  @override
  void didUpdateWidget(HlsCameraStreamWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamId != widget.streamId ||
        oldWidget.isLoadingStreamId != widget.isLoadingStreamId) {
      print('[HLS] StreamId changed from ${oldWidget.streamId} to ${widget.streamId}');
      print(
        '[HLS] isLoadingStreamId changed from ${oldWidget.isLoadingStreamId} to ${widget.isLoadingStreamId}',
      );
      _initializeStream();
    }
  }

  void _initializeStream() {
    debugPrint('[HLS] Initializing stream...');
    debugPrint('[HLS] streamId: ${widget.streamId}');
    debugPrint('[HLS] streamId is null: ${widget.streamId == null}');
    debugPrint('[HLS] streamId is empty: ${widget.streamId?.isEmpty}');
    debugPrint('[HLS] isLoadingStreamId: ${widget.isLoadingStreamId}');

    if (widget.streamId != null && widget.streamId!.isNotEmpty) {
      // Use stream ID from API with configured server URL
      final hlsUrl = _streamServerService.getStreamUrl(widget.streamId!);
      debugPrint('[HLS] Using API stream ID: ${widget.streamId}');
      debugPrint('[HLS] Stream URL: $hlsUrl');
      _playHlsFromUrl(hlsUrl);
    } else if (widget.isLoadingStreamId) {
      // Stream ID is being loaded, show loading state
      debugPrint('[HLS] Stream ID is being loaded...');
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      // No stream ID available and not loading
      debugPrint('[HLS] No stream ID available - streamId: ${widget.streamId}');
      setState(() {
        _error = 'No stream ID available';
        _isLoading = false;
      });
    }
  }

  Future<void> _playHlsFromUrl(String url) async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });
    debugPrint('[HLS] Đang phát URL: $url');

    try {
      // Dispose existing controller if any
      await _controller?.dispose();

      _controller = VideoPlayerController.network(
        url,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true, allowBackgroundPlayback: false),
      );

      // Add listener for player state changes
      _controller!.addListener(_videoPlayerListener);

      await _controller!.initialize();

      if (_isDisposed) {
        await _controller?.dispose();
        return;
      }

      setState(() {
        _isLoading = false;
      });

      await _controller!.play();
      debugPrint('[HLS] Video player started successfully');
    } catch (e, stack) {
      debugPrint('[HLS] Lỗi khởi tạo video player: $e');
      debugPrint('[HLS] Stacktrace: $stack');

      if (!_isDisposed) {
        setState(() {
          _error = 'Lỗi khởi tạo video player: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _videoPlayerListener() {
    if (_isDisposed || _controller == null) return;

    final value = _controller!.value;

    // Log player state changes
    if (value.hasError) {
      debugPrint('[HLS] Video player error: ${value.errorDescription}');
      if (!_isDisposed) {
        _handlePlayerError();
      }
    } else if (value.isInitialized) {
      debugPrint(
        '[HLS] Video player initialized - Duration: ${value.duration}, Position: ${value.position}',
      );
      // Reset retry count on successful initialization
      _retryCount = 0;
    }
  }

  void _handlePlayerError() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      debugPrint('[HLS] Retrying video player (attempt $_retryCount/$_maxRetries)');

      setState(() {
        _error = null;
      });

      // Retry after a delay
      Future.delayed(Duration(seconds: _retryCount * 2), () {
        if (!_isDisposed) {
          _initializeStream();
        }
      });
    } else {
      setState(() {
        _error = 'Video player failed after $_maxRetries attempts';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_isDisposed || _controller == null) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background
        if (_controller!.value.isPlaying) {
          _wasPlayingBeforeBackground = true;
          _controller!.pause();
          debugPrint('[HLS] Paused video due to app backgrounding');
        }
        break;
      case AppLifecycleState.resumed:
        // App returning to foreground
        if (_wasPlayingBeforeBackground && _controller!.value.isInitialized) {
          _controller!.play();
          _wasPlayingBeforeBackground = false;
          debugPrint('[HLS] Resumed video after app foregrounding');
        }
        break;
      case AppLifecycleState.detached:
        // App being terminated
        _controller?.pause();
        break;
      case AppLifecycleState.hidden:
        // App hidden (iOS specific)
        if (_controller!.value.isPlaying) {
          _wasPlayingBeforeBackground = true;
          _controller!.pause();
        }
        break;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_videoPlayerListener);
    _controller?.dispose();
    super.dispose();
  }

  // Bỏ qua logic tạo HLS và polling, chỉ dùng cho test trực tiếp HLS URL

  // _initializeVideoPlayer is not needed for direct HLS test

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height ?? 200,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_error != null) {
      return Container(
        width: widget.width,
        height: widget.height ?? 200,
        color: Colors.black,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _initializeStream();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_controller != null && _controller!.value.isInitialized) {
      return Container(
        width: widget.width,
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      );
    }
    return Container(
      width: widget.width,
      height: widget.height ?? 200,
      color: Colors.black,
      child: const Center(
        child: Text('No video available', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
