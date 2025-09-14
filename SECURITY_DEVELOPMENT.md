# دليل التطوير المتقدم للأمان - BookDoc

## 🔒 نظرة عامة

يتبع مشروع BookDoc أعلى معايير الأمان لحماية البيانات الحساسة والمستخدمين. يتضمن النظام عدة طبقات أمنية متقدمة.

## 🛡️ طبقات الأمان

### 1. Authentication & Authorization
```typescript
// src/middleware/advancedAuth.ts
import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';
import { User } from '../models/User';
import { UnauthorizedError, ForbiddenError } from '../utils/errors';

interface AuthRequest extends Request {
  user?: any;
  token?: string;
}

export const advancedAuth = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      throw new UnauthorizedError('No token provided');
    }

    // التحقق من صحة Token
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    
    // التحقق من وجود المستخدم
    const user = await User.findById(decoded.userId).select('-password');
    
    if (!user || !user.isActive) {
      throw new UnauthorizedError('Invalid token');
    }

    // التحقق من انتهاء صلاحية الحساب
    if (user.isLocked) {
      throw new UnauthorizedError('Account is locked');
    }

    req.user = user;
    req.token = token;
    next();
  } catch (error) {
    next(error);
  }
};

// التحقق من الصلاحيات
export const requireRole = (roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new UnauthorizedError('Authentication required');
    }

    if (!roles.includes(req.user.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }

    next();
  };
};

// التحقق من الملكية
export const requireOwnership = (resourceModel: any) => {
  return async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const resourceId = req.params.id;
      const resource = await resourceModel.findById(resourceId);
      
      if (!resource) {
        throw new NotFoundError('Resource not found');
      }

      // التحقق من الملكية
      if (resource.userId.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
        throw new ForbiddenError('Access denied');
      }

      req.resource = resource;
      next();
    } catch (error) {
      next(error);
    }
  };
};
```

### 2. Input Validation & Sanitization
```typescript
// src/middleware/validation.ts
import Joi from 'joi';
import { Request, Response, NextFunction } from 'express';
import DOMPurify from 'isomorphic-dompurify';

export const validateRequest = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation Error',
        errors: error.details.map(detail => ({
          field: detail.path.join('.'),
          message: detail.message
        }))
      });
    }
    
    next();
  };
};

export const sanitizeInput = (req: Request, res: Response, next: NextFunction) => {
  const sanitizeObject = (obj: any): any => {
    if (typeof obj === 'string') {
      return DOMPurify.sanitize(obj.trim());
    }
    
    if (Array.isArray(obj)) {
      return obj.map(sanitizeObject);
    }
    
    if (obj && typeof obj === 'object') {
      const sanitized: any = {};
      for (const key in obj) {
        sanitized[key] = sanitizeObject(obj[key]);
      }
      return sanitized;
    }
    
    return obj;
  };

  req.body = sanitizeObject(req.body);
  req.query = sanitizeObject(req.query);
  req.params = sanitizeObject(req.params);
  
  next();
};

// Schema للتحقق من البيانات
export const schemas = {
  user: {
    create: Joi.object({
      name: Joi.string().min(2).max(50).required(),
      email: Joi.string().email().required(),
      password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/).required(),
      phone: Joi.string().pattern(/^01[0-9]{9}$/).required(),
      role: Joi.string().valid('patient', 'doctor', 'admin').default('patient')
    }),
    update: Joi.object({
      name: Joi.string().min(2).max(50),
      phone: Joi.string().pattern(/^01[0-9]{9}$/),
      address: Joi.string().max(200),
      dateOfBirth: Joi.date().max('now'),
      gender: Joi.string().valid('male', 'female')
    })
  },
  doctor: {
    create: Joi.object({
      specialty: Joi.string().required(),
      experience: Joi.number().min(0).max(50).required(),
      location: Joi.string().required(),
      price: Joi.number().min(50).max(2000).required(),
      description: Joi.string().max(500),
      education: Joi.string().max(200),
      certifications: Joi.array().items(Joi.string().max(100)),
      languages: Joi.array().items(Joi.string()),
      workingHours: Joi.object().required()
    })
  },
  booking: {
    create: Joi.object({
      doctorId: Joi.string().required(),
      date: Joi.date().min('now').required(),
      time: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).required(),
      type: Joi.string().valid('normal', 'vip').default('normal'),
      notes: Joi.string().max(500)
    })
  }
};
```

### 3. Rate Limiting & DDoS Protection
```typescript
// src/middleware/rateLimiting.ts
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD
});

// Rate limiting عام
export const generalLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args) => redis.sendCommand(args),
  }),
  windowMs: 15 * 60 * 1000, // 15 دقيقة
  max: 100, // 100 طلب لكل IP
  message: 'Too many requests from this IP, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Too many requests from this IP, please try again later'
    });
  }
});

// Rate limiting للمصادقة
export const authLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args) => redis.sendCommand(args),
  }),
  windowMs: 15 * 60 * 1000, // 15 دقيقة
  max: 5, // 5 محاولات تسجيل دخول
  message: 'Too many login attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Too many login attempts, please try again later'
    });
  }
});

// Rate limiting للعمليات الحساسة
export const sensitiveLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args) => redis.sendCommand(args),
  }),
  windowMs: 60 * 60 * 1000, // ساعة واحدة
  max: 10, // 10 عمليات حساسة
  message: 'Too many sensitive operations, please try again later',
  standardHeaders: true,
  legacyHeaders: false
});
```

### 4. Encryption & Data Protection
```typescript
// src/utils/encryption.ts
import crypto from 'crypto';
import bcrypt from 'bcrypt';

export class EncryptionService {
  private static readonly algorithm = 'aes-256-gcm';
  private static readonly keyLength = 32;
  private static readonly ivLength = 16;
  private static readonly tagLength = 16;
  private static readonly saltRounds = 12;

  // تشفير البيانات الحساسة
  static encrypt(text: string, secretKey: string): string {
    const key = crypto.scryptSync(secretKey, 'salt', this.keyLength);
    const iv = crypto.randomBytes(this.ivLength);
    const cipher = crypto.createCipher(this.algorithm, key);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const tag = cipher.getAuthTag();
    
    return iv.toString('hex') + ':' + tag.toString('hex') + ':' + encrypted;
  }

  // فك تشفير البيانات
  static decrypt(encryptedText: string, secretKey: string): string {
    const parts = encryptedText.split(':');
    const iv = Buffer.from(parts[0], 'hex');
    const tag = Buffer.from(parts[1], 'hex');
    const encrypted = parts[2];
    
    const key = crypto.scryptSync(secretKey, 'salt', this.keyLength);
    const decipher = crypto.createDecipher(this.algorithm, key);
    
    decipher.setAuthTag(tag);
    
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }

  // تشفير كلمات المرور
  static async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, this.saltRounds);
  }

  // التحقق من كلمة المرور
  static async comparePassword(password: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(password, hashedPassword);
  }

  // إنشاء مفتاح عشوائي
  static generateRandomKey(length: number = 32): string {
    return crypto.randomBytes(length).toString('hex');
  }

  // إنشاء hash للبيانات
  static createHash(data: string): string {
    return crypto.createHash('sha256').update(data).digest('hex');
  }
}
```

### 5. Security Headers & CORS
```typescript
// src/middleware/security.ts
import helmet from 'helmet';
import { Request, Response, NextFunction } from 'express';

export const securityMiddleware = [
  // Helmet for security headers
  helmet({
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
        frameSrc: ["'none'"],
        upgradeInsecureRequests: []
      }
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true
    },
    noSniff: true,
    xssFilter: true,
    referrerPolicy: { policy: 'strict-origin-when-cross-origin' }
  }),

  // CORS Configuration
  (req: Request, res: Response, next: NextFunction) => {
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:3002',
      'https://yourdomain.com'
    ];

    const origin = req.headers.origin;
    if (allowedOrigins.includes(origin as string)) {
      res.setHeader('Access-Control-Allow-Origin', origin as string);
    }

    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
    res.setHeader('Access-Control-Allow-Credentials', 'true');
    res.setHeader('Access-Control-Max-Age', '86400');

    if (req.method === 'OPTIONS') {
      res.sendStatus(200);
    } else {
      next();
    }
  }
];
```

### 6. Session Security
```typescript
// src/middleware/sessionSecurity.ts
import session from 'express-session';
import MongoStore from 'connect-mongo';
import { Request, Response, NextFunction } from 'express';

export const sessionConfig = session({
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  store: MongoStore.create({
    mongoUrl: process.env.MONGODB_URI,
    touchAfter: 24 * 3600, // 24 ساعة
    ttl: 7 * 24 * 60 * 60 // 7 أيام
  }),
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 أيام
    sameSite: 'strict'
  },
  name: 'bookdoc.sid'
});

// CSRF Protection
export const csrfProtection = (req: Request, res: Response, next: NextFunction) => {
  if (req.method === 'GET' || req.method === 'HEAD' || req.method === 'OPTIONS') {
    return next();
  }

  const token = req.header('X-CSRF-Token') || req.body._csrf;
  const sessionToken = req.session?.csrfToken;

  if (!token || !sessionToken || token !== sessionToken) {
    return res.status(403).json({
      success: false,
      message: 'Invalid CSRF token'
    });
  }

  next();
};
```

### 7. File Upload Security
```typescript
// src/middleware/fileUpload.ts
import multer from 'multer';
import path from 'path';
import { Request, Response, NextFunction } from 'express';

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  // التحقق من نوع الملف
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
  
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type'));
  }
};

export const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
    files: 5 // 5 ملفات كحد أقصى
  },
  fileFilter: fileFilter
});

// التحقق من الملفات المرفوعة
export const validateUploadedFiles = (req: Request, res: Response, next: NextFunction) => {
  if (!req.files || req.files.length === 0) {
    return next();
  }

  const files = Array.isArray(req.files) ? req.files : Object.values(req.files);
  
  for (const file of files) {
    // التحقق من حجم الملف
    if (file.size > 5 * 1024 * 1024) {
      return res.status(400).json({
        success: false,
        message: 'File size too large'
      });
    }

    // التحقق من نوع الملف
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
    if (!allowedTypes.includes(file.mimetype)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid file type'
      });
    }

    // التحقق من امتداد الملف
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.pdf'];
    const fileExtension = path.extname(file.originalname).toLowerCase();
    if (!allowedExtensions.includes(fileExtension)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid file extension'
      });
    }
  }

  next();
};
```

### 8. Logging & Monitoring
```typescript
// src/utils/securityLogger.ts
import winston from 'winston';
import { Request, Response, NextFunction } from 'express';

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/security.log' }),
    new winston.transports.Console()
  ]
});

export const securityMiddleware = (req: Request, res: Response, next: NextFunction) => {
  // تسجيل الطلبات المشبوهة
  const suspiciousPatterns = [
    /\.\./, // Directory traversal
    /<script/i, // XSS attempts
    /union.*select/i, // SQL injection
    /javascript:/i, // JavaScript injection
    /on\w+\s*=/i // Event handler injection
  ];

  const requestData = {
    url: req.url,
    method: req.method,
    body: req.body,
    query: req.query,
    params: req.params,
    headers: req.headers,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  };

  // التحقق من الأنماط المشبوهة
  const requestString = JSON.stringify(requestData);
  const isSuspicious = suspiciousPatterns.some(pattern => pattern.test(requestString));

  if (isSuspicious) {
    securityLogger.warn('Suspicious request detected', {
      ...requestData,
      timestamp: new Date().toISOString()
    });
  }

  // تسجيل محاولات الوصول غير المصرح
  if (req.url.includes('/admin') && !req.user) {
    securityLogger.warn('Unauthorized admin access attempt', {
      ...requestData,
      timestamp: new Date().toISOString()
    });
  }

  next();
};
```

## 📞 الدعم

للمساعدة في التطوير المتقدم للأمان:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير الأساسي
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security](https://nodejs.org/en/docs/guides/security/)
- [Express Security](https://expressjs.com/en/advanced/best-practice-security.html)
- [Helmet.js](https://helmetjs.github.io/)
- [JWT Security](https://tools.ietf.org/html/rfc7519)
- [bcrypt Documentation](https://github.com/kelektiv/node.bcrypt.js)
