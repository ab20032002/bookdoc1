# وثائق API - BookDoc

## 🔗 Base URL
```
http://localhost:5000/api
```

## 🔐 المصادقة

### تسجيل الدخول
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user_id",
    "name": "اسم المستخدم",
    "email": "user@example.com",
    "role": "patient"
  }
}
```

### إنشاء حساب جديد
```http
POST /auth/register
Content-Type: application/json

{
  "name": "اسم المستخدم",
  "email": "user@example.com",
  "password": "password123",
  "phone": "01234567890",
  "role": "patient"
}
```

### تحديث كلمة المرور
```http
PUT /auth/change-password
Authorization: Bearer <token>
Content-Type: application/json

{
  "currentPassword": "old_password",
  "newPassword": "new_password"
}
```

## 👤 إدارة المستخدمين

### الحصول على الملف الشخصي
```http
GET /users/profile
Authorization: Bearer <token>
```

### تحديث الملف الشخصي
```http
PUT /users/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "الاسم الجديد",
  "phone": "01234567890",
  "address": "العنوان الجديد"
}
```

### حذف الحساب
```http
DELETE /users/profile
Authorization: Bearer <token>
```

## 👨‍⚕️ إدارة الأطباء

### الحصول على قائمة الأطباء
```http
GET /doctors
```

**Query Parameters:**
- `specialty` - التخصص
- `location` - الموقع
- `rating` - التقييم
- `page` - رقم الصفحة
- `limit` - عدد النتائج

**Response:**
```json
{
  "success": true,
  "doctors": [
    {
      "id": "doctor_id",
      "name": "د. أحمد محمد",
      "specialty": "أمراض القلب",
      "rating": 4.8,
      "experience": 10,
      "location": "القاهرة",
      "price": 200,
      "image": "doctor_image_url"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 50,
    "pages": 5
  }
}
```

### الحصول على تفاصيل طبيب
```http
GET /doctors/:id
```

### إنشاء ملف طبيب
```http
POST /doctors
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "د. أحمد محمد",
  "specialty": "أمراض القلب",
  "experience": 10,
  "location": "القاهرة",
  "price": 200,
  "description": "وصف الطبيب",
  "education": "تعليم الطبيب",
  "certifications": ["شهادة 1", "شهادة 2"]
}
```

### تحديث ملف طبيب
```http
PUT /doctors/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "الاسم الجديد",
  "specialty": "التخصص الجديد",
  "price": 250
}
```

### حذف طبيب
```http
DELETE /doctors/:id
Authorization: Bearer <token>
```

## 📅 إدارة الحجوزات

### إنشاء حجز جديد
```http
POST /bookings
Authorization: Bearer <token>
Content-Type: application/json

{
  "doctorId": "doctor_id",
  "date": "2024-01-15",
  "time": "10:00",
  "type": "normal",
  "notes": "ملاحظات إضافية"
}
```

### الحصول على حجوزات المستخدم
```http
GET /bookings
Authorization: Bearer <token>
```

**Query Parameters:**
- `status` - حالة الحجز (pending, confirmed, completed, cancelled)
- `page` - رقم الصفحة
- `limit` - عدد النتائج

### الحصول على تفاصيل حجز
```http
GET /bookings/:id
Authorization: Bearer <token>
```

### تحديث حالة الحجز
```http
PUT /bookings/:id/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "confirmed"
}
```

### إلغاء حجز
```http
DELETE /bookings/:id
Authorization: Bearer <token>
```

## ⭐ التقييمات

### إضافة تقييم
```http
POST /reviews
Authorization: Bearer <token>
Content-Type: application/json

{
  "doctorId": "doctor_id",
  "bookingId": "booking_id",
  "rating": 5,
  "comment": "تعليق على الطبيب"
}
```

### الحصول على تقييمات طبيب
```http
GET /doctors/:id/reviews
```

### تحديث تقييم
```http
PUT /reviews/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "rating": 4,
  "comment": "التعليق المحدث"
}
```

### حذف تقييم
```http
DELETE /reviews/:id
Authorization: Bearer <token>
```

## 🔔 الإشعارات

### الحصول على الإشعارات
```http
GET /notifications
Authorization: Bearer <token>
```

### تحديث حالة الإشعار
```http
PUT /notifications/:id/read
Authorization: Bearer <token>
```

### حذف إشعار
```http
DELETE /notifications/:id
Authorization: Bearer <token>
```

## 📊 الإحصائيات

### إحصائيات المدير
```http
GET /admin/stats
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "stats": {
    "totalUsers": 1000,
    "totalDoctors": 50,
    "totalBookings": 5000,
    "totalRevenue": 100000,
    "monthlyStats": {
      "users": 100,
      "doctors": 5,
      "bookings": 500,
      "revenue": 10000
    }
  }
}
```

### إحصائيات الطبيب
```http
GET /doctors/stats
Authorization: Bearer <token>
```

## 🏥 التخصصات

### الحصول على قائمة التخصصات
```http
GET /specialties
```

### إنشاء تخصص جديد
```http
POST /specialties
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "أمراض القلب",
  "description": "وصف التخصص"
}
```

### تحديث تخصص
```http
PUT /specialties/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "الاسم الجديد",
  "description": "الوصف الجديد"
}
```

### حذف تخصص
```http
DELETE /specialties/:id
Authorization: Bearer <token>
```

## 📱 QR Code

### إنشاء QR Code للحجز
```http
POST /bookings/:id/qr
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "qrCode": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
}
```

### مسح QR Code
```http
POST /qr/scan
Authorization: Bearer <token>
Content-Type: application/json

{
  "qrData": "booking_data_from_qr_code"
}
```

## 📄 PDF

### إنشاء PDF للحجز
```http
POST /bookings/:id/pdf
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "pdfUrl": "http://localhost:5000/uploads/booking_123.pdf"
}
```

## 🔍 البحث

### البحث عن الأطباء
```http
GET /search/doctors
```

**Query Parameters:**
- `q` - كلمة البحث
- `specialty` - التخصص
- `location` - الموقع
- `minPrice` - الحد الأدنى للسعر
- `maxPrice` - الحد الأقصى للسعر
- `rating` - الحد الأدنى للتقييم

## 📧 البريد الإلكتروني

### إرسال إشعار بريد إلكتروني
```http
POST /notifications/email
Authorization: Bearer <token>
Content-Type: application/json

{
  "to": "user@example.com",
  "subject": "موضوع الرسالة",
  "message": "محتوى الرسالة"
}
```

## 🚨 رموز الحالة

| الكود | المعنى |
|-------|--------|
| 200 | نجح الطلب |
| 201 | تم الإنشاء بنجاح |
| 400 | طلب غير صحيح |
| 401 | غير مصرح |
| 403 | ممنوع |
| 404 | غير موجود |
| 409 | تعارض |
| 500 | خطأ في الخادم |

## 🔒 الأمان

### Headers المطلوبة
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

### Rate Limiting
- **100 طلب في الدقيقة** للمستخدمين العاديين
- **1000 طلب في الدقيقة** للمديرين

### CORS
```javascript
// المسموح
Origin: http://localhost:3000
Origin: http://localhost:3001
Origin: http://localhost:3002
```

## 📝 أمثلة على الاستخدام

### JavaScript (Fetch)
```javascript
// تسجيل الدخول
const login = async (email, password) => {
  const response = await fetch('http://localhost:5000/api/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ email, password })
  });
  
  const data = await response.json();
  return data;
};

// الحصول على الأطباء
const getDoctors = async (token) => {
  const response = await fetch('http://localhost:5000/api/doctors', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  const data = await response.json();
  return data;
};
```

### Axios
```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:5000/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

// إضافة Token للطلبات
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// تسجيل الدخول
const login = async (email, password) => {
  const response = await api.post('/auth/login', { email, password });
  return response.data;
};
```

### cURL
```bash
# تسجيل الدخول
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'

# الحصول على الأطباء
curl -X GET http://localhost:5000/api/doctors \
  -H "Authorization: Bearer <token>"

# إنشاء حجز
curl -X POST http://localhost:5000/api/bookings \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"doctorId": "doctor_id", "date": "2024-01-15", "time": "10:00"}'
```

## 🧪 اختبار API

### Postman Collection
```json
{
  "info": {
    "name": "BookDoc API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"email\": \"user@example.com\",\n  \"password\": \"password123\"\n}"
            },
            "url": {
              "raw": "{{baseUrl}}/auth/login",
              "host": ["{{baseUrl}}"],
              "path": ["auth", "login"]
            }
          }
        }
      ]
    }
  ]
}
```

## 📞 الدعم

للمساعدة في استخدام API:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير
- راجع ملف `DEPLOYMENT.md` للنشر

## 🔗 روابط مفيدة

- [Postman Documentation](https://learning.postman.com/docs/)
- [REST API Best Practices](https://restfulapi.net/)
- [HTTP Status Codes](https://httpstatuses.com/)
- [JWT.io](https://jwt.io/)
- [MongoDB REST API](https://docs.mongodb.com/realm/api/)
