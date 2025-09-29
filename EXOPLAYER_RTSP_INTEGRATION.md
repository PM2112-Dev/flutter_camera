# ExoPlayer RTSP Integration Guide

This document explains how to integrate and use ExoPlayer for RTSP streaming in your Flutter camera app.

## Overview

The ExoPlayer integration provides native Android video playback for RTSP streams with better performance and reliability compared to WebView-based solutions.

## Components

### 1. Android Native Code

#### ExoPlayerManager.kt

- Manages multiple ExoPlayer instances
- Handles RTSP stream playback
- Provides texture-based rendering for Flutter

#### MainActivity.kt

- Sets up method channel communication
- Handles Flutter-to-Android method calls

### 2. Flutter Code

#### ExoPlayerService

- Service class for communicating with Android native code
- Provides methods for player lifecycle management

#### ExoPlayerRtspWidget

- Flutter widget for displaying single RTSP stream
- Handles loading states and error handling

#### MultiExoPlayerRtspWidget

- Flutter widget for displaying multiple RTSP streams in a grid
- Supports customizable grid layout

## Usage Examples

### Single RTSP Stream

```dart
ExoPlayerRtspWidget(
  rtspUrl: "rtsp://admin:password@192.168.1.100:554/stream",
  autoPlay: true,
  width: double.infinity,
  height: 200,
)
```

### Multiple RTSP Streams

```dart
MultiExoPlayerRtspWidget(
  rtspUrls: [
    "rtsp://admin:password@192.168.1.100:554/stream1",
    "rtsp://admin:password@192.168.1.101:554/stream2",
    "rtsp://admin:password@192.168.1.102:554/stream3",
  ],
  crossAxisCount: 2,
  childAspectRatio: 16 / 9,
  autoPlay: true,
)
```

### Programmatic Control

```dart
// Create widget reference
final GlobalKey<_ExoPlayerRtspWidgetState> playerKey = GlobalKey();

// Control playback
await playerKey.currentState?.play();
await playerKey.currentState?.pause();
await playerKey.currentState?.resume();
```

### Helper Functions

```dart
// Create single player
Widget player = createExoPlayerRtspWidget("rtsp://your-url-here");

// Create multiple players
List<Widget> players = createMultipleExoPlayerRtspWidgets([
  "rtsp://url1",
  "rtsp://url2",
  "rtsp://url3",
]);
```

## Key Features

1. **Native Performance**: Uses Android's native ExoPlayer for optimal performance
2. **Multiple Streams**: Support for displaying multiple RTSP streams simultaneously
3. **Auto Retry**: Built-in error handling with retry functionality
4. **Texture Rendering**: Uses Flutter's Texture widget for smooth video display
5. **Memory Management**: Automatic cleanup of resources when widgets are disposed
6. **TCP Support**: Forces RTP over TCP for better compatibility with firewalls

## Configuration

### Android Dependencies

The following dependencies are automatically added to `android/app/build.gradle.kts`:

```kotlin
dependencies {
    implementation("androidx.media3:media3-exoplayer:1.2.1")
    implementation("androidx.media3:media3-exoplayer-rtsp:1.2.1")
    implementation("androidx.media3:media3-ui:1.2.1")
    implementation("androidx.media3:media3-common:1.2.1")
}
```

### Method Channel

The integration uses method channel `com.example.flutter_camera/exoplayer` for communication between Flutter and Android.

## Demo Page

Navigate to the ExoPlayer Demo page from the app drawer to test the integration:

1. **Single Stream Tab**: Shows one RTSP stream in full screen
2. **Multiple Streams Tab**: Shows multiple RTSP streams in a grid layout

## Error Handling

The widgets include comprehensive error handling:

- Network connectivity issues
- Invalid RTSP URLs
- Authentication failures
- Codec compatibility problems

Errors are displayed with retry buttons for user convenience.

## Performance Notes

1. **Android Only**: This implementation is Android-specific
2. **Hardware Acceleration**: ExoPlayer automatically uses hardware decoding when available
3. **Memory Usage**: Each stream creates its own ExoPlayer instance
4. **Network Optimization**: Uses RTP over TCP for better network compatibility

## Troubleshooting

### Common Issues

1. **Black Screen**: Check RTSP URL format and network connectivity
2. **Authentication Errors**: Verify username/password in RTSP URL
3. **Performance Issues**: Limit number of concurrent streams based on device capabilities

### Debug Tips

1. Check Android logs for ExoPlayer errors
2. Test RTSP URLs with external players (VLC, etc.)
3. Verify network connectivity and firewall settings

## Integration with Existing Code

You can easily integrate ExoPlayer widgets into your existing camera streaming setup:

```dart
// Replace WebView-based streaming
CameraStreamWidget(camera: camera) // Old WebView approach

// With ExoPlayer-based streaming
ExoPlayerRtspWidget(rtspUrl: camera.rtspUrl) // New ExoPlayer approach
```

The ExoPlayer widgets follow the same interface patterns as your existing camera widgets for easy migration.

