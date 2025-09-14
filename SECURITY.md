# دليل الأمان - BookDoc

## 🔒 نظرة عامة على الأمان

يتبع مشروع BookDoc أفضل الممارسات الأمنية لحماية البيانات الحساسة والمستخدمين. يتضمن النظام عدة طبقات أمنية:

1. **مصادقة المستخدمين** - JWT Tokens
2. **تشفير البيانات** - bcrypt للكلمات السرية
3. **التحقق من الصلاحيات** - Role-based Access Control
4. **حماية API** - Rate Limiting و CORS
5. **تشفير الاتصالات** - HTTPS
6. **حماية قاعدة البيانات** - MongoDB Security

## 🔐 نظام المصادقة

### JWT Tokens
```javascript
// إنشاء Token
const jwt = require('jsonwebtoken');
const token = jwt.sign(
  { userId: user._id, role: user.role },
  process.env.JWT_SECRET,
  { expiresIn: '7d' }
);

// التحقق من Token
const decoded = jwt.verify(token, process.env.JWT_SECRET);
```

### تشفير كلمات المرور
```javascript
const bcrypt = require('bcrypt');

// تشفير كلمة المرور
const saltRounds = 10;
const hashedPassword = await bcrypt.hash(password, saltRounds);

// التحقق من كلمة المرور
const isValid = await bcrypt.compare(password, hashedPassword);
```

### Middleware للمصادقة
```javascript
const authMiddleware = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ message: 'No token provided' });
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId);
    
    if (!user || !user.isActive) {
      return res.status(401).json({ message: 'Invalid token' });
    }
    
    req.user = user;
    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid token' });
  }
};
```

## 🛡️ التحقق من الصلاحيات

### Role-based Access Control
```javascript
const authorize = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ message: 'Authentication required' });
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Insufficient permissions' });
    }
    
    next();
  };
};

// استخدام الصلاحيات
app.get('/admin/users', authMiddleware, authorize(['admin']), getUsers);
app.get('/doctors/stats', authMiddleware, authorize(['doctor', 'admin']), getDoctorStats);
```

### التحقق من الملكية
```javascript
const checkOwnership = (resource) => {
  return async (req, res, next) => {
    try {
      const resourceId = req.params.id;
      const resource = await resource.findById(resourceId);
      
      if (!resource) {
        return res.status(404).json({ message: 'Resource not found' });
      }
      
      // التحقق من الملكية
      if (resource.userId.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Access denied' });
      }
      
      req.resource = resource;
      next();
    } catch (error) {
      res.status(500).json({ message: 'Server error' });
    }
  };
};
```

## 🚫 حماية API

### Rate Limiting
```javascript
const rateLimit = require('express-rate-limit');

// Rate limiting عام
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 دقيقة
  max: 100, // 100 طلب لكل IP
  message: 'Too many requests from this IP'
});

// Rate limiting للمصادقة
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 دقيقة
  max: 5, // 5 محاولات تسجيل دخول
  message: 'Too many login attempts'
});

app.use('/api/auth', authLimiter);
app.use('/api', generalLimiter);
```

### CORS Configuration
```javascript
const cors = require('cors');

const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:3002',
      'https://yourdomain.com'
    ];
    
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
```

### Input Validation
```javascript
const { body, validationResult } = require('express-validator');

// التحقق من بيانات التسجيل
const validateRegistration = [
  body('name').trim().isLength({ min: 2 }).escape(),
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('phone').isMobilePhone('ar-EG'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  }
];
```

## 🔒 حماية قاعدة البيانات

### MongoDB Security
```javascript
// إعدادات MongoDB
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      ssl: true,
      sslValidate: true,
      authSource: 'admin'
    });
  } catch (error) {
    console.error('Database connection error:', error);
  }
};
```

### تشفير البيانات الحساسة
```javascript
const crypto = require('crypto');

class EncryptionService {
  constructor() {
    this.algorithm = 'aes-256-cbc';
    this.key = crypto.randomBytes(32);
    this.iv = crypto.randomBytes(16);
  }
  
  encrypt(text) {
    const cipher = crypto.createCipher(this.algorithm, this.key);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return encrypted;
  }
  
  decrypt(encryptedText) {
    const decipher = crypto.createDecipher(this.algorithm, this.key);
    let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  }
}
```

### تنظيف البيانات
```javascript
const sanitizeInput = (input) => {
  if (typeof input !== 'string') return input;
  
  return input
    .trim()
    .replace(/[<>]/g, '') // إزالة HTML tags
    .replace(/javascript:/gi, '') // إزالة JavaScript
    .replace(/on\w+=/gi, ''); // إزالة Event handlers
};

// Middleware لتنظيف البيانات
const sanitizeMiddleware = (req, res, next) => {
  if (req.body) {
    for (let key in req.body) {
      if (typeof req.body[key] === 'string') {
        req.body[key] = sanitizeInput(req.body[key]);
      }
    }
  }
  next();
};
```

## 🛡️ حماية الجلسات

### Session Security
```javascript
const session = require('express-session');
const MongoStore = require('connect-mongo');

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  store: MongoStore.create({
    mongoUrl: process.env.MONGODB_URI,
    touchAfter: 24 * 3600 // 24 ساعة
  }),
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 7 * 24 * 60 * 60 * 1000 // 7 أيام
  }
}));
```

### CSRF Protection
```javascript
const csrf = require('csurf');

const csrfProtection = csrf({
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict'
  }
});

app.use(csrfProtection);
```

## 🔐 حماية الملفات

### File Upload Security
```javascript
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type'), false);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB
  },
  fileFilter: fileFilter
});
```

### File Access Control
```javascript
const express = require('express');
const path = require('path');

// حماية الملفات الحساسة
app.use('/uploads', (req, res, next) => {
  // التحقق من الصلاحيات
  if (!req.user) {
    return res.status(401).json({ message: 'Authentication required' });
  }
  
  // التحقق من نوع الملف
  const filePath = req.path;
  if (filePath.includes('private') && req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Access denied' });
  }
  
  next();
});

app.use('/uploads', express.static('uploads'));
```

## 🚨 مراقبة الأمان

### Logging
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console()
  ]
});

// Middleware لتسجيل الطلبات
const requestLogger = (req, res, next) => {
  logger.info({
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    timestamp: new Date().toISOString()
  });
  next();
};
```

### Security Headers
```javascript
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));
```

## 🔍 اكتشاف التهديدات

### Intrusion Detection
```javascript
const suspiciousActivity = new Map();

const detectSuspiciousActivity = (req, res, next) => {
  const ip = req.ip;
  const now = Date.now();
  
  if (!suspiciousActivity.has(ip)) {
    suspiciousActivity.set(ip, { count: 0, lastSeen: now });
  }
  
  const activity = suspiciousActivity.get(ip);
  
  // إعادة تعيين العداد كل ساعة
  if (now - activity.lastSeen > 3600000) {
    activity.count = 0;
  }
  
  // زيادة العداد
  activity.count++;
  activity.lastSeen = now;
  
  // اكتشاف النشاط المشبوه
  if (activity.count > 100) {
    logger.warn(`Suspicious activity detected from IP: ${ip}`);
    return res.status(429).json({ message: 'Too many requests' });
  }
  
  next();
};
```

### Brute Force Protection
```javascript
const failedAttempts = new Map();

const bruteForceProtection = (req, res, next) => {
  const ip = req.ip;
  const now = Date.now();
  
  if (!failedAttempts.has(ip)) {
    failedAttempts.set(ip, { count: 0, lastAttempt: now });
  }
  
  const attempts = failedAttempts.get(ip);
  
  // إعادة تعيين العداد كل 15 دقيقة
  if (now - attempts.lastAttempt > 900000) {
    attempts.count = 0;
  }
  
  // زيادة العداد عند فشل تسجيل الدخول
  if (req.url.includes('/login') && req.method === 'POST') {
    attempts.count++;
    attempts.lastAttempt = now;
    
    if (attempts.count > 5) {
      logger.warn(`Brute force attempt detected from IP: ${ip}`);
      return res.status(429).json({ message: 'Too many failed attempts' });
    }
  }
  
  next();
};
```

## 🔐 متغيرات البيئة الآمنة

### .env Security
```bash
# ملف .env
NODE_ENV=production
PORT=5000

# قاعدة البيانات
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/bookdoc

# JWT
JWT_SECRET=your_very_secure_jwt_secret_key_here
JWT_EXPIRES_IN=7d

# البريد الإلكتروني
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password

# الأمان
SESSION_SECRET=your_session_secret_key
CSRF_SECRET=your_csrf_secret_key

# الملفات
UPLOAD_PATH=uploads/
MAX_FILE_SIZE=5242880

# Rate Limiting
RATE_LIMIT_WINDOW=900000
RATE_LIMIT_MAX=100
```

### Environment Validation
```javascript
const Joi = require('joi');

const envSchema = Joi.object({
  NODE_ENV: Joi.string().valid('development', 'production', 'test').required(),
  PORT: Joi.number().port().required(),
  MONGODB_URI: Joi.string().uri().required(),
  JWT_SECRET: Joi.string().min(32).required(),
  EMAIL_USER: Joi.string().email().required(),
  EMAIL_PASS: Joi.string().required()
});

const { error, value } = envSchema.validate(process.env);
if (error) {
  throw new Error(`Environment validation error: ${error.message}`);
}
```

## 🚨 الاستجابة للحوادث

### Incident Response Plan
```javascript
const incidentResponse = {
  // اكتشاف الحادث
  detect: (type, details) => {
    logger.error(`Security incident detected: ${type}`, details);
    
    // إرسال تنبيه فوري
    sendSecurityAlert(type, details);
    
    // تسجيل الحادث
    recordIncident(type, details);
  },
  
  // احتواء الحادث
  contain: (incidentId) => {
    // حظر IP المشبوه
    blockSuspiciousIP(incidentId);
    
    // تعطيل الحسابات المشبوهة
    disableSuspiciousAccounts(incidentId);
  },
  
  // استعادة النظام
  recover: (incidentId) => {
    // استعادة النسخ الاحتياطية
    restoreBackup(incidentId);
    
    // إعادة تشغيل الخدمات
    restartServices(incidentId);
  }
};
```

## 📊 مراجعة الأمان

### Security Audit Checklist
```markdown
## مراجعة الأمان الشاملة

### المصادقة والتفويض
- [ ] JWT Tokens آمنة
- [ ] كلمات المرور مشفرة
- [ ] التحقق من الصلاحيات
- [ ] انتهاء صلاحية الجلسات

### حماية API
- [ ] Rate Limiting
- [ ] CORS Configuration
- [ ] Input Validation
- [ ] Error Handling

### قاعدة البيانات
- [ ] اتصال آمن
- [ ] تشفير البيانات
- [ ] النسخ الاحتياطية
- [ ] مراقبة الوصول

### الشبكة
- [ ] HTTPS
- [ ] Security Headers
- [ ] Firewall
- [ ] DDoS Protection

### التطبيق
- [ ] Code Review
- [ ] Dependency Updates
- [ ] Security Testing
- [ ] Monitoring
```

## 📞 الدعم

للمساعدة في الأمان:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير
- راجع ملف `DEPLOYMENT.md` للنشر

## 🔗 روابط مفيدة

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security](https://nodejs.org/en/docs/guides/security/)
- [MongoDB Security](https://docs.mongodb.com/manual/security/)
- [JWT Security](https://tools.ietf.org/html/rfc7519)
- [Helmet.js](https://helmetjs.github.io/)
- [Express Security](https://expressjs.com/en/advanced/best-practice-security.html)
