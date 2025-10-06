# 🔔 Notification Sound Fix

## ❌ **Vấn đề:**
- **Khi app đang mở**: Notification có âm thanh ✅
- **Khi app đang đóng**: Notification không có âm thanh ❌

## 🔍 **Nguyên nhân:**

### 1. **Khi app đang mở (Foreground)**:
- Flutter app xử lý notification
- Sử dụng `_showLocalNotification()` method
- Âm thanh được control bởi `_notificationPreference.soundEnabled`

### 2. **Khi app đang đóng (Background)**:
- Hệ thống Android/iOS xử lý notification
- **Không** sử dụng Flutter code
- Âm thanh phụ thuộc vào:
  - Server payload
  - Android notification channel
  - iOS notification settings

## ✅ **Giải pháp đã thực hiện:**

### 1. **Sửa Android Notification Channel**:
```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications',
  importance: Importance.max,
  playSound: true,  // ✅ Đảm bảo có âm thanh
  enableVibration: true,
  showBadge: true,
);
```

### 2. **Sửa Android Notification Details**:
```dart
final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.max,
  priority: Priority.high,
  playSound: _notificationPreference.soundEnabled,
  enableVibration: _notificationPreference.vibrationEnabled,
  sound: const RawResourceAndroidNotificationSound('notification'), // ✅ Âm thanh mặc định
);
```

### 3. **Sửa iOS Notification Details**:
```dart
final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: _notificationPreference.soundEnabled,
  sound: _notificationPreference.soundEnabled ? 'default' : 'default', // ✅ Luôn có âm thanh
  interruptionLevel: InterruptionLevel.active, // ✅ Active notification
);
```

## 🎯 **Kết quả mong đợi:**

### **Android:**
- ✅ App mở: Có âm thanh (Flutter control)
- ✅ App đóng: Có âm thanh (Android system control)

### **iOS:**
- ✅ App mở: Có âm thanh (Flutter control)  
- ✅ App đóng: Có âm thanh (iOS system control)

## 📱 **Cách test:**

1. **Test khi app mở:**
   - Mở app
   - Gửi notification từ server
   - ✅ Phải có âm thanh

2. **Test khi app đóng:**
   - Đóng app hoàn toàn (swipe up)
   - Gửi notification từ server
   - ✅ Phải có âm thanh

## ⚠️ **Lưu ý quan trọng:**

### **Server cần gửi đúng payload:**
```json
{
  "notification": {
    "title": "Thông báo",
    "body": "Nội dung thông báo",
    "sound": "default"  // ✅ Quan trọng!
  },
  "data": {
    "id": "123",
    "type": "alert"
  }
}
```

### **Android Settings:**
- User phải cho phép notification sound
- App không bị battery optimization
- Notification channel không bị disable

### **iOS Settings:**
- User phải cho phép notification sound
- App không bị Background App Refresh disable
- Notification permission được grant

## 🔧 **Nếu vẫn không có âm thanh:**

1. **Kiểm tra server payload** có `"sound": "default"`
2. **Kiểm tra device settings** - notification sound enabled
3. **Kiểm tra app settings** - notification permission granted
4. **Test trên device thật** (không phải simulator)
5. **Kiểm tra battery optimization** settings
