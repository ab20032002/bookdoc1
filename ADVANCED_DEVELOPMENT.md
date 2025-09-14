# دليل التطوير المتقدم - BookDoc

## 🚀 الميزات المتقدمة

### 1. Real-time Notifications

#### WebSocket Implementation
```javascript
// backend/websocket/socketHandler.js
const socketIo = require('socket.io');

class SocketHandler {
  constructor(server) {
    this.io = socketIo(server, {
      cors: {
        origin: process.env.FRONTEND_URL,
        methods: ['GET', 'POST']
      }
    });
    
    this.setupConnection();
  }

  setupConnection() {
    this.io.on('connection', (socket) => {
      console.log('User connected:', socket.id);

      // انضمام المستخدم لغرفة محددة
      socket.on('join-room', (userId) => {
        socket.join(`user-${userId}`);
        console.log(`User ${userId} joined room`);
      });

      // إرسال إشعار فوري
      socket.on('send-notification', (data) => {
        this.sendNotification(data.userId, data.message);
      });

      socket.on('disconnect', () => {
        console.log('User disconnected:', socket.id);
      });
    });
  }

  sendNotification(userId, message) {
    this.io.to(`user-${userId}`).emit('notification', {
      message,
      timestamp: new Date(),
      type: 'info'
    });
  }

  broadcastBookingUpdate(bookingId, update) {
    this.io.emit('booking-update', {
      bookingId,
      update,
      timestamp: new Date()
    });
  }
}

module.exports = SocketHandler;
```

#### Frontend WebSocket Client
```javascript
// src/services/socketService.js
import io from 'socket.io-client';

class SocketService {
  constructor() {
    this.socket = null;
    this.isConnected = false;
  }

  connect(token) {
    this.socket = io(process.env.REACT_APP_API_URL, {
      auth: { token },
      transports: ['websocket']
    });

    this.socket.on('connect', () => {
      this.isConnected = true;
      console.log('Connected to server');
    });

    this.socket.on('disconnect', () => {
      this.isConnected = false;
      console.log('Disconnected from server');
    });

    this.socket.on('notification', (data) => {
      this.handleNotification(data);
    });

    this.socket.on('booking-update', (data) => {
      this.handleBookingUpdate(data);
    });
  }

  joinRoom(userId) {
    if (this.socket) {
      this.socket.emit('join-room', userId);
    }
  }

  sendNotification(userId, message) {
    if (this.socket) {
      this.socket.emit('send-notification', { userId, message });
    }
  }

  handleNotification(data) {
    // عرض الإشعار للمستخدم
    this.showNotification(data.message, data.type);
  }

  handleBookingUpdate(data) {
    // تحديث حالة الحجز في التطبيق
    this.updateBookingState(data.bookingId, data.update);
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
      this.isConnected = false;
    }
  }
}

export default new SocketService();
```

### 2. Advanced Search & Filtering

#### Elasticsearch Integration
```javascript
// backend/services/searchService.js
const { Client } = require('@elastic/elasticsearch');

class SearchService {
  constructor() {
    this.client = new Client({
      node: process.env.ELASTICSEARCH_URL,
      auth: {
        username: process.env.ELASTICSEARCH_USERNAME,
        password: process.env.ELASTICSEARCH_PASSWORD
      }
    });
  }

  async indexDoctor(doctor) {
    await this.client.index({
      index: 'doctors',
      id: doctor._id.toString(),
      body: {
        name: doctor.name,
        specialty: doctor.specialty,
        location: doctor.location,
        rating: doctor.rating,
        price: doctor.price,
        experience: doctor.experience,
        description: doctor.description,
        languages: doctor.languages,
        workingHours: doctor.workingHours
      }
    });
  }

  async searchDoctors(query, filters = {}) {
    const searchBody = {
      query: {
        bool: {
          must: [],
          filter: []
        }
      },
      sort: [
        { rating: { order: 'desc' } },
        { _score: { order: 'desc' } }
      ]
    };

    // البحث النصي
    if (query) {
      searchBody.query.bool.must.push({
        multi_match: {
          query: query,
          fields: ['name^2', 'specialty^1.5', 'description', 'location'],
          type: 'best_fields',
          fuzziness: 'AUTO'
        }
      });
    }

    // الفلاتر
    if (filters.specialty) {
      searchBody.query.bool.filter.push({
        term: { specialty: filters.specialty }
      });
    }

    if (filters.location) {
      searchBody.query.bool.filter.push({
        term: { location: filters.location }
      });
    }

    if (filters.minPrice || filters.maxPrice) {
      const priceRange = {};
      if (filters.minPrice) priceRange.gte = filters.minPrice;
      if (filters.maxPrice) priceRange.lte = filters.maxPrice;
      
      searchBody.query.bool.filter.push({
        range: { price: priceRange }
      });
    }

    if (filters.minRating) {
      searchBody.query.bool.filter.push({
        range: { rating: { gte: filters.minRating } }
      });
    }

    const response = await this.client.search({
      index: 'doctors',
      body: searchBody
    });

    return response.body.hits.hits.map(hit => ({
      ...hit._source,
      _id: hit._id,
      _score: hit._score
    }));
  }

  async getSuggestions(query) {
    const response = await this.client.search({
      index: 'doctors',
      body: {
        suggest: {
          doctor_suggest: {
            prefix: query,
            completion: {
              field: 'name_suggest',
              size: 10
            }
          }
        }
      }
    });

    return response.body.suggest.doctor_suggest[0].options;
  }
}

module.exports = new SearchService();
```

#### Advanced Filtering Component
```javascript
// src/components/AdvancedSearch.js
import React, { useState, useEffect } from 'react';
import { useDebounce } from '../hooks/useDebounce';

const AdvancedSearch = ({ onSearch, onFilterChange }) => {
  const [query, setQuery] = useState('');
  const [filters, setFilters] = useState({
    specialty: '',
    location: '',
    minPrice: '',
    maxPrice: '',
    minRating: '',
    availability: 'all'
  });
  const [suggestions, setSuggestions] = useState([]);
  const [showSuggestions, setShowSuggestions] = useState(false);

  const debouncedQuery = useDebounce(query, 300);

  useEffect(() => {
    if (debouncedQuery) {
      fetchSuggestions(debouncedQuery);
    } else {
      setSuggestions([]);
    }
  }, [debouncedQuery]);

  const fetchSuggestions = async (searchQuery) => {
    try {
      const response = await fetch(`/api/search/suggestions?q=${searchQuery}`);
      const data = await response.json();
      setSuggestions(data.suggestions);
    } catch (error) {
      console.error('Error fetching suggestions:', error);
    }
  };

  const handleSearch = () => {
    onSearch(query, filters);
  };

  const handleFilterChange = (key, value) => {
    const newFilters = { ...filters, [key]: value };
    setFilters(newFilters);
    onFilterChange(newFilters);
  };

  const handleSuggestionClick = (suggestion) => {
    setQuery(suggestion.text);
    setShowSuggestions(false);
    onSearch(suggestion.text, filters);
  };

  return (
    <div className="advanced-search">
      <div className="search-input-container">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onFocus={() => setShowSuggestions(true)}
          placeholder="البحث عن الأطباء..."
          className="search-input"
        />
        
        {showSuggestions && suggestions.length > 0 && (
          <div className="suggestions-dropdown">
            {suggestions.map((suggestion, index) => (
              <div
                key={index}
                className="suggestion-item"
                onClick={() => handleSuggestionClick(suggestion)}
              >
                {suggestion.text}
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="filters-container">
        <select
          value={filters.specialty}
          onChange={(e) => handleFilterChange('specialty', e.target.value)}
          className="filter-select"
        >
          <option value="">جميع التخصصات</option>
          <option value="أمراض القلب">أمراض القلب</option>
          <option value="الأعصاب">الأعصاب</option>
          <option value="العظام">العظام</option>
        </select>

        <select
          value={filters.location}
          onChange={(e) => handleFilterChange('location', e.target.value)}
          className="filter-select"
        >
          <option value="">جميع المواقع</option>
          <option value="القاهرة">القاهرة</option>
          <option value="الإسكندرية">الإسكندرية</option>
          <option value="الجيزة">الجيزة</option>
        </select>

        <input
          type="number"
          placeholder="الحد الأدنى للسعر"
          value={filters.minPrice}
          onChange={(e) => handleFilterChange('minPrice', e.target.value)}
          className="filter-input"
        />

        <input
          type="number"
          placeholder="الحد الأقصى للسعر"
          value={filters.maxPrice}
          onChange={(e) => handleFilterChange('maxPrice', e.target.value)}
          className="filter-input"
        />

        <select
          value={filters.minRating}
          onChange={(e) => handleFilterChange('minRating', e.target.value)}
          className="filter-select"
        >
          <option value="">جميع التقييمات</option>
          <option value="4">4+ نجوم</option>
          <option value="3">3+ نجوم</option>
          <option value="2">2+ نجوم</option>
        </select>
      </div>

      <button onClick={handleSearch} className="search-button">
        بحث
      </button>
    </div>
  );
};

export default AdvancedSearch;
```

### 3. Advanced Analytics

#### Analytics Service
```javascript
// backend/services/analyticsService.js
const mongoose = require('mongoose');

class AnalyticsService {
  constructor() {
    this.analyticsCollection = mongoose.connection.db.collection('analytics');
  }

  async trackEvent(userId, eventType, eventData) {
    const event = {
      userId,
      eventType,
      eventData,
      timestamp: new Date(),
      userAgent: eventData.userAgent,
      ip: eventData.ip,
      sessionId: eventData.sessionId
    };

    await this.analyticsCollection.insertOne(event);
  }

  async getUserAnalytics(userId, dateRange) {
    const startDate = new Date(dateRange.start);
    const endDate = new Date(dateRange.end);

    const pipeline = [
      {
        $match: {
          userId: new mongoose.Types.ObjectId(userId),
          timestamp: { $gte: startDate, $lte: endDate }
        }
      },
      {
        $group: {
          _id: '$eventType',
          count: { $sum: 1 },
          lastOccurrence: { $max: '$timestamp' }
        }
      },
      {
        $sort: { count: -1 }
      }
    ];

    return await this.analyticsCollection.aggregate(pipeline).toArray();
  }

  async getSystemAnalytics(dateRange) {
    const startDate = new Date(dateRange.start);
    const endDate = new Date(dateRange.end);

    const pipeline = [
      {
        $match: {
          timestamp: { $gte: startDate, $lte: endDate }
        }
      },
      {
        $group: {
          _id: {
            eventType: '$eventType',
            date: {
              $dateToString: {
                format: '%Y-%m-%d',
                date: '$timestamp'
              }
            }
          },
          count: { $sum: 1 }
        }
      },
      {
        $group: {
          _id: '$_id.date',
          events: {
            $push: {
              eventType: '$_id.eventType',
              count: '$count'
            }
          }
        }
      },
      {
        $sort: { '_id': 1 }
      }
    ];

    return await this.analyticsCollection.aggregate(pipeline).toArray();
  }

  async getPopularDoctors(limit = 10) {
    const pipeline = [
      {
        $match: {
          eventType: 'doctor_view'
        }
      },
      {
        $group: {
          _id: '$eventData.doctorId',
          viewCount: { $sum: 1 },
          uniqueUsers: { $addToSet: '$userId' }
        }
      },
      {
        $project: {
          doctorId: '$_id',
          viewCount: 1,
          uniqueUserCount: { $size: '$uniqueUsers' }
        }
      },
      {
        $sort: { viewCount: -1 }
      },
      {
        $limit: limit
      }
    ];

    return await this.analyticsCollection.aggregate(pipeline).toArray();
  }

  async getConversionRates() {
    const pipeline = [
      {
        $group: {
          _id: '$eventType',
          count: { $sum: 1 }
        }
      }
    ];

    const events = await this.analyticsCollection.aggregate(pipeline).toArray();
    
    const totalViews = events.find(e => e._id === 'doctor_view')?.count || 0;
    const totalBookings = events.find(e => e._id === 'booking_created')?.count || 0;
    
    return {
      totalViews,
      totalBookings,
      conversionRate: totalViews > 0 ? (totalBookings / totalViews) * 100 : 0
    };
  }
}

module.exports = new AnalyticsService();
```

#### Analytics Dashboard Component
```javascript
// src/components/AnalyticsDashboard.js
import React, { useState, useEffect } from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell
} from 'recharts';

const AnalyticsDashboard = () => {
  const [analytics, setAnalytics] = useState({
    userAnalytics: [],
    systemAnalytics: [],
    popularDoctors: [],
    conversionRates: {}
  });
  const [dateRange, setDateRange] = useState({
    start: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
    end: new Date()
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAnalytics();
  }, [dateRange]);

  const fetchAnalytics = async () => {
    try {
      setLoading(true);
      const response = await fetch(`/api/analytics?start=${dateRange.start.toISOString()}&end=${dateRange.end.toISOString()}`);
      const data = await response.json();
      setAnalytics(data);
    } catch (error) {
      console.error('Error fetching analytics:', error);
    } finally {
      setLoading(false);
    }
  };

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8'];

  if (loading) {
    return <div className="loading">جاري تحميل البيانات...</div>;
  }

  return (
    <div className="analytics-dashboard">
      <div className="dashboard-header">
        <h2>لوحة التحليلات</h2>
        <div className="date-range-selector">
          <input
            type="date"
            value={dateRange.start.toISOString().split('T')[0]}
            onChange={(e) => setDateRange({ ...dateRange, start: new Date(e.target.value) })}
          />
          <input
            type="date"
            value={dateRange.end.toISOString().split('T')[0]}
            onChange={(e) => setDateRange({ ...dateRange, end: new Date(e.target.value) })}
          />
        </div>
      </div>

      <div className="analytics-grid">
        <div className="chart-container">
          <h3>إحصائيات النظام</h3>
          <LineChart width={600} height={300} data={analytics.systemAnalytics}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="_id" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="events.0.count" stroke="#8884d8" name="مشاهدات" />
            <Line type="monotone" dataKey="events.1.count" stroke="#82ca9d" name="حجوزات" />
          </LineChart>
        </div>

        <div className="chart-container">
          <h3>الأطباء الأكثر شعبية</h3>
          <BarChart width={600} height={300} data={analytics.popularDoctors}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="doctorId" />
            <YAxis />
            <Tooltip />
            <Bar dataKey="viewCount" fill="#8884d8" />
          </BarChart>
        </div>

        <div className="chart-container">
          <h3>معدلات التحويل</h3>
          <PieChart width={400} height={300}>
            <Pie
              data={[
                { name: 'مشاهدات', value: analytics.conversionRates.totalViews },
                { name: 'حجوزات', value: analytics.conversionRates.totalBookings }
              ]}
              cx={200}
              cy={150}
              labelLine={false}
              label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
              outerRadius={80}
              fill="#8884d8"
              dataKey="value"
            >
              {[0, 1].map((entry, index) => (
                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
          </PieChart>
        </div>
      </div>
    </div>
  );
};

export default AnalyticsDashboard;
```

### 4. Advanced Caching

#### Redis Caching Service
```javascript
// backend/services/cacheService.js
const redis = require('redis');

class CacheService {
  constructor() {
    this.client = redis.createClient({
      url: process.env.REDIS_URL
    });
    
    this.client.on('error', (err) => {
      console.error('Redis Client Error:', err);
    });
    
    this.client.connect();
  }

  async get(key) {
    try {
      const value = await this.client.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('Cache get error:', error);
      return null;
    }
  }

  async set(key, value, ttl = 3600) {
    try {
      await this.client.setEx(key, ttl, JSON.stringify(value));
    } catch (error) {
      console.error('Cache set error:', error);
    }
  }

  async del(key) {
    try {
      await this.client.del(key);
    } catch (error) {
      console.error('Cache delete error:', error);
    }
  }

  async invalidatePattern(pattern) {
    try {
      const keys = await this.client.keys(pattern);
      if (keys.length > 0) {
        await this.client.del(keys);
      }
    } catch (error) {
      console.error('Cache invalidate pattern error:', error);
    }
  }

  // Cache middleware
  cacheMiddleware(ttl = 3600) {
    return async (req, res, next) => {
      const key = `cache:${req.originalUrl}:${JSON.stringify(req.query)}`;
      
      try {
        const cached = await this.get(key);
        if (cached) {
          return res.json(cached);
        }
        
        // Store original res.json
        const originalJson = res.json;
        res.json = function(data) {
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

module.exports = new CacheService();
```

### 5. Advanced Error Handling

#### Global Error Handler
```javascript
// backend/middleware/errorHandler.js
const winston = require('winston');

class ErrorHandler {
  constructor() {
    this.logger = winston.createLogger({
      level: 'error',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.errors({ stack: true }),
        winston.format.json()
      ),
      transports: [
        new winston.transports.File({ filename: 'logs/error.log' }),
        new winston.transports.Console()
      ]
    });
  }

  handleError(error, req, res, next) {
    // Log error
    this.logger.error({
      message: error.message,
      stack: error.stack,
      url: req.url,
      method: req.method,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      userId: req.user?.id
    });

    // Determine error type
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: 'Validation Error',
        errors: error.errors
      });
    }

    if (error.name === 'CastError') {
      return res.status(400).json({
        success: false,
        message: 'Invalid ID format'
      });
    }

    if (error.name === 'MongoError' && error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: 'Duplicate entry'
      });
    }

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }

    // Default error
    res.status(error.status || 500).json({
      success: false,
      message: process.env.NODE_ENV === 'production' 
        ? 'Internal server error' 
        : error.message
    });
  }

  handleAsync(fn) {
    return (req, res, next) => {
      Promise.resolve(fn(req, res, next)).catch(next);
    };
  }
}

module.exports = new ErrorHandler();
```

### 6. Advanced Security

#### Rate Limiting with Redis
```javascript
// backend/middleware/rateLimiter.js
const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis');
const redis = require('redis');

const redisClient = redis.createClient({
  url: process.env.REDIS_URL
});

const createRateLimiter = (windowMs, max, message) => {
  return rateLimit({
    store: new RedisStore({
      sendCommand: (...args) => redisClient.sendCommand(args),
    }),
    windowMs,
    max,
    message: { success: false, message },
    standardHeaders: true,
    legacyHeaders: false,
  });
};

// Different rate limits for different endpoints
const authLimiter = createRateLimiter(
  15 * 60 * 1000, // 15 minutes
  5, // 5 attempts
  'Too many login attempts, please try again later'
);

const generalLimiter = createRateLimiter(
  15 * 60 * 1000, // 15 minutes
  100, // 100 requests
  'Too many requests from this IP, please try again later'
);

const strictLimiter = createRateLimiter(
  15 * 60 * 1000, // 15 minutes
  10, // 10 requests
  'Too many requests, please try again later'
);

module.exports = {
  authLimiter,
  generalLimiter,
  strictLimiter
};
```

### 7. Performance Optimization

#### Database Optimization
```javascript
// backend/utils/databaseOptimizer.js
const mongoose = require('mongoose');

class DatabaseOptimizer {
  static optimizeQueries() {
    // Enable query optimization
    mongoose.set('debug', process.env.NODE_ENV === 'development');
    
    // Set connection options
    mongoose.set('bufferCommands', false);
    mongoose.set('bufferMaxEntries', 0);
  }

  static createIndexes() {
    // Create compound indexes for better performance
    const User = require('../models/User');
    const Doctor = require('../models/Doctor');
    const Booking = require('../models/Booking');

    // User indexes
    User.collection.createIndex({ email: 1 }, { unique: true });
    User.collection.createIndex({ role: 1, isActive: 1 });

    // Doctor indexes
    Doctor.collection.createIndex({ specialty: 1, location: 1 });
    Doctor.collection.createIndex({ rating: -1, isAvailable: 1 });
    Doctor.collection.createIndex({ price: 1 });

    // Booking indexes
    Booking.collection.createIndex({ doctorId: 1, date: 1 });
    Booking.collection.createIndex({ patientId: 1, status: 1 });
    Booking.collection.createIndex({ status: 1, createdAt: -1 });
  }

  static async optimizeAggregation() {
    // Use aggregation for complex queries
    const Booking = require('../models/Booking');
    
    const pipeline = [
      {
        $match: {
          status: 'completed',
          createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
        }
      },
      {
        $group: {
          _id: '$doctorId',
          totalBookings: { $sum: 1 },
          totalRevenue: { $sum: '$totalAmount' },
          averageRating: { $avg: '$rating' }
        }
      },
      {
        $lookup: {
          from: 'doctors',
          localField: '_id',
          foreignField: '_id',
          as: 'doctor'
        }
      },
      {
        $unwind: '$doctor'
      },
      {
        $project: {
          doctorName: '$doctor.name',
          specialty: '$doctor.specialty',
          totalBookings: 1,
          totalRevenue: 1,
          averageRating: 1
        }
      },
      {
        $sort: { totalRevenue: -1 }
      }
    ];

    return await Booking.aggregate(pipeline);
  }
}

module.exports = DatabaseOptimizer;
```

## 📞 الدعم

للمساعدة في التطوير المتقدم:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير الأساسي
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [Socket.io Documentation](https://socket.io/docs/)
- [Elasticsearch Documentation](https://www.elastic.co/guide/)
- [Redis Documentation](https://redis.io/documentation)
- [Winston Documentation](https://github.com/winstonjs/winston)
- [MongoDB Aggregation](https://docs.mongodb.com/manual/aggregation/)
- [Node.js Performance](https://nodejs.org/en/docs/guides/simple-profiling/)
