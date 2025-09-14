# دليل التطوير المتقدم للخادم الخلفي - BookDoc

## 🚀 نظرة عامة

يتم تطوير خادم BookDoc الخلفي باستخدام **Node.js** مع **Express.js** و **MongoDB**. يتضمن النظام معمارية متقدمة مع دعم كامل للأمان والأداء.

## 🛠️ التقنيات المستخدمة

### Core Technologies
- **Node.js 18.x** - بيئة التشغيل
- **Express.js 4.x** - إطار العمل
- **MongoDB 6.x** - قاعدة البيانات
- **Mongoose 7.x** - ODM
- **TypeScript** - لغة البرمجة

### Security & Auth
- **JWT** - المصادقة
- **bcrypt** - تشفير كلمات المرور
- **helmet** - أمان HTTP
- **cors** - CORS
- **rate-limiter** - تحديد المعدل

### Performance & Monitoring
- **Redis** - التخزين المؤقت
- **Winston** - تسجيل الأحداث
- **Morgan** - تسجيل HTTP
- **Compression** - ضغط البيانات

## 📁 هيكل المشروع

```
backend/
├── src/
│   ├── controllers/        # Controllers
│   ├── models/            # نماذج قاعدة البيانات
│   ├── routes/            # مسارات API
│   ├── middleware/        # Middleware
│   ├── services/          # خدمات الأعمال
│   ├── utils/             # وظائف مساعدة
│   ├── types/             # أنواع TypeScript
│   ├── config/            # إعدادات التطبيق
│   └── validators/        # التحقق من البيانات
├── tests/                 # الاختبارات
├── docs/                  # الوثائق
└── package.json
```

## 🏗️ المعمارية المتقدمة

### Service Layer Pattern
```typescript
// src/services/doctorService.ts
import { Doctor, IDoctor } from '../models/Doctor';
import { IUser } from '../models/User';
import { NotFoundError, ValidationError } from '../utils/errors';
import { cacheService } from './cacheService';

export class DoctorService {
  async createDoctor(userId: string, doctorData: Partial<IDoctor>): Promise<IDoctor> {
    try {
      const doctor = new Doctor({
        ...doctorData,
        userId
      });

      await doctor.save();
      
      // إضافة إلى التخزين المؤقت
      await cacheService.set(`doctor:${doctor._id}`, doctor, 3600);
      
      return doctor;
    } catch (error) {
      throw new ValidationError('فشل في إنشاء ملف الطبيب');
    }
  }

  async getDoctorById(id: string): Promise<IDoctor> {
    // التحقق من التخزين المؤقت أولاً
    const cached = await cacheService.get(`doctor:${id}`);
    if (cached) return cached;

    const doctor = await Doctor.findById(id).populate('userId');
    if (!doctor) {
      throw new NotFoundError('الطبيب غير موجود');
    }

    // إضافة إلى التخزين المؤقت
    await cacheService.set(`doctor:${id}`, doctor, 3600);
    
    return doctor;
  }

  async searchDoctors(filters: any): Promise<IDoctor[]> {
    const cacheKey = `doctors:search:${JSON.stringify(filters)}`;
    
    // التحقق من التخزين المؤقت
    const cached = await cacheService.get(cacheKey);
    if (cached) return cached;

    const query: any = {};
    
    if (filters.specialty) {
      query.specialty = filters.specialty;
    }
    
    if (filters.location) {
      query.location = filters.location;
    }
    
    if (filters.minRating) {
      query.rating = { $gte: filters.minRating };
    }
    
    if (filters.minPrice || filters.maxPrice) {
      query.price = {};
      if (filters.minPrice) query.price.$gte = filters.minPrice;
      if (filters.maxPrice) query.price.$lte = filters.maxPrice;
    }

    const doctors = await Doctor.find(query)
      .populate('userId')
      .sort({ rating: -1 })
      .limit(filters.limit || 20);

    // إضافة إلى التخزين المؤقت
    await cacheService.set(cacheKey, doctors, 1800);
    
    return doctors;
  }

  async updateDoctor(id: string, updateData: Partial<IDoctor>): Promise<IDoctor> {
    const doctor = await Doctor.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!doctor) {
      throw new NotFoundError('الطبيب غير موجود');
    }

    // تحديث التخزين المؤقت
    await cacheService.set(`doctor:${id}`, doctor, 3600);
    
    return doctor;
  }

  async deleteDoctor(id: string): Promise<void> {
    const doctor = await Doctor.findByIdAndDelete(id);
    
    if (!doctor) {
      throw new NotFoundError('الطبيب غير موجود');
    }

    // حذف من التخزين المؤقت
    await cacheService.del(`doctor:${id}`);
  }
}

export const doctorService = new DoctorService();
```

### Advanced Middleware
```typescript
// src/middleware/advancedAuth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
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

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    const user = await User.findById(decoded.userId).select('-password');
    
    if (!user || !user.isActive) {
      throw new UnauthorizedError('Invalid token');
    }

    req.user = user;
    req.token = token;
    next();
  } catch (error) {
    next(error);
  }
};

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

### Error Handling System
```typescript
// src/utils/errors.ts
export class AppError extends Error {
  public statusCode: number;
  public isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string) {
    super(message, 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string) {
    super(message, 403);
  }
}

export class NotFoundError extends AppError {
  constructor(message: string) {
    super(message, 404);
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 409);
  }
}

// Global error handler
export const globalErrorHandler = (
  error: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  let statusCode = error.statusCode || 500;
  let message = error.message || 'Internal server error';

  // Log error
  console.error('Error:', error);

  // Handle specific error types
  if (error.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation Error';
  }

  if (error.name === 'CastError') {
    statusCode = 400;
    message = 'Invalid ID format';
  }

  if (error.name === 'MongoError' && error.code === 11000) {
    statusCode = 409;
    message = 'Duplicate entry';
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
};
```

## 🔒 نظام الأمان المتقدم

### Security Middleware
```typescript
// src/middleware/security.ts
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
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
        frameSrc: ["'none'"]
      }
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true
    }
  }),

  // Rate limiting
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // 100 requests per window
    message: 'Too many requests from this IP',
    standardHeaders: true,
    legacyHeaders: false
  }),

  // CORS
  (req: Request, res: Response, next: NextFunction) => {
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:3002'
    ];

    const origin = req.headers.origin;
    if (allowedOrigins.includes(origin as string)) {
      res.setHeader('Access-Control-Allow-Origin', origin as string);
    }

    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.setHeader('Access-Control-Allow-Credentials', 'true');

    if (req.method === 'OPTIONS') {
      res.sendStatus(200);
    } else {
      next();
    }
  }
];
```

### Input Validation
```typescript
// src/validators/doctorValidator.ts
import Joi from 'joi';

export const createDoctorSchema = Joi.object({
  specialty: Joi.string().required().messages({
    'string.empty': 'التخصص مطلوب',
    'any.required': 'التخصص مطلوب'
  }),
  experience: Joi.number().min(0).required().messages({
    'number.min': 'الخبرة يجب أن تكون أكبر من أو تساوي 0',
    'any.required': 'الخبرة مطلوبة'
  }),
  location: Joi.string().required().messages({
    'string.empty': 'الموقع مطلوب',
    'any.required': 'الموقع مطلوب'
  }),
  price: Joi.number().min(0).required().messages({
    'number.min': 'السعر يجب أن يكون أكبر من أو يساوي 0',
    'any.required': 'السعر مطلوب'
  }),
  description: Joi.string().optional(),
  education: Joi.string().optional(),
  certifications: Joi.array().items(Joi.string()).optional(),
  languages: Joi.array().items(Joi.string()).optional(),
  workingHours: Joi.object({
    monday: Joi.object({
      start: Joi.string().required(),
      end: Joi.string().required(),
      isWorking: Joi.boolean().required()
    }).required(),
    tuesday: Joi.object({
      start: Joi.string().required(),
      end: Joi.string().required(),
      isWorking: Joi.boolean().required()
    }).required(),
    // ... other days
  }).required()
});

export const updateDoctorSchema = Joi.object({
  specialty: Joi.string().optional(),
  experience: Joi.number().min(0).optional(),
  location: Joi.string().optional(),
  price: Joi.number().min(0).optional(),
  description: Joi.string().optional(),
  education: Joi.string().optional(),
  certifications: Joi.array().items(Joi.string()).optional(),
  languages: Joi.array().items(Joi.string()).optional(),
  workingHours: Joi.object().optional()
});

export const validateDoctor = (schema: Joi.ObjectSchema) => {
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
```

## 📊 نظام المراقبة والتسجيل

### Logging System
```typescript
// src/utils/logger.ts
import winston from 'winston';
import path from 'path';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'bookdoc-api' },
  transports: [
    new winston.transports.File({
      filename: path.join('logs', 'error.log'),
      level: 'error'
    }),
    new winston.transports.File({
      filename: path.join('logs', 'combined.log')
    })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

export default logger;
```

### Performance Monitoring
```typescript
// src/middleware/performance.ts
import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger';

export const performanceMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    const { method, url } = req;
    const { statusCode } = res;
    
    logger.info('Request completed', {
      method,
      url,
      statusCode,
      duration: `${duration}ms`,
      userAgent: req.get('User-Agent'),
      ip: req.ip
    });
    
    // تحذير للطلبات البطيئة
    if (duration > 5000) {
      logger.warn('Slow request detected', {
        method,
        url,
        duration: `${duration}ms`
      });
    }
  });
  
  next();
};
```

## 🚀 التحسينات المتقدمة

### Database Optimization
```typescript
// src/utils/databaseOptimizer.ts
import mongoose from 'mongoose';

export class DatabaseOptimizer {
  static async createIndexes() {
    const db = mongoose.connection.db;
    
    // User indexes
    await db.collection('users').createIndex({ email: 1 }, { unique: true });
    await db.collection('users').createIndex({ role: 1, isActive: 1 });
    
    // Doctor indexes
    await db.collection('doctors').createIndex({ specialty: 1, location: 1 });
    await db.collection('doctors').createIndex({ rating: -1, isAvailable: 1 });
    await db.collection('doctors').createIndex({ price: 1 });
    
    // Booking indexes
    await db.collection('bookings').createIndex({ doctorId: 1, date: 1 });
    await db.collection('bookings').createIndex({ patientId: 1, status: 1 });
    await db.collection('bookings').createIndex({ status: 1, createdAt: -1 });
    
    // Review indexes
    await db.collection('reviews').createIndex({ doctorId: 1, rating: 1 });
    await db.collection('reviews').createIndex({ patientId: 1 });
  }

  static async optimizeQueries() {
    // Enable query optimization
    mongoose.set('debug', process.env.NODE_ENV === 'development');
    mongoose.set('bufferCommands', false);
    mongoose.set('bufferMaxEntries', 0);
  }
}
```

### Caching Strategy
```typescript
// src/services/cacheService.ts
import Redis from 'ioredis';

class CacheService {
  private redis: Redis;

  constructor() {
    this.redis = new Redis({
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT || '6379'),
      password: process.env.REDIS_PASSWORD,
      retryDelayOnFailover: 100,
      maxRetriesPerRequest: 3
    });
  }

  async get(key: string): Promise<any> {
    try {
      const value = await this.redis.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('Cache get error:', error);
      return null;
    }
  }

  async set(key: string, value: any, ttl: number = 3600): Promise<void> {
    try {
      await this.redis.setex(key, ttl, JSON.stringify(value));
    } catch (error) {
      console.error('Cache set error:', error);
    }
  }

  async del(key: string): Promise<void> {
    try {
      await this.redis.del(key);
    } catch (error) {
      console.error('Cache delete error:', error);
    }
  }

  async invalidatePattern(pattern: string): Promise<void> {
    try {
      const keys = await this.redis.keys(pattern);
      if (keys.length > 0) {
        await this.redis.del(...keys);
      }
    } catch (error) {
      console.error('Cache invalidate pattern error:', error);
    }
  }
}

export const cacheService = new CacheService();
```

## 📞 الدعم

للمساعدة في التطوير المتقدم للخادم الخلفي:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير الأساسي
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [Node.js Documentation](https://nodejs.org/docs/)
- [Express.js Documentation](https://expressjs.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Mongoose Documentation](https://mongoosejs.com/docs/)
- [JWT Documentation](https://jwt.io/)
- [Winston Documentation](https://github.com/winstonjs/winston)
- [Redis Documentation](https://redis.io/documentation)
