@echo off
chcp 65001 >nul
echo ========================================
echo    تشغيل BookDoc Iraq يدوياً
echo ========================================
echo.

echo [1/6] التحقق من المتطلبات...
echo.

echo فحص Node.js...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js غير مثبت
    echo يرجى تثبيت Node.js أولاً من https://nodejs.org/
    pause
    exit /b 1
) else (
    echo ✅ Node.js مثبت
    node --version
)

echo.
echo فحص MongoDB...
where mongod >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MongoDB غير مثبت
    echo يرجى تثبيت MongoDB أولاً من https://www.mongodb.com/try/download/community
    pause
    exit /b 1
) else (
    echo ✅ MongoDB مثبت
    mongod --version
)

echo.
echo [2/6] إنشاء مجلد المشروع...
if not exist "bookdoc-iraq" (
    mkdir bookdoc-iraq
    echo ✅ تم إنشاء مجلد bookdoc-iraq
)

cd bookdoc-iraq

echo.
echo [3/6] إنشاء الخادم الخلفي...
if not exist "backend" (
    mkdir backend
    echo ✅ تم إنشاء مجلد backend
)

cd backend

echo إنشاء package.json...
echo {> package.json
echo   "name": "bookdoc-backend",>> package.json
echo   "version": "1.0.0",>> package.json
echo   "main": "server.js",>> package.json
echo   "scripts": {>> package.json
echo     "start": "node server.js">> package.json
echo   },>> package.json
echo   "dependencies": {>> package.json
echo     "express": "^4.18.2",>> package.json
echo     "cors": "^2.8.5">> package.json
echo   }>> package.json
echo }>> package.json

echo إنشاء server.js...
echo const express = require('express'); > server.js
echo const cors = require('cors'); >> server.js
echo. >> server.js
echo const app = express(); >> server.js
echo const PORT = 5000; >> server.js
echo. >> server.js
echo app.use(cors()); >> server.js
echo app.use(express.json()); >> server.js
echo. >> server.js
echo app.get('/', (req, res) =^> { >> server.js
echo   res.json({ message: 'BookDoc Iraq API is running!' }); >> server.js
echo }); >> server.js
echo. >> server.js
echo app.get('/api/health', (req, res) =^> { >> server.js
echo   res.json({ status: 'OK', message: 'API is healthy' }); >> server.js
echo }); >> server.js
echo. >> server.js
echo app.listen(PORT, () =^> { >> server.js
echo   console.log(`Server is running on port ${PORT}`); >> server.js
echo }); >> server.js

echo ✅ تم إنشاء الخادم الخلفي

echo.
echo [4/6] تثبيت تبعيات الخادم الخلفي...
npm install
echo ✅ تم تثبيت تبعيات الخادم الخلفي

echo.
echo [5/6] إنشاء تطبيق الواجهة الأمامية...
cd ..

if not exist "frontend" (
    mkdir frontend
    echo ✅ تم إنشاء مجلد frontend
)

cd frontend

echo إنشاء index.html...
echo ^<!DOCTYPE html^> > index.html
echo ^<html lang="ar" dir="rtl"^> >> index.html
echo ^<head^> >> index.html
echo   ^<meta charset="UTF-8"^> >> index.html
echo   ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> index.html
echo   ^<title^>BookDoc Iraq^</title^> >> index.html
echo   ^<style^> >> index.html
echo     * { margin: 0; padding: 0; box-sizing: border-box; } >> index.html
echo     body { font-family: 'Arial', sans-serif; background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); min-height: 100vh; } >> index.html
echo     .container { max-width: 1200px; margin: 0 auto; padding: 20px; } >> index.html
echo     .header { text-align: center; color: white; margin-bottom: 40px; } >> index.html
echo     .header h1 { font-size: 3rem; margin-bottom: 10px; } >> index.html
echo     .header p { font-size: 1.2rem; opacity: 0.9; } >> index.html
echo     .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 40px; } >> index.html
echo     .feature { background: white; padding: 30px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); text-align: center; } >> index.html
echo     .feature h3 { color: #333; margin-bottom: 15px; font-size: 1.5rem; } >> index.html
echo     .feature p { color: #666; line-height: 1.6; } >> index.html
echo     .cta { text-align: center; } >> index.html
echo     .btn { background: #4CAF50; color: white; padding: 15px 30px; border: none; border-radius: 25px; font-size: 1.1rem; cursor: pointer; text-decoration: none; display: inline-block; margin: 10px; transition: all 0.3s; } >> index.html
echo     .btn:hover { background: #45a049; transform: translateY(-2px); } >> index.html
echo     .status { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin-top: 20px; } >> index.html
echo     .status h3 { color: white; margin-bottom: 10px; } >> index.html
echo     .status p { color: white; opacity: 0.9; } >> index.html
echo   ^</style^> >> index.html
echo ^</head^> >> index.html
echo ^<body^> >> index.html
echo   ^<div class="container"^> >> index.html
echo     ^<div class="header"^> >> index.html
echo       ^<h1^>BookDoc Iraq^</h1^> >> index.html
echo       ^<p^>تطبيق حجز مواعيد الأطباء العراقي^</p^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="features"^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>حجز المواعيد^</h3^> >> index.html
echo         ^<p^>احجز موعدك مع أفضل الأطباء في العراق بسهولة وسرعة^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>المحافظات العراقية^</h3^> >> index.html
echo         ^<p^>ابحث عن الأطباء في جميع محافظات العراق^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>طرق الدفع المحلية^</h3^> >> index.html
echo         ^<p^>ادفع بالدينار العراقي وبطرق الدفع المحلية^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>المصطلحات الطبية^</h3^> >> index.html
echo         ^<p^>استخدم المصطلحات الطبية العراقية المألوفة^</p^> >> index.html
echo       ^</div^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="cta"^> >> index.html
echo       ^<a href="#" class="btn" onclick="testAPI()"^>اختبار API^</a^> >> index.html
echo       ^<a href="#" class="btn" onclick="showStatus()"^>عرض الحالة^</a^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="status" id="status" style="display: none;"^> >> index.html
echo       ^<h3^>حالة النظام^</h3^> >> index.html
echo       ^<p id="statusText"^>جاري التحقق...^</p^> >> index.html
echo     ^</div^> >> index.html
echo   ^</div^> >> index.html
echo. >> index.html
echo   ^<script^> >> index.html
echo     async function testAPI() { >> index.html
echo       try { >> index.html
echo         const response = await fetch('http://localhost:5000/api/health'); >> index.html
echo         const data = await response.json(); >> index.html
echo         alert('API يعمل بنجاح: ' + data.message); >> index.html
echo       } catch (error) { >> index.html
echo         alert('خطأ في الاتصال بـ API: ' + error.message); >> index.html
echo       } >> index.html
echo     } >> index.html
echo. >> index.html
echo     async function showStatus() { >> index.html
echo       const statusDiv = document.getElementById('status'); >> index.html
echo       const statusText = document.getElementById('statusText'); >> index.html
echo       statusDiv.style.display = 'block'; >> index.html
echo. >> index.html
echo       try { >> index.html
echo         const response = await fetch('http://localhost:5000/api/health'); >> index.html
echo         const data = await response.json(); >> index.html
echo         statusText.innerHTML = '✅ API يعمل بنجاح - ' + data.message; >> index.html
echo       } catch (error) { >> index.html
echo         statusText.innerHTML = '❌ خطأ في الاتصال بـ API: ' + error.message; >> index.html
echo       } >> index.html
echo     } >> index.html
echo   ^</script^> >> index.html
echo ^</body^> >> index.html
echo ^</html^> >> index.html

echo ✅ تم إنشاء تطبيق الواجهة الأمامية

echo.
echo [6/6] تشغيل المشروع...
echo.

echo تشغيل MongoDB...
start "MongoDB" /min mongod

echo انتظار 5 ثوان...
timeout /t 5 /nobreak >nul

echo تشغيل الخادم الخلفي...
start "Backend Server" cmd /k "cd /d %~dp0bookdoc-iraq\backend && npm start"

echo انتظار 10 ثوان...
timeout /t 10 /nobreak >nul

echo فتح تطبيق الواجهة الأمامية...
start index.html

echo.
echo ========================================
echo    تم تشغيل المشروع بنجاح! 🎉
echo ========================================
echo.
echo 🌐 الروابط:
echo    الواجهة الأمامية: index.html (مفتوح في المتصفح)
echo    API الخادم الخلفي: http://localhost:5000
echo.
echo 📋 للاختبار:
echo    1. تأكد من فتح index.html في المتصفح
echo    2. اضغط على "اختبار API"
echo    3. اضغط على "عرض الحالة"
echo.
echo ⚠️  إذا لم يعمل:
echo    1. تأكد من تثبيت Node.js و MongoDB
echo    2. أعد تشغيل Command Prompt
echo    3. جرب تشغيل الملفات يدوياً
echo.
pause
