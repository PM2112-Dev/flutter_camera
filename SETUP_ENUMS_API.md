# Setup Common Enums API

## 📋 Tóm tắt

Đã thêm API call để lấy danh sách enum từ server (`/api/CommonLists/allEnums`).

## 🔧 Files đã tạo

1. **Model**: `lib/data/network/model/common_enums_model.dart`

   - `CommonEnumsResponse` - Response chứa tất cả enum lists
   - `EnumItem` - Model cho từng enum item (id, code, name)

2. **API Service**: `lib/data/network/api/common_enums_api_service.dart`

   - `CommonEnumsApiService` - Service call API allEnums
   - Đã thêm `@injectable` annotation

3. **Service Layer**: `lib/data/services/common_enums_service.dart`

   - `CommonEnumsService` - Service với caching logic
   - Cache data trong 24 giờ
   - Đã thêm `@lazySingleton` annotation

4. **Integration**:
   - `lib/main.dart` - Pre-load enums khi app khởi động
   - `lib/presentation/ui/utilities/page/utilities_page.dart` - Sử dụng enum data từ API

## ⚠️ BẮT BUỘC: Chạy Build Runner

Sau khi thêm các service mới với annotation, **BẮT BUỘC** phải chạy build_runner:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Hoặc watch mode để auto-rebuild:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 📊 Dữ liệu enum có sẵn

### Temperature Level List (dùng cho filter)

- Good (1) - Tốt
- Fair (2) - Khá
- Average (3) - Trung bình
- Bad (4) - Xấu

### Threshold Type List

- Enviroment (1) - So với môi trường
- Threshold (2) - So với ngưỡng nhiệt
- MinPhase (3) - So với pha min
- TwoArea (4) - So với phần tử cùng loại
- GlobalMinPhase (5) - So với pha min toàn trạm
- GlobalTwoArea (6) - So với phần tử cùng loại toàn trạm

### Và nhiều enum list khác...

- Device Status, Camera Type, Monitor Type, etc.

## 🎯 Cách sử dụng

### Trong code:

```dart
// Get service từ dependency injection
final enumsService = getIt<CommonEnumsService>();

// Load all enums
final enums = await enumsService.getAllEnums();

// Get specific list
final temperatureLevels = enumsService.getTemperatureLevels();
final thresholdTypes = enumsService.getThresholdTypes();
```

### Caching:

- Data tự động cache trong 24 giờ
- Force refresh: `getAllEnums(forceRefresh: true)`
- Clear cache: `enumsService.clearCache()`

## ✅ Đã tích hợp

- ✅ Filter dialog tự động load temperature levels từ API
- ✅ Fallback về default values nếu API fail
- ✅ Loading indicator khi đang fetch data
- ✅ Pre-load khi app khởi động để UX mượt mà hơn

## 🚀 Tiếp theo

1. Chạy `flutter pub run build_runner build --delete-conflicting-outputs`
2. Restart app để test
3. Check console logs để verify enum data được load thành công
