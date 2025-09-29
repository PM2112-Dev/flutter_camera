# Hướng dẫn FCM khi đổi tài khoản

## 🔄 Cách FCM hoạt động sau khi sửa

### ✅ **Những gì đã được cải thiện:**

1. **User ID động**: FCM token giờ sử dụng User ID thực từ profile thay vì hard-code
2. **Hủy đăng ký khi logout**: FCM token được xóa khỏi server khi user logout
3. **Đăng ký lại khi login**: FCM token được đăng ký lại với user mới
4. **Tích hợp với Auth Flow**: FCM tự động cập nhật khi có thay đổi authentication

### 📋 **Quy trình hoạt động:**

#### **1. Khi đăng nhập:**
```
Login → Get Profile → Register FCM Token với User mới
```
- FCM token được đăng ký với `userId` thực từ profile
- `isAdmin` được xác định từ `roleNames` của user
- Token được gửi lên server với thông tin user chính xác

#### **2. Khi đăng xuất:**
```
Logout → Unregister FCM Token → Clear User Info
```
- FCM token được xóa khỏi server
- Thông tin user hiện tại bị xóa
- User cũ sẽ không nhận được thông báo nữa

#### **3. Khi đổi tài khoản:**
```
Logout User A → Login User B → Register Token với User B
```
- Token cũ được hủy đăng ký
- Token được đăng ký lại với user mới
- Thông báo sẽ được gửi cho user mới

### 🔧 **Các method mới trong FirebaseMessagingService:**

```dart
// Cập nhật user hiện tại và đăng ký lại token
await firebaseMessagingService.updateCurrentUser(user);

// Hủy đăng ký token khi logout
await firebaseMessagingService.unregisterToken();

// Đăng ký token cho user mới
await firebaseMessagingService.registerTokenForNewUser(user);

// Xóa thông tin user hiện tại
firebaseMessagingService.clearCurrentUser();
```

### 📱 **Tích hợp với AuthBloc:**

- **Login**: Tự động đăng ký FCM token cho user mới
- **Logout**: Tự động hủy đăng ký FCM token
- **App Start**: Kiểm tra và đăng ký token cho user đã đăng nhập
- **Auth Error**: Xóa thông tin FCM khi có lỗi authentication

### 🎯 **Kết quả:**

1. **FCM token không thay đổi** khi đổi tài khoản (vì gắn với thiết bị)
2. **Server được cập nhật** với thông tin user mới cho cùng FCM token
3. **Thông báo chính xác** được gửi đến đúng user
4. **Không có thông báo thừa** từ user cũ
5. **Tự động hóa** hoàn toàn quá trình đổi tài khoản

### 🚀 **Cách test:**

1. **Login với User A** → Kiểm tra logs: "Token registered with server successfully for user A"
2. **Logout** → Kiểm tra logs: "Token unregistered successfully"
3. **Login với User B** → Kiểm tra logs: "Token registered with server successfully for user B"
4. **Gửi thông báo** → Chỉ User B nhận được, User A không nhận

### ⚠️ **Lưu ý:**

- Server cần hỗ trợ API `DELETE /api/Users/userToken` để hủy đăng ký
- FCM token vẫn giữ nguyên trên thiết bị, chỉ thông tin user trên server thay đổi
- Nếu server không hỗ trợ delete, token cũ vẫn có thể nhận thông báo (cần xử lý ở server)

### 🔍 **Debug logs:**

Khi test, tìm các log sau:
- `👤 Firebase: Updating current user to [username] (ID: [id])`
- `✅ Firebase: Token registered with server successfully for user [username]`
- `🗑️ Firebase: Unregistering FCM token...`
- `✅ Firebase: Token unregistered successfully`

