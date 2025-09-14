# دليل التطوير المحمول - BookDoc

## 📱 نظرة عامة

يتم تطوير تطبيق BookDoc المحمول باستخدام **React Native** مع دعم كامل للغتين العربية والإنجليزية. يتضمن التطبيق جميع الميزات الأساسية مع تجربة مستخدم محسنة للأجهزة المحمولة.

## 🛠️ المتطلبات

### الأدوات المطلوبة
- **Node.js** 18.x أو أحدث
- **React Native CLI** 0.72.x
- **Android Studio** (للتطوير على Android)
- **Xcode** (للتطوير على iOS)
- **Expo CLI** (اختياري)

### تثبيت الأدوات
```bash
# تثبيت React Native CLI
npm install -g react-native-cli

# تثبيت Expo CLI
npm install -g @expo/cli

# تثبيت Android Studio
# قم بتحميله من https://developer.android.com/studio

# تثبيت Xcode
# قم بتحميله من App Store (macOS فقط)
```

## 🚀 إعداد المشروع

### إنشاء مشروع جديد
```bash
# إنشاء مشروع React Native
npx react-native init BookDocMobile --template react-native-template-typescript

# أو استخدام Expo
npx create-expo-app BookDocMobile --template blank-typescript

# الانتقال إلى مجلد المشروع
cd BookDocMobile
```

### تثبيت التبعيات
```bash
# تثبيت التبعيات الأساسية
npm install @react-navigation/native @react-navigation/stack @react-navigation/bottom-tabs
npm install react-native-screens react-native-safe-area-context
npm install react-native-gesture-handler react-native-reanimated

# تثبيت تبعيات UI
npm install react-native-elements react-native-vector-icons
npm install react-native-paper react-native-ratings

# تثبيت تبعيات الوظائف
npm install @react-native-async-storage/async-storage
npm install react-native-qrcode-svg react-native-svg
npm install react-native-pdf react-native-fs
npm install react-native-image-picker react-native-permissions

# تثبيت تبعيات الشبكة
npm install axios react-query
npm install react-native-netinfo

# تثبيت تبعيات الإشعارات
npm install @react-native-firebase/app @react-native-firebase/messaging
npm install react-native-push-notification

# تثبيت تبعيات التطوير
npm install --save-dev @types/react @types/react-native
npm install --save-dev eslint @typescript-eslint/eslint-plugin
npm install --save-dev prettier eslint-config-prettier
```

## 📁 هيكل المشروع

```
BookDocMobile/
├── src/
│   ├── components/          # المكونات المشتركة
│   │   ├── common/         # مكونات عامة
│   │   ├── forms/          # مكونات النماذج
│   │   └── ui/             # مكونات واجهة المستخدم
│   ├── screens/            # شاشات التطبيق
│   │   ├── auth/           # شاشات المصادقة
│   │   ├── home/           # الشاشة الرئيسية
│   │   ├── doctors/        # شاشات الأطباء
│   │   ├── bookings/       # شاشات الحجوزات
│   │   └── profile/        # شاشات الملف الشخصي
│   ├── navigation/         # إعداد التنقل
│   ├── services/           # خدمات API
│   ├── hooks/              # Custom Hooks
│   ├── utils/              # وظائف مساعدة
│   ├── constants/          # الثوابت
│   ├── types/              # أنواع TypeScript
│   └── locales/            # ملفات الترجمة
├── android/                # ملفات Android
├── ios/                    # ملفات iOS
├── assets/                 # الأصول (الصور، الخطوط)
└── package.json
```

## 🧩 المكونات الأساسية

### Navigation Setup
```typescript
// src/navigation/AppNavigator.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useAuth } from '../hooks/useAuth';

// Screens
import LoginScreen from '../screens/auth/LoginScreen';
import RegisterScreen from '../screens/auth/RegisterScreen';
import HomeScreen from '../screens/home/HomeScreen';
import DoctorsScreen from '../screens/doctors/DoctorsScreen';
import BookingsScreen from '../screens/bookings/BookingsScreen';
import ProfileScreen from '../screens/profile/ProfileScreen';

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();

const AuthStack = () => (
  <Stack.Navigator screenOptions={{ headerShown: false }}>
    <Stack.Screen name="Login" component={LoginScreen} />
    <Stack.Screen name="Register" component={RegisterScreen} />
  </Stack.Navigator>
);

const MainTabs = () => (
  <Tab.Navigator
    screenOptions={{
      headerShown: false,
      tabBarStyle: { backgroundColor: '#fff' }
    }}
  >
    <Tab.Screen 
      name="Home" 
      component={HomeScreen}
      options={{ tabBarLabel: 'الرئيسية' }}
    />
    <Tab.Screen 
      name="Doctors" 
      component={DoctorsScreen}
      options={{ tabBarLabel: 'الأطباء' }}
    />
    <Tab.Screen 
      name="Bookings" 
      component={BookingsScreen}
      options={{ tabBarLabel: 'حجوزاتي' }}
    />
    <Tab.Screen 
      name="Profile" 
      component={ProfileScreen}
      options={{ tabBarLabel: 'الملف الشخصي' }}
    />
  </Tab.Navigator>
);

const AppNavigator = () => {
  const { isAuthenticated } = useAuth();

  return (
    <NavigationContainer>
      {isAuthenticated ? <MainTabs /> : <AuthStack />}
    </NavigationContainer>
  );
};

export default AppNavigator;
```

### Authentication Hook
```typescript
// src/hooks/useAuth.ts
import { useState, useEffect, createContext, useContext } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { apiService } from '../services/apiService';

interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: 'patient' | 'doctor' | 'admin';
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (userData: any) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    checkAuthState();
  }, []);

  const checkAuthState = async () => {
    try {
      const token = await AsyncStorage.getItem('authToken');
      if (token) {
        const userData = await apiService.getProfile();
        setUser(userData);
      }
    } catch (error) {
      console.error('Auth check error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const login = async (email: string, password: string) => {
    try {
      const response = await apiService.login(email, password);
      await AsyncStorage.setItem('authToken', response.token);
      setUser(response.user);
    } catch (error) {
      throw error;
    }
  };

  const register = async (userData: any) => {
    try {
      const response = await apiService.register(userData);
      await AsyncStorage.setItem('authToken', response.token);
      setUser(response.user);
    } catch (error) {
      throw error;
    }
  };

  const logout = async () => {
    try {
      await AsyncStorage.removeItem('authToken');
      setUser(null);
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    register,
    logout
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
```

### API Service
```typescript
// src/services/apiService.ts
import axios, { AxiosInstance, AxiosResponse } from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

class ApiService {
  private api: AxiosInstance;

  constructor() {
    this.api = axios.create({
      baseURL: 'http://localhost:5000/api',
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json'
      }
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor
    this.api.interceptors.request.use(
      async (config) => {
        const token = await AsyncStorage.getItem('authToken');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor
    this.api.interceptors.response.use(
      (response) => response,
      async (error) => {
        if (error.response?.status === 401) {
          await AsyncStorage.removeItem('authToken');
          // Redirect to login
        }
        return Promise.reject(error);
      }
    );
  }

  async login(email: string, password: string) {
    const response: AxiosResponse = await this.api.post('/auth/login', {
      email,
      password
    });
    return response.data;
  }

  async register(userData: any) {
    const response: AxiosResponse = await this.api.post('/auth/register', userData);
    return response.data;
  }

  async getProfile() {
    const response: AxiosResponse = await this.api.get('/users/profile');
    return response.data.user;
  }

  async getDoctors(filters?: any) {
    const response: AxiosResponse = await this.api.get('/doctors', { params: filters });
    return response.data.doctors;
  }

  async getDoctor(id: string) {
    const response: AxiosResponse = await this.api.get(`/doctors/${id}`);
    return response.data.doctor;
  }

  async createBooking(bookingData: any) {
    const response: AxiosResponse = await this.api.post('/bookings', bookingData);
    return response.data.booking;
  }

  async getBookings() {
    const response: AxiosResponse = await this.api.get('/bookings');
    return response.data.bookings;
  }

  async updateBooking(id: string, updateData: any) {
    const response: AxiosResponse = await this.api.put(`/bookings/${id}`, updateData);
    return response.data.booking;
  }

  async cancelBooking(id: string) {
    const response: AxiosResponse = await this.api.delete(`/bookings/${id}`);
    return response.data;
  }
}

export const apiService = new ApiService();
```

## 🎨 واجهة المستخدم

### Custom Components
```typescript
// src/components/ui/CustomButton.tsx
import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
  TextStyle
} from 'react-native';

interface CustomButtonProps {
  title: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'small' | 'medium' | 'large';
  style?: ViewStyle;
  textStyle?: TextStyle;
}

const CustomButton: React.FC<CustomButtonProps> = ({
  title,
  onPress,
  loading = false,
  disabled = false,
  variant = 'primary',
  size = 'medium',
  style,
  textStyle
}) => {
  const buttonStyle = [
    styles.button,
    styles[variant],
    styles[size],
    disabled && styles.disabled,
    style
  ];

  const buttonTextStyle = [
    styles.text,
    styles[`${variant}Text`],
    styles[`${size}Text`],
    textStyle
  ];

  return (
    <TouchableOpacity
      style={buttonStyle}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.8}
    >
      {loading ? (
        <ActivityIndicator color="#fff" size="small" />
      ) : (
        <Text style={buttonTextStyle}>{title}</Text>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row'
  },
  primary: {
    backgroundColor: '#2563eb'
  },
  secondary: {
    backgroundColor: '#6b7280'
  },
  outline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: '#2563eb'
  },
  small: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    minHeight: 36
  },
  medium: {
    paddingHorizontal: 24,
    paddingVertical: 12,
    minHeight: 48
  },
  large: {
    paddingHorizontal: 32,
    paddingVertical: 16,
    minHeight: 56
  },
  disabled: {
    opacity: 0.6
  },
  text: {
    fontWeight: '600',
    textAlign: 'center'
  },
  primaryText: {
    color: '#fff'
  },
  secondaryText: {
    color: '#fff'
  },
  outlineText: {
    color: '#2563eb'
  },
  smallText: {
    fontSize: 14
  },
  mediumText: {
    fontSize: 16
  },
  largeText: {
    fontSize: 18
  }
});

export default CustomButton;
```

### Doctor Card Component
```typescript
// src/components/ui/DoctorCard.tsx
import React from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  TouchableOpacity,
  Dimensions
} from 'react-native';
import { Star } from 'react-native-vector-icons/Feather';
import CustomButton from './CustomButton';

interface Doctor {
  id: string;
  name: string;
  specialty: string;
  rating: number;
  experience: number;
  location: string;
  price: number;
  image?: string;
}

interface DoctorCardProps {
  doctor: Doctor;
  onPress: () => void;
  onBook: () => void;
}

const { width } = Dimensions.get('window');

const DoctorCard: React.FC<DoctorCardProps> = ({ doctor, onPress, onBook }) => {
  return (
    <TouchableOpacity style={styles.card} onPress={onPress}>
      <View style={styles.imageContainer}>
        <Image
          source={{ uri: doctor.image || 'https://via.placeholder.com/150' }}
          style={styles.image}
          resizeMode="cover"
        />
      </View>
      
      <View style={styles.content}>
        <Text style={styles.name}>{doctor.name}</Text>
        <Text style={styles.specialty}>{doctor.specialty}</Text>
        <Text style={styles.location}>{doctor.location}</Text>
        
        <View style={styles.ratingContainer}>
          <Star name="star" size={16} color="#fbbf24" fill="#fbbf24" />
          <Text style={styles.rating}>{doctor.rating.toFixed(1)}</Text>
          <Text style={styles.experience}>({doctor.experience} سنة خبرة)</Text>
        </View>
        
        <View style={styles.priceContainer}>
          <Text style={styles.price}>{doctor.price} جنيه</Text>
          <CustomButton
            title="حجز"
            onPress={onBook}
            size="small"
            style={styles.bookButton}
          />
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    marginHorizontal: 16,
    marginVertical: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3
  },
  imageContainer: {
    height: 120,
    borderTopLeftRadius: 12,
    borderTopRightRadius: 12,
    overflow: 'hidden'
  },
  image: {
    width: '100%',
    height: '100%'
  },
  content: {
    padding: 16
  },
  name: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 4
  },
  specialty: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 4
  },
  location: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 8
  },
  ratingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12
  },
  rating: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1f2937',
    marginLeft: 4
  },
  experience: {
    fontSize: 12,
    color: '#6b7280',
    marginLeft: 8
  },
  priceContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  price: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2563eb'
  },
  bookButton: {
    minWidth: 80
  }
});

export default DoctorCard;
```

## 📱 الشاشات الرئيسية

### Login Screen
```typescript
// src/screens/auth/LoginScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView
} from 'react-native';
import { useAuth } from '../../hooks/useAuth';
import CustomButton from '../../components/ui/CustomButton';
import { useNavigation } from '@react-navigation/native';

const LoginScreen: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  
  const { login } = useAuth();
  const navigation = useNavigation();

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('خطأ', 'يرجى ملء جميع الحقول');
      return;
    }

    try {
      setLoading(true);
      await login(email, password);
    } catch (error: any) {
      Alert.alert('خطأ', error.message || 'حدث خطأ أثناء تسجيل الدخول');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={styles.header}>
          <Text style={styles.title}>مرحباً بك في BookDoc</Text>
          <Text style={styles.subtitle}>سجل دخولك للوصول إلى خدماتنا</Text>
        </View>

        <View style={styles.form}>
          <View style={styles.inputContainer}>
            <Text style={styles.label}>البريد الإلكتروني</Text>
            <TextInput
              style={styles.input}
              value={email}
              onChangeText={setEmail}
              placeholder="أدخل بريدك الإلكتروني"
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>

          <View style={styles.inputContainer}>
            <Text style={styles.label}>كلمة المرور</Text>
            <TextInput
              style={styles.input}
              value={password}
              onChangeText={setPassword}
              placeholder="أدخل كلمة المرور"
              secureTextEntry
              autoCapitalize="none"
            />
          </View>

          <CustomButton
            title="تسجيل الدخول"
            onPress={handleLogin}
            loading={loading}
            style={styles.loginButton}
          />

          <CustomButton
            title="إنشاء حساب جديد"
            onPress={() => navigation.navigate('Register')}
            variant="outline"
            style={styles.registerButton}
          />
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb'
  },
  scrollContainer: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: 24
  },
  header: {
    alignItems: 'center',
    marginBottom: 32
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 8
  },
  subtitle: {
    fontSize: 16,
    color: '#6b7280',
    textAlign: 'center'
  },
  form: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3
  },
  inputContainer: {
    marginBottom: 16
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#374151',
    marginBottom: 8
  },
  input: {
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    backgroundColor: '#fff'
  },
  loginButton: {
    marginTop: 8,
    marginBottom: 16
  },
  registerButton: {
    marginTop: 8
  }
});

export default LoginScreen;
```

### Doctors Screen
```typescript
// src/screens/doctors/DoctorsScreen.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  RefreshControl,
  TextInput,
  TouchableOpacity
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { apiService } from '../../services/apiService';
import DoctorCard from '../../components/ui/DoctorCard';
import { Doctor } from '../../types/Doctor';

const DoctorsScreen: React.FC = () => {
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedSpecialty, setSelectedSpecialty] = useState('');
  
  const navigation = useNavigation();

  useEffect(() => {
    fetchDoctors();
  }, [selectedSpecialty]);

  const fetchDoctors = async () => {
    try {
      setLoading(true);
      const filters = selectedSpecialty ? { specialty: selectedSpecialty } : {};
      const data = await apiService.getDoctors(filters);
      setDoctors(data);
    } catch (error) {
      console.error('Error fetching doctors:', error);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchDoctors();
    setRefreshing(false);
  };

  const handleDoctorPress = (doctor: Doctor) => {
    navigation.navigate('DoctorDetails', { doctor });
  };

  const handleBookPress = (doctor: Doctor) => {
    navigation.navigate('Booking', { doctor });
  };

  const filteredDoctors = doctors.filter(doctor =>
    doctor.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    doctor.specialty.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const renderDoctor = ({ item }: { item: Doctor }) => (
    <DoctorCard
      doctor={item}
      onPress={() => handleDoctorPress(item)}
      onBook={() => handleBookPress(item)}
    />
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>الأطباء</Text>
        
        <View style={styles.searchContainer}>
          <TextInput
            style={styles.searchInput}
            placeholder="البحث عن الأطباء..."
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
        </View>

        <View style={styles.filterContainer}>
          <TouchableOpacity
            style={[
              styles.filterButton,
              selectedSpecialty === '' && styles.activeFilter
            ]}
            onPress={() => setSelectedSpecialty('')}
          >
            <Text style={[
              styles.filterText,
              selectedSpecialty === '' && styles.activeFilterText
            ]}>
              الكل
            </Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={[
              styles.filterButton,
              selectedSpecialty === 'أمراض القلب' && styles.activeFilter
            ]}
            onPress={() => setSelectedSpecialty('أمراض القلب')}
          >
            <Text style={[
              styles.filterText,
              selectedSpecialty === 'أمراض القلب' && styles.activeFilterText
            ]}>
              أمراض القلب
            </Text>
          </TouchableOpacity>
        </View>
      </View>

      <FlatList
        data={filteredDoctors}
        renderItem={renderDoctor}
        keyExtractor={(item) => item.id}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        contentContainerStyle={styles.listContainer}
        showsVerticalScrollIndicator={false}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb'
  },
  header: {
    backgroundColor: '#fff',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb'
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 16
  },
  searchContainer: {
    marginBottom: 16
  },
  searchInput: {
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    backgroundColor: '#fff'
  },
  filterContainer: {
    flexDirection: 'row',
    gap: 8
  },
  filterButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: '#f3f4f6',
    borderWidth: 1,
    borderColor: '#d1d5db'
  },
  activeFilter: {
    backgroundColor: '#2563eb',
    borderColor: '#2563eb'
  },
  filterText: {
    fontSize: 14,
    color: '#6b7280'
  },
  activeFilterText: {
    color: '#fff'
  },
  listContainer: {
    paddingVertical: 8
  }
});

export default DoctorsScreen;
```

## 🔔 الإشعارات

### Push Notifications Setup
```typescript
// src/services/notificationService.ts
import PushNotification from 'react-native-push-notification';
import { Platform } from 'react-native';

class NotificationService {
  constructor() {
    this.configure();
  }

  configure() {
    PushNotification.configure({
      onRegister: (token) => {
        console.log('FCM Token:', token);
        // إرسال Token للخادم
        this.sendTokenToServer(token.token);
      },

      onNotification: (notification) => {
        console.log('Notification received:', notification);
        
        if (notification.userInteraction) {
          // المستخدم نقر على الإشعار
          this.handleNotificationPress(notification);
        }
      },

      onAction: (notification) => {
        console.log('Notification action:', notification);
      },

      onRegistrationError: (err) => {
        console.error('Registration error:', err);
      },

      permissions: {
        alert: true,
        badge: true,
        sound: true,
      },

      popInitialNotification: true,
      requestPermissions: Platform.OS === 'ios',
    });

    // إنشاء قناة إشعارات لـ Android
    if (Platform.OS === 'android') {
      PushNotification.createChannel(
        {
          channelId: 'bookdoc-channel',
          channelName: 'BookDoc Notifications',
          channelDescription: 'إشعارات BookDoc',
          playSound: true,
          soundName: 'default',
          importance: 4,
          vibrate: true,
        },
        (created) => console.log(`Channel created: ${created}`)
      );
    }
  }

  sendTokenToServer = async (token: string) => {
    try {
      // إرسال Token للخادم
      await apiService.updateDeviceToken(token);
    } catch (error) {
      console.error('Error sending token to server:', error);
    }
  };

  handleNotificationPress = (notification: any) => {
    // التعامل مع نقر المستخدم على الإشعار
    const { data } = notification;
    
    if (data?.type === 'booking_update') {
      // الانتقال إلى صفحة الحجز
      navigation.navigate('BookingDetails', { bookingId: data.bookingId });
    }
  };

  showLocalNotification = (title: string, message: string, data?: any) => {
    PushNotification.localNotification({
      channelId: 'bookdoc-channel',
      title,
      message,
      data,
      playSound: true,
      soundName: 'default',
    });
  };

  scheduleNotification = (title: string, message: string, date: Date, data?: any) => {
    PushNotification.localNotificationSchedule({
      channelId: 'bookdoc-channel',
      title,
      message,
      date,
      data,
      playSound: true,
      soundName: 'default',
    });
  };

  cancelAllNotifications = () => {
    PushNotification.cancelAllLocalNotifications();
  };
}

export default new NotificationService();
```

## 📱 PWA Features

### Offline Support
```typescript
// src/services/offlineService.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import NetInfo from '@react-native-community/netinfo';

class OfflineService {
  private isOnline: boolean = true;

  constructor() {
    this.setupNetworkListener();
  }

  private setupNetworkListener() {
    NetInfo.addEventListener(state => {
      this.isOnline = state.isConnected ?? false;
      console.log('Network status:', this.isOnline);
    });
  }

  async cacheData(key: string, data: any) {
    try {
      await AsyncStorage.setItem(key, JSON.stringify(data));
    } catch (error) {
      console.error('Error caching data:', error);
    }
  }

  async getCachedData(key: string) {
    try {
      const data = await AsyncStorage.getItem(key);
      return data ? JSON.parse(data) : null;
    } catch (error) {
      console.error('Error getting cached data:', error);
      return null;
    }
  }

  async syncPendingData() {
    if (!this.isOnline) return;

    try {
      const pendingData = await this.getCachedData('pendingData');
      if (pendingData && pendingData.length > 0) {
        // إرسال البيانات المعلقة للخادم
        for (const item of pendingData) {
          await this.syncItem(item);
        }
        
        // مسح البيانات المعلقة
        await AsyncStorage.removeItem('pendingData');
      }
    } catch (error) {
      console.error('Error syncing pending data:', error);
    }
  }

  private async syncItem(item: any) {
    // إرسال العنصر للخادم
    // Implementation depends on the specific item type
  }

  isOnlineStatus() {
    return this.isOnline;
  }
}

export default new OfflineService();
```

## 🚀 البناء والنشر

### Android Build
```bash
# إنشاء APK للتطوير
cd android
./gradlew assembleDebug

# إنشاء AAB للإنتاج
./gradlew bundleRelease

# تثبيت التطبيق على الجهاز
npx react-native run-android
```

### iOS Build
```bash
# بناء التطبيق
cd ios
xcodebuild -workspace BookDocMobile.xcworkspace -scheme BookDocMobile -configuration Release

# تشغيل التطبيق على المحاكي
npx react-native run-ios
```

### App Store Deployment
```bash
# إنشاء ملف IPA
xcodebuild -workspace BookDocMobile.xcworkspace -scheme BookDocMobile -configuration Release -archivePath BookDocMobile.xcarchive archive

# تصدير التطبيق
xcodebuild -exportArchive -archivePath BookDocMobile.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
```

## 📞 الدعم

للمساعدة في التطوير المحمول:
- راجع ملف `README.md` للحصول على دليل شامل
- راجع ملف `DEVELOPMENT.md` للتطوير الأساسي
- راجع ملف `API_DOCUMENTATION.md` لاستخدام API

## 🔗 روابط مفيدة

- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [React Navigation](https://reactnavigation.org/)
- [React Native Elements](https://reactnativeelements.com/)
- [React Native Paper](https://reactnativepaper.com/)
- [Expo Documentation](https://docs.expo.dev/)
- [React Native Firebase](https://rnfirebase.io/)
- [React Native Vector Icons](https://github.com/oblador/react-native-vector-icons)
