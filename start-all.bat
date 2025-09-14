@echo off
chcp 65001 >nul
echo ========================================
echo    BookDoc Iraq - تشغيل المشروع
echo ========================================
echo.

echo [1/6] التحقق من المتطلبات...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Node.js غير مثبت. يرجى تثبيته من https://nodejs.org/
    pause
    exit /b 1
)

where mongod >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ MongoDB غير مثبت. يرجى تثبيته من https://www.mongodb.com/
    pause
    exit /b 1
)

echo ✅ جميع المتطلبات متوفرة
echo.

echo [2/6] تشغيل MongoDB...
start "MongoDB" /min mongod
echo ✅ تم تشغيل MongoDB
echo.

echo [3/6] انتظار MongoDB للبدء...
timeout /t 5 /nobreak >nul
echo.

echo [4/6] تشغيل الخادم الخلفي...
start "BookDoc Backend" cmd /k "cd /d %~dp0backend && echo تشغيل الخادم الخلفي... && npm start"
echo ✅ تم تشغيل الخادم الخلفي
echo.

echo [5/6] انتظار الخادم الخلفي...
timeout /t 10 /nobreak >nul
echo.

echo [6/6] تشغيل التطبيقات...
start "BookDoc Mobile App" cmd /k "cd /d %~dp0mobile-app && echo تشغيل تطبيق المرضى... && npm start"
timeout /t 3 /nobreak >nul

start "BookDoc Doctor Dashboard" cmd /k "cd /d %~dp0doctor-dashboard && echo تشغيل لوحة تحكم الأطباء... && npm start"
timeout /t 3 /nobreak >nul

start "BookDoc Admin Dashboard" cmd /k "cd /d %~dp0admin-dashboard && echo تشغيل لوحة تحكم المدير... && npm start"
echo ✅ تم تشغيل جميع التطبيقات
echo.

echo ========================================
echo    تم تشغيل المشروع بنجاح! 🎉
echo ========================================
echo.
echo 🌐 روابط التطبيقات:
echo    تطبيق المرضى: http://localhost:3000
echo    لوحة تحكم الأطباء: http://localhost:3001
echo    لوحة تحكم المدير: http://localhost:3002
echo    API الخادم الخلفي: http://localhost:5000
echo.
echo 📱 للحصول على أفضل تجربة:
echo    1. افتح المتصفح واذهب إلى الروابط أعلاه
echo    2. جرب إنشاء حساب جديد
echo    3. استكشف الميزات المختلفة
echo.
echo ⚠️  لإيقاف المشروع: أغلق جميع النوافذ المفتوحة
echo.
pause
