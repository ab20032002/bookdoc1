@echo off
echo ========================================
echo    إعداد بديل لـ BookDoc Iraq
echo ========================================
echo.

echo [1/5] إنشاء مجلد المشروع...
if not exist "bookdoc-iraq" (
    mkdir bookdoc-iraq
    echo ✅ تم إنشاء مجلد bookdoc-iraq
)

cd bookdoc-iraq

echo.
echo [2/5] إنشاء ملفات المشروع الأساسية...

echo إنشاء package.json...
echo {> package.json
echo   "name": "bookdoc-iraq",>> package.json
echo   "version": "1.0.0",>> package.json
echo   "description": "BookDoc Iraq Project",>> package.json
echo   "main": "index.js",>> package.json
echo   "scripts": {>> package.json
echo     "start": "echo Project started successfully!" >> package.json
echo   }>> package.json
echo }>> package.json

echo ✅ تم إنشاء package.json

echo.
echo [3/5] إنشاء ملف HTML بسيط...
echo ^<!DOCTYPE html^> > index.html
echo ^<html lang="ar" dir="rtl"^> >> index.html
echo ^<head^> >> index.html
echo   ^<meta charset="UTF-8"^> >> index.html
echo   ^<title^>BookDoc Iraq^</title^> >> index.html
echo   ^<style^> >> index.html
echo     body { font-family: Arial, sans-serif; text-align: center; padding: 50px; } >> index.html
echo     .container { max-width: 800px; margin: 0 auto; } >> index.html
echo     .success { color: green; font-size: 24px; } >> index.html
echo   ^</style^> >> index.html
echo ^</head^> >> index.html
echo ^<body^> >> index.html
echo   ^<div class="container"^> >> index.html
echo     ^<h1^>BookDoc Iraq^</h1^> >> index.html
echo     ^<p class="success"^>تم تشغيل المشروع بنجاح!^</p^> >> index.html
echo     ^<p^>تطبيق حجز مواعيد الأطباء العراقي^</p^> >> index.html
echo     ^<p^>الميزات:^</p^> >> index.html
echo     ^<ul^> >> index.html
echo       ^<li^>حجز مواعيد الأطباء^</li^> >> index.html
echo       ^<li^>دعم المحافظات العراقية^</li^> >> index.html
echo       ^<li^>طرق الدفع المحلية^</li^> >> index.html
echo       ^<li^>العملة العراقية^</li^> >> index.html
echo     ^</ul^> >> index.html
echo   ^</div^> >> index.html
echo ^</body^> >> index.html
echo ^</html^> >> index.html

echo ✅ تم إنشاء index.html

echo.
echo [4/5] إنشاء ملف README...
echo # BookDoc Iraq > README.md
echo. >> README.md
echo تطبيق حجز مواعيد الأطباء العراقي >> README.md
echo. >> README.md
echo ## الميزات >> README.md
echo - حجز مواعيد الأطباء >> README.md
echo - دعم المحافظات العراقية >> README.md
echo - طرق الدفع المحلية >> README.md
echo - العملة العراقية >> README.md
echo. >> README.md
echo ## التشغيل >> README.md
echo افتح index.html في المتصفح >> README.md

echo ✅ تم إنشاء README.md

echo.
echo [5/5] فتح المشروع...
start index.html

echo.
echo ========================================
echo    تم إنشاء المشروع بنجاح! 🎉
echo ========================================
echo.
echo 📁 تم إنشاء:
echo    - bookdoc-iraq/
echo    - bookdoc-iraq/package.json
echo    - bookdoc-iraq/index.html
echo    - bookdoc-iraq/README.md
echo.
echo 🌐 تم فتح المشروع في المتصفح
echo.
echo 📋 الخطوات التالية:
echo    1. تأكد من تثبيت Node.js و MongoDB
echo    2. أعد تشغيل Command Prompt
echo    3. جرب: node --version
echo    4. جرب: mongod --version
echo.
pause
