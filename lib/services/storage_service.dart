// ══════════════════════════════════════════════════════════
//  services/storage_service.dart
//  حفظ واسترجاع المشاريع محلياً باستخدام Hive
// ══════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/project_model.dart';

class StorageService {
  static const String _boxName = 'projects_box';
  static late Box _box;

  /// تهيئة قاعدة البيانات المحلية
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// حفظ أو تحديث مشروع
  static Future<void> saveProject(Project project) async {
    await _box.put(project.id, jsonEncode(project.toMap()));
  }

  /// استرجاع جميع المشاريع مرتبة من الأحدث
  static List<Project> getAllProjects() {
    return _box.values
        .map((v) => Project.fromMap(jsonDecode(v)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// استرجاع مشروع بالمعرّف
  static Project? getProject(String id) {
    final v = _box.get(id);
    if (v == null) return null;
    return Project.fromMap(jsonDecode(v));
  }

  /// حذف مشروع
  static Future<void> deleteProject(String id) async {
    await _box.delete(id);
  }

  /// عدد المشاريع
  static int get count => _box.length;
}
