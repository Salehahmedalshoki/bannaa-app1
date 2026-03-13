import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'No Firebase options for this platform: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBQwoDS3-7xiJcGq-4F1L55sz58x5ynrzU',
    appId: '1:711113852305:web:b45a085dcb3ca7bf384630',
    messagingSenderId: '711113852305',
    projectId: 'bannaa-app',
    authDomain: 'bannaa-app.firebaseapp.com',
    storageBucket: 'bannaa-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQwoDS3-7xiJcGq-4F1L55sz58x5ynrzU',
    appId: '1:711113852305:android:b45a085dcb3ca7bf384630',
    messagingSenderId: '711113852305',
    projectId: 'bannaa-app',
    storageBucket: 'bannaa-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQwoDS3-7xiJcGq-4F1L55sz58x5ynrzU',
    appId: '1:711113852305:ios:b45a085dcb3ca7bf384630',
    messagingSenderId: '711113852305',
    projectId: 'bannaa-app',
    storageBucket: 'bannaa-app.firebasestorage.app',
    iosClientId:
        '711113852305-v1df4itn8u4brt8dsre0eb2ks058nrbg.apps.googleusercontent.com',
    iosBundleId: 'com.bannaa.bannaa_app',
  );
}
