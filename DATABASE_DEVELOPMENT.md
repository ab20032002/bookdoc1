# دليل التطوير المتقدم لقاعدة البيانات - BookDoc

## 🗄️ نظرة عامة

يستخدم مشروع BookDoc **MongoDB** كقاعدة بيانات رئيسية مع **Mongoose** كـ ODM. يتضمن النظام تصميم قاعدة بيانات متقدم مع تحسينات للأداء والأمان.

## 🏗️ تصميم قاعدة البيانات

### Schema Design Patterns
```typescript
// src/models/User.ts
import mongoose, { Schema, Document } from 'mongoose';

export interface IUser extends Document {
  name: string;
  email: string;
  password: string;
  phone: string;
  role: 'patient' | 'doctor' | 'admin';
  isActive: boolean;
  profileImage?: string;
  address?: string;
  dateOfBirth?: Date;
  gender?: 'male' | 'female';
  lastLogin?: Date;
  loginAttempts: number;
  lockUntil?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>({
  name: {
    type: String,
    required: [true, 'الاسم مطلوب'],
    trim: true,
    minlength: [2, 'الاسم يجب أن يكون على الأقل حرفين'],
    maxlength: [50, 'الاسم لا يمكن أن يتجاوز 50 حرف']
  },
  email: {
    type: String,
    required: [true, 'البريد الإلكتروني مطلوب'],
    unique: true,
    lowercase: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'بريد إلكتروني غير صحيح']
  },
  password: {
    type: String,
    required: [true, 'كلمة المرور مطلوبة'],
    minlength: [6, 'كلمة المرور يجب أن تكون على الأقل 6 أحرف'],
    select: false // عدم إرجاع كلمة المرور في الاستعلامات
  },
  phone: {
    type: String,
    required: [true, 'رقم الهاتف مطلوب'],
    match: [/^01[0-9]{9}$/, 'رقم هاتف غير صحيح']
  },
  role: {
    type: String,
    enum: ['patient', 'doctor', 'admin'],
    default: 'patient'
  },
  isActive: {
    type: Boolean,
    default: true
  },
  profileImage: {
    type: String,
    default: null
  },
  address: {
    type: String,
    maxlength: [200, 'العنوان لا يمكن أن يتجاوز 200 حرف']
  },
  dateOfBirth: {
    type: Date,
    validate: {
      validator: function(value: Date) {
        return value < new Date();
      },
      message: 'تاريخ الميلاد يجب أن يكون في الماضي'
    }
  },
  gender: {
    type: String,
    enum: ['male', 'female']
  },
  lastLogin: {
    type: Date
  },
  loginAttempts: {
    type: Number,
    default: 0
  },
  lockUntil: {
    type: Date
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for account lock status
userSchema.virtual('isLocked').get(function() {
  return !!(this.lockUntil && this.lockUntil > new Date());
});

// Indexes
userSchema.index({ email: 1 }, { unique: true });
userSchema.index({ role: 1, isActive: 1 });
userSchema.index({ createdAt: -1 });

// Pre-save middleware
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const bcrypt = require('bcrypt');
    const saltRounds = 10;
    this.password = await bcrypt.hash(this.password, saltRounds);
    next();
  } catch (error) {
    next(error);
  }
});

// Instance methods
userSchema.methods.comparePassword = async function(candidatePassword: string): Promise<boolean> {
  const bcrypt = require('bcrypt');
  return bcrypt.compare(candidatePassword, this.password);
};

userSchema.methods.incrementLoginAttempts = function() {
  // If we have a previous lock that has expired, restart at 1
  if (this.lockUntil && this.lockUntil < new Date()) {
    return this.updateOne({
      $unset: { lockUntil: 1 },
      $set: { loginAttempts: 1 }
    });
  }
  
  const updates = { $inc: { loginAttempts: 1 } };
  
  // Lock account after 5 failed attempts
  if (this.loginAttempts + 1 >= 5 && !this.isLocked) {
    updates.$set = { lockUntil: new Date(Date.now() + 2 * 60 * 60 * 1000) }; // 2 hours
  }
  
  return this.updateOne(updates);
};

userSchema.methods.resetLoginAttempts = function() {
  return this.updateOne({
    $unset: { loginAttempts: 1, lockUntil: 1 }
  });
};

export const User = mongoose.model<IUser>('User', userSchema);
```

### Advanced Doctor Schema
```typescript
// src/models/Doctor.ts
import mongoose, { Schema, Document } from 'mongoose';

export interface IWorkingHours {
  start: string;
  end: string;
  isWorking: boolean;
}

export interface IDoctor extends Document {
  userId: mongoose.Types.ObjectId;
  specialty: string;
  experience: number;
  location: string;
  price: number;
  description?: string;
  education?: string;
  certifications: string[];
  languages: string[];
  workingHours: {
    monday: IWorkingHours;
    tuesday: IWorkingHours;
    wednesday: IWorkingHours;
    thursday: IWorkingHours;
    friday: IWorkingHours;
    saturday: IWorkingHours;
    sunday: IWorkingHours;
  };
  rating: number;
  totalReviews: number;
  isAvailable: boolean;
  consultationFee: number;
  followUpFee: number;
  emergencyFee: number;
  createdAt: Date;
  updatedAt: Date;
}

const workingHoursSchema = new Schema<IWorkingHours>({
  start: {
    type: String,
    required: true,
    match: [/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'تنسيق الوقت غير صحيح']
  },
  end: {
    type: String,
    required: true,
    match: [/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'تنسيق الوقت غير صحيح']
  },
  isWorking: {
    type: Boolean,
    required: true
  }
});

const doctorSchema = new Schema<IDoctor>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  specialty: {
    type: String,
    required: [true, 'التخصص مطلوب'],
    enum: [
      'أمراض القلب',
      'الأعصاب',
      'العظام',
      'الجلدية',
      'العيون',
      'الأذن والأنف والحنجرة',
      'النساء والتوليد',
      'الأطفال',
      'الطب النفسي',
      'الجراحة العامة',
      'الجراحة التجميلية',
      'الأورام',
      'الطب الباطني',
      'الطب الرياضي',
      'الطب الطبيعي'
    ]
  },
  experience: {
    type: Number,
    required: [true, 'الخبرة مطلوبة'],
    min: [0, 'الخبرة يجب أن تكون أكبر من أو تساوي 0'],
    max: [50, 'الخبرة لا يمكن أن تتجاوز 50 سنة']
  },
  location: {
    type: String,
    required: [true, 'الموقع مطلوب'],
    enum: [
      'القاهرة',
      'الإسكندرية',
      'الجيزة',
      'الشرقية',
      'الدقهلية',
      'البحيرة',
      'المنيا',
      'أسيوط',
      'سوهاج',
      'قنا',
      'الأقصر',
      'أسوان',
      'البحر الأحمر',
      'الوادي الجديد',
      'مطروح',
      'شمال سيناء',
      'جنوب سيناء',
      'كفر الشيخ',
      'الغربية',
      'المنوفية',
      'القليوبية',
      'بني سويف',
      'الفيوم',
      'الإسماعيلية',
      'السويس',
      'بورسعيد',
      'دمياط'
    ]
  },
  price: {
    type: Number,
    required: [true, 'السعر مطلوب'],
    min: [50, 'السعر يجب أن يكون على الأقل 50 جنيه'],
    max: [2000, 'السعر لا يمكن أن يتجاوز 2000 جنيه']
  },
  description: {
    type: String,
    maxlength: [500, 'الوصف لا يمكن أن يتجاوز 500 حرف']
  },
  education: {
    type: String,
    maxlength: [200, 'التعليم لا يمكن أن يتجاوز 200 حرف']
  },
  certifications: [{
    type: String,
    maxlength: [100, 'الشهادة لا يمكن أن تتجاوز 100 حرف']
  }],
  languages: [{
    type: String,
    enum: ['العربية', 'الإنجليزية', 'الفرنسية', 'الألمانية', 'الإيطالية', 'الإسبانية']
  }],
  workingHours: {
    monday: workingHoursSchema,
    tuesday: workingHoursSchema,
    wednesday: workingHoursSchema,
    thursday: workingHoursSchema,
    friday: workingHoursSchema,
    saturday: workingHoursSchema,
    sunday: workingHoursSchema
  },
  rating: {
    type: Number,
    default: 0,
    min: [0, 'التقييم يجب أن يكون أكبر من أو يساوي 0'],
    max: [5, 'التقييم لا يمكن أن يتجاوز 5']
  },
  totalReviews: {
    type: Number,
    default: 0,
    min: [0, 'عدد التقييمات يجب أن يكون أكبر من أو يساوي 0']
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  consultationFee: {
    type: Number,
    default: 0,
    min: [0, 'رسوم الاستشارة يجب أن تكون أكبر من أو تساوي 0']
  },
  followUpFee: {
    type: Number,
    default: 0,
    min: [0, 'رسوم المتابعة يجب أن تكون أكبر من أو تساوي 0']
  },
  emergencyFee: {
    type: Number,
    default: 0,
    min: [0, 'رسوم الطوارئ يجب أن تكون أكبر من أو تساوي 0']
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for average rating
doctorSchema.virtual('averageRating').get(function() {
  return this.totalReviews > 0 ? this.rating / this.totalReviews : 0;
});

// Indexes
doctorSchema.index({ userId: 1 }, { unique: true });
doctorSchema.index({ specialty: 1, location: 1 });
doctorSchema.index({ rating: -1, isAvailable: 1 });
doctorSchema.index({ price: 1 });
doctorSchema.index({ experience: -1 });
doctorSchema.index({ createdAt: -1 });

// Text search index
doctorSchema.index({
  specialty: 'text',
  location: 'text',
  description: 'text',
  education: 'text'
});

// Pre-save middleware
doctorSchema.pre('save', function(next) {
  // Calculate average rating
  if (this.totalReviews > 0) {
    this.rating = this.rating / this.totalReviews;
  }
  next();
});

// Static methods
doctorSchema.statics.findBySpecialty = function(specialty: string) {
  return this.find({ specialty, isAvailable: true });
};

doctorSchema.statics.findByLocation = function(location: string) {
  return this.find({ location, isAvailable: true });
};

doctorSchema.statics.findByPriceRange = function(minPrice: number, maxPrice: number) {
  return this.find({
    price: { $gte: minPrice, $lte: maxPrice },
    isAvailable: true
  });
};

doctorSchema.statics.findTopRated = function(limit: number = 10) {
  return this.find({ isAvailable: true })
    .sort({ rating: -1, totalReviews: -1 })
    .limit(limit);
};

export const Doctor = mongoose.model<IDoctor>('Doctor', doctorSchema);
```

## 🔍 الاستعلامات المتقدمة

### Aggregation Pipelines
```typescript
// src/services/analyticsService.ts
import { Doctor } from '../models/Doctor';
import { Booking } from '../models/Booking';
import { Review } from '../models/Review';

export class AnalyticsService {
  // إحصائيات شاملة للأطباء
  async getDoctorAnalytics(doctorId: string, dateRange: { start: Date; end: Date }) {
    const pipeline = [
      {
        $match: {
          doctorId: new mongoose.Types.ObjectId(doctorId),
          createdAt: { $gte: dateRange.start, $lte: dateRange.end }
        }
      },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          totalRevenue: { $sum: '$totalAmount' }
        }
      },
      {
        $group: {
          _id: null,
          statusBreakdown: {
            $push: {
              status: '$_id',
              count: '$count',
              revenue: '$totalRevenue'
            }
          },
          totalBookings: { $sum: '$count' },
          totalRevenue: { $sum: '$totalRevenue' }
        }
      }
    ];

    return await Booking.aggregate(pipeline);
  }

  // إحصائيات الأداء
  async getPerformanceMetrics(dateRange: { start: Date; end: Date }) {
    const pipeline = [
      {
        $match: {
          createdAt: { $gte: dateRange.start, $lte: dateRange.end }
        }
      },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
            day: { $dayOfMonth: '$createdAt' }
          },
          dailyBookings: { $sum: 1 },
          dailyRevenue: { $sum: '$totalAmount' }
        }
      },
      {
        $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 }
      }
    ];

    return await Booking.aggregate(pipeline);
  }

  // تحليل التقييمات
  async getRatingAnalysis(doctorId: string) {
    const pipeline = [
      {
        $match: { doctorId: new mongoose.Types.ObjectId(doctorId) }
      },
      {
        $group: {
          _id: '$rating',
          count: { $sum: 1 }
        }
      },
      {
        $sort: { '_id': 1 }
      },
      {
        $group: {
          _id: null,
          ratingDistribution: {
            $push: {
              rating: '$_id',
              count: '$count'
            }
          },
          totalReviews: { $sum: '$count' },
          averageRating: { $avg: '$_id' }
        }
      }
    ];

    return await Review.aggregate(pipeline);
  }

  // إحصائيات التخصصات
  async getSpecialtyStatistics() {
    const pipeline = [
      {
        $lookup: {
          from: 'doctors',
          localField: 'doctorId',
          foreignField: '_id',
          as: 'doctor'
        }
      },
      {
        $unwind: '$doctor'
      },
      {
        $group: {
          _id: '$doctor.specialty',
          totalBookings: { $sum: 1 },
          totalRevenue: { $sum: '$totalAmount' },
          averageRating: { $avg: '$doctor.rating' },
          doctorCount: { $addToSet: '$doctorId' }
        }
      },
      {
        $project: {
          specialty: '$_id',
          totalBookings: 1,
          totalRevenue: 1,
          averageRating: 1,
          doctorCount: { $size: '$doctorCount' }
        }
      },
      {
        $sort: { totalBookings: -1 }
      }
    ];

    return await Booking.aggregate(pipeline);
  }
}

export const analyticsService = new AnalyticsService();
```

### Advanced Queries
```typescript
// src/services/doctorService.ts
export class DoctorService {
  // البحث المتقدم
  async advancedSearch(filters: {
    specialty?: string;
    location?: string;
    minPrice?: number;
    maxPrice?: number;
    minRating?: number;
    minExperience?: number;
    languages?: string[];
    availability?: boolean;
    searchTerm?: string;
  }) {
    const query: any = {};

    // الفلاتر الأساسية
    if (filters.specialty) query.specialty = filters.specialty;
    if (filters.location) query.location = filters.location;
    if (filters.availability !== undefined) query.isAvailable = filters.availability;

    // فلاتر النطاق
    if (filters.minPrice || filters.maxPrice) {
      query.price = {};
      if (filters.minPrice) query.price.$gte = filters.minPrice;
      if (filters.maxPrice) query.price.$lte = filters.maxPrice;
    }

    if (filters.minRating) query.rating = { $gte: filters.minRating };
    if (filters.minExperience) query.experience = { $gte: filters.minExperience };

    // فلاتر المصفوفات
    if (filters.languages && filters.languages.length > 0) {
      query.languages = { $in: filters.languages };
    }

    // البحث النصي
    if (filters.searchTerm) {
      query.$text = { $search: filters.searchTerm };
    }

    return await Doctor.find(query)
      .populate('userId', 'name email phone')
      .sort({ rating: -1, totalReviews: -1 });
  }

  // البحث الجغرافي
  async findNearbyDoctors(latitude: number, longitude: number, maxDistance: number = 10) {
    // هذا يتطلب إعداد فهرس جغرافي
    return await Doctor.find({
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [longitude, latitude]
          },
          $maxDistance: maxDistance * 1000 // تحويل إلى أمتار
        }
      }
    });
  }

  // إحصائيات الأداء
  async getPerformanceStats(doctorId: string) {
    const stats = await Booking.aggregate([
      {
        $match: { doctorId: new mongoose.Types.ObjectId(doctorId) }
      },
      {
        $group: {
          _id: null,
          totalBookings: { $sum: 1 },
          completedBookings: {
            $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] }
          },
          cancelledBookings: {
            $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, 1, 0] }
          },
          totalRevenue: { $sum: '$totalAmount' },
          averageBookingValue: { $avg: '$totalAmount' }
        }
      }
    ]);

    return stats[0] || {
      totalBookings: 0,
      completedBookings: 0,
      cancelledBookings: 0,
      totalRevenue: 0,
      averageBookingValue: 0
    };
  }
}
```

## 🔒 الأمان والتحقق

### Data Validation
```typescript
// src/utils/validation.ts
import Joi from 'joi';
import { Request, Response, NextFunction } from 'express';

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

// Schema للتحقق من البيانات
export const schemas = {
  user: {
    create: Joi.object({
      name: Joi.string().min(2).max(50).required(),
      email: Joi.string().email().required(),
      password: Joi.string().min(6).required(),
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
      workingHours: Joi.object({
        monday: Joi.object({
          start: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).required(),
          end: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).required(),
          isWorking: Joi.boolean().required()
        }).required(),
        // ... other days
      }).required()
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

### Data Sanitization
```typescript
// src/middleware/sanitization.ts
import { Request, Response, NextFunction } from 'express';
import DOMPurify from 'isomorphic-dompurify';

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
```

## 📊 المراقبة والأداء

### Database Monitoring
```typescript
// src/utils/dbMonitor.ts
import mongoose from 'mongoose';
import logger from './logger';

export class DatabaseMonitor {
  static setupMonitoring() {
    // مراقبة الاتصال
    mongoose.connection.on('connected', () => {
      logger.info('MongoDB connected successfully');
    });

    mongoose.connection.on('error', (error) => {
      logger.error('MongoDB connection error:', error);
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected');
    });

    // مراقبة الاستعلامات البطيئة
    mongoose.set('debug', (collectionName, method, query, doc) => {
      const start = Date.now();
      
      return (error, result) => {
        const duration = Date.now() - start;
        
        if (duration > 1000) { // أكثر من ثانية
          logger.warn('Slow query detected', {
            collection: collectionName,
            method,
            query: JSON.stringify(query),
            duration: `${duration}ms`
          });
        }
      };
    });
  }

  static async getDatabaseStats() {
    const stats = await mongoose.connection.db.stats();
    return {
      collections: stats.collections,
      dataSize: stats.dataSize,
      storageSize: stats.storageSize,
      indexes: stats.indexes,
      indexSize: stats.indexSize
    };
  }

  static async getCollectionStats(collectionName: string) {
    const stats = await mongoose.connection.db.collection(collectionName).stats();
    return {
      count: stats.count,
      size: stats.size,
      avgObjSize: stats.avgObjSize,
      storageSize: stats.storageSize,
      totalIndexSize: stats.totalIndexSize,
      indexSizes: stats.indexSizes
    };
  }
}
```

## 📞 الدعم

للمساعدة في التطوير المتقدم لقاعدة البيانات:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير الأساسي
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [MongoDB Documentation](https://docs.mongodb.com/)
- [Mongoose Documentation](https://mongoosejs.com/docs/)
- [MongoDB Atlas](https://www.mongodb.com/atlas)
- [MongoDB Compass](https://www.mongodb.com/products/compass)
- [MongoDB University](https://university.mongodb.com/)
- [MongoDB Aggregation](https://docs.mongodb.com/manual/aggregation/)
