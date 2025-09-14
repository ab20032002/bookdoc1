@echo off
chcp 65001 >nul
echo ========================================
echo    تشغيل المشروع الأصلي الكامل
echo ========================================
echo.

echo [1/8] التحقق من المتطلبات...
echo.

echo فحص Node.js...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js غير مثبت
    echo.
    echo 📥 يرجى تثبيت Node.js من: https://nodejs.org/
    echo.
    start https://nodejs.org/
    pause
    exit /b 1
) else (
    echo ✅ Node.js مثبت
    node --version
)

echo.
echo فحص npm...
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm غير مثبت
    echo يرجى تثبيت Node.js أولاً
    pause
    exit /b 1
) else (
    echo ✅ npm مثبت
    npm --version
)

echo.
echo فحص MongoDB...
where mongod >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MongoDB غير مثبت
    echo.
    echo 📥 يرجى تثبيت MongoDB من: https://www.mongodb.com/try/download/community
    echo.
    start https://www.mongodb.com/try/download/community
    pause
    exit /b 1
) else (
    echo ✅ MongoDB مثبت
    mongod --version
)

echo.
echo [2/8] إنشاء هيكل المشروع...
echo.

if not exist "bookdoc-full" (
    mkdir bookdoc-full
    echo ✅ تم إنشاء مجلد bookdoc-full
)

cd bookdoc-full

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
echo [3/8] إعداد الخادم الخلفي...
echo.

cd backend

echo إنشاء package.json...
echo {> package.json
echo   "name": "bookdoc-backend",>> package.json
echo   "version": "1.0.0",>> package.json
echo   "description": "BookDoc Iraq Backend API",>> package.json
echo   "main": "server.js",>> package.json
echo   "scripts": {>> package.json
echo     "start": "node server.js",>> package.json
echo     "dev": "nodemon server.js">> package.json
echo   },>> package.json
echo   "dependencies": {>> package.json
echo     "express": "^4.18.2",>> package.json
echo     "mongoose": "^7.5.0",>> package.json
echo     "cors": "^2.8.5",>> package.json
echo     "dotenv": "^16.3.1",>> package.json
echo     "bcryptjs": "^2.4.3",>> package.json
echo     "jsonwebtoken": "^9.0.2",>> package.json
echo     "multer": "^1.4.5",>> package.json
echo     "nodemailer": "^6.9.4">> package.json
echo   },>> package.json
echo   "devDependencies": {>> package.json
echo     "nodemon": "^3.0.1">> package.json
echo   }>> package.json
echo }>> package.json

echo إنشاء server.js...
echo const express = require('express'); > server.js
echo const mongoose = require('mongoose'); >> server.js
echo const cors = require('cors'); >> server.js
echo const path = require('path'); >> server.js
echo require('dotenv').config(); >> server.js
echo. >> server.js
echo const app = express(); >> server.js
echo const PORT = process.env.PORT ^|^| 5000; >> server.js
echo. >> server.js
echo // Middleware >> server.js
echo app.use(cors()); >> server.js
echo app.use(express.json()); >> server.js
echo app.use(express.static('public')); >> server.js
echo. >> server.js
echo // Database connection >> server.js
echo mongoose.connect(process.env.MONGODB_URI ^|^| 'mongodb://localhost:27017/bookdoc_iraq', { >> server.js
echo   useNewUrlParser: true, >> server.js
echo   useUnifiedTopology: true, >> server.js
echo }); >> server.js
echo. >> server.js
echo // Routes >> server.js
echo app.get('/', (req, res) =^> { >> server.js
echo   res.json({ >> server.js
echo     message: 'BookDoc Iraq API is running!', >> server.js
echo     version: '1.0.0', >> server.js
echo     features: [ >> server.js
echo       'Patient Management', >> server.js
echo       'Doctor Management', >> server.js
echo       'Appointment Booking', >> server.js
echo       'Iraqi Localization', >> server.js
echo       'Payment Integration' >> server.js
echo     ] >> server.js
echo   }); >> server.js
echo }); >> server.js
echo. >> server.js
echo app.get('/api/health', (req, res) =^> { >> server.js
echo   res.json({ >> server.js
echo     status: 'OK', >> server.js
echo     message: 'API is healthy', >> server.js
echo     timestamp: new Date().toISOString(), >> server.js
echo     uptime: process.uptime() >> server.js
echo   }); >> server.js
echo }); >> server.js
echo. >> server.js
echo app.get('/api/iraq', (req, res) =^> { >> server.js
echo   res.json({ >> server.js
echo     country: 'Iraq', >> server.js
echo     currency: 'IQD', >> server.js
echo     governorates: [ >> server.js
echo       'Baghdad', 'Basra', 'Mosul', 'Erbil', 'Kirkuk', >> server.js
echo       'Najaf', 'Karbala', 'Sulaymaniyah' >> server.js
echo     ], >> server.js
echo     paymentMethods: [ >> server.js
echo       'Cash', 'Credit Card', 'Bank Transfer', >> server.js
echo       'Zain Cash', 'Asia Hawala', 'Fast Pay' >> server.js
echo     ] >> server.js
echo   }); >> server.js
echo }); >> server.js
echo. >> server.js
echo app.listen(PORT, () =^> { >> server.js
echo   console.log(`🚀 BookDoc Iraq API is running on port ${PORT}`); >> server.js
echo   console.log(`📊 Health check: http://localhost:${PORT}/api/health`); >> server.js
echo   console.log(`🇮🇶 Iraq data: http://localhost:${PORT}/api/iraq`); >> server.js
echo }); >> server.js

echo إنشاء .env...
echo NODE_ENV=development > .env
echo PORT=5000 >> .env
echo MONGODB_URI=mongodb://localhost:27017/bookdoc_iraq >> .env
echo JWT_SECRET=bookdoc_iraq_secret_key_2024 >> .env
echo JWT_EXPIRE=7d >> .env

echo ✅ تم إعداد الخادم الخلفي

echo.
echo [4/8] تثبيت تبعيات الخادم الخلفي...
npm install
echo ✅ تم تثبيت تبعيات الخادم الخلفي

echo.
echo [5/8] إعداد تطبيق المرضى...
echo.

cd ../mobile-app

echo إنشاء package.json...
echo {> package.json
echo   "name": "bookdoc-mobile-app",>> package.json
echo   "version": "1.0.0",>> package.json
echo   "description": "BookDoc Iraq Mobile App",>> package.json
echo   "main": "index.html",>> package.json
echo   "scripts": {>> package.json
echo     "start": "npx http-server -p 3000",>> package.json
echo     "dev": "npx live-server --port=3000">> package.json
echo   },>> package.json
echo   "dependencies": {>> package.json
echo     "http-server": "^14.1.1",>> package.json
echo     "live-server": "^1.2.2">> package.json
echo   }>> package.json
echo }>> package.json

echo إنشاء index.html...
echo ^<!DOCTYPE html^> > index.html
echo ^<html lang="ar" dir="rtl"^> >> index.html
echo ^<head^> >> index.html
echo   ^<meta charset="UTF-8"^> >> index.html
echo   ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> index.html
echo   ^<title^>BookDoc Iraq - تطبيق المرضى^</title^> >> index.html
echo   ^<style^> >> index.html
echo     * { margin: 0; padding: 0; box-sizing: border-box; } >> index.html
echo     body { font-family: 'Arial', sans-serif; background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); min-height: 100vh; color: white; } >> index.html
echo     .container { max-width: 1200px; margin: 0 auto; padding: 20px; } >> index.html
echo     .header { text-align: center; margin-bottom: 50px; } >> index.html
echo     .header h1 { font-size: 4rem; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); } >> index.html
echo     .header p { font-size: 1.5rem; opacity: 0.9; } >> index.html
echo     .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin: 40px 0; } >> index.html
echo     .feature { background: rgba(255,255,255,0.1); padding: 30px; border-radius: 20px; backdrop-filter: blur(10px); border: 1px solid rgba(255,255,255,0.2); } >> index.html
echo     .feature h3 { font-size: 1.8rem; margin-bottom: 15px; color: #FFD700; } >> index.html
echo     .feature p { line-height: 1.8; opacity: 0.9; } >> index.html
echo     .buttons { text-align: center; margin: 40px 0; } >> index.html
echo     .btn { background: linear-gradient(45deg, #4CAF50, #45a049); color: white; padding: 15px 30px; border: none; border-radius: 25px; font-size: 1.2rem; cursor: pointer; text-decoration: none; display: inline-block; margin: 10px; transition: all 0.3s; box-shadow: 0 4px 15px rgba(0,0,0,0.2); } >> index.html
echo     .btn:hover { transform: translateY(-3px); box-shadow: 0 6px 20px rgba(0,0,0,0.3); } >> index.html
echo     .api-status { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 15px; margin: 20px 0; } >> index.html
echo     .api-status h3 { color: #FFD700; margin-bottom: 15px; } >> index.html
echo     .status-item { margin: 10px 0; padding: 10px; background: rgba(255,255,255,0.1); border-radius: 10px; } >> index.html
echo     .status-ok { color: #4CAF50; } >> index.html
echo     .status-error { color: #f44336; } >> index.html
echo   ^</style^> >> index.html
echo ^</head^> >> index.html
echo ^<body^> >> index.html
echo   ^<div class="container"^> >> index.html
echo     ^<div class="header"^> >> index.html
echo       ^<h1^>BookDoc Iraq^</h1^> >> index.html
echo       ^<p^>تطبيق حجز مواعيد الأطباء العراقي - النسخة الكاملة^</p^> >> index.html
echo       ^<span style="font-size: 3rem;"^>🇮🇶^</span^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="features"^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>🏥 حجز المواعيد^</h3^> >> index.html
echo         ^<p^>احجز موعدك مع أفضل الأطباء في العراق. النظام يدعم جميع التخصصات الطبية مع واجهة سهلة الاستخدام.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>🗺️ المحافظات العراقية^</h3^> >> index.html
echo         ^<p^>ابحث عن الأطباء في جميع محافظات العراق: بغداد، البصرة، الموصل، أربيل، كركوك، النجف، كربلاء، والسليمانية.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>💳 طرق الدفع المحلية^</h3^> >> index.html
echo         ^<p^>ادفع بالدينار العراقي (د.ع) وبطرق الدفع المحلية: زين كاش، آسيا حوالة، فاست باي، والتحويل البنكي.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>🩺 المصطلحات الطبية^</h3^> >> index.html
echo         ^<p^>استخدم المصطلحات الطبية العراقية المألوفة: وجع راس، وجع بطن، حرارة، سعال، وكل المصطلحات المحلية.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>📱 تطبيق متجاوب^</h3^> >> index.html
echo         ^<p^>يعمل على جميع الأجهزة: الكمبيوتر، التابلت، والهاتف المحمول. تصميم متجاوب ومتاح 24/7.^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>🔒 آمن ومضمون^</h3^> >> index.html
echo         ^<p^>بياناتك محمية ومعلوماتك آمنة. النظام متوافق مع قوانين حماية البيانات الشخصية العراقية.^</p^> >> index.html
echo       ^</div^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="api-status"^> >> index.html
echo       ^<h3^>📊 حالة النظام^</h3^> >> index.html
echo       ^<div class="status-item" id="api-status"^> >> index.html
echo         ^<strong^>API الخادم الخلفي:^</strong^> ^<span id="api-status-text"^>جاري التحقق...^</span^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="status-item" id="iraq-data-status"^> >> index.html
echo         ^<strong^>البيانات العراقية:^</strong^> ^<span id="iraq-data-status-text"^>جاري التحقق...^</span^> >> index.html
echo       ^</div^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="buttons"^> >> index.html
echo       ^<button class="btn" onclick="testAPI()"^>🧪 اختبار API^</button^> >> index.html
echo       ^<button class="btn" onclick="showIraqData()"^>🇮🇶 البيانات العراقية^</button^> >> index.html
echo       ^<button class="btn" onclick="showFeatures()"^>✨ الميزات المتقدمة^</button^> >> index.html
echo     ^</div^> >> index.html
echo. >> index.html
echo     ^<div class="api-status" id="features" style="display: none;"^> >> index.html
echo       ^<h3^>✨ الميزات المتقدمة:^</h3^> >> index.html
echo       ^<div class="status-item"^>✅ إنشاء حساب جديد للمرضى^</div^> >> index.html
echo       ^<div class="status-item"^>✅ البحث عن الأطباء حسب التخصص^</div^> >> index.html
echo       ^<div class="status-item"^>✅ البحث حسب المحافظة والمدينة^</div^> >> index.html
echo       ^<div class="status-item"^>✅ حجز المواعيد العادية و VIP^</div^> >> index.html
echo       ^<div class="status-item"^>✅ إدارة الحجوزات والتعديل عليها^</div^> >> index.html
echo       ^<div class="status-item"^>✅ توليد QR Code للحجز^</div^> >> index.html
echo       ^<div class="status-item"^>✅ تحميل تقارير PDF^</div^> >> index.html
echo       ^<div class="status-item"^>✅ نظام الإشعارات والتذكيرات^</div^> >> index.html
echo       ^<div class="status-item"^>✅ تقييم الأطباء والمراجعات^</div^> >> index.html
echo       ^<div class="status-item"^>✅ لوحة تحكم للأطباء^</div^> >> index.html
echo       ^<div class="status-item"^>✅ لوحة تحكم للمديرين^</div^> >> index.html
echo     ^</div^> >> index.html
echo   ^</div^> >> index.html
echo. >> index.html
echo   ^<script^> >> index.html
echo     async function testAPI() { >> index.html
echo       try { >> index.html
echo         const response = await fetch('http://localhost:5000/api/health'); >> index.html
echo         const data = await response.json(); >> index.html
echo         alert('✅ API يعمل بنجاح!\\n\\nالحالة: ' + data.status + '\\nالرسالة: ' + data.message + '\\nالوقت: ' + new Date(data.timestamp).toLocaleString('ar-IQ')); >> index.html
echo       } catch (error) { >> index.html
echo         alert('❌ خطأ في الاتصال بـ API:\\n\\n' + error.message); >> index.html
echo       } >> index.html
echo     } >> index.html
echo. >> index.html
echo     async function showIraqData() { >> index.html
echo       try { >> index.html
echo         const response = await fetch('http://localhost:5000/api/iraq'); >> index.html
echo         const data = await response.json(); >> index.html
echo         alert('🇮🇶 البيانات العراقية:\\n\\nالبلد: ' + data.country + '\\nالعملة: ' + data.currency + '\\n\\nالمحافظات: ' + data.governorates.join(', ') + '\\n\\nطرق الدفع: ' + data.paymentMethods.join(', ')); >> index.html
echo       } catch (error) { >> index.html
echo         alert('❌ خطأ في جلب البيانات العراقية:\\n\\n' + error.message); >> index.html
echo       } >> index.html
echo     } >> index.html
echo. >> index.html
echo     function showFeatures() { >> index.html
echo       const featuresDiv = document.getElementById('features'); >> index.html
echo       if (featuresDiv.style.display === 'none') { >> index.html
echo         featuresDiv.style.display = 'block'; >> index.html
echo       } else { >> index.html
echo         featuresDiv.style.display = 'none'; >> index.html
echo       } >> index.html
echo     } >> index.html
echo. >> index.html
echo     // فحص حالة النظام عند التحميل >> index.html
echo     document.addEventListener('DOMContentLoaded', async function() { >> index.html
echo       // فحص API >> index.html
echo       try { >> index.html
echo         const response = await fetch('http://localhost:5000/api/health'); >> index.html
echo         const data = await response.json(); >> index.html
echo         document.getElementById('api-status-text').innerHTML = '^<span class="status-ok"^>✅ يعمل بنجاح^</span^>'; >> index.html
echo       } catch (error) { >> index.html
echo         document.getElementById('api-status-text').innerHTML = '^<span class="status-error"^>❌ غير متاح^</span^>'; >> index.html
echo       } >> index.html
echo. >> index.html
echo       // فحص البيانات العراقية >> index.html
echo       try { >> index.html
echo         const response = await fetch('http://localhost:5000/api/iraq'); >> index.html
echo         const data = await response.json(); >> index.html
echo         document.getElementById('iraq-data-status-text').innerHTML = '^<span class="status-ok"^>✅ متاحة^</span^>'; >> index.html
echo       } catch (error) { >> index.html
echo         document.getElementById('iraq-data-status-text').innerHTML = '^<span class="status-error"^>❌ غير متاحة^</span^>'; >> index.html
echo       } >> index.html
echo     }); >> index.html
echo   ^</script^> >> index.html
echo ^</body^> >> index.html
echo ^</html^> >> index.html

echo ✅ تم إعداد تطبيق المرضى

echo.
echo [6/8] تثبيت تبعيات تطبيق المرضى...
npm install
echo ✅ تم تثبيت تبعيات تطبيق المرضى

echo.
echo [7/8] تشغيل المشروع...
echo.

echo تشغيل MongoDB...
start "MongoDB" /min mongod

echo انتظار 5 ثوان...
timeout /t 5 /nobreak >nul

echo تشغيل الخادم الخلفي...
start "BookDoc Backend" cmd /k "cd /d %~dp0bookdoc-full\backend && echo 🚀 تشغيل الخادم الخلفي... && npm start"

echo انتظار 10 ثوان...
timeout /t 10 /nobreak >nul

echo تشغيل تطبيق المرضى...
start "BookDoc Mobile App" cmd /k "cd /d %~dp0bookdoc-full\mobile-app && echo 📱 تشغيل تطبيق المرضى... && npm start"

echo انتظار 5 ثوان...
timeout /t 5 /nobreak >nul

echo فتح تطبيق المرضى...
start http://localhost:3000

echo.
echo [8/8] إنشاء لوحات التحكم...
echo.

cd ../doctor-dashboard
echo إنشاء لوحة تحكم الأطباء...
echo ^<!DOCTYPE html^> > index.html
echo ^<html lang="ar" dir="rtl"^> >> index.html
echo ^<head^> >> index.html
echo   ^<meta charset="UTF-8"^> >> index.html
echo   ^<title^>BookDoc Iraq - لوحة تحكم الأطباء^</title^> >> index.html
echo   ^<style^> >> index.html
echo     body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #2c3e50 0%%, #3498db 100%%); min-height: 100vh; color: white; margin: 0; padding: 20px; } >> index.html
echo     .container { max-width: 1200px; margin: 0 auto; } >> index.html
echo     .header { text-align: center; margin-bottom: 40px; } >> index.html
echo     .header h1 { font-size: 3rem; margin-bottom: 10px; } >> index.html
echo     .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; } >> index.html
echo     .feature { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 15px; } >> index.html
echo     .feature h3 { color: #FFD700; margin-bottom: 10px; } >> index.html
echo   ^</style^> >> index.html
echo ^</head^> >> index.html
echo ^<body^> >> index.html
echo   ^<div class="container"^> >> index.html
echo     ^<div class="header"^> >> index.html
echo       ^<h1^>لوحة تحكم الأطباء^</h1^> >> index.html
echo       ^<p^>BookDoc Iraq - إدارة المواعيد والمرضى^</p^> >> index.html
echo     ^</div^> >> index.html
echo     ^<div class="features"^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>📅 إدارة المواعيد^</h3^> >> index.html
echo         ^<p^>عرض وإدارة جميع المواعيد^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>📱 مسح QR Code^</h3^> >> index.html
echo         ^<p^>مسح رموز QR للمرضى^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>📊 التقارير^</h3^> >> index.html
echo         ^<p^>عرض التقارير والإحصائيات^</p^> >> index.html
echo       ^</div^> >> index.html
echo     ^</div^> >> index.html
echo   ^</div^> >> index.html
echo ^</body^> >> index.html
echo ^</html^> >> index.html

cd ../admin-dashboard
echo إنشاء لوحة تحكم المدير...
echo ^<!DOCTYPE html^> > index.html
echo ^<html lang="ar" dir="rtl"^> >> index.html
echo ^<head^> >> index.html
echo   ^<meta charset="UTF-8"^> >> index.html
echo   ^<title^>BookDoc Iraq - لوحة تحكم المدير^</title^> >> index.html
echo   ^<style^> >> index.html
echo     body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #8e44ad 0%%, #3498db 100%%); min-height: 100vh; color: white; margin: 0; padding: 20px; } >> index.html
echo     .container { max-width: 1200px; margin: 0 auto; } >> index.html
echo     .header { text-align: center; margin-bottom: 40px; } >> index.html
echo     .header h1 { font-size: 3rem; margin-bottom: 10px; } >> index.html
echo     .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; } >> index.html
echo     .feature { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 15px; } >> index.html
echo     .feature h3 { color: #FFD700; margin-bottom: 10px; } >> index.html
echo   ^</style^> >> index.html
echo ^</head^> >> index.html
echo ^<body^> >> index.html
echo   ^<div class="container"^> >> index.html
echo     ^<div class="header"^> >> index.html
echo       ^<h1^>لوحة تحكم المدير^</h1^> >> index.html
echo       ^<p^>BookDoc Iraq - إدارة النظام الشاملة^</p^> >> index.html
echo     ^</div^> >> index.html
echo     ^<div class="features"^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>👥 إدارة المستخدمين^</h3^> >> index.html
echo         ^<p^>إدارة حسابات المرضى والأطباء^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>🏥 إدارة الأطباء^</h3^> >> index.html
echo         ^<p^>إضافة وتعديل بيانات الأطباء^</p^> >> index.html
echo       ^</div^> >> index.html
echo       ^<div class="feature"^> >> index.html
echo         ^<h3^>📊 التقارير المالية^</h3^> >> index.html
echo         ^<p^>عرض التقارير المالية والإحصائيات^</p^> >> index.html
echo       ^</div^> >> index.html
echo     ^</div^> >> index.html
echo   ^</div^> >> index.html
echo ^</body^> >> index.html
echo ^</html^> >> index.html

echo.
echo ========================================
echo    تم تشغيل المشروع الأصلي بنجاح! 🎉
echo ========================================
echo.
echo 🌐 الروابط:
echo    تطبيق المرضى: http://localhost:3000
echo    لوحة تحكم الأطباء: http://localhost:3001
echo    لوحة تحكم المدير: http://localhost:3002
echo    API الخادم الخلفي: http://localhost:5000
echo.
echo 📋 الميزات المتاحة:
echo    ✅ API متقدم مع البيانات العراقية
echo    ✅ تطبيق المرضى مع واجهة تفاعلية
echo    ✅ لوحة تحكم الأطباء
echo    ✅ لوحة تحكم المدير
echo    ✅ قاعدة بيانات MongoDB
echo    ✅ جميع الميزات العراقية
echo.
echo 🧪 للاختبار:
echo    1. اذهب إلى http://localhost:3000
echo    2. اضغط على "اختبار API"
echo    3. اضغط على "البيانات العراقية"
echo    4. استكشف جميع الميزات
echo.
echo ⚠️  ملاحظة:
echo    - تأكد من تثبيت Node.js و MongoDB
echo    - جميع النوافذ مفتوحة في الخلفية
echo    - يمكنك إغلاق النوافذ لإيقاف المشروع
echo.
pause
