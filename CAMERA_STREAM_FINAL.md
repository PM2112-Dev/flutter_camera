# Camera Stream Widget - Final Version

## **Tổng quan:**

`CameraStreamWidget` đã được sửa lại để **chỉ hiển thị video** thông qua WebView với go2rtc server, loại bỏ tất cả UI elements không cần thiết.

## **Tính năng chính:**

### **1. WebView Streaming:**

- **Go2RTC Server**: `http://thermal.infosysvietnam.com.vn:1984`
- **Multiple Protocols**: WebRTC, MSE, HLS, MJPEG
- **Auto Fallback**: Tự động chuyển đổi protocol
- **Thermal Camera Support**: Scale transform cho thermal camera

### **2. Simplified UI:**

- **Initial State**: Chỉ icon camera
- **Loading State**: Chỉ progress indicator
- **Loaded State**: Chỉ WebView video
- **Error State**: Chỉ icon lỗi
- **Stopped State**: Chỉ icon camera off

### **3. Core Functionality:**

- ✅ WebView streaming với go2rtc
- ✅ Thermal camera support (scale transform)
- ✅ Visibility detection (pause/resume)
- ✅ Auto-play functionality
- ✅ Stream management
- ✅ Proper lifecycle management

## **Code Structure:**

### **1. Dependencies:**

```yaml
dependencies:
  webview_flutter: ^4.4.2
```

### **2. Imports:**

```dart
import 'package:webview_flutter/webview_flutter.dart';
```

### **3. Controller:**

```dart
WebViewController? _webViewController;
```

### **4. URL Building:**

```dart
String _buildGo2RTCUrl() {
  final baseUrl = 'http://thermal.infosysvietnam.com.vn:1984';
  final modes = 'webrtc,mse,hls,mjpeg';
  final background = 'false';
  final width = '320';

  return '$baseUrl/stream.html?src=${widget.camera.uniqueId}&mode=$modes&background=$background&width=${width}px';
}
```

## **UI States:**

### **1. Initial State:**

```dart
Container(
  color: Colors.black,
  child: const Center(
    child: Icon(Icons.videocam_outlined, color: Colors.grey, size: 48),
  ),
)
```

### **2. Loading State:**

```dart
Container(
  color: Colors.black,
  child: const Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    ),
  ),
)
```

### **3. Loaded State:**

```dart
// Thermal camera
ClipRect(
  child: Transform.scale(
    scaleX: 1.4,
    scaleY: 1.0,
    child: WebViewWidget(controller: _webViewController!),
  ),
)

// Regular camera
WebViewWidget(controller: _webViewController!)
```

### **4. Error State:**

```dart
Container(
  color: Colors.black,
  child: const Center(
    child: Icon(Icons.error_outline, color: Colors.red, size: 48),
  ),
)
```

### **5. Stopped State:**

```dart
Container(
  color: Colors.black,
  child: const Center(
    child: Icon(Icons.videocam_off, color: Colors.grey, size: 48),
  ),
)
```

## **Performance Benefits:**

### **1. Minimal UI:**

- Chỉ hiển thị video
- Không có overlays
- Không có status indicators
- Không có control buttons

### **2. Optimized Rendering:**

- Ít UI elements
- Faster loading
- Lower memory usage
- Better performance

### **3. Clean Interface:**

- Tập trung vào video
- Không có distractions
- Simple và effective

## **Usage:**

```dart
CameraStreamWidget(
  camera: camera,
  autoPlay: true,
  onTap: () => print('Tapped'),
)
```

## **Key Features:**

### **1. WebView Integration:**

- Direct go2rtc server connection
- Multiple protocol support
- Auto protocol fallback
- JavaScript injection for basic monitoring

### **2. Thermal Camera Support:**

- Scale transform: `scaleX: 1.4, scaleY: 1.0`
- ClipRect for proper display
- Maintains aspect ratio

### **3. Visibility Management:**

- Pause video when not visible
- Resume video when visible
- App lifecycle management

### **4. Stream Management:**

- Proper initialization
- Clean disposal
- State management
- Error handling

## **Troubleshooting:**

### **1. WebView không load:**

- Kiểm tra network connection
- Kiểm tra go2rtc server
- Kiểm tra stream name

### **2. Video không phát:**

- Kiểm tra protocol support
- Kiểm tra JavaScript injection
- Kiểm tra WebView permissions

### **3. Performance issues:**

- Chọn protocol phù hợp
- Giảm số streams đồng thời
- Tắt background play

## **Kết luận:**

CameraStreamWidget giờ đây:

- **Chỉ hiển thị video** thông qua WebView
- **Không có UI distractions**
- **Tập trung vào core functionality**
- **Performance tối ưu**
- **Clean và simple** interface

Perfect cho việc hiển thị video stream một cách đơn giản và hiệu quả! 🎥
