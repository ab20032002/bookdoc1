# دليل تشغيل مشروع BookDoc العراقي - دليل شامل

## 📋 المتطلبات الأساسية

### 1. البرامج المطلوبة
- **Node.js** (الإصدار 16 أو أحدث)
- **MongoDB** (الإصدار 4.4 أو أحدث)
- **Git** (لتحميل المشروع)
- **محرر نصوص** (VS Code مفضل)

### 2. تحميل البرامج

#### تحميل Node.js
1. اذهب إلى: https://nodejs.org/
2. حمل الإصدار LTS (مستقر)
3. ثبت البرنامج
4. تأكد من التثبيت:
```bash
node --version
npm --version
```

#### تحميل MongoDB
1. اذهب إلى: https://www.mongodb.com/try/download/community
2. حمل MongoDB Community Server
3. ثبت البرنامج
4. تأكد من التثبيت:
```bash
mongod --version
mongo --version
```

#### تحميل Git
1. اذهب إلى: https://git-scm.com/
2. حمل Git for Windows
3. ثبت البرنامج
4. تأكد من التثبيت:
```bash
git --version
```

## 🚀 خطوات التشغيل التفصيلية

### الخطوة 1: تحميل المشروع

```bash
# إنشاء مجلد للمشروع
mkdir bookdoc-iraq
cd bookdoc-iraq

# تحميل المشروع (إذا كان على GitHub)
git clone https://github.com/your-username/bookdoc-iraq.git

# أو إنشاء المشروع من الصفر
mkdir bookdoc-project
cd bookdoc-project
```

### الخطوة 2: إنشاء هيكل المشروع

```bash
# إنشاء المجلدات الأساسية
mkdir mobile-app
mkdir doctor-dashboard
mkdir admin-dashboard
mkdir backend
mkdir database
mkdir docs

# إنشاء ملف package.json الرئيسي
```

### الخطوة 3: إعداد قاعدة البيانات

#### تشغيل MongoDB
```bash
# في نافذة Terminal منفصلة
mongod

# في نافذة Terminal أخرى
mongo

# إنشاء قاعدة البيانات
> use bookdoc_iraq
> db.createUser({
    user: "bookdoc_user",
    pwd: "bookdoc_password",
    roles: ["readWrite"]
  })
> exit
```

### الخطوة 4: إعداد الخادم الخلفي (Backend)

```bash
# الانتقال لمجلد Backend
cd backend

# إنشاء package.json
npm init -y

# تثبيت التبعيات
npm install express mongoose cors dotenv bcryptjs jsonwebtoken multer nodemailer
npm install --save-dev nodemon

# إنشاء ملفات المشروع
mkdir models
mkdir routes
mkdir controllers
mkdir middleware
mkdir utils
mkdir uploads
```

#### إنشاء ملف server.js
```javascript
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('uploads'));

// الاتصال بقاعدة البيانات
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bookdoc_iraq', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/doctors', require('./routes/doctors'));
app.use('/api/bookings', require('./routes/bookings'));
app.use('/api/users', require('./routes/users'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`الخادم يعمل على المنفذ ${PORT}`);
});
```

#### إنشاء ملف .env
```env
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/bookdoc_iraq
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRE=7d

# إعدادات البريد الإلكتروني
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password

# إعدادات الدفع
PAYMENT_GATEWAY_API_KEY=your_payment_api_key
PAYMENT_GATEWAY_SECRET=your_payment_secret
```

### الخطوة 5: إعداد تطبيق المرضى (Mobile App)

```bash
# الانتقال لمجلد Mobile App
cd ../mobile-app

# إنشاء تطبيق React
npx create-react-app . --template typescript

# تثبيت التبعيات الإضافية
npm install react-router-dom react-i18next i18next
npm install lucide-react react-hot-toast
npm install react-query axios
npm install react-hook-form react-datepicker
npm install qrcode html-pdf

# تثبيت تبعيات التطوير
npm install --save-dev @types/react @types/react-dom
```

#### إنشاء ملف .env
```env
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_APP_NAME=BookDoc Iraq
REACT_APP_VERSION=1.0.0
```

### الخطوة 6: إعداد لوحة تحكم الأطباء

```bash
# الانتقال لمجلد Doctor Dashboard
cd ../doctor-dashboard

# إنشاء تطبيق React
npx create-react-app . --template typescript

# تثبيت التبعيات
npm install react-router-dom react-i18next i18next
npm install lucide-react react-hot-toast
npm install react-query axios
npm install recharts
npm install qr-scanner
```

#### إنشاء ملف .env
```env
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_APP_NAME=BookDoc Doctor Dashboard
REACT_APP_VERSION=1.0.0
```

### الخطوة 7: إعداد لوحة تحكم المدير

```bash
# الانتقال لمجلد Admin Dashboard
cd ../admin-dashboard

# إنشاء تطبيق React
npx create-react-app . --template typescript

# تثبيت التبعيات
npm install react-router-dom react-i18next i18next
npm install lucide-react react-hot-toast
npm install react-query axios
npm install recharts
npm install react-table
```

#### إنشاء ملف .env
```env
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_APP_NAME=BookDoc Admin Dashboard
REACT_APP_VERSION=1.0.0
```

## 🔧 تشغيل المشروع

### الطريقة 1: التشغيل اليدوي

#### 1. تشغيل قاعدة البيانات
```bash
# في نافذة Terminal منفصلة
mongod
```

#### 2. تشغيل الخادم الخلفي
```bash
# في نافذة Terminal منفصلة
cd backend
npm start
```

#### 3. تشغيل تطبيق المرضى
```bash
# في نافذة Terminal منفصلة
cd mobile-app
npm start
```

#### 4. تشغيل لوحة تحكم الأطباء
```bash
# في نافذة Terminal منفصلة
cd doctor-dashboard
npm start
```

#### 5. تشغيل لوحة تحكم المدير
```bash
# في نافذة Terminal منفصلة
cd admin-dashboard
npm start
```

### الطريقة 2: التشغيل التلقائي

#### إنشاء ملف start-all.bat (Windows)
```batch
@echo off
echo بدء تشغيل مشروع BookDoc العراقي...

echo تشغيل MongoDB...
start "MongoDB" mongod

echo انتظار 5 ثوان...
timeout /t 5

echo تشغيل الخادم الخلفي...
start "Backend" cmd /k "cd backend && npm start"

echo انتظار 10 ثوان...
timeout /t 10

echo تشغيل تطبيق المرضى...
start "Mobile App" cmd /k "cd mobile-app && npm start"

echo انتظار 5 ثوان...
timeout /t 5

echo تشغيل لوحة تحكم الأطباء...
start "Doctor Dashboard" cmd /k "cd doctor-dashboard && npm start"

echo انتظار 5 ثوان...
timeout /t 5

echo تشغيل لوحة تحكم المدير...
start "Admin Dashboard" cmd /k "cd admin-dashboard && npm start"

echo تم تشغيل جميع التطبيقات بنجاح!
pause
```

#### إنشاء ملف start-all.sh (Linux/Mac)
```bash
#!/bin/bash
echo "بدء تشغيل مشروع BookDoc العراقي..."

echo "تشغيل MongoDB..."
mongod &

echo "انتظار 5 ثوان..."
sleep 5

echo "تشغيل الخادم الخلفي..."
cd backend && npm start &

echo "انتظار 10 ثوان..."
sleep 10

echo "تشغيل تطبيق المرضى..."
cd ../mobile-app && npm start &

echo "انتظار 5 ثوان..."
sleep 5

echo "تشغيل لوحة تحكم الأطباء..."
cd ../doctor-dashboard && npm start &

echo "انتظار 5 ثوان..."
sleep 5

echo "تشغيل لوحة تحكم المدير..."
cd ../admin-dashboard && npm start &

echo "تم تشغيل جميع التطبيقات بنجاح!"
```

## 🌐 الوصول للتطبيقات

بعد تشغيل جميع التطبيقات، يمكنك الوصول إليها عبر:

- **تطبيق المرضى**: http://localhost:3000
- **لوحة تحكم الأطباء**: http://localhost:3001
- **لوحة تحكم المدير**: http://localhost:3002
- **API الخادم الخلفي**: http://localhost:5000

## 🔍 اختبار المشروع

### 1. اختبار قاعدة البيانات
```bash
mongo
> use bookdoc_iraq
> db.stats()
> exit
```

### 2. اختبار API
```bash
# اختبار الاتصال
curl http://localhost:5000/api/health

# اختبار إنشاء مستخدم
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"أحمد محمد","email":"ahmed@test.com","password":"123456"}'
```

### 3. اختبار التطبيقات
- افتح المتصفح واذهب إلى http://localhost:3000
- تأكد من تحميل الصفحة الرئيسية
- جرب إنشاء حساب جديد
- جرب البحث عن الأطباء

## 🐛 حل المشاكل الشائعة

### مشكلة: MongoDB لا يعمل
```bash
# تأكد من تشغيل MongoDB
mongod --version

# إذا لم يعمل، أعد تثبيته
# أو استخدم MongoDB Atlas (السحابي)
```

### مشكلة: المنافذ محجوزة
```bash
# تحقق من المنافذ المستخدمة
netstat -ano | findstr :3000
netstat -ano | findstr :5000

# أو غير المنافذ في ملفات .env
```

### مشكلة: تبعيات مفقودة
```bash
# احذف node_modules وأعد التثبيت
rm -rf node_modules
rm package-lock.json
npm install
```

### مشكلة: خطأ في الترميز
```bash
# تأكد من استخدام UTF-8
# في VS Code: File > Preferences > Settings > Encoding
```

## 📱 اختبار على الأجهزة المحمولة

### 1. اختبار على الشبكة المحلية
```bash
# احصل على عنوان IP
ipconfig

# استخدم العنوان في التطبيق
# مثال: http://192.168.1.100:3000
```

### 2. اختبار على الإنترنت
- استخدم ngrok أو خدمة مشابهة
- أو نشر التطبيق على خادم سحابي

## 🚀 النشر والإنتاج

### 1. بناء التطبيقات للإنتاج
```bash
# بناء تطبيق المرضى
cd mobile-app
npm run build

# بناء لوحة تحكم الأطباء
cd ../doctor-dashboard
npm run build

# بناء لوحة تحكم المدير
cd ../admin-dashboard
npm run build
```

### 2. نشر على خادم
- استخدم PM2 لإدارة العمليات
- استخدم Nginx كخادم ويب
- استخدم MongoDB Atlas لقاعدة البيانات

## 📞 الدعم والمساعدة

إذا واجهت أي مشاكل:
1. تحقق من ملفات السجل (logs)
2. تأكد من تثبيت جميع المتطلبات
3. تحقق من إعدادات الشبكة
4. راجع الوثائق الرسمية

---

**ملاحظة**: هذا الدليل شامل ويغطي جميع جوانب تشغيل المشروع. اتبع الخطوات بالترتيب المذكور لضمان التشغيل السليم.
