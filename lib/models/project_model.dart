// ══════════════════════════════════════════════════════════
//  models/project_model.dart  — مُحدَّث مع السيناريو الجديد
// ══════════════════════════════════════════════════════════

// ── أنواع المنشآت ─────────────────────────────────────────────
enum BuildingType {
  villa('فيلا سكنية', '🏠'),
  apartment('شقة سكنية', '🏢'),
  commercial('مبنى تجاري', '🏬'),
  warehouse('مستودع', '🏭'),
  villaFloor('فيلا دورين', '🏡'),
  villaPlus('فيلا متعددة', '🏘️'),
  other('أخرى', '🏗️');

  final String label;
  final String emoji;
  const BuildingType(this.label, this.emoji);
}

// ── أنواع التسليح ────────────────────────────────────────────
enum ReinforcementType {
  traditional('تسليح تقليدي', '🔩', 100),
  weldedMesh('شبك ملحوم', '🔗', 85),
  ringSteel('حديد حلقي', '⭕', 90),
  fiber('ألياف تسليح', '🧵', 120);

  final String label;
  final String emoji;
  final double kgPerM3;
  const ReinforcementType(this.label, this.emoji, this.kgPerM3);
}

// ── أنواع الخرسانة ───────────────────────────────────────────
enum ConcreteGrade {
  C16('C16 (200)', 300, 0.50, 0.80, 180, 80),
  C20('C20 (250)', 350, 0.45, 0.75, 175, 100),
  C25('C25 (300)', 380, 0.42, 0.72, 170, 110),
  C30('C30 (350)', 420, 0.40, 0.70, 165, 120),
  C35('C35 (400)', 450, 0.38, 0.68, 160, 130),
  C40('C40 (450)', 480, 0.36, 0.65, 155, 140);

  final String label;
  final double cementKg, sandM3, gravelM3, waterL, steelKg;
  const ConcreteGrade(this.label, this.cementKg, this.sandM3, this.gravelM3,
      this.waterL, this.steelKg);
}

// ── مراحل المشروع ────────────────────────────────────────────
enum ProjectPhase {
  foundation('الأساسات', '🔲', 0.25),
  columns('الأعمدة', '🏛️', 0.20),
  roofs('السقف', '⬜', 0.30),
  walls('الجدران', '🧱', 0.15),
  finishing('التشطيبات', '🎨', 0.10);

  final String label;
  final String emoji;
  final double ratio;
  const ProjectPhase(this.label, this.emoji, this.ratio);
}

// ── حالة المشروع ────────────────────────────────────────────
enum ProjectStatus {
  draft('مسودة', '📝'),
  inProgress('قيد التنفيذ', '🔄'),
  completed('مكتمل', '✅'),
  onHold('موقف', '⏸️');

  final String label;
  final String emoji;
  const ProjectStatus(this.label, this.emoji);
}

// ── نوع المكون ───────────────────────────────────────────────
enum ComponentType {
  column('عمود', '🏛️'),
  slab('سقف / بلاطة', '⬜'),
  foundation('أساس', '🔲'),
  wall('جدار', '🧱'),
  beam('كمرة', '━'),
  staircase('درج', '🪜'),
  retainingWall('جدار ساند', '🔩'),
  pile('ركيزة', '🔧'),
  roofBeam('كمرة سقف', '📏'),
  lintel('عتبة', '➖');

  final String label;
  final String emoji;
  const ComponentType(this.label, this.emoji);
}

// ══════════════════════════════════════════════════════════
//  مكونات البناء
// ══════════════════════════════════════════════════════════
class BuildingComponent {
  final String id;
  final ComponentType type;
  final String name;
  final double length, width, height;
  final int count;
  final ProjectPhase phase;

  const BuildingComponent(
      {required this.id,
      required this.type,
      required this.name,
      required this.length,
      required this.width,
      required this.height,
      this.count = 1,
      this.phase = ProjectPhase.foundation});

  double get volume => length * width * height * count;

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'name': name,
        'length': length,
        'width': width,
        'height': height,
        'count': count,
        'phase': phase.name
      };

  factory BuildingComponent.fromMap(Map<String, dynamic> m) =>
      BuildingComponent(
          id: m['id'],
          type: ComponentType.values.firstWhere((e) => e.name == m['type'],
              orElse: () => ComponentType.column),
          name: m['name'],
          length: (m['length'] as num).toDouble(),
          width: (m['width'] as num).toDouble(),
          height: (m['height'] as num).toDouble(),
          count: (m['count'] as int?) ?? 1,
          phase: ProjectPhase.values.firstWhere((e) => e.name == m['phase'],
              orElse: () => ProjectPhase.foundation));
}

// ══════════════════════════════════════════════════════════
//  كميات المواد
// ══════════════════════════════════════════════════════════
class MaterialQuantity {
  final String name, unit, icon;
  final double quantity, unitPrice;
  final String? note;
  final double totalCost;

  const MaterialQuantity(
      {required this.name,
      required this.unit,
      required this.quantity,
      required this.unitPrice,
      required this.icon,
      this.note,
      double? totalCost})
      : totalCost = totalCost ?? (quantity * unitPrice);

  MaterialQuantity copyWith({double? quantity, double? unitPrice}) =>
      MaterialQuantity(
          name: name,
          unit: unit,
          quantity: quantity ?? this.quantity,
          unitPrice: unitPrice ?? this.unitPrice,
          icon: icon,
          note: note);
}

// ══════════════════════════════════════════════════════════
//  أسعار المواد (قائمة أسعار)
// ══════════════════════════════════════════════════════════
class MaterialPrice {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String? supplierId;
  final DateTime lastUpdated;

  const MaterialPrice(
      {required this.id,
      required this.name,
      required this.category,
      required this.price,
      required this.unit,
      this.supplierId,
      required this.lastUpdated});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'unit': unit,
        'supplierId': supplierId,
        'lastUpdated': lastUpdated.toIso8601String()
      };

  factory MaterialPrice.fromMap(Map<String, dynamic> m) => MaterialPrice(
      id: m['id'],
      name: m['name'],
      category: m['category'],
      price: (m['price'] as num).toDouble(),
      unit: m['unit'],
      supplierId: m['supplierId'],
      lastUpdated: DateTime.tryParse(m['lastUpdated'] ?? '') ?? DateTime.now());
}

// ══════════════════════════════════════════════════════════
//  أسعار المواد (ورقة الأسعار للمستخدم)
// ══════════════════════════════════════════════════════════
class PriceSheet {
  final double cementPerBag, sandPerM3, gravelPerM3, steelPerKg, waterPerM3;
  final String currencySymbol;
  final DateTime lastUpdated;

  const PriceSheet(
      {this.cementPerBag = 50.0,
      this.sandPerM3 = 150.0,
      this.gravelPerM3 = 180.0,
      this.steelPerKg = 4.0,
      this.waterPerM3 = 5.0,
      this.currencySymbol = 'ر.س',
      DateTime? lastUpdated})
      : lastUpdated = lastUpdated ?? const _DefaultDate();

  Map<String, dynamic> toMap() => {
        'cementPerBag': cementPerBag,
        'sandPerM3': sandPerM3,
        'gravelPerM3': gravelPerM3,
        'steelPerKg': steelPerKg,
        'waterPerM3': waterPerM3,
        'currencySymbol': currencySymbol,
        'lastUpdated': lastUpdated.toIso8601String()
      };

  factory PriceSheet.fromMap(Map<String, dynamic> m) => PriceSheet(
      cementPerBag: (m['cementPerBag'] as num?)?.toDouble() ?? 50.0,
      sandPerM3: (m['sandPerM3'] as num?)?.toDouble() ?? 150.0,
      gravelPerM3: (m['gravelPerM3'] as num?)?.toDouble() ?? 180.0,
      steelPerKg: (m['steelPerKg'] as num?)?.toDouble() ?? 4.0,
      waterPerM3: (m['waterPerM3'] as num?)?.toDouble() ?? 5.0,
      currencySymbol: m['currencySymbol'] ?? 'ر.س',
      lastUpdated: m['lastUpdated'] != null
          ? DateTime.tryParse(m['lastUpdated'])
          : null);
}

class _DefaultDate implements DateTime {
  const _DefaultDate();
  DateTime get _default => DateTime.now();
  @override
  dynamic noSuchMethod(Invocation i) => DateTime.now();
}

// ══════════════════════════════════════════════════════════
//  المشروع الرئيسي
// ══════════════════════════════════════════════════════════
class Project {
  final String id;
  String name;
  BuildingType buildingType;
  int floors;
  String city;
  final DateTime createdAt;

  List<BuildingComponent> components;
  String? buildingCodeName;
  ConcreteGrade? concreteGrade;
  ReinforcementType? reinforcementType;
  ProjectStatus status;
  PriceSheet? priceSheet;

  // معلومات إضافية
  double? totalArea;
  String? notes;
  List<String>? tags;

  Project(
      {required this.id,
      required this.name,
      required this.buildingType,
      required this.floors,
      required this.city,
      required this.createdAt,
      List<BuildingComponent>? components,
      this.buildingCodeName,
      this.concreteGrade,
      this.reinforcementType,
      this.status = ProjectStatus.draft,
      this.priceSheet,
      this.totalArea,
      this.notes,
      this.tags})
      : components = components ?? [];

  // ── حساب الحجم الإجمالي ───────────────────────────────────
  double get totalVolume => components.fold(0.0, (s, c) => s + c.volume);

  // ── حساب المواد ───────────────────────────────────────────
  List<MaterialQuantity> calculateMaterials({
    ConcreteGrade? grade,
    ReinforcementType? reinforcement,
    PriceSheet? prices,
  }) {
    final g = grade ?? concreteGrade ?? ConcreteGrade.C20;
    final r =
        reinforcement ?? reinforcementType ?? ReinforcementType.traditional;
    final p = prices ?? priceSheet ?? const PriceSheet();
    final v = totalVolume;

    if (v <= 0) return [];

    // حساب الأسمنت
    final cementBags = (v * g.cementKg / 50).ceil().toDouble();
    final sandM3 = _r2(v * g.sandM3);
    final gravelM3 = _r2(v * g.gravelM3);
    final waterL = _r0(v * g.waterL);
    final steelKg = _r1(v * r.kgPerM3);

    return [
      MaterialQuantity(
          name: 'أسمنت',
          icon: '🪣',
          unit: 'كيس (50 كغ)',
          quantity: cementBags,
          unitPrice: p.cementPerBag,
          note: 'نوع ${g.label}'),
      MaterialQuantity(
          name: 'رمل',
          icon: '🏖️',
          unit: 'م³',
          quantity: sandM3,
          unitPrice: p.sandPerM3),
      MaterialQuantity(
          name: 'حجر / زلط',
          icon: '🪨',
          unit: 'م³',
          quantity: gravelM3,
          unitPrice: p.gravelPerM3),
      MaterialQuantity(
          name: 'حديد تسليح',
          icon: r.emoji,
          unit: 'كغ',
          quantity: steelKg,
          unitPrice: p.steelPerKg,
          note: r.label),
      MaterialQuantity(
          name: 'ماء',
          icon: '💧',
          unit: 'لتر',
          quantity: waterL,
          unitPrice: p.waterPerM3 / 1000),
    ];
  }

  // ── التكلفة الإجمالية ─────────────────────────────────────
  double get totalCost {
    final materials = calculateMaterials();
    return materials.fold(0.0, (s, m) => s + m.totalCost);
  }

  double totalCostWith(
      {ConcreteGrade? grade,
      ReinforcementType? reinforcement,
      PriceSheet? prices}) {
    final materials = calculateMaterials(
        grade: grade, reinforcement: reinforcement, prices: prices);
    return materials.fold(0.0, (s, m) => s + m.totalCost);
  }

  // ── التكلفة حسب المرحلة ───────────────────────────────────
  Map<ProjectPhase, double> get costByPhase {
    final materials = calculateMaterials();
    final total = totalCost;
    final result = <ProjectPhase, double>{};

    for (final phase in ProjectPhase.values) {
      result[phase] = total * phase.ratio;
    }
    return result;
  }

  // ── Serialize ─────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'buildingType': buildingType.name,
        'floors': floors,
        'city': city,
        'createdAt': createdAt.toIso8601String(),
        'components': components.map((c) => c.toMap()).toList(),
        'buildingCodeName': buildingCodeName,
        'concreteGrade': concreteGrade?.name,
        'reinforcementType': reinforcementType?.name,
        'status': status.name,
        'priceSheet': priceSheet?.toMap(),
        'totalArea': totalArea,
        'notes': notes,
        'tags': tags
      };

  factory Project.fromMap(Map<String, dynamic> m) => Project(
      id: m['id'],
      name: m['name'],
      buildingType: BuildingType.values.firstWhere(
          (e) => e.name == m['buildingType'],
          orElse: () => BuildingType.other),
      floors: (m['floors'] as int?) ?? 1,
      city: m['city'] ?? '',
      createdAt: DateTime.parse(m['createdAt']),
      components: ((m['components'] as List?) ?? [])
          .map((c) => BuildingComponent.fromMap(c as Map<String, dynamic>))
          .toList(),
      buildingCodeName: m['buildingCodeName'],
      concreteGrade: m['concreteGrade'] != null
          ? ConcreteGrade.values.firstWhere((e) => e.name == m['concreteGrade'],
              orElse: () => ConcreteGrade.C20)
          : null,
      reinforcementType: m['reinforcementType'] != null
          ? ReinforcementType.values.firstWhere(
              (e) => e.name == m['reinforcementType'],
              orElse: () => ReinforcementType.traditional)
          : null,
      status: ProjectStatus.values.firstWhere((e) => e.name == m['status'],
          orElse: () => ProjectStatus.draft),
      priceSheet: m['priceSheet'] != null
          ? PriceSheet.fromMap(m['priceSheet'] as Map<String, dynamic>)
          : null,
      totalArea: (m['totalArea'] as num?)?.toDouble(),
      notes: m['notes'],
      tags: (m['tags'] as List?)?.cast<String>());

  // ── Helpers ───────────────────────────────────────────────
  static double _r0(double v) => double.parse(v.toStringAsFixed(0));
  static double _r1(double v) => double.parse(v.toStringAsFixed(1));
  static double _r2(double v) => double.parse(v.toStringAsFixed(2));
}
