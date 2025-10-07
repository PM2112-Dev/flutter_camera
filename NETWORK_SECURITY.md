# Network Security Configuration

## Tổng quan

Ứng dụng này sử dụng **Network Security Configuration** để đảm bảo tính bảo mật khi kết nối mạng. Cấu hình này thay thế cho việc vô hiệu hóa SSL certificate checking (một lỗ hổng bảo mật nghiêm trọng).

## Cấu hình hiện tại

### Production (Mặc định)

- ✅ **Chỉ tin tưởng system certificates** (CA certificates được cài đặt sẵn)
- ✅ **Không cho phép cleartext traffic** (HTTP) trên hầu hết các domain
- ✅ **Bảo mật cao** - Tuân thủ chính sách Google Play

### Development (Localhost)

- ✅ **Cho phép cleartext traffic** cho localhost, 127.0.0.1, và 10.0.2.2
- ✅ Giúp test với local server trong quá trình phát triển

## File cấu hình

### `android/app/src/main/res/xml/network_security_config.xml`

```xml
<network-security-config>
    <!-- Trust only system certificates -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>

    <!-- Allow cleartext for localhost (development) -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">127.0.0.1</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

## Nếu cần trust self-signed certificates (Development Only)

### ⚠️ CẢNH BÁO

**Chỉ sử dụng cho môi trường development, KHÔNG BAO GIỜ release lên production với cấu hình này!**

### Cách thêm domain cụ thể:

1. Mở `network_security_config.xml`
2. Thêm domain-config cho server development:

```xml
<domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">your-dev-server.com</domain>
    <trust-anchors>
        <certificates src="system" />
        <certificates src="user" />
    </trust-anchors>
</domain-config>
```

3. **LƯU Ý**: Xóa hoặc comment section này trước khi build production!

## Build variants (Khuyến nghị)

### Tạo file riêng cho development:

```xml
<!-- debug/res/xml/network_security_config.xml -->
<network-security-config>
    <!-- More permissive config for development -->
</network-security-config>
```

### Và file riêng cho production:

```xml
<!-- release/res/xml/network_security_config.xml -->
<network-security-config>
    <!-- Strict config for production -->
</network-security-config>
```

## Lỗi thường gặp

### 1. CertPathValidatorException: Trust anchor for certification path not found

**Nguyên nhân**: Server sử dụng self-signed certificate hoặc certificate không được trust

**Giải pháp**:

- **Production**: Yêu cầu server sử dụng certificate từ CA hợp lệ (Let's Encrypt, etc.)
- **Development**: Thêm domain vào network_security_config.xml (như hướng dẫn ở trên)

### 2. Cleartext HTTP traffic not permitted

**Nguyên nhân**: App cố gắng kết nối HTTP thay vì HTTPS

**Giải pháp**:

- Sử dụng HTTPS thay vì HTTP
- Hoặc thêm domain vào `<domain-config cleartextTrafficPermitted="true">` (chỉ cho development)

## Kiểm tra trước khi release

- [ ] Xóa tất cả các `<certificates src="user" />` trong production config
- [ ] Đảm bảo `cleartextTrafficPermitted="false"` cho base-config
- [ ] Xóa các domain-config cho development servers
- [ ] Test ứng dụng với production server
- [ ] Chạy `./gradlew assembleRelease` và kiểm tra không có warning về network security

## Tài liệu tham khảo

- [Android Network Security Configuration](https://developer.android.com/training/articles/security-config)
- [Google Play Security Best Practices](https://support.google.com/googleplay/android-developer/answer/9888379)
- [Certificate Pinning on Android](https://developer.android.com/training/articles/security-ssl)

## Changelog

### 2025-01-07

- ✅ **Xóa hoàn toàn TrustManager không an toàn** trong MainActivity
- ✅ **Xóa UnsafeHttpDataSourceFactory**
- ✅ **Thêm Network Security Configuration** đúng chuẩn
- ✅ **Loại bỏ android:usesCleartextTraffic="true"** toàn cục
- ✅ Tuân thủ chính sách Google Play về Device and Network Abuse

### Trước đây

- ❌ Sử dụng TrustManager không an toàn (vi phạm chính sách)
- ❌ Vô hiệu hóa SSL certificate checking (lỗ hổng bảo mật nghiêm trọng)
