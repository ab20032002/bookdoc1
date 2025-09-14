@echo off
chcp 65001 >nul
echo ========================================
echo    تثبيت متطلبات BookDoc Iraq
echo ========================================
echo.

echo [1/4] فتح صفحات التحميل...
echo.
echo 📥 Node.js: https://nodejs.org/
echo 📥 MongoDB: https://www.mongodb.com/try/download/community
echo.

start https://nodejs.org/
timeout /t 3 /nobreak >nul
start https://www.mongodb.com/try/download/community

echo.
echo [2/4] تعليمات التثبيت:
echo.
echo 1. حمل Node.js من الصفحة المفتوحة
echo 2. ثبت Node.js (اضغط Next حتى النهاية)
echo 3. حمل MongoDB من الصفحة المفتوحة
echo 4. ثبت MongoDB (اختر Complete)
echo 5. اختر "Install MongoDB as a Service"
echo.

pause

echo.
echo [3/4] التحقق من التثبيت...
echo.

echo فحص Node.js...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Node.js مثبت بنجاح
    node --version
) else (
    echo ❌ Node.js غير مثبت
    echo يرجى تثبيت Node.js أولاً
)

echo.
echo فحص npm...
npm --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ npm مثبت بنجاح
    npm --version
) else (
    echo ❌ npm غير مثبت
    echo يرجى تثبيت Node.js أولاً
)

echo.
echo فحص MongoDB...
mongod --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ MongoDB مثبت بنجاح
    mongod --version
) else (
    echo ❌ MongoDB غير مثبت
    echo يرجى تثبيت MongoDB أولاً
)

echo.
echo [4/4] النتيجة:
echo.

node --version >nul 2>&1
if %errorlevel% equ 0 (
    mongod --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo 🎉 جميع المتطلبات مثبتة بنجاح!
        echo.
        echo يمكنك الآن تشغيل المشروع باستخدام:
        echo start-all.bat
        echo.
    ) else (
        echo ⚠️  Node.js مثبت لكن MongoDB غير مثبت
        echo يرجى تثبيت MongoDB أولاً
    )
) else (
    echo ❌ المتطلبات غير مكتملة
    echo يرجى تثبيت Node.js و MongoDB أولاً
)

echo.
pause
