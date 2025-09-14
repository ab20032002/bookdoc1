@echo off
chcp 65001 >nul
echo ========================================
echo    BookDoc Iraq - تشغيل سريع
echo ========================================
echo.

echo [1/5] التحقق من المتطلبات...
echo.

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js غير مثبت
    echo يرجى تشغيل install-requirements.bat أولاً
    pause
    exit /b 1
)

mongod --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MongoDB غير مثبت
    echo يرجى تشغيل install-requirements.bat أولاً
    pause
    exit /b 1
)

echo ✅ جميع المتطلبات متوفرة
echo.

echo [2/5] إنشاء مجلد المشروع...
if not exist "bookdoc-iraq" (
    mkdir bookdoc-iraq
    echo ✅ تم إنشاء مجلد bookdoc-iraq
) else (
    echo ✅ مجلد bookdoc-iraq موجود
)
echo.

echo [3/5] تشغيل MongoDB...
start "MongoDB" /min mongod
echo ✅ تم تشغيل MongoDB
echo.

echo [4/5] انتظار MongoDB للبدء...
timeout /t 5 /nobreak >nul
echo.

echo [5/5] إنشاء ملفات المشروع...
echo.

cd bookdoc-iraq

if not exist "backend" (
    mkdir backend
    echo ✅ تم إنشاء مجلد backend
)

if not exist "mobile-app" (
    mkdir mobile-app
    echo ✅ تم إنشاء مجلد mobile-app
)

if not exist "doctor-dashboard" (
    mkdir doctor-dashboard
    echo ✅ تم إنشاء مجلد doctor-dashboard
)

if not exist "admin-dashboard" (
    mkdir admin-dashboard
    echo ✅ تم إنشاء مجلد admin-dashboard
)

echo.
echo ========================================
echo    تم إعداد المشروع بنجاح! 🎉
echo ========================================
echo.
echo 📁 تم إنشاء المجلدات:
echo    - bookdoc-iraq/
echo    - bookdoc-iraq/backend/
echo    - bookdoc-iraq/mobile-app/
echo    - bookdoc-iraq/doctor-dashboard/
echo    - bookdoc-iraq/admin-dashboard/
echo.
echo 🗄️  MongoDB يعمل في الخلفية
echo.
echo 📋 الخطوات التالية:
echo    1. اتبع دليل التشغيل المفصل
echo    2. أو استخدم start-all.bat
echo.
echo 📖 للمساعدة: راجع SIMPLE_SETUP_GUIDE.md
echo.
pause
