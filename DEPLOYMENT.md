# دليل النشر - BookDoc

## 🚀 خيارات النشر

### 1. النشر على Heroku

#### إعداد المشروع للنشر
```bash
# إنشاء ملف Procfile في مجلد backend
echo "web: npm start" > backend/Procfile

# إنشاء ملف .env في backend
cp backend/.env.example backend/.env
```

#### إعداد متغيرات البيئة
```bash
# في لوحة تحكم Heroku
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/bookdoc
JWT_SECRET=your_jwt_secret
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
```

#### نشر التطبيقات
```bash
# نشر الخادم الخلفي
cd backend
git init
git add .
git commit -m "Initial commit"
heroku create bookdoc-backend
git push heroku main

# نشر تطبيق المرضى
cd mobile-app
git init
git add .
git commit -m "Initial commit"
heroku create bookdoc-mobile
git push heroku main

# نشر لوحة تحكم الأطباء
cd doctor-dashboard
git init
git add .
git commit -m "Initial commit"
heroku create bookdoc-doctor
git push heroku main

# نشر لوحة تحكم المدير
cd admin-dashboard
git init
git add .
git commit -m "Initial commit"
heroku create bookdoc-admin
git push heroku main
```

### 2. النشر على Vercel

#### إعداد المشروع
```bash
# إنشاء ملف vercel.json في كل مجلد
# mobile-app/vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "build"
      }
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

#### نشر التطبيقات
```bash
# تثبيت Vercel CLI
npm i -g vercel

# نشر كل تطبيق
cd mobile-app
vercel --prod

cd doctor-dashboard
vercel --prod

cd admin-dashboard
vercel --prod
```

### 3. النشر على Netlify

#### إعداد المشروع
```bash
# إنشاء ملف _redirects في public
echo "/* /index.html 200" > mobile-app/public/_redirects
echo "/* /index.html 200" > doctor-dashboard/public/_redirects
echo "/* /index.html 200" > admin-dashboard/public/_redirects
```

#### نشر التطبيقات
```bash
# بناء التطبيقات
cd mobile-app
npm run build

cd doctor-dashboard
npm run build

cd admin-dashboard
npm run build

# رفع مجلد build إلى Netlify
```

### 4. النشر على DigitalOcean

#### إعداد الخادم
```bash
# تحديث النظام
sudo apt update && sudo apt upgrade -y

# تثبيت Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# تثبيت MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# تثبيت PM2
sudo npm install -g pm2
```

#### نشر التطبيقات
```bash
# نسخ المشروع
git clone https://github.com/yourusername/bookdoc-project.git
cd bookdoc-project

# تثبيت التبعيات
cd backend && npm install
cd ../mobile-app && npm install
cd ../doctor-dashboard && npm install
cd ../admin-dashboard && npm install

# بناء التطبيقات
cd mobile-app && npm run build
cd ../doctor-dashboard && npm run build
cd ../admin-dashboard && npm run build

# تشغيل التطبيقات
cd backend
pm2 start server.js --name "bookdoc-backend"

cd ../mobile-app
pm2 start "npm start" --name "bookdoc-mobile"

cd ../doctor-dashboard
pm2 start "npm start" --name "bookdoc-doctor"

cd ../admin-dashboard
pm2 start "npm start" --name "bookdoc-admin"

# حفظ إعدادات PM2
pm2 save
pm2 startup
```

### 5. النشر على AWS

#### إعداد EC2
```bash
# إنشاء instance جديد
# تثبيت Docker
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# إنشاء Dockerfile لكل تطبيق
```

#### Dockerfile للخادم الخلفي
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
```

#### Dockerfile للتطبيقات الأمامية
```dockerfile
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 🔧 إعدادات الإنتاج

### متغيرات البيئة
```bash
# backend/.env
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/bookdoc
JWT_SECRET=your_very_secure_jwt_secret
JWT_EXPIRES_IN=7d
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
FRONTEND_URL=https://your-frontend-domain.com
```

### إعدادات قاعدة البيانات
```bash
# إنشاء مستخدم قاعدة البيانات
use bookdoc
db.createUser({
  user: "bookdoc_user",
  pwd: "secure_password",
  roles: ["readWrite"]
})
```

### إعدادات الأمان
```bash
# تحديث CORS
const corsOptions = {
  origin: ['https://your-domain.com', 'https://www.your-domain.com'],
  credentials: true
}
```

## 📊 مراقبة الأداء

### استخدام PM2
```bash
# مراقبة التطبيقات
pm2 monit

# عرض السجلات
pm2 logs

# إعادة تشغيل التطبيقات
pm2 restart all
```

### استخدام Nginx
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 🔒 الأمان

### SSL Certificate
```bash
# تثبيت Certbot
sudo apt install certbot python3-certbot-nginx

# الحصول على شهادة SSL
sudo certbot --nginx -d your-domain.com
```

### Firewall
```bash
# إعداد UFW
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

## 📱 PWA للنشر

### إعداد Service Worker
```javascript
// public/sw.js
const CACHE_NAME = 'bookdoc-v1';
const urlsToCache = [
  '/',
  '/static/js/bundle.js',
  '/static/css/main.css'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});
```

## 🚀 النشر التلقائي

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.12.12
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}}
          heroku_app_name: "your-app-name"
          heroku_email: "your-email@example.com"
```

## 📞 الدعم

للمساعدة في النشر، راجع:
- [Heroku Documentation](https://devcenter.heroku.com/)
- [Vercel Documentation](https://vercel.com/docs)
- [Netlify Documentation](https://docs.netlify.com/)
- [DigitalOcean Documentation](https://docs.digitalocean.com/)
- [AWS Documentation](https://docs.aws.amazon.com/)
