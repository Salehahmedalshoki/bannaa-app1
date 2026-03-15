# Firebase Console Setup Guide

## تفعيل خدمات Firebase للتطبيق

### 1. Firebase Crashlytics

```bash
# إضافة Crashlytics
flutter pub add firebase_crashlytics
```

في `main.dart`:
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // تفعيل Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(const MyApp());
}
```

### 2. Firebase Analytics

```bash
flutter pub add firebase_analytics
```

في `main.dart`:
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// تسجيل حدث
analytics.logEvent(name: 'project_created', parameters: {
  'project_id': 'xxx',
  'building_type': 'villa',
});
```

### 3. Firebase Cloud Messaging (الإشعارات)

```bash
flutter pub add firebase_messaging
```

إعداد الـ Service:
```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _ messaging = FirebaseMessaging.instance;
  
  static Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission();
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // معالجة الإشعار الوارد
    });
  }
}
```

### 4. خطوات Firebase Console

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. أضف مشروع جديد أو اختر المشروع الموجود
3. سجّل التطبيق (Android/iOS)
4. حمّل ملف `google-services.json` (Android) أو `GoogleService-Info.plist` (iOS)
5. فعّل الخدمات المطلوبة:
   - **Authentication**: مفعل
   - **Firestore**: مفعل
   - **Crashlytics**: فعّل من القسم
   - **Analytics**: فعّل من القسم
   - **Cloud Messaging**: فعّل من القسم

### 5. قواعد Firestore

القواعد الحالية في `firestore.rules`:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /projects/{projectId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    // ... بقية القواعد
  }
}
```

### 6. تفعيل Storage (إذا需要的)

```bash
flutter pub add firebase_storage
```

أضف القواعد:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
