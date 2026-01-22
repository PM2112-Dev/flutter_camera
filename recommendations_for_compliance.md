# Khuyến nghị để tuân thủ Google Play Policy

## **1. Cải thiện ngay lập tức:**

### **A. Cập nhật AndroidManifest.xml:**
```xml
<!-- Thêm mô tả rõ ràng cho quyền nhạy cảm -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"
    tools:ignore="ScopedStorage" />
    
<!-- Thêm feature declarations -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

### **B. Cập nhật build.gradle:**
```kotlin
android {
    defaultConfig {
        // Đổi applicationId thành tên công ty chính thức
        applicationId = "com.mtktech.thermalvision"
        
        // Thêm mô tả ứng dụng
        manifestPlaceholders = [
            appName: "MTK Thermal Vision",
            appDescription: "Official thermal camera monitoring system for MTK Technology"
        ]
    }
}
```

### **C. Cải thiện mô tả ứng dụng:**
```yaml
# pubspec.yaml
name: mtk_thermal_vision
description: "Official thermal camera monitoring application for MTK Technology industrial surveillance systems."
```

## **2. Thêm tài liệu chính thức:**

### **A. Tạo Privacy Policy:**
- Tạo trang web chính thức với Privacy Policy
- Giải thích rõ cách sử dụng dữ liệu
- Liên kết trong ứng dụng và Google Play Console

### **B. Cập nhật README.md:**
```markdown
# MTK Thermal Vision

Official thermal camera monitoring application for MTK Technology.

## Purpose
This application is designed for authorized personnel to monitor industrial thermal cameras and security systems.

## Features
- Real-time thermal camera streaming
- Security notifications
- Industrial monitoring dashboard
- Authorized access only

## Company Information
MTK Technology - Industrial Monitoring Solutions
Website: https://mtktech.com.vn
```

## **3. Cải thiện code để tuân thủ:**

### **A. Thêm permission rationale:**
```dart
// Trong main.dart hoặc permission handler
Future<void> requestStoragePermission() async {
  if (await Permission.manageExternalStorage.isDenied) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Permission Required'),
        content: Text(
          'This app needs storage access to save camera images and monitoring reports for industrial surveillance purposes.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Permission.manageExternalStorage.request();
            },
            child: Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}
```

### **B. Thêm company branding:**
```dart
// Trong app theme
class AppTheme {
  static const String companyName = 'MTK Technology';
  static const String appPurpose = 'Industrial Thermal Monitoring';
  
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.blue,
    appBarTheme: AppBarTheme(
      title: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
```

## **4. Tài liệu cần chuẩn bị:**

### **A. Giấy tờ pháp lý:**
- Giấy phép kinh doanh của MTK Technology
- Giấy chứng nhận đăng ký doanh nghiệp
- Hợp đồng lao động hoặc ủy quyền phát triển ứng dụng

### **B. Tài liệu kỹ thuật:**
- Sơ đồ kiến trúc hệ thống
- Chứng chỉ bảo mật server
- Tài liệu API và giao thức RTSP

### **C. Chính sách và quy trình:**
- Privacy Policy chi tiết
- Terms of Service
- Data Retention Policy
- Security Policy

## **5. Chiến lược phòng ngừa:**

### **A. Tạo website chính thức:**
```
https://mtktech.com.vn/thermal-vision
- Giới thiệu ứng dụng
- Hướng dẫn sử dụng
- Liên hệ hỗ trợ
- Privacy Policy
- Terms of Service
```

### **B. Cải thiện Google Play listing:**
- Sử dụng screenshots thực tế của ứng dụng
- Mô tả chi tiết chức năng và mục đích
- Thêm thông tin liên hệ công ty
- Danh mục phù hợp: "Business" hoặc "Tools"

### **C. Compliance checklist:**
- [ ] Cập nhật applicationId thành tên công ty
- [ ] Thêm Privacy Policy
- [ ] Cải thiện mô tả ứng dụng
- [ ] Thêm company branding
- [ ] Tạo website chính thức
- [ ] Chuẩn bị tài liệu pháp lý
- [ ] Test ứng dụng trên nhiều thiết bị
- [ ] Đảm bảo không có crash hoặc lỗi

## **6. Lời khuyên cho tương lai:**

1. **Luôn giữ tài liệu đầy đủ** về mục đích sử dụng ứng dụng
2. **Cập nhật thường xuyên** Privacy Policy và Terms of Service
3. **Giám sát feedback** từ người dùng và Google Play Console
4. **Tuân thủ nghiêm ngặt** các chính sách mới của Google
5. **Backup code và tài liệu** để tránh mất dữ liệu

## **7. Liên hệ hỗ trợ:**

Nếu cần hỗ trợ thêm:
- Google Play Developer Support
- Flutter Community Forums
- Android Developer Documentation
- Legal consultation for app compliance

