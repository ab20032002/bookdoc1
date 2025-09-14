# دليل التطوير - BookDoc

## 🛠️ بيئة التطوير

### المتطلبات
- **Node.js** 18.x أو أحدث
- **MongoDB** 6.0 أو أحدث
- **Git** 2.0 أو أحدث
- **VS Code** (مستحسن)

### تثبيت الأدوات
```bash
# تثبيت Node.js
# قم بتحميله من https://nodejs.org/

# تثبيت MongoDB
# قم بتحميله من https://www.mongodb.com/try/download/community

# تثبيت Git
# قم بتحميله من https://git-scm.com/

# تثبيت VS Code
# قم بتحميله من https://code.visualstudio.com/
```

## 📁 هيكل المشروع

```
bookdoc-project/
├── mobile-app/                 # تطبيق المرضى
│   ├── public/                # الملفات العامة
│   ├── src/                   # الكود المصدري
│   │   ├── components/        # المكونات
│   │   ├── pages/            # الصفحات
│   │   ├── hooks/            # Custom Hooks
│   │   ├── services/         # خدمات API
│   │   ├── locales/          # ملفات الترجمة
│   │   └── utils/            # وظائف مساعدة
│   ├── package.json          # تبعيات المشروع
│   └── README.md             # دليل التطبيق
├── doctor-dashboard/          # لوحة تحكم الأطباء
│   ├── public/               # الملفات العامة
│   ├── src/                  # الكود المصدري
│   │   ├── components/       # المكونات
│   │   ├── pages/           # الصفحات
│   │   ├── hooks/           # Custom Hooks
│   │   ├── services/        # خدمات API
│   │   └── utils/           # وظائف مساعدة
│   ├── package.json         # تبعيات المشروع
│   └── README.md            # دليل التطبيق
├── admin-dashboard/          # لوحة تحكم المدير
│   ├── public/              # الملفات العامة
│   ├── src/                 # الكود المصدري
│   │   ├── components/      # المكونات
│   │   ├── pages/          # الصفحات
│   │   ├── hooks/          # Custom Hooks
│   │   ├── services/       # خدمات API
│   │   └── utils/          # وظائف مساعدة
│   ├── package.json        # تبعيات المشروع
│   └── README.md           # دليل التطبيق
├── backend/                 # الخادم الخلفي
│   ├── models/             # نماذج قاعدة البيانات
│   ├── routes/             # مسارات API
│   ├── middleware/         # Middleware
│   ├── controllers/        # Controllers
│   ├── utils/              # وظائف مساعدة
│   ├── package.json        # تبعيات المشروع
│   └── README.md           # دليل الخادم
├── README.md               # دليل المشروع الرئيسي
├── QUICK_START.md          # دليل التشغيل السريع
├── PROJECT_SUMMARY.md      # ملخص المشروع
├── DEPLOYMENT.md           # دليل النشر
└── DEVELOPMENT.md          # دليل التطوير (هذا الملف)
```

## 🚀 إعداد بيئة التطوير

### 1. استنساخ المشروع
```bash
git clone https://github.com/yourusername/bookdoc-project.git
cd bookdoc-project
```

### 2. تثبيت التبعيات
```bash
# تثبيت تبعيات الخادم الخلفي
cd backend
npm install

# تثبيت تبعيات تطبيق المرضى
cd ../mobile-app
npm install

# تثبيت تبعيات لوحة تحكم الأطباء
cd ../doctor-dashboard
npm install

# تثبيت تبعيات لوحة تحكم المدير
cd ../admin-dashboard
npm install
```

### 3. إعداد متغيرات البيئة
```bash
# نسخ ملفات البيئة
cp backend/.env.example backend/.env
cp mobile-app/.env.example mobile-app/.env
cp doctor-dashboard/.env.example doctor-dashboard/.env
cp admin-dashboard/.env.example admin-dashboard/.env

# تعديل المتغيرات حسب الحاجة
```

### 4. تشغيل قاعدة البيانات
```bash
# تشغيل MongoDB
mongod

# أو استخدام MongoDB Atlas
# قم بتحديث MONGODB_URI في ملف .env
```

### 5. تشغيل التطبيقات
```bash
# تشغيل الخادم الخلفي
cd backend
npm run dev

# تشغيل تطبيق المرضى
cd mobile-app
npm start

# تشغيل لوحة تحكم الأطباء
cd doctor-dashboard
npm start

# تشغيل لوحة تحكم المدير
cd admin-dashboard
npm start
```

## 🧪 الاختبار

### تشغيل الاختبارات
```bash
# اختبارات الخادم الخلفي
cd backend
npm test

# اختبارات تطبيق المرضى
cd mobile-app
npm test

# اختبارات لوحة تحكم الأطباء
cd doctor-dashboard
npm test

# اختبارات لوحة تحكم المدير
cd admin-dashboard
npm test
```

### اختبارات API
```bash
# استخدام Postman أو Insomnia
# استيراد ملف Postman Collection
# أو استخدام curl

# مثال على اختبار API
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123"}'
```

## 🔧 أدوات التطوير

### VS Code Extensions
```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-eslint",
    "ms-vscode.vscode-json",
    "ms-vscode.vscode-css-peek",
    "ms-vscode.vscode-html-css-support",
    "ms-vscode.vscode-javascript-booster",
    "ms-vscode.vscode-react-native",
    "ms-vscode.vscode-node-azure-pack"
  ]
}
```

### إعدادات VS Code
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "emmet.includeLanguages": {
    "javascript": "javascriptreact"
  },
  "files.associations": {
    "*.js": "javascriptreact"
  }
}
```

## 📝 معايير الكود

### ESLint Configuration
```json
{
  "extends": [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended"
  ],
  "rules": {
    "react/prop-types": "off",
    "react/react-in-jsx-scope": "off",
    "no-unused-vars": "warn",
    "no-console": "warn"
  }
}
```

### Prettier Configuration
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

## 🗂️ إدارة الملفات

### تسمية الملفات
```
# المكونات
ComponentName.js          # PascalCase
component-name.js         # kebab-case

# الصفحات
PageName.js              # PascalCase
page-name.js             # kebab-case

# الخدمات
serviceName.js           # camelCase
service-name.js          # kebab-case

# الثوابت
CONSTANTS.js             # UPPER_SNAKE_CASE
constants.js             # camelCase
```

### تنظيم المكونات
```javascript
// ترتيب المكونات
import React from 'react';
import PropTypes from 'prop-types';

// المكونات الخارجية
import { Button } from 'react-bootstrap';

// المكونات الداخلية
import CustomComponent from './CustomComponent';

// الخدمات
import { apiService } from '../services/api';

// الأنماط
import './ComponentName.css';

const ComponentName = ({ prop1, prop2 }) => {
  // Hooks
  const [state, setState] = useState();
  
  // Effects
  useEffect(() => {
    // Effect logic
  }, []);
  
  // Handlers
  const handleClick = () => {
    // Handler logic
  };
  
  // Render
  return (
    <div>
      {/* JSX */}
    </div>
  );
};

ComponentName.propTypes = {
  prop1: PropTypes.string.isRequired,
  prop2: PropTypes.number
};

export default ComponentName;
```

## 🔄 Git Workflow

### Branch Strategy
```bash
# إنشاء فرع جديد
git checkout -b feature/new-feature

# إضافة التغييرات
git add .

# عمل commit
git commit -m "feat: add new feature"

# دفع الفرع
git push origin feature/new-feature

# إنشاء Pull Request
```

### Commit Messages
```
feat: add new feature
fix: fix bug
docs: update documentation
style: formatting changes
refactor: code refactoring
test: add tests
chore: maintenance tasks
```

## 🐛 استكشاف الأخطاء

### مشاكل شائعة

#### 1. خطأ في التبعيات
```bash
# حل المشكلة
rm -rf node_modules
rm package-lock.json
npm install
```

#### 2. خطأ في قاعدة البيانات
```bash
# التحقق من حالة MongoDB
sudo systemctl status mongod

# إعادة تشغيل MongoDB
sudo systemctl restart mongod
```

#### 3. خطأ في المنافذ
```bash
# التحقق من المنافذ المستخدمة
netstat -tulpn | grep :3000

# قتل العملية
kill -9 PID
```

#### 4. خطأ في الذاكرة
```bash
# زيادة حد الذاكرة
export NODE_OPTIONS="--max-old-space-size=4096"
```

## 📊 مراقبة الأداء

### استخدام React DevTools
```bash
# تثبيت React DevTools
npm install -g react-devtools

# تشغيل DevTools
react-devtools
```

### استخدام Chrome DevTools
```javascript
// قياس الأداء
console.time('operation');
// الكود المراد قياسه
console.timeEnd('operation');

// تحليل الذاكرة
console.memory;
```

## 🔒 الأمان

### أفضل الممارسات
```javascript
// تشفير كلمات المرور
const bcrypt = require('bcrypt');
const hashedPassword = await bcrypt.hash(password, 10);

// التحقق من الصلاحيات
const authMiddleware = (req, res, next) => {
  const token = req.header('Authorization');
  if (!token) return res.status(401).json({ message: 'No token' });
  // التحقق من Token
};

// تنظيف البيانات
const sanitizeInput = (input) => {
  return input.trim().replace(/[<>]/g, '');
};
```

## 📱 PWA Development

### Service Worker
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

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
```

## 🌐 دعم اللغات

### إضافة لغة جديدة
```javascript
// src/locales/en.json
{
  "welcome": "Welcome",
  "login": "Login",
  "register": "Register"
}

// src/locales/ar.json
{
  "welcome": "مرحباً",
  "login": "تسجيل الدخول",
  "register": "إنشاء حساب"
}

// استخدام الترجمة
import { useTranslation } from 'react-i18next';

const Component = () => {
  const { t } = useTranslation();
  
  return (
    <div>
      <h1>{t('welcome')}</h1>
    </div>
  );
};
```

## 📞 الدعم

للمساعدة في التطوير:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `QUICK_START.md` للتشغيل السريع
- راجع ملف `PROJECT_SUMMARY.md` لفهم المشروع
- راجع ملف `DEPLOYMENT.md` للنشر

## 🔗 روابط مفيدة

- [React Documentation](https://reactjs.org/docs)
- [Node.js Documentation](https://nodejs.org/docs)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Express.js Documentation](https://expressjs.com/)
- [Mongoose Documentation](https://mongoosejs.com/docs/)
- [i18next Documentation](https://www.i18next.com/)
- [Recharts Documentation](https://recharts.org/)
- [Lucide React Documentation](https://lucide.dev/)
