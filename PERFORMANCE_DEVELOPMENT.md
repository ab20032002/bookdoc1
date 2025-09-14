# دليل التطوير المتقدم للأداء - BookDoc

## ⚡ نظرة عامة

يغطي هذا الدليل استراتيجيات تحسين الأداء لمشروع BookDoc مع التركيز على سرعة التحميل والاستجابة والكفاءة.

## 🎯 أهداف الأداء

### Performance Targets
- **First Contentful Paint (FCP)**: < 1.5s
- **Largest Contentful Paint (LCP)**: < 2.5s
- **First Input Delay (FID)**: < 100ms
- **Cumulative Layout Shift (CLS)**: < 0.1
- **Time to Interactive (TTI)**: < 3.5s
- **API Response Time**: < 200ms
- **Database Query Time**: < 50ms

## 🚀 Frontend Performance

### Code Splitting & Lazy Loading
```typescript
// src/utils/lazyLoading.tsx
import React, { Suspense, lazy } from 'react';
import { LoadingSpinner } from '../components/ui/LoadingSpinner';

// Lazy load components
export const LazyLoginPage = lazy(() => import('../pages/auth/LoginPage'));
export const LazyRegisterPage = lazy(() => import('../pages/auth/RegisterPage'));
export const LazyDashboardPage = lazy(() => import('../pages/dashboard/DashboardPage'));
export const LazyDoctorsPage = lazy(() => import('../pages/doctors/DoctorsPage'));
export const LazyBookingsPage = lazy(() => import('../pages/bookings/BookingsPage'));

// HOC for lazy loading with fallback
export const withLazyLoading = <P extends object>(
  Component: React.ComponentType<P>
) => {
  return (props: P) => (
    <Suspense fallback={<LoadingSpinner />}>
      <Component {...props} />
    </Suspense>
  );
};

// Route-based code splitting
export const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/login" element={
        <Suspense fallback={<LoadingSpinner />}>
          <LazyLoginPage />
        </Suspense>
      } />
      <Route path="/register" element={
        <Suspense fallback={<LoadingSpinner />}>
          <LazyRegisterPage />
        </Suspense>
      } />
      <Route path="/dashboard" element={
        <Suspense fallback={<LoadingSpinner />}>
          <LazyDashboardPage />
        </Suspense>
      } />
      <Route path="/doctors" element={
        <Suspense fallback={<LoadingSpinner />}>
          <LazyDoctorsPage />
        </Suspense>
      } />
      <Route path="/bookings" element={
        <Suspense fallback={<LoadingSpinner />}>
          <LazyBookingsPage />
        </Suspense>
      } />
    </Routes>
  );
};
```

### Image Optimization
```typescript
// src/components/ui/OptimizedImage.tsx
import React, { useState, useRef, useEffect } from 'react';

interface OptimizedImageProps {
  src: string;
  alt: string;
  width?: number;
  height?: number;
  className?: string;
  placeholder?: string;
  lazy?: boolean;
}

const OptimizedImage: React.FC<OptimizedImageProps> = ({
  src,
  alt,
  width,
  height,
  className = '',
  placeholder,
  lazy = true
}) => {
  const [isLoaded, setIsLoaded] = useState(false);
  const [isInView, setIsInView] = useState(!lazy);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    if (!lazy) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsInView(true);
          observer.disconnect();
        }
      },
      { threshold: 0.1 }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => observer.disconnect();
  }, [lazy]);

  const handleLoad = () => {
    setIsLoaded(true);
  };

  return (
    <div
      ref={imgRef}
      className={`relative overflow-hidden ${className}`}
      style={{ width, height }}
    >
      {placeholder && !isLoaded && (
        <div
          className="absolute inset-0 bg-gray-200 animate-pulse"
          style={{ backgroundImage: `url(${placeholder})`, backgroundSize: 'cover' }}
        />
      )}
      
      {isInView && (
        <img
          src={src}
          alt={alt}
          width={width}
          height={height}
          className={`transition-opacity duration-300 ${
            isLoaded ? 'opacity-100' : 'opacity-0'
          }`}
          onLoad={handleLoad}
          loading={lazy ? 'lazy' : 'eager'}
          decoding="async"
        />
      )}
    </div>
  );
};

export default OptimizedImage;
```

### Virtual Scrolling
```typescript
// src/components/ui/VirtualList.tsx
import React, { useState, useEffect, useRef, useMemo } from 'react';

interface VirtualListProps<T> {
  items: T[];
  itemHeight: number;
  containerHeight: number;
  renderItem: (item: T, index: number) => React.ReactNode;
  className?: string;
}

const VirtualList = <T,>({
  items,
  itemHeight,
  containerHeight,
  renderItem,
  className = ''
}: VirtualListProps<T>) => {
  const [scrollTop, setScrollTop] = useState(0);
  const containerRef = useRef<HTMLDivElement>(null);

  const visibleItems = useMemo(() => {
    const startIndex = Math.floor(scrollTop / itemHeight);
    const endIndex = Math.min(
      startIndex + Math.ceil(containerHeight / itemHeight) + 1,
      items.length
    );

    return items.slice(startIndex, endIndex).map((item, index) => ({
      item,
      index: startIndex + index
    }));
  }, [items, itemHeight, containerHeight, scrollTop]);

  const totalHeight = items.length * itemHeight;
  const offsetY = Math.floor(scrollTop / itemHeight) * itemHeight;

  const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop);
  };

  return (
    <div
      ref={containerRef}
      className={`overflow-auto ${className}`}
      style={{ height: containerHeight }}
      onScroll={handleScroll}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        <div
          style={{
            transform: `translateY(${offsetY}px)`,
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0
          }}
        >
          {visibleItems.map(({ item, index }) => (
            <div
              key={index}
              style={{ height: itemHeight }}
            >
              {renderItem(item, index)}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default VirtualList;
```

### Memoization & Optimization
```typescript
// src/components/optimized/ExpensiveComponent.tsx
import React, { memo, useMemo, useCallback } from 'react';

interface ExpensiveComponentProps {
  data: any[];
  onItemClick: (item: any) => void;
  filter: string;
  sortBy: string;
}

const ExpensiveComponent = memo<ExpensiveComponentProps>(({
  data,
  onItemClick,
  filter,
  sortBy
}) => {
  // Memoize expensive calculations
  const processedData = useMemo(() => {
    return data
      .filter(item => 
        item.name.toLowerCase().includes(filter.toLowerCase())
      )
      .sort((a, b) => {
        if (sortBy === 'name') {
          return a.name.localeCompare(b.name);
        }
        if (sortBy === 'date') {
          return new Date(b.date).getTime() - new Date(a.date).getTime();
        }
        return 0;
      });
  }, [data, filter, sortBy]);

  // Memoize callbacks
  const handleItemClick = useCallback((item: any) => {
    onItemClick(item);
  }, [onItemClick]);

  // Memoize expensive rendering
  const renderedItems = useMemo(() => {
    return processedData.map(item => (
      <div
        key={item.id}
        onClick={() => handleItemClick(item)}
        className="p-4 border rounded hover:bg-gray-50 cursor-pointer"
      >
        <h3 className="font-semibold">{item.name}</h3>
        <p className="text-gray-600">{item.description}</p>
        <span className="text-sm text-gray-500">{item.date}</span>
      </div>
    ));
  }, [processedData, handleItemClick]);

  return (
    <div className="space-y-2">
      {renderedItems}
    </div>
  );
});

ExpensiveComponent.displayName = 'ExpensiveComponent';

export default ExpensiveComponent;
```

## 🗄️ Database Performance

### Query Optimization
```typescript
// src/utils/queryOptimizer.ts
import mongoose from 'mongoose';

export class QueryOptimizer {
  // إنشاء فهارس محسنة
  static async createOptimizedIndexes() {
    const db = mongoose.connection.db;
    
    // فهارس مركبة للاستعلامات الشائعة
    await db.collection('doctors').createIndex(
      { specialty: 1, location: 1, rating: -1 },
      { background: true }
    );
    
    await db.collection('bookings').createIndex(
      { doctorId: 1, date: 1, status: 1 },
      { background: true }
    );
    
    await db.collection('reviews').createIndex(
      { doctorId: 1, rating: 1, createdAt: -1 },
      { background: true }
    );
    
    // فهارس نصية للبحث
    await db.collection('doctors').createIndex({
      specialty: 'text',
      location: 'text',
      description: 'text'
    });
  }

  // تحسين الاستعلامات
  static optimizeQuery(query: any) {
    // إضافة select للحد من البيانات
    if (!query.select) {
      query.select('-__v -createdAt -updatedAt');
    }
    
    // إضافة populate محسن
    if (query.populate) {
      query.populate({
        path: 'userId',
        select: 'name email phone'
      });
    }
    
    // إضافة lean للاستعلامات السريعة
    if (query.lean === undefined) {
      query.lean(true);
    }
    
    return query;
  }

  // تحسين التجميع
  static async getOptimizedStats(doctorId: string) {
    const pipeline = [
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
          totalRevenue: { $sum: '$totalAmount' },
          averageRating: { $avg: '$rating' }
        }
      }
    ];

    return await mongoose.connection.db
      .collection('bookings')
      .aggregate(pipeline)
      .toArray();
  }
}
```

### Connection Pooling
```typescript
// src/config/database.ts
import mongoose from 'mongoose';

export const connectDB = async () => {
  try {
    const options = {
      maxPoolSize: 10, // Maintain up to 10 socket connections
      serverSelectionTimeoutMS: 5000, // Keep trying to send operations for 5 seconds
      socketTimeoutMS: 45000, // Close sockets after 45 seconds of inactivity
      bufferMaxEntries: 0, // Disable mongoose buffering
      bufferCommands: false, // Disable mongoose buffering
    };

    await mongoose.connect(process.env.MONGODB_URI!, options);
    
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

// Event listeners for connection monitoring
mongoose.connection.on('connected', () => {
  console.log('Mongoose connected to MongoDB');
});

mongoose.connection.on('error', (err) => {
  console.error('Mongoose connection error:', err);
});

mongoose.connection.on('disconnected', () => {
  console.log('Mongoose disconnected from MongoDB');
});

// Graceful shutdown
process.on('SIGINT', async () => {
  await mongoose.connection.close();
  console.log('MongoDB connection closed through app termination');
  process.exit(0);
});
```

## 🚀 Backend Performance

### Caching Strategy
```typescript
// src/services/cacheService.ts
import Redis from 'ioredis';

class CacheService {
  private redis: Redis;
  private defaultTTL = 3600; // 1 hour

  constructor() {
    this.redis = new Redis({
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT || '6379'),
      password: process.env.REDIS_PASSWORD,
      retryDelayOnFailover: 100,
      maxRetriesPerRequest: 3,
      lazyConnect: true
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

  async set(key: string, value: any, ttl: number = this.defaultTTL): Promise<void> {
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

  // Cache middleware
  cacheMiddleware(ttl: number = this.defaultTTL) {
    return async (req: any, res: any, next: any) => {
      const key = `cache:${req.originalUrl}:${JSON.stringify(req.query)}`;
      
      try {
        const cached = await this.get(key);
        if (cached) {
          return res.json(cached);
        }
        
        // Store original res.json
        const originalJson = res.json;
        res.json = function(data: any) {
          // Cache the response
          this.set(key, data, ttl);
          return originalJson.call(this, data);
        }.bind(this);
        
        next();
      } catch (error) {
        console.error('Cache middleware error:', error);
        next();
      }
    };
  }
}

export const cacheService = new CacheService();
```

### Response Compression
```typescript
// src/middleware/compression.ts
import compression from 'compression';
import { Request, Response, NextFunction } from 'express';

export const compressionMiddleware = compression({
  level: 6, // Compression level (1-9)
  threshold: 1024, // Only compress responses larger than 1KB
  filter: (req: Request, res: Response) => {
    // Don't compress if the request includes a no-transform directive
    if (req.headers['cache-control'] && req.headers['cache-control'].includes('no-transform')) {
      return false;
    }
    
    // Use compression for all other responses
    return compression.filter(req, res);
  }
});
```

### Request Batching
```typescript
// src/utils/requestBatcher.ts
class RequestBatcher<T, R> {
  private batch: Array<{ request: T; resolve: (value: R) => void; reject: (error: any) => void }> = [];
  private timeout: NodeJS.Timeout | null = null;
  private batchSize: number;
  private batchTimeout: number;
  private processor: (requests: T[]) => Promise<R[]>;

  constructor(
    processor: (requests: T[]) => Promise<R[]>,
    batchSize: number = 10,
    batchTimeout: number = 100
  ) {
    this.processor = processor;
    this.batchSize = batchSize;
    this.batchTimeout = batchTimeout;
  }

  async add(request: T): Promise<R> {
    return new Promise((resolve, reject) => {
      this.batch.push({ request, resolve, reject });
      
      if (this.batch.length >= this.batchSize) {
        this.processBatch();
      } else if (!this.timeout) {
        this.timeout = setTimeout(() => {
          this.processBatch();
        }, this.batchTimeout);
      }
    });
  }

  private async processBatch() {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }

    const currentBatch = this.batch.splice(0, this.batchSize);
    
    if (currentBatch.length === 0) return;

    try {
      const requests = currentBatch.map(item => item.request);
      const results = await this.processor(requests);
      
      currentBatch.forEach((item, index) => {
        item.resolve(results[index]);
      });
    } catch (error) {
      currentBatch.forEach(item => {
        item.reject(error);
      });
    }
  }
}

// Usage example
const userBatcher = new RequestBatcher(
  async (userIds: string[]) => {
    return await User.find({ _id: { $in: userIds } });
  },
  10, // batch size
  100 // timeout in ms
);

export { RequestBatcher, userBatcher };
```

## 📊 Performance Monitoring

### Performance Metrics
```typescript
// src/middleware/performance.ts
import { Request, Response, NextFunction } from 'express';
import { performance } from 'perf_hooks';

export const performanceMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const start = performance.now();
  
  res.on('finish', () => {
    const duration = performance.now() - start;
    const { method, url } = req;
    const { statusCode } = res;
    
    // Log performance metrics
    console.log(`Performance: ${method} ${url} - ${statusCode} - ${duration.toFixed(2)}ms`);
    
    // Send metrics to monitoring service
    if (process.env.NODE_ENV === 'production') {
      // Send to Prometheus, DataDog, etc.
      sendMetrics({
        method,
        url,
        statusCode,
        duration,
        timestamp: new Date().toISOString()
      });
    }
    
    // Alert for slow requests
    if (duration > 1000) {
      console.warn(`Slow request detected: ${method} ${url} - ${duration.toFixed(2)}ms`);
    }
  });
  
  next();
};

const sendMetrics = (metrics: any) => {
  // Implementation depends on your monitoring service
  // Example: Send to Prometheus
  // prometheusClient.recordRequestDuration(metrics);
};
```

### Bundle Analysis
```typescript
// scripts/analyze-bundle.js
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

module.exports = {
  plugins: [
    new BundleAnalyzerPlugin({
      analyzerMode: 'static',
      openAnalyzer: false,
      reportFilename: 'bundle-report.html'
    })
  ]
};
```

## 🎯 Performance Testing

### Load Testing
```typescript
// tests/performance/load-test.ts
import { check, sleep } from 'k6';
import http from 'k6/http';

export let options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up to 100 users
    { duration: '5m', target: 100 }, // Stay at 100 users
    { duration: '2m', target: 200 }, // Ramp up to 200 users
    { duration: '5m', target: 200 }, // Stay at 200 users
    { duration: '2m', target: 0 },   // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.1'],    // Error rate must be below 10%
  },
};

export default function() {
  // Test API endpoints
  let response = http.get('https://api.bookdoc.com/doctors');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);

  // Test booking creation
  response = http.post('https://api.bookdoc.com/bookings', {
    doctorId: '507f1f77bcf86cd799439011',
    date: '2024-01-15',
    time: '10:00',
    type: 'normal'
  });
  check(response, {
    'status is 201': (r) => r.status === 201,
    'response time < 1000ms': (r) => r.timings.duration < 1000,
  });

  sleep(1);
}
```

## 📞 الدعم

للمساعدة في التطوير المتقدم للأداء:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير الأساسي
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [React Performance](https://reactjs.org/docs/optimizing-performance.html)
- [Web Vitals](https://web.dev/vitals/)
- [MongoDB Performance](https://docs.mongodb.com/manual/performance/)
- [Redis Performance](https://redis.io/docs/manual/performance/)
- [Node.js Performance](https://nodejs.org/en/docs/guides/simple-profiling/)
- [K6 Load Testing](https://k6.io/docs/)
