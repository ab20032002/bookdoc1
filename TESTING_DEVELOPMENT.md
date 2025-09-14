# دليل التطوير المتقدم للاختبار - BookDoc

## 🧪 نظرة عامة

يتبع مشروع BookDoc استراتيجية اختبار شاملة تشمل اختبارات الوحدة والتكامل واختبارات نهاية إلى نهاية مع تغطية كاملة للكود.

## 🛠️ أدوات الاختبار

### Frontend Testing
```json
{
  "devDependencies": {
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/user-event": "^14.4.3",
    "jest": "^29.3.1",
    "jest-environment-jsdom": "^29.3.1",
    "jest-axe": "^7.0.0",
    "msw": "^1.0.0",
    "cypress": "^12.0.0"
  }
}
```

### Backend Testing
```json
{
  "devDependencies": {
    "jest": "^29.3.1",
    "supertest": "^6.3.3",
    "mongodb-memory-server": "^8.12.2",
    "faker": "^6.6.6",
    "sinon": "^15.0.0"
  }
}
```

## 🧩 اختبارات الوحدة المتقدمة

### Advanced Component Testing
```typescript
// src/components/__tests__/AdvancedForm.test.tsx
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe, toHaveNoViolations } from 'jest-axe';
import AdvancedForm from '../AdvancedForm';

expect.extend(toHaveNoViolations);

describe('AdvancedForm', () => {
  const mockFields = [
    {
      name: 'name',
      label: 'الاسم',
      type: 'text' as const,
      required: true,
      placeholder: 'أدخل اسمك'
    },
    {
      name: 'email',
      label: 'البريد الإلكتروني',
      type: 'email' as const,
      required: true,
      placeholder: 'أدخل بريدك الإلكتروني'
    },
    {
      name: 'role',
      label: 'الدور',
      type: 'select' as const,
      required: true,
      options: [
        { value: 'patient', label: 'مريض' },
        { value: 'doctor', label: 'طبيب' }
      ]
    }
  ];

  const mockOnSubmit = jest.fn();

  beforeEach(() => {
    mockOnSubmit.mockClear();
  });

  test('renders form with all fields', () => {
    render(<AdvancedForm fields={mockFields} onSubmit={mockOnSubmit} />);
    
    expect(screen.getByLabelText(/الاسم/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/البريد الإلكتروني/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/الدور/i)).toBeInTheDocument();
  });

  test('validates required fields', async () => {
    const user = userEvent.setup();
    render(<AdvancedForm fields={mockFields} onSubmit={mockOnSubmit} />);
    
    const submitButton = screen.getByRole('button', { name: /إرسال/i });
    await user.click(submitButton);
    
    expect(screen.getByText(/الاسم مطلوب/i)).toBeInTheDocument();
    expect(screen.getByText(/البريد الإلكتروني مطلوب/i)).toBeInTheDocument();
  });

  test('submits form with valid data', async () => {
    const user = userEvent.setup();
    render(<AdvancedForm fields={mockFields} onSubmit={mockOnSubmit} />);
    
    await user.type(screen.getByLabelText(/الاسم/i), 'أحمد محمد');
    await user.type(screen.getByLabelText(/البريد الإلكتروني/i), 'ahmed@example.com');
    await user.selectOptions(screen.getByLabelText(/الدور/i), 'patient');
    
    const submitButton = screen.getByRole('button', { name: /إرسال/i });
    await user.click(submitButton);
    
    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        name: 'أحمد محمد',
        email: 'ahmed@example.com',
        role: 'patient'
      });
    });
  });

  test('handles form submission errors', async () => {
    const user = userEvent.setup();
    const errorMessage = 'حدث خطأ أثناء الإرسال';
    mockOnSubmit.mockRejectedValueOnce(new Error(errorMessage));
    
    render(<AdvancedForm fields={mockFields} onSubmit={mockOnSubmit} />);
    
    await user.type(screen.getByLabelText(/الاسم/i), 'أحمد محمد');
    await user.type(screen.getByLabelText(/البريد الإلكتروني/i), 'ahmed@example.com');
    await user.selectOptions(screen.getByLabelText(/الدور/i), 'patient');
    
    const submitButton = screen.getByRole('button', { name: /إرسال/i });
    await user.click(submitButton);
    
    await waitFor(() => {
      expect(screen.getByText(errorMessage)).toBeInTheDocument();
    });
  });

  test('has no accessibility violations', async () => {
    const { container } = render(<AdvancedForm fields={mockFields} onSubmit={mockOnSubmit} />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  test('shows loading state during submission', async () => {
    const user = userEvent.setup();
    let resolvePromise: (value: any) => void;
    const promise = new Promise(resolve => {
      resolvePromise = resolve;
    });
    mockOnSubmit.mockReturnValueOnce(promise);
    
    render(<AdvancedForm fields={mockFields} onSubmit={mockOnSubmit} />);
    
    await user.type(screen.getByLabelText(/الاسم/i), 'أحمد محمد');
    await user.type(screen.getByLabelText(/البريد الإلكتروني/i), 'ahmed@example.com');
    await user.selectOptions(screen.getByLabelText(/الدور/i), 'patient');
    
    const submitButton = screen.getByRole('button', { name: /إرسال/i });
    await user.click(submitButton);
    
    expect(screen.getByText(/جاري الإرسال/i)).toBeInTheDocument();
    expect(submitButton).toBeDisabled();
    
    resolvePromise!({});
    await waitFor(() => {
      expect(screen.queryByText(/جاري الإرسال/i)).not.toBeInTheDocument();
    });
  });
});
```

### Advanced Hook Testing
```typescript
// src/hooks/__tests__/useApi.test.ts
import { renderHook, act } from '@testing-library/react';
import { useApi } from '../useApi';

describe('useApi', () => {
  const mockApiFunction = jest.fn();

  beforeEach(() => {
    mockApiFunction.mockClear();
  });

  test('initial state is correct', () => {
    const { result } = renderHook(() => useApi(mockApiFunction));
    
    expect(result.current.data).toBeNull();
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
  });

  test('executes API function and updates state', async () => {
    const mockData = { id: 1, name: 'Test' };
    mockApiFunction.mockResolvedValueOnce(mockData);
    
    const { result } = renderHook(() => useApi(mockApiFunction));
    
    await act(async () => {
      await result.current.execute();
    });
    
    expect(result.current.data).toEqual(mockData);
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
  });

  test('handles API errors', async () => {
    const mockError = new Error('API Error');
    mockApiFunction.mockRejectedValueOnce(mockError);
    
    const { result } = renderHook(() => useApi(mockApiFunction));
    
    await act(async () => {
      try {
        await result.current.execute();
      } catch (error) {
        // Expected to throw
      }
    });
    
    expect(result.current.data).toBeNull();
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toEqual(mockError);
  });

  test('executes immediately when immediate option is true', async () => {
    const mockData = { id: 1, name: 'Test' };
    mockApiFunction.mockResolvedValueOnce(mockData);
    
    renderHook(() => useApi(mockApiFunction, { immediate: true }));
    
    await act(async () => {
      // Wait for the immediate execution
    });
    
    expect(mockApiFunction).toHaveBeenCalledTimes(1);
  });

  test('calls onSuccess callback', async () => {
    const mockData = { id: 1, name: 'Test' };
    const mockOnSuccess = jest.fn();
    mockApiFunction.mockResolvedValueOnce(mockData);
    
    const { result } = renderHook(() => 
      useApi(mockApiFunction, { onSuccess: mockOnSuccess })
    );
    
    await act(async () => {
      await result.current.execute();
    });
    
    expect(mockOnSuccess).toHaveBeenCalledWith(mockData);
  });

  test('calls onError callback', async () => {
    const mockError = new Error('API Error');
    const mockOnError = jest.fn();
    mockApiFunction.mockRejectedValueOnce(mockError);
    
    const { result } = renderHook(() => 
      useApi(mockApiFunction, { onError: mockOnError })
    );
    
    await act(async () => {
      try {
        await result.current.execute();
      } catch (error) {
        // Expected to throw
      }
    });
    
    expect(mockOnError).toHaveBeenCalledWith(mockError);
  });
});
```

## 🔗 اختبارات التكامل المتقدمة

### API Integration Testing
```typescript
// src/__tests__/integration/api.test.ts
import request from 'supertest';
import app from '../../app';
import { connectDB, disconnectDB } from '../../config/database';
import { User } from '../../models/User';
import { Doctor } from '../../models/Doctor';
import { Booking } from '../../models/Booking';

describe('API Integration Tests', () => {
  let authToken: string;
  let userId: string;
  let doctorId: string;

  beforeAll(async () => {
    await connectDB();
  });

  afterAll(async () => {
    await disconnectDB();
  });

  beforeEach(async () => {
    // تنظيف قاعدة البيانات
    await User.deleteMany({});
    await Doctor.deleteMany({});
    await Booking.deleteMany({});

    // إنشاء مستخدم تجريبي
    const user = new User({
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      phone: '01234567890',
      role: 'patient'
    });
    await user.save();
    userId = user._id.toString();

    // تسجيل الدخول
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'password123'
      });

    authToken = loginResponse.body.token;

    // إنشاء طبيب تجريبي
    const doctor = new Doctor({
      userId: user._id,
      specialty: 'أمراض القلب',
      experience: 10,
      location: 'القاهرة',
      price: 200
    });
    await doctor.save();
    doctorId = doctor._id.toString();
  });

  describe('Authentication Flow', () => {
    test('complete authentication flow', async () => {
      // تسجيل الدخول
      const loginResponse = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'password123'
        });

      expect(loginResponse.status).toBe(200);
      expect(loginResponse.body.success).toBe(true);
      expect(loginResponse.body.token).toBeDefined();

      // الوصول إلى محتوى محمي
      const profileResponse = await request(app)
        .get('/api/users/profile')
        .set('Authorization', `Bearer ${loginResponse.body.token}`);

      expect(profileResponse.status).toBe(200);
      expect(profileResponse.body.user.email).toBe('test@example.com');
    });

    test('handles invalid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'wrongpassword'
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('Booking Flow', () => {
    test('complete booking process', async () => {
      // إنشاء حجز
      const bookingResponse = await request(app)
        .post('/api/bookings')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          doctorId,
          date: '2024-01-15',
          time: '10:00',
          type: 'normal'
        });

      expect(bookingResponse.status).toBe(201);
      expect(bookingResponse.body.booking).toBeDefined();

      const bookingId = bookingResponse.body.booking._id;

      // الحصول على الحجز
      const getBookingResponse = await request(app)
        .get(`/api/bookings/${bookingId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(getBookingResponse.status).toBe(200);
      expect(getBookingResponse.body.booking._id).toBe(bookingId);

      // تحديث حالة الحجز
      const updateResponse = await request(app)
        .put(`/api/bookings/${bookingId}/status`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({ status: 'confirmed' });

      expect(updateResponse.status).toBe(200);
      expect(updateResponse.body.booking.status).toBe('confirmed');
    });

    test('handles booking conflicts', async () => {
      // إنشاء حجز أول
      await request(app)
        .post('/api/bookings')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          doctorId,
          date: '2024-01-15',
          time: '10:00',
          type: 'normal'
        });

      // محاولة إنشاء حجز متعارض
      const conflictResponse = await request(app)
        .post('/api/bookings')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          doctorId,
          date: '2024-01-15',
          time: '10:00',
          type: 'normal'
        });

      expect(conflictResponse.status).toBe(409);
      expect(conflictResponse.body.success).toBe(false);
    });
  });

  describe('Doctor Search', () => {
    test('search doctors with filters', async () => {
      const response = await request(app)
        .get('/api/doctors')
        .query({
          specialty: 'أمراض القلب',
          location: 'القاهرة',
          minRating: 4.0
        });

      expect(response.status).toBe(200);
      expect(response.body.doctors).toHaveLength(1);
      expect(response.body.doctors[0].specialty).toBe('أمراض القلب');
    });

    test('handles empty search results', async () => {
      const response = await request(app)
        .get('/api/doctors')
        .query({
          specialty: 'غير موجود',
          location: 'القاهرة'
        });

      expect(response.status).toBe(200);
      expect(response.body.doctors).toHaveLength(0);
    });
  });
});
```

## 🎭 اختبارات نهاية إلى نهاية

### Cypress E2E Tests
```typescript
// cypress/e2e/booking-flow.cy.ts
describe('Booking Flow', () => {
  beforeEach(() => {
    cy.visit('/');
  });

  it('complete booking process', () => {
    // تسجيل الدخول
    cy.get('[data-testid="login-button"]').click();
    cy.get('[data-testid="email-input"]').type('test@example.com');
    cy.get('[data-testid="password-input"]').type('password123');
    cy.get('[data-testid="login-submit"]').click();

    // الانتقال إلى صفحة الأطباء
    cy.get('[data-testid="doctors-nav"]').click();
    cy.url().should('include', '/doctors');

    // البحث عن طبيب
    cy.get('[data-testid="specialty-filter"]').select('أمراض القلب');
    cy.get('[data-testid="search-button"]').click();

    // اختيار طبيب
    cy.get('[data-testid="doctor-card"]').first().click();
    cy.url().should('include', '/doctors/');

    // حجز موعد
    cy.get('[data-testid="book-appointment"]').click();
    cy.get('[data-testid="date-input"]').type('2024-01-15');
    cy.get('[data-testid="time-select"]').select('10:00');
    cy.get('[data-testid="booking-submit"]').click();

    // التحقق من نجاح الحجز
    cy.get('[data-testid="success-message"]').should('contain', 'تم حجز الموعد بنجاح');
    cy.get('[data-testid="booking-id"]').should('be.visible');
  });

  it('handles booking errors', () => {
    // تسجيل الدخول
    cy.get('[data-testid="login-button"]').click();
    cy.get('[data-testid="email-input"]').type('test@example.com');
    cy.get('[data-testid="password-input"]').type('password123');
    cy.get('[data-testid="login-submit"]').click();

    // محاولة حجز موعد بدون اختيار تاريخ
    cy.get('[data-testid="doctors-nav"]').click();
    cy.get('[data-testid="doctor-card"]').first().click();
    cy.get('[data-testid="book-appointment"]').click();
    cy.get('[data-testid="booking-submit"]').click();

    // التحقق من رسالة الخطأ
    cy.get('[data-testid="error-message"]').should('contain', 'يرجى اختيار تاريخ');
  });

  it('handles network errors gracefully', () => {
    // محاكاة خطأ في الشبكة
    cy.intercept('POST', '/api/bookings', { forceNetworkError: true });

    // تسجيل الدخول
    cy.get('[data-testid="login-button"]').click();
    cy.get('[data-testid="email-input"]').type('test@example.com');
    cy.get('[data-testid="password-input"]').type('password123');
    cy.get('[data-testid="login-submit"]').click();

    // محاولة حجز موعد
    cy.get('[data-testid="doctors-nav"]').click();
    cy.get('[data-testid="doctor-card"]').first().click();
    cy.get('[data-testid="book-appointment"]').click();
    cy.get('[data-testid="date-input"]').type('2024-01-15');
    cy.get('[data-testid="time-select"]').select('10:00');
    cy.get('[data-testid="booking-submit"]').click();

    // التحقق من رسالة الخطأ
    cy.get('[data-testid="error-message"]').should('contain', 'حدث خطأ في الشبكة');
  });
});
```

## ⚡ اختبارات الأداء

### Performance Testing
```typescript
// tests/performance/api-performance.test.ts
import request from 'supertest';
import app from '../../app';

describe('API Performance Tests', () => {
  test('handles multiple concurrent requests', async () => {
    const requests = [];
    const startTime = Date.now();

    // إرسال 100 طلب متزامن
    for (let i = 0; i < 100; i++) {
      requests.push(
        request(app)
          .get('/api/doctors')
          .expect(200)
      );
    }

    await Promise.all(requests);
    const endTime = Date.now();
    const duration = endTime - startTime;

    // التحقق من أن جميع الطلبات اكتملت في أقل من 5 ثوان
    expect(duration).toBeLessThan(5000);
  });

  test('handles large data sets efficiently', async () => {
    const startTime = Date.now();

    const response = await request(app)
      .get('/api/doctors?limit=1000')
      .expect(200);

    const endTime = Date.now();
    const duration = endTime - startTime;

    // التحقق من أن الاستجابة اكتملت في أقل من 2 ثانية
    expect(duration).toBeLessThan(2000);
    expect(response.body.doctors).toHaveLength(1000);
  });

  test('database queries are optimized', async () => {
    const startTime = Date.now();

    const response = await request(app)
      .get('/api/doctors?specialty=أمراض القلب&location=القاهرة')
      .expect(200);

    const endTime = Date.now();
    const duration = endTime - startTime;

    // التحقق من أن الاستعلام اكتمل في أقل من 500 مللي ثانية
    expect(duration).toBeLessThan(500);
  });
});
```

## 🧪 اختبارات الأمان

### Security Testing
```typescript
// tests/security/security.test.ts
import request from 'supertest';
import app from '../../app';

describe('Security Tests', () => {
  test('prevents SQL injection', async () => {
    const maliciousInput = "'; DROP TABLE users; --";
    
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: maliciousInput,
        password: 'password123'
      });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
  });

  test('prevents XSS attacks', async () => {
    const maliciousInput = '<script>alert("XSS")</script>';
    
    const response = await request(app)
      .post('/api/users/profile')
      .set('Authorization', 'Bearer valid-token')
      .send({
        name: maliciousInput
      });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
  });

  test('enforces rate limiting', async () => {
    const requests = [];
    
    // إرسال 101 طلب (أكثر من الحد المسموح)
    for (let i = 0; i < 101; i++) {
      requests.push(
        request(app)
          .post('/api/auth/login')
          .send({
            email: 'test@example.com',
            password: 'password123'
          })
      );
    }

    const responses = await Promise.all(requests);
    const rateLimitedResponses = responses.filter(r => r.status === 429);
    
    expect(rateLimitedResponses.length).toBeGreaterThan(0);
  });

  test('validates JWT tokens', async () => {
    const response = await request(app)
      .get('/api/users/profile')
      .set('Authorization', 'Bearer invalid-token')
      .expect(401);

    expect(response.body.success).toBe(false);
    expect(response.body.message).toContain('Invalid token');
  });
});
```

## 📊 اختبارات التغطية

### Coverage Configuration
```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.js'],
  moduleNameMapping: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
    '\\.(gif|ttf|eot|svg|png)$': '<rootDir>/__mocks__/fileMock.js'
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/index.js',
    '!src/reportWebVitals.js',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}'
  ],
  coverageThreshold: {
    global: {
      branches: 85,
      functions: 85,
      lines: 85,
      statements: 85
    },
    './src/components/': {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90
    },
    './src/hooks/': {
      branches: 95,
      functions: 95,
      lines: 95,
      statements: 95
    }
  },
  coverageReporters: ['text', 'lcov', 'html', 'json-summary']
};
```

## 📞 الدعم

للمساعدة في التطوير المتقدم للاختبار:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير الأساسي
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Cypress Documentation](https://docs.cypress.io/)
- [Supertest Documentation](https://github.com/visionmedia/supertest)
- [MSW Documentation](https://mswjs.io/)
- [Jest Axe Documentation](https://github.com/nickcolley/jest-axe)