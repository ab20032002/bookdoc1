# دليل الاختبار - BookDoc

## 🧪 نظرة عامة على الاختبار

يتبع مشروع BookDoc استراتيجية اختبار شاملة تشمل:

1. **Unit Tests** - اختبار الوحدات الفردية
2. **Integration Tests** - اختبار التكامل بين المكونات
3. **API Tests** - اختبار واجهات برمجة التطبيقات
4. **E2E Tests** - اختبار نهاية إلى نهاية
5. **Performance Tests** - اختبار الأداء

## 🛠️ أدوات الاختبار

### Frontend Testing
```json
{
  "devDependencies": {
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/user-event": "^14.4.3",
    "jest": "^29.3.1",
    "jest-environment-jsdom": "^29.3.1"
  }
}
```

### Backend Testing
```json
{
  "devDependencies": {
    "jest": "^29.3.1",
    "supertest": "^6.3.3",
    "mongodb-memory-server": "^8.12.2"
  }
}
```

## 🧪 Unit Tests

### اختبار المكونات React
```javascript
// src/components/__tests__/Button.test.js
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import Button from '../Button';

describe('Button Component', () => {
  test('renders button with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  test('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  test('applies disabled state correctly', () => {
    render(<Button disabled>Disabled Button</Button>);
    expect(screen.getByText('Disabled Button')).toBeDisabled();
  });
});
```

### اختبار Hooks
```javascript
// src/hooks/__tests__/useAuth.test.js
import { renderHook, act } from '@testing-library/react';
import { useAuth } from '../useAuth';

describe('useAuth Hook', () => {
  test('initial state is correct', () => {
    const { result } = renderHook(() => useAuth());
    
    expect(result.current.user).toBeNull();
    expect(result.current.isLoading).toBe(false);
    expect(result.current.isAuthenticated).toBe(false);
  });

  test('login updates user state', async () => {
    const { result } = renderHook(() => useAuth());
    
    await act(async () => {
      await result.current.login('test@example.com', 'password');
    });
    
    expect(result.current.user).toBeTruthy();
    expect(result.current.isAuthenticated).toBe(true);
  });
});
```

### اختبار الخدمات
```javascript
// src/services/__tests__/api.test.js
import { apiService } from '../api';

// Mock fetch
global.fetch = jest.fn();

describe('API Service', () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  test('login makes correct API call', async () => {
    const mockResponse = {
      success: true,
      token: 'mock-token',
      user: { id: 1, name: 'Test User' }
    };

    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => mockResponse
    });

    const result = await apiService.login('test@example.com', 'password');

    expect(fetch).toHaveBeenCalledWith('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'test@example.com',
        password: 'password'
      })
    });

    expect(result).toEqual(mockResponse);
  });
});
```

## 🔗 Integration Tests

### اختبار التكامل بين المكونات
```javascript
// src/__tests__/integration/LoginForm.test.js
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import LoginForm from '../../components/LoginForm';
import { AuthProvider } from '../../contexts/AuthContext';

const renderWithProviders = (component) => {
  return render(
    <BrowserRouter>
      <AuthProvider>
        {component}
      </AuthProvider>
    </BrowserRouter>
  );
};

describe('LoginForm Integration', () => {
  test('complete login flow', async () => {
    renderWithProviders(<LoginForm />);

    // ملء النموذج
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'test@example.com' }
    });
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: 'password123' }
    });

    // النقر على زر تسجيل الدخول
    fireEvent.click(screen.getByRole('button', { name: /login/i }));

    // انتظار النجاح
    await waitFor(() => {
      expect(screen.getByText(/welcome/i)).toBeInTheDocument();
    });
  });
});
```

## 🌐 API Tests

### اختبار API Endpoints
```javascript
// backend/__tests__/routes/auth.test.js
const request = require('supertest');
const app = require('../../app');
const User = require('../../models/User');

describe('Auth Routes', () => {
  beforeEach(async () => {
    await User.deleteMany({});
  });

  describe('POST /api/auth/register', () => {
    test('should register a new user', async () => {
      const userData = {
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        phone: '01234567890'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.user.email).toBe(userData.email);
      expect(response.body.token).toBeDefined();
    });

    test('should not register user with existing email', async () => {
      const userData = {
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        phone: '01234567890'
      };

      // إنشاء مستخدم أول
      await request(app)
        .post('/api/auth/register')
        .send(userData);

      // محاولة إنشاء مستخدم بنفس البريد الإلكتروني
      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('already exists');
    });
  });

  describe('POST /api/auth/login', () => {
    test('should login with valid credentials', async () => {
      // إنشاء مستخدم أول
      const userData = {
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        phone: '01234567890'
      };

      await request(app)
        .post('/api/auth/register')
        .send(userData);

      // تسجيل الدخول
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: userData.email,
          password: userData.password
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.token).toBeDefined();
      expect(response.body.user.email).toBe(userData.email);
    });

    test('should not login with invalid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: 'wrongpassword'
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Invalid credentials');
    });
  });
});
```

### اختبار Middleware
```javascript
// backend/__tests__/middleware/auth.test.js
const request = require('supertest');
const app = require('../../app');
const User = require('../../models/User');
const jwt = require('jsonwebtoken');

describe('Auth Middleware', () => {
  test('should allow access with valid token', async () => {
    // إنشاء مستخدم
    const user = new User({
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      phone: '01234567890'
    });
    await user.save();

    // إنشاء token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET
    );

    const response = await request(app)
      .get('/api/users/profile')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(response.body.user.email).toBe(user.email);
  });

  test('should deny access without token', async () => {
    const response = await request(app)
      .get('/api/users/profile')
      .expect(401);

    expect(response.body.message).toContain('No token provided');
  });

  test('should deny access with invalid token', async () => {
    const response = await request(app)
      .get('/api/users/profile')
      .set('Authorization', 'Bearer invalid-token')
      .expect(401);

    expect(response.body.message).toContain('Invalid token');
  });
});
```

## 🎭 E2E Tests

### اختبار نهاية إلى نهاية
```javascript
// e2e/booking-flow.test.js
const { test, expect } = require('@playwright/test');

test.describe('Booking Flow', () => {
  test('complete booking process', async ({ page }) => {
    // الانتقال إلى الصفحة الرئيسية
    await page.goto('http://localhost:3000');

    // تسجيل الدخول
    await page.click('text=تسجيل الدخول');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // البحث عن طبيب
    await page.click('text=البحث عن أطباء');
    await page.selectOption('select[name="specialty"]', 'أمراض القلب');
    await page.click('button[type="submit"]');

    // اختيار طبيب
    await page.click('.doctor-card:first-child');

    // حجز موعد
    await page.click('text=حجز موعد');
    await page.fill('input[name="date"]', '2024-01-15');
    await page.selectOption('select[name="time"]', '10:00');
    await page.click('button[type="submit"]');

    // التحقق من نجاح الحجز
    await expect(page.locator('text=تم حجز الموعد بنجاح')).toBeVisible();
  });
});
```

## ⚡ Performance Tests

### اختبار الأداء
```javascript
// tests/performance/api-performance.test.js
const request = require('supertest');
const app = require('../../backend/app');

describe('API Performance', () => {
  test('should handle multiple concurrent requests', async () => {
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

  test('should handle large data sets efficiently', async () => {
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
});
```

## 🧪 Test Configuration

### Jest Configuration
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
    'src/**/*.{js,jsx}',
    '!src/index.js',
    '!src/reportWebVitals.js'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```

### Test Setup
```javascript
// src/setupTests.js
import '@testing-library/jest-dom';

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn()
};
global.localStorage = localStorageMock;

// Mock fetch
global.fetch = jest.fn();

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  disconnect() {}
  observe() {}
  unobserve() {}
};
```

## 📊 Test Coverage

### تشغيل اختبارات التغطية
```bash
# تشغيل الاختبارات مع التغطية
npm test -- --coverage

# تشغيل الاختبارات في وضع المراقبة
npm test -- --watch

# تشغيل اختبارات محددة
npm test -- --testNamePattern="Login"
```

### Coverage Report
```javascript
// coverage/lcov-report/index.html
// تقرير تفصيلي عن تغطية الكود

// coverage/lcov.info
// ملف LCOV للتحليل

// coverage/coverage-summary.json
// ملخص التغطية
```

## 🚀 CI/CD Testing

### GitHub Actions
```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test -- --coverage --watchAll=false
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

## 🧪 Test Data

### Mock Data
```javascript
// __mocks__/mockData.js
export const mockUser = {
  id: '1',
  name: 'Test User',
  email: 'test@example.com',
  role: 'patient',
  phone: '01234567890'
};

export const mockDoctor = {
  id: '1',
  name: 'د. أحمد محمد',
  specialty: 'أمراض القلب',
  rating: 4.8,
  experience: 10,
  location: 'القاهرة',
  price: 200
};

export const mockBooking = {
  id: '1',
  patientId: '1',
  doctorId: '1',
  date: '2024-01-15',
  time: '10:00',
  status: 'confirmed',
  type: 'normal'
};
```

### Test Database
```javascript
// tests/setup/testDatabase.js
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;

const setupTestDatabase = async () => {
  mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();
  
  await mongoose.connect(mongoUri);
};

const teardownTestDatabase = async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
};

module.exports = {
  setupTestDatabase,
  teardownTestDatabase
};
```

## 📝 Test Documentation

### Test Cases Documentation
```markdown
# Test Cases Documentation

## Authentication Tests
- [ ] User registration with valid data
- [ ] User registration with invalid data
- [ ] User login with valid credentials
- [ ] User login with invalid credentials
- [ ] Password reset functionality
- [ ] Token expiration handling

## Booking Tests
- [ ] Create booking with valid data
- [ ] Create booking with invalid data
- [ ] Update booking status
- [ ] Cancel booking
- [ ] View booking details
- [ ] Generate QR code

## Doctor Tests
- [ ] Create doctor profile
- [ ] Update doctor profile
- [ ] Search doctors by specialty
- [ ] Filter doctors by location
- [ ] View doctor details
- [ ] Rate doctor

## Admin Tests
- [ ] View system statistics
- [ ] Manage users
- [ ] Manage doctors
- [ ] View reports
- [ ] System configuration
```

## 📞 الدعم

للمساعدة في الاختبار:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Supertest Documentation](https://github.com/visionmedia/supertest)
- [Playwright Documentation](https://playwright.dev/)
- [MongoDB Memory Server](https://github.com/nodkz/mongodb-memory-server)
- [Code Coverage](https://jestjs.io/docs/code-coverage)
