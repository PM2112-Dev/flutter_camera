# Hướng dẫn Implementation Native iOS cho Image Gallery

## ✅ Đã hoàn thành:

### 1. **Native Swift Code**
- `ios/Runner/ImageGallerySaver.swift` - Class chính xử lý lưu ảnh
- Sử dụng `PHPhotoLibrary` API native của iOS
- Không phụ thuộc vào React Native types

### 2. **Flutter Integration**
- `lib/data/services/ios_image_gallery_service.dart` - Service Dart
- `lib/presentation/ui/device/pages/onvif_camera_page.dart` - UI integration
- Method channel: `image_gallery_saver`

### 3. **iOS Configuration**
- `ios/Runner/Info.plist` - Thêm photo library permissions
- `ios/Runner/AppDelegate.swift` - Method channel handler

## 🔧 Cần thực hiện:

### 1. **Thêm file Swift vào Xcode project**
```bash
# Mở Xcode project
open ios/Runner.xcworkspace
```

**Trong Xcode:**
1. Right-click vào thư mục `Runner`
2. Chọn "Add Files to 'Runner'"
3. Navigate đến `ios/Runner/ImageGallerySaver.swift`
4. Chọn file và click "Add"
5. Đảm bảo "Add to target" là "Runner"

### 2. **Xóa file .m không cần thiết**
1. Trong Xcode, tìm file `ImageGallerySaver.m`
2. Right-click và chọn "Delete"
3. Chọn "Move to Trash"

### 3. **Build và Test**
```bash
# Clean và build
flutter clean
flutter build ios

# Hoặc run trực tiếp
flutter run
```

## 🎯 Cách hoạt động:

### **iOS Flow:**
1. **Tap nút chụp ảnh** → `_captureImage()`
2. **Platform check** → `Platform.isIOS` → `_captureImageForIOS()`
3. **Check permission** → `IosImageGalleryService.checkPermission()`
4. **Request permission** → `IosImageGalleryService.requestPermission()` (nếu cần)
5. **Capture image** → `_captureVideoScreenshotBytes()` hoặc `_createTestImageBytes()`
6. **Save to gallery** → `IosImageGalleryService.saveImageToGallery()`
7. **Native Swift** → `PHPhotoLibrary.shared().performChanges()`

### **Android Flow:**
1. **Tap nút chụp ảnh** → `_captureImage()`
2. **Platform check** → `Platform.isAndroid` → `_captureImageForAndroid()`
3. **GAL permission** → `Gal.hasAccess()` và `Gal.requestAccess()`
4. **Capture & save** → `Gal.putImage()`

## 📱 Test Cases:

### **iOS Device:**
1. **Permission dialog** xuất hiện khi lần đầu chụp ảnh
2. **Ảnh được lưu** vào Photos app
3. **Test image** được tạo nếu không capture được video
4. **Error handling** hiển thị thông báo lỗi

### **Android Device:**
1. **GAL permission** được xin tự động
2. **Ảnh được lưu** vào gallery
3. **Fallback** tạo test image nếu cần

## 🚀 Ưu điểm của Native Swift:

1. **Hiệu suất cao** - Không qua bridge layer phức tạp
2. **Ổn định** - Sử dụng API native của iOS
3. **Tương thích tốt** - Hoạt động với mọi version iOS
4. **Error handling** - Xử lý lỗi chi tiết và rõ ràng
5. **Permission handling** - Tự động xin quyền và xử lý các trường hợp

## 🔍 Debug:

### **Nếu có lỗi build:**
1. Kiểm tra file Swift đã được thêm vào Xcode project
2. Clean build folder (Cmd+Shift+K)
3. Xóa file .m không cần thiết
4. Rebuild project

### **Nếu có lỗi runtime:**
1. Kiểm tra permissions trong Info.plist
2. Kiểm tra method channel name
3. Kiểm tra data types trong method calls

## 📝 Code Structure:

```
ios/Runner/
├── ImageGallerySaver.swift     # Native Swift class
├── AppDelegate.swift          # Method channel handler
└── Info.plist                # Permissions

lib/data/services/
└── ios_image_gallery_service.dart  # Dart service

lib/presentation/ui/device/pages/
└── onvif_camera_page.dart    # UI integration
```

Chức năng native iOS đã sẵn sàng để test! 🎉
