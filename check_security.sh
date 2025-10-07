#!/bin/bash

# Script kiểm tra bảo mật trước khi release
# Chạy script này trước khi build APK/AAB để submit lên Google Play

echo "🔒 ===== SECURITY CHECK FOR GOOGLE PLAY ====="
echo ""

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Biến đếm lỗi
ERRORS=0
WARNINGS=0

# 1. Kiểm tra TrustManager không an toàn
echo "1️⃣ Checking for unsafe TrustManager..."
if grep -r "X509TrustManager" android/ 2>/dev/null | grep -v "\.gradle" | grep -v "build/"; then
    echo -e "${RED}❌ FAIL: Found X509TrustManager implementation${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✅ PASS: No unsafe TrustManager found${NC}"
fi
echo ""

# 2. Kiểm tra vô hiệu hóa SSL
echo "2️⃣ Checking for SSL certificate bypass..."
if grep -r "setDefaultHostnameVerifier\|setDefaultSSLSocketFactory" android/ 2>/dev/null | grep -v "\.gradle" | grep -v "build/"; then
    echo -e "${RED}❌ FAIL: Found SSL bypass code${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✅ PASS: No SSL bypass found${NC}"
fi
echo ""

# 3. Kiểm tra cleartext traffic toàn cục
echo "3️⃣ Checking for global cleartext traffic..."
if grep -q 'android:usesCleartextTraffic="true"' android/app/src/main/AndroidManifest.xml 2>/dev/null; then
    echo -e "${YELLOW}⚠️  WARNING: Global cleartext traffic is enabled${NC}"
    echo "   Consider using Network Security Config instead"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ PASS: No global cleartext traffic${NC}"
fi
echo ""

# 4. Kiểm tra Network Security Config
echo "4️⃣ Checking Network Security Config..."
if [ -f "android/app/src/main/res/xml/network_security_config.xml" ]; then
    echo -e "${GREEN}✅ PASS: Network Security Config exists${NC}"
    
    # Kiểm tra có trust user certificates không
    if grep -q 'src="user"' android/app/src/main/res/xml/network_security_config.xml; then
        echo -e "${YELLOW}⚠️  WARNING: Config trusts user certificates${NC}"
        echo "   Make sure this is removed for production build!"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠️  WARNING: No Network Security Config found${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 5. Kiểm tra debuggable flag
echo "5️⃣ Checking debuggable flag..."
if grep -q 'android:debuggable="true"' android/app/src/main/AndroidManifest.xml 2>/dev/null; then
    echo -e "${RED}❌ FAIL: App is debuggable${NC}"
    echo "   Remove debuggable flag for production!"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✅ PASS: App is not explicitly debuggable${NC}"
fi
echo ""

# 6. Kiểm tra log statements (optional)
echo "6️⃣ Checking for excessive logging..."
LOG_COUNT=$(grep -r "Log\." android/app/src/main/kotlin/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$LOG_COUNT" -gt 50 ]; then
    echo -e "${YELLOW}⚠️  WARNING: Found $LOG_COUNT Log statements${NC}"
    echo "   Consider removing debug logs for production"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ PASS: Logging looks reasonable ($LOG_COUNT statements)${NC}"
fi
echo ""

# 7. Kiểm tra ProGuard/R8
echo "7️⃣ Checking ProGuard/R8 configuration..."
if [ -f "android/app/proguard-rules.pro" ]; then
    echo -e "${GREEN}✅ PASS: ProGuard rules file exists${NC}"
else
    echo -e "${YELLOW}⚠️  WARNING: No ProGuard rules file${NC}"
    echo "   Consider adding obfuscation for production"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Tổng kết
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SUMMARY:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CHECKS PASSED!${NC}"
    echo "   Your app is ready for Google Play submission"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS WARNING(S) FOUND${NC}"
    echo "   Review warnings before submitting to Google Play"
    exit 0
else
    echo -e "${RED}❌ $ERRORS ERROR(S) FOUND${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}   $WARNINGS WARNING(S) ALSO FOUND${NC}"
    fi
    echo ""
    echo "   ⛔ DO NOT SUBMIT TO GOOGLE PLAY UNTIL ERRORS ARE FIXED!"
    echo ""
    exit 1
fi

