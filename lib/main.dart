// ══════════════════════════════════════════════════════════
//  main.dart — ✅ Firebase مفعّل + ميزة الإسقاط الجوي
// ══════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/app_settings_provider.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'utils/app_localizations.dart';
import 'screens/splash_screen.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── تهيئة Firebase ────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── تهيئة Crashlytics ────────────────────────────────
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // ── تهيئة Analytics ───────────────────────────────────
  // تعطيل Analytics في وضع Debug
  await analytics.setAnalyticsCollectionEnabled(kReleaseMode);

  // ── تهيئة التخزين المحلي (للـ Offline) ───────────────
  await StorageService.init();

  final settings = AppSettingsProvider();
  await settings.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: const BannaaApp(),
    ),
  );
}

class BannaaApp extends StatelessWidget {
  const BannaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final locale = settings.locale;
    final isRtl = locale.languageCode == 'ar';

    return MaterialApp(
      title: 'بنّاء',
      debugShowCheckedModeBanner: false,
      theme: settings.darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      locale: locale,
      supportedLocales: BannaaLocalizations.supportedLocales,
      localizationsDelegates: const [
        BannaaLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: const SplashScreen(),
    );
  }
}
