// ══════════════════════════════════════════════════════════
//  services/firestore_service.dart
//  ✅ حفظ المشاريع على Firestore
//  ✅ مزامنة تلقائية
//  ✅ وضع Offline (يعمل بدون إنترنت ويزامن لاحقاً)
// ══════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── مسار مشاريع المستخدم الحالي ──────────────────────
  static CollectionReference<Map<String, dynamic>>? get _userProjects {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('projects');
  }

  // ════════════════════════════════════════════════════════
  //  حفظ أو تحديث مشروع
  // ════════════════════════════════════════════════════════
  static Future<void> saveProject(Project project) async {
    final col = _userProjects;
    if (col == null) return;
    try {
      await col.doc(project.id).set({
        ...project.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // سيُزامَن تلقائياً عند عودة الإنترنت (Offline support)
    }
  }

  // ════════════════════════════════════════════════════════
  //  Stream لمتابعة المشاريع في الوقت الفعلي
  // ════════════════════════════════════════════════════════
  static Stream<List<Project>> projectsStream() {
    final col = _userProjects;
    if (col == null) return Stream.value([]);

    return col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              try {
                return Project.fromMap(doc.data());
              } catch (_) {
                return null;
              }
            })
            .whereType<Project>()
            .toList());
  }

  // ════════════════════════════════════════════════════════
  //  جلب المشاريع مرة واحدة (للحالات التي لا تحتاج Stream)
  // ════════════════════════════════════════════════════════
  static Future<List<Project>> getProjects() async {
    final col = _userProjects;
    if (col == null) return [];
    try {
      final snap = await col
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.serverAndCache));
      return snap.docs
          .map((doc) {
            try {
              return Project.fromMap(doc.data());
            } catch (_) {
              return null;
            }
          })
          .whereType<Project>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ════════════════════════════════════════════════════════
  //  حذف مشروع
  // ════════════════════════════════════════════════════════
  static Future<void> deleteProject(String projectId) async {
    final col = _userProjects;
    if (col == null) return;
    try {
      await col.doc(projectId).delete();
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════
  //  ترحيل المشاريع المحلية إلى السحابة (عند أول تسجيل دخول)
  // ════════════════════════════════════════════════════════
  static Future<void> migrateLocalProjects(List<Project> localProjects) async {
    if (localProjects.isEmpty) return;
    final col = _userProjects;
    if (col == null) return;

    // نتحقق أن السحابة فارغة قبل الترحيل
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) return; // السحابة بها بيانات مسبقاً

    final batch = _db.batch();
    for (final project in localProjects) {
      batch.set(col.doc(project.id), {
        ...project.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'migratedFromLocal': true,
      });
    }
    await batch.commit();
  }

  // ════════════════════════════════════════════════════════
  //  حفظ إعدادات المستخدم (الأسعار، اللغة، العملة)
  // ════════════════════════════════════════════════════════
  static Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).set(
        {...settings, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════
  //  جلب إعدادات المستخدم
  // ════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>?> getUserSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }
}
