// ══════════════════════════════════════════════════════════
//  models/quote_request_model.dart
//  موديل طلب عرض السعر بين المستخدم والمورّد
// ══════════════════════════════════════════════════════════

enum QuoteStatus {
  pending('قيد الانتظار'),
  viewed('تمت المشاهدة'),
  responded('تم الرد'),
  accepted('مقبول'),
  rejected('مرفوض');

  final String label;
  const QuoteStatus(this.label);
}

class QuoteMaterial {
  final String name;
  final String icon;
  final double quantity;
  final String unit;

  const QuoteMaterial({
    required this.name,
    required this.icon,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'icon': icon,
        'quantity': quantity,
        'unit': unit,
      };

  factory QuoteMaterial.fromMap(Map<String, dynamic> m) => QuoteMaterial(
        name: m['name'] ?? '',
        icon: m['icon'] ?? '📦',
        quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
        unit: m['unit'] ?? '',
      );
}

class QuoteRequest {
  final String id;
  final String userId;
  final String userName;
  final String supplierId;
  final String projectName;
  final String city;
  final List<QuoteMaterial> materials;
  final String? note;
  final QuoteStatus status;
  final DateTime createdAt;
  final String? supplierResponse;
  final DateTime? respondedAt;

  const QuoteRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.supplierId,
    required this.projectName,
    required this.city,
    required this.materials,
    this.note,
    required this.status,
    required this.createdAt,
    this.supplierResponse,
    this.respondedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'supplierId': supplierId,
        'projectName': projectName,
        'city': city,
        'materials': materials.map((m) => m.toMap()).toList(),
        'note': note,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'supplierResponse': supplierResponse,
        'respondedAt': respondedAt?.toIso8601String(),
      };

  factory QuoteRequest.fromMap(Map<String, dynamic> m) => QuoteRequest(
        id: m['id'] ?? '',
        userId: m['userId'] ?? '',
        userName: m['userName'] ?? 'مجهول',
        supplierId: m['supplierId'] ?? '',
        projectName: m['projectName'] ?? '',
        city: m['city'] ?? '',
        materials: ((m['materials'] as List?) ?? [])
            .map((e) => QuoteMaterial.fromMap(e as Map<String, dynamic>))
            .toList(),
        note: m['note'],
        status: QuoteStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => QuoteStatus.pending,
        ),
        createdAt: m['createdAt'] != null
            ? DateTime.tryParse(m['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        supplierResponse: m['supplierResponse'],
        respondedAt: m['respondedAt'] != null
            ? DateTime.tryParse(m['respondedAt'])
            : null,
      );
}

class SupplierProfile {
  final String uid;
  final String name;
  final String? email;
  final List<String> categories; // أنواع المواد
  final List<String> cities; // المدن المخدومة
  final double rating;
  final int totalOrders;

  const SupplierProfile({
    required this.uid,
    required this.name,
    this.email,
    required this.categories,
    required this.cities,
    this.rating = 0,
    this.totalOrders = 0,
  });

  factory SupplierProfile.fromMap(String uid, Map<String, dynamic> m) =>
      SupplierProfile(
        uid: uid,
        name: m['displayName'] ?? m['name'] ?? 'مورّد',
        email: m['email'],
        categories: List<String>.from(m['categories'] ?? []),
        cities: List<String>.from(m['cities'] ?? []),
        rating: (m['rating'] as num?)?.toDouble() ?? 0,
        totalOrders: (m['totalOrders'] as int?) ?? 0,
      );
}
