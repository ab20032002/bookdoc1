# مخطط قاعدة البيانات - BookDoc

## 🗄️ نظرة عامة

قاعدة البيانات تستخدم **MongoDB** مع **Mongoose ODM** وتتكون من 4 مجموعات رئيسية:

1. **Users** - المستخدمين (مرضى، أطباء، مديرين)
2. **Doctors** - ملفات الأطباء
3. **Bookings** - الحجوزات
4. **Reviews** - التقييمات

## 👤 Users Collection

### Schema
```javascript
{
  _id: ObjectId,
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  phone: {
    type: String,
    required: true
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
    default: null
  },
  dateOfBirth: {
    type: Date,
    default: null
  },
  gender: {
    type: String,
    enum: ['male', 'female'],
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
// فهرس فريد للبريد الإلكتروني
db.users.createIndex({ "email": 1 }, { unique: true })

// فهرس للبحث
db.users.createIndex({ "name": "text", "email": "text" })

// فهرس للدور
db.users.createIndex({ "role": 1 })

// فهرس للحالة النشطة
db.users.createIndex({ "isActive": 1 })
```

### أمثلة على البيانات
```javascript
// مريض
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "name": "أحمد محمد",
  "email": "ahmed@example.com",
  "password": "$2b$10$encrypted_password",
  "phone": "01234567890",
  "role": "patient",
  "isActive": true,
  "address": "القاهرة، مصر",
  "dateOfBirth": ISODate("1990-01-01"),
  "gender": "male",
  "createdAt": ISODate("2024-01-01T00:00:00Z"),
  "updatedAt": ISODate("2024-01-01T00:00:00Z")
}

// طبيب
{
  "_id": ObjectId("507f1f77bcf86cd799439012"),
  "name": "د. سارة أحمد",
  "email": "sara@example.com",
  "password": "$2b$10$encrypted_password",
  "phone": "01234567891",
  "role": "doctor",
  "isActive": true,
  "address": "الإسكندرية، مصر",
  "dateOfBirth": ISODate("1985-05-15"),
  "gender": "female",
  "createdAt": ISODate("2024-01-01T00:00:00Z"),
  "updatedAt": ISODate("2024-01-01T00:00:00Z")
}
```

## 👨‍⚕️ Doctors Collection

### Schema
```javascript
{
  _id: ObjectId,
  userId: {
    type: ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  specialty: {
    type: String,
    required: true
  },
  experience: {
    type: Number,
    required: true,
    min: 0
  },
  location: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  description: {
    type: String,
    default: null
  },
  education: {
    type: String,
    default: null
  },
  certifications: [{
    type: String
  }],
  languages: [{
    type: String
  }],
  workingHours: {
    monday: {
      start: String,
      end: String,
      isWorking: Boolean
    },
    tuesday: {
      start: String,
      end: String,
      isWorking: Boolean
    },
    wednesday: {
      start: String,
      end: String,
      isWorking: Boolean
    },
    thursday: {
      start: String,
      end: String,
      isWorking: Boolean
    },
    friday: {
      start: String,
      end: String,
      isWorking: Boolean
    },
    saturday: {
      start: String,
      end: String,
      isWorking: Boolean
    },
    sunday: {
      start: String,
      end: String,
      isWorking: Boolean
    }
  },
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  totalReviews: {
    type: Number,
    default: 0
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
// فهرس للمستخدم
db.doctors.createIndex({ "userId": 1 }, { unique: true })

// فهرس للتخصص
db.doctors.createIndex({ "specialty": 1 })

// فهرس للموقع
db.doctors.createIndex({ "location": 1 })

// فهرس للسعر
db.doctors.createIndex({ "price": 1 })

// فهرس للتقييم
db.doctors.createIndex({ "rating": -1 })

// فهرس للبحث
db.doctors.createIndex({ "specialty": "text", "location": "text" })
```

### أمثلة على البيانات
```javascript
{
  "_id": ObjectId("507f1f77bcf86cd799439013"),
  "userId": ObjectId("507f1f77bcf86cd799439012"),
  "specialty": "أمراض القلب",
  "experience": 10,
  "location": "القاهرة",
  "price": 200,
  "description": "طبيب قلب متخصص في علاج أمراض القلب والشرايين",
  "education": "دكتوراه في أمراض القلب - جامعة القاهرة",
  "certifications": ["شهادة البورد العربي", "شهادة الكلية الملكية"],
  "languages": ["العربية", "الإنجليزية"],
  "workingHours": {
    "monday": { "start": "09:00", "end": "17:00", "isWorking": true },
    "tuesday": { "start": "09:00", "end": "17:00", "isWorking": true },
    "wednesday": { "start": "09:00", "end": "17:00", "isWorking": true },
    "thursday": { "start": "09:00", "end": "17:00", "isWorking": true },
    "friday": { "start": "09:00", "end": "17:00", "isWorking": true },
    "saturday": { "start": "09:00", "end": "13:00", "isWorking": true },
    "sunday": { "start": "09:00", "end": "13:00", "isWorking": true }
  },
  "rating": 4.8,
  "totalReviews": 150,
  "isAvailable": true,
  "createdAt": ISODate("2024-01-01T00:00:00Z"),
  "updatedAt": ISODate("2024-01-01T00:00:00Z")
}
```

## 📅 Bookings Collection

### Schema
```javascript
{
  _id: ObjectId,
  patientId: {
    type: ObjectId,
    ref: 'User',
    required: true
  },
  doctorId: {
    type: ObjectId,
    ref: 'Doctor',
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  time: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['normal', 'vip'],
    default: 'normal'
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'completed', 'cancelled'],
    default: 'pending'
  },
  notes: {
    type: String,
    default: null
  },
  qrCode: {
    type: String,
    default: null
  },
  pdfUrl: {
    type: String,
    default: null
  },
  totalAmount: {
    type: Number,
    required: true
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'paid', 'refunded'],
    default: 'pending'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
// فهرس للمريض
db.bookings.createIndex({ "patientId": 1 })

// فهرس للطبيب
db.bookings.createIndex({ "doctorId": 1 })

// فهرس للتاريخ
db.bookings.createIndex({ "date": 1 })

// فهرس للحالة
db.bookings.createIndex({ "status": 1 })

// فهرس مركب للطبيب والتاريخ
db.bookings.createIndex({ "doctorId": 1, "date": 1 })

// فهرس مركب للمريض والحالة
db.bookings.createIndex({ "patientId": 1, "status": 1 })
```

### أمثلة على البيانات
```javascript
{
  "_id": ObjectId("507f1f77bcf86cd799439014"),
  "patientId": ObjectId("507f1f77bcf86cd799439011"),
  "doctorId": ObjectId("507f1f77bcf86cd799439013"),
  "date": ISODate("2024-01-15T00:00:00Z"),
  "time": "10:00",
  "type": "normal",
  "status": "confirmed",
  "notes": "متابعة حالة القلب",
  "qrCode": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
  "pdfUrl": "http://localhost:5000/uploads/booking_123.pdf",
  "totalAmount": 200,
  "paymentStatus": "paid",
  "createdAt": ISODate("2024-01-01T00:00:00Z"),
  "updatedAt": ISODate("2024-01-01T00:00:00Z")
}
```

## ⭐ Reviews Collection

### Schema
```javascript
{
  _id: ObjectId,
  patientId: {
    type: ObjectId,
    ref: 'User',
    required: true
  },
  doctorId: {
    type: ObjectId,
    ref: 'Doctor',
    required: true
  },
  bookingId: {
    type: ObjectId,
    ref: 'Booking',
    required: true
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  comment: {
    type: String,
    default: null
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
// فهرس للمريض
db.reviews.createIndex({ "patientId": 1 })

// فهرس للطبيب
db.reviews.createIndex({ "doctorId": 1 })

// فهرس للحجز
db.reviews.createIndex({ "bookingId": 1 })

// فهرس مركب للطبيب والتقييم
db.reviews.createIndex({ "doctorId": 1, "rating": 1 })

// فهرس للتحقق
db.reviews.createIndex({ "isVerified": 1 })
```

### أمثلة على البيانات
```javascript
{
  "_id": ObjectId("507f1f77bcf86cd799439015"),
  "patientId": ObjectId("507f1f77bcf86cd799439011"),
  "doctorId": ObjectId("507f1f77bcf86cd799439013"),
  "bookingId": ObjectId("507f1f77bcf86cd799439014"),
  "rating": 5,
  "comment": "طبيب ممتاز، استمع جيداً وشرح الحالة بوضوح",
  "isVerified": true,
  "createdAt": ISODate("2024-01-01T00:00:00Z"),
  "updatedAt": ISODate("2024-01-01T00:00:00Z")
}
```

## 🔔 Notifications Collection

### Schema
```javascript
{
  _id: ObjectId,
  userId: {
    type: ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: ['booking_confirmed', 'booking_cancelled', 'reminder', 'general'],
    required: true
  },
  title: {
    type: String,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  isRead: {
    type: Boolean,
    default: false
  },
  data: {
    type: Object,
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
// فهرس للمستخدم
db.notifications.createIndex({ "userId": 1 })

// فهرس للنوع
db.notifications.createIndex({ "type": 1 })

// فهرس للقراءة
db.notifications.createIndex({ "isRead": 1 })

// فهرس مركب للمستخدم والقراءة
db.notifications.createIndex({ "userId": 1, "isRead": 1 })
```

## 🏥 Specialties Collection

### Schema
```javascript
{
  _id: ObjectId,
  name: {
    type: String,
    required: true,
    unique: true
  },
  description: {
    type: String,
    default: null
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
// فهرس فريد للاسم
db.specialties.createIndex({ "name": 1 }, { unique: true })

// فهرس للحالة النشطة
db.specialties.createIndex({ "isActive": 1 })
```

## 📊 إحصائيات قاعدة البيانات

### حجم البيانات المتوقع
```
Users: ~10,000 مستخدم
Doctors: ~500 طبيب
Bookings: ~50,000 حجز
Reviews: ~25,000 تقييم
Notifications: ~100,000 إشعار
Specialties: ~50 تخصص
```

### استعلامات شائعة

#### البحث عن الأطباء
```javascript
db.doctors.find({
  specialty: "أمراض القلب",
  location: "القاهرة",
  rating: { $gte: 4.0 },
  isAvailable: true
}).sort({ rating: -1 })
```

#### الحصول على حجوزات المريض
```javascript
db.bookings.find({
  patientId: ObjectId("507f1f77bcf86cd799439011"),
  status: { $in: ["confirmed", "completed"] }
}).sort({ date: -1 })
```

#### إحصائيات الطبيب
```javascript
db.bookings.aggregate([
  { $match: { doctorId: ObjectId("507f1f77bcf86cd799439013") } },
  { $group: {
    _id: "$status",
    count: { $sum: 1 },
    totalRevenue: { $sum: "$totalAmount" }
  }}
])
```

#### متوسط التقييم
```javascript
db.reviews.aggregate([
  { $match: { doctorId: ObjectId("507f1f77bcf86cd799439013") } },
  { $group: {
    _id: null,
    averageRating: { $avg: "$rating" },
    totalReviews: { $sum: 1 }
  }}
])
```

## 🔧 صيانة قاعدة البيانات

### النسخ الاحتياطي
```bash
# نسخ احتياطي كامل
mongodump --db bookdoc --out /backup/

# نسخ احتياطي لمجموعة محددة
mongodump --db bookdoc --collection users --out /backup/
```

### استعادة النسخ الاحتياطي
```bash
# استعادة كاملة
mongorestore --db bookdoc /backup/bookdoc/

# استعادة مجموعة محددة
mongorestore --db bookdoc --collection users /backup/bookdoc/users.bson
```

### تحسين الأداء
```javascript
// تحليل الاستعلامات
db.bookings.find({ doctorId: ObjectId("...") }).explain("executionStats")

// إنشاء فهارس مركبة
db.bookings.createIndex({ "doctorId": 1, "date": 1, "status": 1 })

// تنظيف البيانات القديمة
db.notifications.deleteMany({
  createdAt: { $lt: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000) }
})
```

## 🔒 الأمان

### تشفير البيانات الحساسة
```javascript
// تشفير كلمات المرور
const bcrypt = require('bcrypt');
const hashedPassword = await bcrypt.hash(password, 10);

// تشفير البيانات الحساسة
const crypto = require('crypto');
const algorithm = 'aes-256-cbc';
const key = crypto.randomBytes(32);
const iv = crypto.randomBytes(16);
```

### التحقق من الصلاحيات
```javascript
// التحقق من صلاحيات المستخدم
const checkPermission = (user, resource) => {
  if (user.role === 'admin') return true;
  if (user.role === 'doctor' && resource === 'doctor') return true;
  if (user.role === 'patient' && resource === 'patient') return true;
  return false;
};
```

## 📞 الدعم

للمساعدة في قاعدة البيانات:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [MongoDB Documentation](https://docs.mongodb.com/)
- [Mongoose Documentation](https://mongoosejs.com/docs/)
- [MongoDB Atlas](https://www.mongodb.com/atlas)
- [MongoDB Compass](https://www.mongodb.com/products/compass)
- [MongoDB University](https://university.mongodb.com/)
