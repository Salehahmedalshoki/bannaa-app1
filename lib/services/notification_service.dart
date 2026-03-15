// ══════════════════════════════════════════════════════════
//  services/notification_service.dart
//  خدمة الإشعارات
// ══════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

enum NotificationType {
  newOrder('طلب جديد', '📦'),
  orderAccepted('تم قبول الطلب', '✅'),
  orderRejected('تم رفض الطلب', '❌'),
  orderCompleted('اكتمل الطلب', '🎉'),
  newQuote('عرض سعر جديد', '💰'),
  quoteAccepted('تم قبول العرض', '👍'),
  projectUpdate('تحديث المشروع', '🔄'),
  reminder('تذكير', '⏰');

  final String label;
  final String emoji;
  const NotificationType(this.label, this.emoji);
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? dataId;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.dataId,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final List<NotificationModel> _notifications = [];
  bool _initialized = false;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (kDebugMode) print('🔔 NotificationService initialized');
  }

  // ══════════════════════════════════════════════════════════
  //  إشعارات للمستخدم
  // ══════════════════════════════════════════════════════════

  Future<void> showNotification({
    required NotificationType type,
    required String title,
    required String body,
    String? dataId,
  }) async {
    final notification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      dataId: dataId,
      createdAt: DateTime.now(),
    );

    _notifications.insert(0, notification);

    if (kDebugMode) {
      print('🔔 New notification: ${type.emoji} $title - $body');
    }
  }

  // إشعار طلب جديد للمورد
  Future<void> notifyNewOrder(String projectName, String orderId) async {
    await showNotification(
      type: NotificationType.newOrder,
      title: 'طلب جديد',
      body: 'لديك طلب جديد من مشروع $projectName',
      dataId: orderId,
    );
  }

  // إشعار قبول الطلب للمستخدم
  Future<void> notifyOrderAccepted(String projectName, String orderId) async {
    await showNotification(
      type: NotificationType.orderAccepted,
      title: 'تم قبول الطلب',
      body: 'وافق المورد على طلب مشروع $projectName',
      dataId: orderId,
    );
  }

  // إشعار رفض الطلب
  Future<void> notifyOrderRejected(String projectName, String orderId) async {
    await showNotification(
      type: NotificationType.orderRejected,
      title: 'تم رفض الطلب',
      body: 'رفض المورد طلب مشروع $projectName',
      dataId: orderId,
    );
  }

  // إشعار عرض سعر جديد
  Future<void> notifyNewQuote(String projectName, String supplierName) async {
    await showNotification(
      type: NotificationType.newQuote,
      title: 'عرض سعر جديد',
      body: 'المورد $supplierName قدم عرض سعر لمشروع $projectName',
    );
  }

  // ══════════════════════════════════════════════════════════
  //  إدارة الإشعارات
  // ══════════════════════════════════════════════════════════

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        type: _notifications[index].type,
        dataId: _notifications[index].dataId,
        createdAt: _notifications[index].createdAt,
        isRead: true,
      );
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          title: _notifications[i].title,
          body: _notifications[i].body,
          type: _notifications[i].type,
          dataId: _notifications[i].dataId,
          createdAt: _notifications[i].createdAt,
          isRead: true,
        );
      }
    }
  }

  void clearAll() {
    _notifications.clear();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
  }
}
