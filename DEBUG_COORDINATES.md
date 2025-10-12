# 🐛 DEBUG: Tọa độ thiết bị trên sơ đồ

## Bước 1: Chạy app và xem console log

Khi mở sơ đồ, check console log sẽ hiển thị:

```
📍 Devices overlay:
   Display size: 390.0 x 693.3
   Total devices: 16
   📌 112: (492.5, 471.2) → scaled: (492.5, 471.2)
   📌 112-1: (398.0, 481.8) → scaled: (398.0, 481.8)
   ...
```

## Bước 2: Kiểm tra vị trí trên màn hình

**Nếu markers NẰM NGOÀI màn hình (không nhìn thấy):**
→ Tọa độ quá lớn → Cần scale DOWN

**Ví dụ:**

- Display size: 390 x 693
- Device coordinate: (492.5, 471.2)
- 492.5 > 390 → Marker nằm ngoài màn hình bên phải

**Giải pháp:** Hình ảnh gốc lớn hơn màn hình hiển thị

## Bước 3: Tính kích thước hình ảnh gốc

### Option A: Mở file hình ảnh

1. Copy URL từ log: `widget.area.fullPhotoUrl`
2. Mở trong browser
3. Right click → "Open image in new tab"
4. Check properties → Note kích thước (VD: 1920 x 1080)

### Option B: Dùng DevTools

1. In Flutter DevTools, check widget inspector
2. Tìm Image widget
3. Xem ImageInfo

### Option C: Hỏi backend

Kích thước ảnh sơ đồ là bao nhiêu?

## Bước 4: Cập nhật code với kích thước đúng

Giả sử hình ảnh gốc là **1920 x 1080**:

### File: utilities_page.dart

Tìm dòng này (line ~499):

```dart
// Giả sử tọa độ API là trên ảnh có width = 1000 (cần điều chỉnh)
// Tạm thời dùng trực tiếp, sẽ cần thông tin kích thước ảnh gốc từ API
final scaledX = originalX;
final scaledY = originalY;
```

Sửa thành:

```dart
// Kích thước ảnh GỐC (lấy từ properties của file ảnh)
const originalImageWidth = 1920.0;  // ← THAY ĐỔI ĐÚNG KÍCH THƯỚC
const originalImageHeight = 1080.0; // ← THAY ĐỔI ĐÚNG KÍCH THƯỚC

// Tính scale ratio
final scaleX = _imageSize!.width / originalImageWidth;
final scaleY = _imageSize!.height / originalImageHeight;

// Scale tọa độ
final scaledX = originalX * scaleX;
final scaledY = originalY * scaleY;
```

## Bước 5: Test lại

Sau khi sửa, chạy lại app:

```
📍 Devices overlay:
   Display size: 390.0 x 219.4
   Total devices: 16
   📌 112: (492.5, 471.2) → scaled: (100.0, 95.4)   ← Đã scale
   📌 112-1: (398.0, 481.8) → scaled: (80.8, 97.5)  ← Đã scale
```

Check:

- ✅ Markers nằm trong màn hình (0-390 x 0-219)
- ✅ Markers ở đúng vị trí trên thiết bị
- ✅ Zoom in/out → Markers vẫn đúng vị trí

## Bước 6: Nếu vẫn sai

### Tọa độ đã scale nhưng vẫn sai vị trí

**Check 1: Aspect ratio**

- Hình gốc: 1920x1080 = ratio 16:9
- Display: 390x219 = ratio 16:9
- Nếu ratio khác nhau → BoxFit.contain sẽ có padding

**Check 2: Gốc tọa độ**

- (0, 0) là góc trên-trái hay góc dưới-trái?
- Thử invert Y: `scaledY = _imageSize!.height - (originalY * scaleY)`

**Check 3: Marker center**

- Marker 48x48px, đang trừ 24 để center
- Nếu marker khác size, cần điều chỉnh

## Quick Fix: Hardcode để test

Nếu bạn biết 1 thiết bị ở vị trí nào trên ảnh, thử hardcode:

```dart
// Test với device "112"
if (device.name == "112") {
  // Giả sử trên ảnh device này ở giữa màn hình
  scaledX = _imageSize!.width / 2;
  scaledY = _imageSize!.height / 2;
}
```

Nếu device "112" hiện đúng ở giữa → Scale ratio logic đúng, chỉ cần kích thước gốc đúng.

## Recommended Solution

**Best practice:** Yêu cầu backend thêm vào API:

```json
{
  "id": 5,
  "name": "Khu vực A",
  "photoPath": "/diagrams/area5.jpg",
  "imageWidth": 1920, // ← Thêm field này
  "imageHeight": 1080, // ← Thêm field này
  "mapType": "Picture"
}
```

Sau đó code tự động tính scale, không cần hardcode!
