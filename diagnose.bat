@echo off
echo ========================================
echo    تشخيص مشاكل BookDoc Iraq
echo ========================================
echo.

echo [1/6] فحص Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Node.js موجود في النظام
    node --version
) else (
    echo ❌ Node.js غير موجود في PATH
    echo.
    echo الحلول:
    echo 1. أعد تشغيل Command Prompt
    echo 2. أعد تشغيل الكمبيوتر
    echo 3. أضف Node.js إلى PATH يدوياً
)

echo.
echo [2/6] فحص npm...
where npm >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ npm موجود في النظام
    npm --version
) else (
    echo ❌ npm غير موجود في PATH
)

echo.
echo [3/6] فحص MongoDB...
where mongod >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ MongoDB موجود في النظام
    mongod --version
) else (
    echo ❌ MongoDB غير موجود في PATH
    echo.
    echo الحلول:
    echo 1. أعد تشغيل Command Prompt
    echo 2. أعد تشغيل الكمبيوتر
    echo 3. أضف MongoDB إلى PATH يدوياً
)

echo.
echo [4/6] فحص متغيرات البيئة...
echo PATH = %PATH%
echo.

echo [5/6] فحص مجلدات التثبيت...
if exist "C:\Program Files\nodejs\node.exe" (
    echo ✅ Node.js مثبت في C:\Program Files\nodejs\
) else (
    echo ❌ Node.js غير موجود في C:\Program Files\nodejs\
)

if exist "C:\Program Files\MongoDB\Server\*\bin\mongod.exe" (
    echo ✅ MongoDB مثبت في C:\Program Files\MongoDB\
) else (
    echo ❌ MongoDB غير موجود في C:\Program Files\MongoDB\
)

echo.
echo [6/6] الحلول المقترحة:
echo.
echo 1. أعد تشغيل Command Prompt
echo 2. أعد تشغيل الكمبيوتر
echo 3. تأكد من تثبيت البرامج كمدير
echo 4. أضف المسارات إلى PATH يدوياً
echo.

pause
