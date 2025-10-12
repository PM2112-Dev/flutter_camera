# 🔧 Hướng dẫn fix tọa độ thiết bị trên sơ đồ

## ⚠️ Vấn đề hiện tại

Code hiện tại đang sử dụng **TRỰC TIẾP** tọa độ từ API:

```dart
left: device.longitude,  // VD: 492.5
top: device.latitude,    // VD: 471.25
```

**Tọa độ này là tọa độ PIXEL trên hình ảnh GỐC**, không phải tọa độ màn hình!

## 📊 Ví dụ minh họa

### Case 1: Hình ảnh lớn hơn màn hình

```
Hình ảnh gốc:     1920 x 1080 px
Màn hình:         390 x 844 px
Scale ratio:      ~0.203 (390/1920)

Device coordinate trong API:
  longitude: 492.5 px (trên hình gốc)
  latitude:  471.25 px (trên hình gốc)

Coordinate trên màn hình:
  left: 492.5 * 0.203 = ~100 px
  top:  471.25 * 0.203 = ~95.6 px
```

### Case 2: Hình ảnh nhỏ hơn màn hình

```
Hình ảnh gốc:     800 x 600 px
Màn hình:         390 x 844 px
Scale ratio:      0.4875 (390/800)

Device coordinate trong API:
  longitude: 400 px (trên hình gốc)
  latitude:  300 px (trên hình gốc)

Coordinate trên màn hình:
  left: 400 * 0.4875 = 195 px
  top:  300 * 0.4875 = 146.25 px
```

## 🔍 Cách kiểm tra

### 1. Chạy app và xem log

```dart
// Khi mở sơ đồ, check console log:
📍 Devices overlay - Display size: 390.0 x 600.0
📍 Total devices: 16
   Device 112: (492.5, 471.25)
   Device 112-1: (398.0, 481.75)
   ...
```

### 2. So sánh vị trí

- Nếu markers **ĐÃ ĐÚNG VỊ TRÍ** trên thiết bị → API đã trả về tọa độ đã scale sẵn ✅
- Nếu markers **SAI VỊ TRÍ** (quá xa hoặc quá gần) → Cần tính scale ❌

## ✅ Solution: Tính scale ratio

### Bước 1: Lấy kích thước hình ảnh gốc

**Option A: Từ Image widget**

```dart
void _updateImageSize() {
  final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox != null && mounted) {
    // Get displayed size
    final displayedSize = renderBox.size;

    // Get original image size (cần ImageStream)
    final ImageStream stream = (renderBox as RenderImage?)?.image;
    stream?.addListener(ImageStreamListener((ImageInfo info, bool synchronousCall) {
      final originalWidth = info.image.width.toDouble();
      final originalHeight = info.image.height.toDouble();

      setState(() {
        _imageSize = displayedSize;
        _originalImageSize = Size(originalWidth, originalHeight);
      });
    }));
  }
}
```

**Option B: Hardcode nếu biết trước**

```dart
// Nếu biết hình ảnh sơ đồ luôn có kích thước cố định
final Size _originalImageSize = Size(1920, 1080); // Ví dụ
```

**Option C: Từ API** (Tốt nhất)

```dart
// Thêm vào AreaMapItem model:
class AreaMapItem {
  ...
  final int? imageWidth;   // Thêm field này
  final int? imageHeight;  // Thêm field này
}
```

### Bước 2: Tính scale ratio và áp dụng

```dart
Widget _buildDevicesOverlay(List<DeviceItem> devices) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Get sizes
      final displaySize = _imageSize ?? Size(constraints.maxWidth, constraints.maxHeight);
      final originalSize = _originalImageSize ?? Size(1920, 1080); // Fallback

      // Calculate scale ratios
      final scaleX = displaySize.width / originalSize.width;
      final scaleY = displaySize.height / originalSize.height;

      print('📏 Original: ${originalSize.width} x ${originalSize.height}');
      print('📏 Display:  ${displaySize.width} x ${displaySize.height}');
      print('📏 Scale:    $scaleX x $scaleY');

      return Stack(
        children: devices.map((device) {
          // ✅ Apply scale to coordinates
          final left = device.longitude * scaleX;
          final top = device.latitude * scaleY;

          return Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () => _onDeviceTap(device),
              child: _buildDeviceMarker(device),
            ),
          );
        }).toList(),
      );
    },
  );
}
```

### Bước 3: Handle rotation

Nếu có rotation (`_rotationAngle`), cần transform tọa độ:

```dart
// For 90° rotation
if (_rotationAngle == 90) {
  final newLeft = displaySize.height - top;
  final newTop = left;
  left = newLeft;
  top = newTop;
}
```

## 🧪 Testing

### Test Case 1: Tọa độ góc

```dart
// Device ở góc trên-trái (0, 0)
// Device ở góc dưới-phải (originalWidth, originalHeight)
// Kiểm tra xem markers có đúng góc không
```

### Test Case 2: Zoom in/out

```dart
// InteractiveViewer scale 0.5x → Markers vẫn đúng vị trí
// InteractiveViewer scale 2x → Markers vẫn đúng vị trí
```

### Test Case 3: Rotation

```dart
// Rotate 90° → Markers xoay theo
// Rotate 180° → Markers xoay theo
```

## 📝 Notes

1. **Tọa độ từ API** = Pixel coordinates trên hình ảnh gốc
2. **BoxFit.contain** = Hình được scale để fit màn hình, giữ nguyên aspect ratio
3. **InteractiveViewer** = Zoom/pan không ảnh hưởng vì nó transform cả Stack
4. **Transform.rotate** = Cần transform tọa độ nếu có rotation

## 🎯 Recommended Approach

**Tốt nhất:** Yêu cầu backend thêm `imageWidth` và `imageHeight` vào API response của AreaMapItem:

```json
{
  "id": 5,
  "name": "Khu vực A",
  "photoPath": "/path/to/diagram.jpg",
  "imageWidth": 1920,
  "imageHeight": 1080,
  "mapType": "Picture"
}
```

Như vậy frontend không cần đoán hoặc load image để lấy kích thước.
