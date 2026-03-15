// ══════════════════════════════════════════════════════════
//  services/app_logger.dart
//  نظام تسجيل الأخطاء والمراقبة
// ══════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

class AppLogger {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  static void logError(String message,
      {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('🔴 ERROR: $message');
      if (error != null) print('   Error: $error');
      if (stackTrace != null) print('   Stack: $stackTrace');
    }
  }

  static void logException(dynamic exception,
      {String? reason, StackTrace? stack}) {
    if (kDebugMode) {
      print('🔴 EXCEPTION: $exception');
      if (reason != null) print('   Reason: $reason');
      if (stack != null) print('   Stack: $stack');
    }
  }

  static void logWarning(String message) {
    if (kDebugMode) print('🟡 WARNING: $message');
  }

  static void logInfo(String message) {
    if (kDebugMode) print('ℹ️ INFO: $message');
  }

  static Future<void> logEvent(String name,
      [Map<String, dynamic>? params]) async {
    if (kDebugMode) print('📊 EVENT: $name ${params ?? ''}');
  }

  static Future<void> logProjectCreated(String projectType) async =>
      await logEvent('project_created', {'project_type': projectType});

  static Future<void> logQuoteSent(String projectId) async =>
      await logEvent('quote_sent', {'project_id': projectId});

  static Future<void> logOrderCreated(String supplierId) async =>
      await logEvent('order_created', {'supplier_id': supplierId});

  static Future<void> logPdfExported(String projectId) async =>
      await logEvent('pdf_exported', {'project_id': projectId});

  static Future<void> logLogin(String method) async =>
      await logEvent('login', {'method': method});

  static Future<void> logSignUp(String method) async =>
      await logEvent('sign_up', {'method': method});

  static Future<void> setUserId(String userId) async {
    if (kDebugMode) print('👤 User ID set: $userId');
  }

  static Future<void> setUserProperties({
    String? userType,
    String? language,
    bool? darkMode,
  }) async {
    if (kDebugMode) {
      print('👤 User props: type=$userType, lang=$language, dark=$darkMode');
    }
  }
}
