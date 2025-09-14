@echo off
echo ========================================
echo    إصلاح مشاكل PATH
echo ========================================
echo.

echo [1/4] إضافة Node.js إلى PATH...
setx PATH "%PATH%;C:\Program Files\nodejs" /M
echo ✅ تم إضافة Node.js إلى PATH

echo.
echo [2/4] إضافة MongoDB إلى PATH...
setx PATH "%PATH%;C:\Program Files\MongoDB\Server\7.0\bin" /M
echo ✅ تم إضافة MongoDB إلى PATH

echo.
echo [3/4] إضافة MongoDB (مسار بديل)...
setx PATH "%PATH%;C:\Program Files\MongoDB\Server\6.0\bin" /M
echo ✅ تم إضافة MongoDB (مسار بديل) إلى PATH

echo.
echo [4/4] النتيجة:
echo.
echo ⚠️  تم تحديث PATH
echo.
echo 📋 الخطوات التالية:
echo 1. أغلق Command Prompt الحالي
echo 2. افتح Command Prompt جديد
echo 3. جرب: node --version
echo 4. جرب: mongod --version
echo.

pause
