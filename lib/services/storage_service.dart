// ══════════════════════════════════════════════════════════
//  services/storage_service.dart  ✅ محسّن مع الوضع Offline
//  حفظ واسترجاع المشاريع محلياً باستخدام Hive
// ══════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/project_model.dart';

class StorageService {
  static const String _projectsBox = 'projects_box';
  static const String _queueBox = 'offline_queue';
  static const String _settingsBox = 'settings_box';

  static late Box _projectsBoxInstance;
  static late Box _queueBoxInstance;
  static late Box _settingsBoxInstance;

  /// تهيئة قاعدة البيانات المحلية
  static Future<void> init() async {
    await Hive.initFlutter();
    _projectsBoxInstance = await Hive.openBox(_projectsBox);
    _queueBoxInstance = await Hive.openBox(_queueBox);
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
  }

  // ══════════════════════════════════════════════════════════
  //  المشاريع المحلية (Offline Cache)
  // ══════════════════════════════════════════════════════════

  /// حفظ أو تحديث مشروع محلياً
  static Future<void> saveProjectLocal(Project project) async {
    await _projectsBoxInstance.put(project.id, jsonEncode(project.toMap()));
  }

  /// استرجاع جميع المشاريع محلياً
  static List<Project> getAllProjectsLocal() {
    return _projectsBoxInstance.values
        .map((v) => Project.fromMap(jsonDecode(v)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// استرجاع مشروع بالمعرّف
  static Project? getProjectLocal(String id) {
    final v = _projectsBoxInstance.get(id);
    if (v == null) return null;
    return Project.fromMap(jsonDecode(v));
  }

  /// حذف مشروع محلياً
  static Future<void> deleteProjectLocal(String id) async {
    await _projectsBoxInstance.delete(id);
  }

  /// مسح جميع المشاريع المحلية
  static Future<void> clearAllProjects() async {
    await _projectsBoxInstance.clear();
  }

  /// عدد المشاريع المحلية
  static int get projectsCount => _projectsBoxInstance.length;

  // ══════════════════════════════════════════════════════════
  //  Queue العمليات (للـ Offline Sync)
  // ══════════════════════════════════════════════════════════

  /// إضافة عملية للـ queue
  static Future<void> queueOperation({
    required String type, // 'save', 'delete'
    required String entity, // 'project', 'quote'
    required String id,
    Map<String, dynamic>? data,
  }) async {
    final operation = {
      'type': type,
      'entity': entity,
      'id': id,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _queueBoxInstance.add(jsonEncode(operation));
  }

  /// استرجاع العمليات المعلقة
  static List<Map<String, dynamic>> getPendingOperations() {
    return _queueBoxInstance.values
        .map((v) => jsonDecode(v) as Map<String, dynamic>)
        .toList();
  }

  /// مسح queue العمليات المنفذة
  static Future<void> clearQueue() async {
    await _queueBoxInstance.clear();
  }

  /// عدد العمليات المعلقة
  static int get pendingOperationsCount => _queueBoxInstance.length;

  // ══════════════════════════════════════════════════════════
  //  الإعدادات المحلية
  // ══════════════════════════════════════════════════════════

  /// حفظ إعداد
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBoxInstance.put(key, value);
  }

  /// استرجاع إعداد
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBoxInstance.get(key, defaultValue: defaultValue);
  }

  /// حذف إعداد
  static Future<void> deleteSetting(String key) async {
    await _settingsBoxInstance.delete(key);
  }
}
