# Hướng dẫn kiểm tra FCM Token và Push Notifications

## 1. Kiểm tra FCM Token có chuẩn chưa

### Sau khi app khởi động, kiểm tra logs:
```
🔥 Starting Firebase messaging initialization...
🔥 Firebase: Initializing messaging...
🔥 Firebase: Messaging instance created
🔥 Firebase: Background handler registered
📱 Firebase: Permission status: AuthorizationStatus.authorized
🔑 Firebase: Getting FCM token...
🔑 Firebase: FCM Token received: [YOUR_FCM_TOKEN]
📋 Firebase: Token length: [TOKEN_LENGTH] characters
📤 Firebase: Registering token with server...
✅ Firebase: Token registered with server successfully
📨 Firebase: Setting up message handlers...
✅ Firebase: Message handlers setup complete
✅ Firebase: Messaging initialization complete
```

### FCM Token chuẩn sẽ có:
- Độ dài khoảng 140-180 ký tự
- Format: ký tự base64 (A-Z, a-z, 0-9, -, _)
- Ví dụ: `dJ8X9ZrqQR6vK3mN1LpP4t:APA91bH...`

## 2. Kiểm tra trong Notification Management Page

1. Mở app → Drawer → "Cài đặt thông báo"
2. Cuộn xuống phần "Thông tin thiết bị"
3. Kiểm tra:
   - **Trạng thái**: Phải hiện "Đã đăng ký" (màu xanh)
   - **Token**: Hiển thị 20 ký tự đầu + "..."
   - Có nút copy để sao chép token

## 3. Test nhận thông báo

### Bước 1: Lấy FCM Token
- Từ logs hoặc từ UI Notification Management
- Copy token đầy đủ

### Bước 2: Gửi test notification
1. Vào [Firebase Console](https://console.firebase.google.com)
2. Chọn project `flutter-camera-8ba66`
3. Cloud Messaging → "Send your first message"
4. Nhập:
   - **Title**: "Test Notification"
   - **Text**: "This is a test message"
5. Chọn "Single device"
6. Paste FCM token vào
7. (Optional) Thêm data:
   ```json
   {
     "type": "vision_alert",
     "cameraId": "test"
   }
   ```
8. Nhấn "Send"

### Bước 3: Kiểm tra logs khi nhận
```
📨 Firebase: Message received (foreground)
📨 Firebase: messageId: [MESSAGE_ID]
📨 Firebase: Title: Test Notification
📨 Firebase: Body: This is a test message
📨 Firebase: Data: {type: vision_alert, cameraId: test}
🤖 Handling vision alert notification
```

## 4. Troubleshooting

### Nếu không nhận được thông báo:
1. **Kiểm tra permission**: Log phải show "AuthorizationStatus.authorized"
2. **Kiểm tra token**: Token phải có độ dài > 140 ký tự
3. **Kiểm tra app state**:
   - Foreground: Sẽ có log "Message received (foreground)"
   - Background: Sẽ có log "Background message received"
   - Terminated: App sẽ mở với log "App opened from notification"

### Nếu token null hoặc empty:
1. Kiểm tra Firebase initialization trong main.dart
2. Kiểm tra permissions trong AndroidManifest.xml
3. Kiểm tra google-services.json có đúng package name

### Nếu server registration thất bại:
1. Kiểm tra API endpoint `/api/Users/userToken`
2. Kiểm tra auth token
3. Kiểm tra network connectivity

## 5. Debug Commands

### Xem logs realtime:
```bash
flutter logs
```

### Xem Firebase logs:
```bash
adb logcat | grep -i firebase
```

### Test với curl:
```bash
curl -X POST \
  "https://fcm.googleapis.com/fcm/send" \
  -H "Authorization: key=[SERVER_KEY]" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "[FCM_TOKEN]",
    "notification": {
      "title": "Test",
      "body": "Hello World"
    }
  }'
```