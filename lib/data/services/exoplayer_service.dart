import 'package:flutter/services.dart';

class ExoPlayerService {
  static const MethodChannel _channel = MethodChannel('com.example.flutter_camera/exoplayer');

  static final ExoPlayerService _instance = ExoPlayerService._internal();
  factory ExoPlayerService() => _instance;
  ExoPlayerService._internal();

  /// Create a new ExoPlayer instance and return the texture ID
  Future<int?> createPlayer(String playerId) async {
    try {
      final result = await _channel.invokeMethod('createPlayer', {'playerId': playerId});
      return result as int?;
    } catch (e) {
      print('Error creating player: $e');
      return null;
    }
  }

  /// Play an RTSP stream
  Future<void> playRtsp(String playerId, String rtspUrl) async {
    try {
      await _channel.invokeMethod('playRtsp', {'playerId': playerId, 'rtspUrl': rtspUrl});
    } catch (e) {
      print('Error playing RTSP: $e');
    }
  }

  /// Pause the player
  Future<void> pause(String playerId) async {
    try {
      await _channel.invokeMethod('pause', {'playerId': playerId});
    } catch (e) {
      print('Error pausing player: $e');
    }
  }

  /// Resume the player
  Future<void> resume(String playerId) async {
    try {
      await _channel.invokeMethod('resume', {'playerId': playerId});
    } catch (e) {
      print('Error resuming player: $e');
    }
  }

  /// Dispose a specific player
  Future<void> dispose(String playerId) async {
    try {
      await _channel.invokeMethod('dispose', {'playerId': playerId});
    } catch (e) {
      print('Error disposing player: $e');
    }
  }

  /// Dispose all players
  Future<void> disposeAll() async {
    try {
      await _channel.invokeMethod('disposeAll');
    } catch (e) {
      print('Error disposing all players: $e');
    }
  }
}

