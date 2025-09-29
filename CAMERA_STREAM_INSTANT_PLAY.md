# Camera Stream Widget - Instant Play

## **Tổng quan:**

`CameraStreamWidget` đã được sửa để **phát video ngay lập tức** khi widget được tạo, loại bỏ tất cả delays và staggered loading.

## **Thay đổi chính:**

### **1. Instant Play:**

```dart
// Trước: Complex delayed loading
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _subscribeToStream();
  _initializeWebView();

  // Auto start stream if autoPlay is true, but with a small delay to stagger initialization
  if (widget.autoPlay) {
    // Check if this is a newly added camera (streams already exist)
    final hasExistingStreams = _streamManager.activeStreamCount > 0;
    debugPrint(
      'CameraStream: Camera ${widget.camera.name} checking for existing streams: $hasExistingStreams (activeCount: ${_streamManager.activeStreamCount})',
    );

    if (hasExistingStreams) {
      // For newly added cameras, use a longer delay to ensure existing streams are stable
      final delay = Duration(milliseconds: 500 + (_streamManager.activeStreamCount * 300));
      Future.delayed(delay, () {
        if (mounted) {
          debugPrint(
            'CameraStream: Starting delayed auto-play for newly added camera: ${widget.camera.name} (delay: ${delay.inMilliseconds}ms, existing streams: ${_streamManager.activeStreamCount})',
          );
          _streamManager.startStream(widget.camera);
        }
      });
    } else {
      // For startup cameras, use original staggered loading
      final delay = Duration(milliseconds: 100 + (widget.camera.id * 200));
      Future.delayed(delay, () {
        if (mounted) {
          debugPrint(
            'CameraStream: Starting delayed auto-play stream for ${widget.camera.name} (delay: ${delay.inMilliseconds}ms)',
          );
          _streamManager.startStream(widget.camera);
        }
      });
    }
  }
}

// Sau: Instant play
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _subscribeToStream();
  _initializeWebView();

  // Start stream immediately
  _streamManager.startStream(widget.camera);
}
```

### **2. Loại bỏ Delays:**

- ❌ Staggered loading delays
- ❌ Camera ID-based delays
- ❌ Active stream count delays
- ❌ Complex delay calculations

### **3. Simplified Initialization:**

- ✅ Immediate stream start
- ✅ No delay calculations
- ✅ No complex conditions
- ✅ Direct stream management

## **Tính năng:**

### **1. Instant Play:**

- **Immediate Start**: Video bắt đầu ngay khi widget được tạo
- **No Delays**: Không có delays hoặc staggered loading
- **Direct Connection**: Kết nối trực tiếp với go2rtc server

### **2. WebView Streaming:**

- **Go2RTC Server**: `http://thermal.mtktech.com.vn:1984`
- **Multiple Protocols**: WebRTC, MSE, HLS, MJPEG
- **Auto Fallback**: Tự động chuyển đổi protocol
- **Thermal Camera Support**: Scale transform cho thermal camera

### **3. Simplified UI:**

- **Initial State**: Chỉ icon camera
- **Loading State**: Chỉ progress indicator
- **Loaded State**: Chỉ WebView video
- **Error State**: Chỉ icon lỗi
- **Stopped State**: Chỉ icon camera off

## **Code Structure:**

### **1. Instant Initialization:**

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _subscribeToStream();
  _initializeWebView();

  // Start stream immediately
  _streamManager.startStream(widget.camera);
}
```

### **2. Direct Stream Management:**

```dart
// No more complex delay logic
// No more staggered loading
// No more camera ID calculations
// Just direct stream start
```

### **3. Simplified URL Building:**

```dart
String _buildGo2RTCUrl() {
  final baseUrl = 'http://thermal.mtktech.com.vn:1984';
  final modes = 'webrtc,mse,hls,mjpeg';
  final background = 'false';
  final width = '320';

  return '$baseUrl/stream.html?src=${widget.camera.uniqueId}&mode=$modes&background=$background&width=${width}px';
}
```

## **Performance Benefits:**

### **1. Faster Loading:**

- **No Delays**: Video bắt đầu ngay lập tức
- **Direct Connection**: Không có waiting time
- **Immediate Response**: User thấy video ngay

### **2. Simplified Logic:**

- **Less Code**: Ít code hơn
- **No Complex Calculations**: Không có delay calculations
- **Easier Maintenance**: Dễ maintain hơn

### **3. Better User Experience:**

- **Instant Feedback**: User thấy video ngay
- **No Waiting**: Không phải chờ đợi
- **Smooth Experience**: Trải nghiệm mượt mà

## **Usage:**

```dart
// Widget sẽ phát video ngay lập tức
CameraStreamWidget(
  camera: camera,
  autoPlay: true, // Không cần thiết nữa vì luôn auto play
  onTap: () => print('Tapped'),
)
```

## **Key Features:**

### **1. Instant Play:**

- Video bắt đầu ngay khi widget được tạo
- Không có delays hoặc staggered loading
- Direct connection với go2rtc server

### **2. WebView Integration:**

- Direct go2rtc server connection
- Multiple protocol support
- Auto protocol fallback
- JavaScript injection for basic monitoring

### **3. Thermal Camera Support:**

- Scale transform: `scaleX: 1.4, scaleY: 1.0`
- ClipRect for proper display
- Maintains aspect ratio

### **4. Visibility Management:**

- Pause video when not visible
- Resume video when visible
- App lifecycle management

## **Troubleshooting:**

### **1. Video không phát ngay:**

- Kiểm tra network connection
- Kiểm tra go2rtc server
- Kiểm tra stream name

### **2. Performance issues:**

- Chọn protocol phù hợp
- Giảm số streams đồng thời
- Tắt background play

### **3. Memory issues:**

- Kiểm tra stream disposal
- Kiểm tra WebView cleanup
- Kiểm tra lifecycle management

## **Kết luận:**

CameraStreamWidget giờ đây:

- **Phát video ngay lập tức** khi widget được tạo
- **Không có delays** hoặc staggered loading
- **Tập trung vào core functionality**
- **Performance tối ưu**
- **User experience tốt hơn**

Perfect cho việc hiển thị video stream một cách nhanh chóng và hiệu quả! 🎥⚡
