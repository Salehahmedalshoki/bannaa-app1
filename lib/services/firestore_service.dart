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
import 'storage_service.dart';

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
    // حفظ محلياً أولاً (Cache)
    await StorageService.saveProjectLocal(project);

    // ثم حفظ على Firestore
    final col = _userProjects;
    if (col == null) return;
    try {
      await col.doc(project.id).set({
        ...project.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // إذا فشل، أضف للـ queue
      await StorageService.queueOperation(
        type: 'save',
        entity: 'project',
        id: project.id,
        data: project.toMap(),
      );
    }
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
    // حذف محلياً أولاً
    await StorageService.deleteProjectLocal(projectId);

    // ثم حذف من Firestore
    final col = _userProjects;
    if (col == null) return;
    try {
      await col.doc(projectId).delete();
    } catch (e) {
      // إذا فشل، أضف للـ queue
      await StorageService.queueOperation(
        type: 'delete',
        entity: 'project',
        id: projectId,
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  //  Duplicate مشروع (كـ قالب)
  // ══════════════════════════════════════════════════════════
  static Future<Project?> duplicateProject(
      Project original, String newName) async {
    final col = _userProjects;
    if (col == null) return null;
    try {
      final newId =
          '${original.id}_copy_${DateTime.now().millisecondsSinceEpoch}';
      final newProject = Project(
        id: newId,
        name: newName,
        buildingType: original.buildingType,
        floors: original.floors,
        city: original.city,
        createdAt: DateTime.now(),
        components: original.components
            .map((c) => BuildingComponent(
                  id: '${c.id}_copy',
                  type: c.type,
                  name: c.name,
                  length: c.length,
                  width: c.width,
                  height: c.height,
                  count: c.count,
                ))
            .toList(),
        buildingCodeName: original.buildingCodeName,
        concreteGrade: original.concreteGrade,
      );
      await col.doc(newId).set(newProject.toMap());
      return newProject;
    } catch (_) {
      return null;
    }
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

  // ══════════════════════════════════════════════════════════
  //  إدارة الموردين - المواد
  // ══════════════════════════════════════════════════════════

  /// حفظ سعر مادة
  static Future<void> saveMaterialPrice(MaterialPrice material) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db
          .collection('suppliers')
          .doc(uid)
          .collection('materials')
          .doc(material.id)
          .set({
        ...material.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// جلب أسعار مواد المورد
  static Stream<List<MaterialPrice>> supplierMaterialsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection('suppliers')
        .doc(uid)
        .collection('materials')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MaterialPrice.fromMap(doc.data())).toList());
  }

  /// حذف مادة
  static Future<void> deleteMaterial(String materialId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db
          .collection('suppliers')
          .doc(uid)
          .collection('materials')
          .doc(materialId)
          .delete();
    } catch (_) {}
  }

  /// جلب أسعار مواد كل الموردين (للمقارنة)
  static Stream<List<MaterialPrice>> allSuppliersMaterialsStream() {
    return _db.collectionGroup('materials').snapshots().map((snap) =>
        snap.docs.map((doc) => MaterialPrice.fromMap(doc.data())).toList());
  }

  // ══════════════════════════════════════════════════════════
  //  إعدادات المتجر
  // ══════════════════════════════════════════════════════════

  /// حفظ إعدادات المتجر
  static Future<void> saveShopSettings({
    required String shopName,
    required String phone,
    String? location,
    List<String>? deliveryAreas,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db.collection('suppliers').doc(uid).set({
        'shopName': shopName,
        'phone': phone,
        'location': location,
        'deliveryAreas': deliveryAreas ?? [],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// جلب إعدادات المتجر
  static Future<Map<String, dynamic>?> getShopSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _db.collection('suppliers').doc(uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  //  العروض المرسلة من المورد
  // ══════════════════════════════════════════════════════════

  /// إرسال عرض سعر للمشروع
  static Future<void> sendOffer({
    required String projectId,
    required String userId,
    required double totalPrice,
    required List<MaterialQuantity> materials,
    required DateTime validUntil,
    String? notes,
  }) async {
    final supplierId = FirebaseAuth.instance.currentUser?.uid;
    if (supplierId == null) return;

    final offerId = 'offer_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // حفظ العرض لدى المورد
      await _db
          .collection('suppliers')
          .doc(supplierId)
          .collection('sent_offers')
          .doc(offerId)
          .set({
        'id': offerId,
        'projectId': projectId,
        'userId': userId,
        'totalPrice': totalPrice,
        'materials': materials
            .map((m) => {
                  'name': m.name,
                  'quantity': m.quantity,
                  'unit': m.unit,
                  'unitPrice': m.unitPrice,
                  'totalCost': m.totalCost,
                })
            .toList(),
        'validUntil': validUntil.toIso8601String(),
        'notes': notes,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // حفظ العرض لدى المستخدم
      await _db
          .collection('users')
          .doc(userId)
          .collection('project_offers')
          .doc(offerId)
          .set({
        'id': offerId,
        'projectId': projectId,
        'supplierId': supplierId,
        'totalPrice': totalPrice,
        'materials': materials
            .map((m) => {
                  'name': m.name,
                  'quantity': m.quantity,
                  'unit': m.unit,
                  'unitPrice': m.unitPrice,
                  'totalCost': m.totalCost,
                })
            .toList(),
        'validUntil': validUntil.toIso8601String(),
        'notes': notes,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  /// جلب العروض المرسلة
  static Stream<List<Map<String, dynamic>>> supplierSentOffersStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection('suppliers')
        .doc(uid)
        .collection('sent_offers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // ══════════════════════════════════════════════════════════
  //  طلبات المواد (Orders)
  // ══════════════════════════════════════════════════════════

  /// إنشاء طلب مواد جديد
  static Future<void> createMaterialOrder(MaterialOrder order) async {
    try {
      // حفظ لدى المستخدم
      await _db
          .collection('users')
          .doc(order.userId)
          .collection('orders')
          .doc(order.id)
          .set(order.toMap());

      // حفظ لدى المورد
      await _db
          .collection('suppliers')
          .doc(order.supplierId)
          .collection('received_orders')
          .doc(order.id)
          .set(order.toMap());
    } catch (_) {}
  }

  /// جلب طلبات المستخدم
  static Stream<List<MaterialOrder>> userOrdersStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MaterialOrder.fromMap(doc.data())).toList());
  }

  /// جلب طلبات المورد الواردة
  static Stream<List<MaterialOrder>> supplierOrdersStream(String supplierId) {
    return _db
        .collection('suppliers')
        .doc(supplierId)
        .collection('received_orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MaterialOrder.fromMap(doc.data())).toList());
  }

  /// تحديث حالة الطلب
  static Future<void> updateOrderStatus({
    required String orderId,
    required String userId,
    required String supplierId,
    required OrderStatus newStatus,
  }) async {
    try {
      final now = DateTime.now();
      final update = {
        'status': newStatus.name,
        'updatedAt': now.toIso8601String(),
        if (newStatus == OrderStatus.completed)
          'completedAt': now.toIso8601String(),
      };

      // تحديث لدى المستخدم
      await _db
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update(update);

      // تحديث لدى المورد
      await _db
          .collection('suppliers')
          .doc(supplierId)
          .collection('received_orders')
          .doc(orderId)
          .update(update);
    } catch (_) {}
  }

  /// جلب عرض معين للمشروع
  static Future<Map<String, dynamic>?> getProjectOffer(
      String projectId, String supplierId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(supplierId)
          .collection('project_offers')
          .where('projectId', isEqualTo: projectId)
          .limit(1)
          .get();
      return doc.docs.isNotEmpty ? doc.docs.first.data() : null;
    } catch (_) {
      return null;
    }
  }
}
