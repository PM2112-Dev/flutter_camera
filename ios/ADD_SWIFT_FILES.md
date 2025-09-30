# Hướng dẫn thêm file Swift vào Xcode project

## Các bước cần thực hiện:

### 1. Mở Xcode project
```bash
open ios/Runner.xcworkspace
```

### 2. Thêm file Swift vào project
1. Trong Xcode, right-click vào thư mục `Runner`
2. Chọn "Add Files to 'Runner'"
3. Navigate đến `ios/Runner/ImageGallerySaver.swift`
4. Chọn file và click "Add"
5. Đảm bảo "Add to target" là "Runner"

### 3. Xóa file .m không cần thiết
1. Trong Xcode, tìm file `ImageGallerySaver.m`
2. Right-click và chọn "Delete"
3. Chọn "Move to Trash"

### 4. Build và test
1. Clean build folder (Cmd+Shift+K)
2. Build project (Cmd+B)
3. Run trên device (Cmd+R)

## Lưu ý:
- File `ImageGallerySaver.swift` đã được tối ưu cho Flutter method channel
- Không cần React Native dependencies
- Sử dụng completion handlers thay vì promise resolvers
