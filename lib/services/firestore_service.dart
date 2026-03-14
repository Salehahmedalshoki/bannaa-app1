// ══════════════════════════════════════════════════════════
//  services/firestore_service.dart — المرحلة الثالثة
//  ✅ مشاريع + مزامنة + Offline
//  ✅ userType (user / supplier)
//  ✅ جلب الموردين حسب المدينة
//  ✅ إرسال واستقبال طلبات عروض الأسعار
// ══════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';
import '../models/quote_request_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>>? get _userProjects {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('projects');
  }

  static DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  // ════════════════════════════════════════════════════════
  //  نوع المستخدم
  // ════════════════════════════════════════════════════════

  static Future<void> setUserType(String uid, String userType) async {
    try {
      await _db.collection('users').doc(uid).set(
        {
          'userType': userType,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  static Future<String> getUserType() async {
    try {
      final doc = await _userDoc?.get();
      if (doc == null || !doc.exists) return 'user';
      return (doc.data()?['userType'] as String?) ?? 'user';
    } catch (_) {
      return 'user';
    }
  }

  static Stream<String> userTypeStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value('user');
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => (doc.data()?['userType'] as String?) ?? 'user',
        );
  }

  // ════════════════════════════════════════════════════════
  //  المشاريع
  // ════════════════════════════════════════════════════════

  static Future<void> saveProject(Project project) async {
    final col = _userProjects;
    if (col == null) return;
    try {
      await col.doc(project.id).set({
        ...project.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  static Stream<List<Project>> projectsStream() {
    final col = _userProjects;
    if (col == null) return Stream.value([]);
    return col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((doc) {
                try {
                  return Project.fromMap(doc.data());
                } catch (_) {
                  return null;
                }
              })
              .whereType<Project>()
              .toList(),
        );
  }

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

  static Future<void> deleteProject(String projectId) async {
    final col = _userProjects;
    if (col == null) return;
    try {
      await col.doc(projectId).delete();
    } catch (_) {}
  }

  static Future<void> migrateLocalProjects(List<Project> localProjects) async {
    if (localProjects.isEmpty) return;
    final col = _userProjects;
    if (col == null) return;
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) return;
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
  //  الموردون — جلب وتصفية
  // ════════════════════════════════════════════════════════

  /// جلب جميع الموردين المسجّلين (للعرض في قائمة الاختيار)
  static Future<List<SupplierProfile>> getSuppliers({String? city}) async {
    try {
      Query<Map<String, dynamic>> query =
          _db.collection('users').where('userType', isEqualTo: 'supplier');

      final snap = await query.get();
      final suppliers = snap.docs
          .map((doc) {
            try {
              return SupplierProfile.fromMap(doc.id, doc.data());
            } catch (_) {
              return null;
            }
          })
          .whereType<SupplierProfile>()
          .toList();

      // تصفية حسب المدينة إذا أُعطيت
      if (city != null && city.isNotEmpty) {
        return suppliers
            .where((s) =>
                s.cities.isEmpty || // مورّد لم يحدد مدناً بعد → يظهر للجميع
                s.cities.any((c) => c.contains(city) || city.contains(c)))
            .toList();
      }
      return suppliers;
    } catch (_) {
      return [];
    }
  }

  /// Stream للموردين
  static Stream<List<SupplierProfile>> suppliersStream({String? city}) {
    Query<Map<String, dynamic>> query =
        _db.collection('users').where('userType', isEqualTo: 'supplier');

    return query.snapshots().map((snap) {
      final suppliers = snap.docs
          .map((doc) {
            try {
              return SupplierProfile.fromMap(doc.id, doc.data());
            } catch (_) {
              return null;
            }
          })
          .whereType<SupplierProfile>()
          .toList();

      if (city != null && city.isNotEmpty) {
        return suppliers
            .where((s) =>
                s.cities.isEmpty ||
                s.cities.any((c) => c.contains(city) || city.contains(c)))
            .toList();
      }
      return suppliers;
    });
  }

  // ════════════════════════════════════════════════════════
  //  طلبات عروض الأسعار — الإرسال والاستقبال
  // ════════════════════════════════════════════════════════

  /// المستخدم يرسل طلب عرض سعر لمورّد
  static Future<bool> sendQuoteRequest(QuoteRequest request) async {
    try {
      final docId = request.id;

      // حفظ في collection المستخدم (لمتابعة طلباته)
      await _db
          .collection('users')
          .doc(request.userId)
          .collection('quote_requests')
          .doc(docId)
          .set(request.toMap());

      // حفظ في collection المورّد (ليستقبله)
      await _db
          .collection('users')
          .doc(request.supplierId)
          .collection('incoming_quotes')
          .doc(docId)
          .set(request.toMap());

      return true;
    } catch (_) {
      return false;
    }
  }

  /// جلب طلبات المستخدم (ما أرسله)
  static Stream<List<QuoteRequest>> myQuoteRequestsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(uid)
        .collection('quote_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              try {
                return QuoteRequest.fromMap(doc.data());
              } catch (_) {
                return null;
              }
            })
            .whereType<QuoteRequest>()
            .toList());
  }

  /// جلب الطلبات الواردة للمورّد
  static Stream<List<QuoteRequest>> incomingQuotesStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(uid)
        .collection('incoming_quotes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              try {
                return QuoteRequest.fromMap(doc.data());
              } catch (_) {
                return null;
              }
            })
            .whereType<QuoteRequest>()
            .toList());
  }

  /// المورّد يرد على الطلب
  static Future<void> respondToQuote({
    required String quoteId,
    required String userId,
    required String response,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final update = {
      'status': QuoteStatus.responded.name,
      'supplierResponse': response,
      'respondedAt': DateTime.now().toIso8601String(),
    };

    try {
      // تحديث عند المورّد
      await _db
          .collection('users')
          .doc(uid)
          .collection('incoming_quotes')
          .doc(quoteId)
          .update(update);

      // تحديث عند المستخدم
      await _db
          .collection('users')
          .doc(userId)
          .collection('quote_requests')
          .doc(quoteId)
          .update(update);
    } catch (_) {}
  }

  /// تغيير حالة الطلب إلى "مشاهَد"
  static Future<void> markQuoteAsViewed(String quoteId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('incoming_quotes')
          .doc(quoteId)
          .update({'status': QuoteStatus.viewed.name});
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════
  //  الإعدادات
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

  /// المستخدم يحدّث حالة طلبه (قبول / رفض)
  static Future<void> updateQuoteStatusByUser({
    required String quoteId,
    required String supplierId,
    required String newStatus,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final update = {'status': newStatus};
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('quote_requests')
          .doc(quoteId)
          .update(update);
      await _db
          .collection('users')
          .doc(supplierId)
          .collection('incoming_quotes')
          .doc(quoteId)
          .update(update);
    } catch (_) {}
  }
}
