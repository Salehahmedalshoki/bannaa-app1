// ══════════════════════════════════════════════════════════
//  models/project_model.dart  — مُراجَع ومُصحَّح
// ══════════════════════════════════════════════════════════

enum BuildingType {
  villa('فيلا سكنية', '🏠'),
  apartment('شقة سكنية', '🏢'),
  commercial('مبنى تجاري', '🏬'),
  warehouse('مستودع', '🏭'),
  other('أخرى', '🏗️');
  final String label; final String emoji;
  const BuildingType(this.label, this.emoji);
}

enum ComponentType {
  column('عمود', '🏛️'), slab('سقف / بلاطة', '⬜'),
  foundation('أساس', '🔲'), wall('جدار', '🧱'),
  beam('كمرة', '━'), staircase('درج', '🪜'),
  retainingWall('جدار ساند', '🔩'), pile('ركيزة', '🔧');
  final String label; final String emoji;
  const ComponentType(this.label, this.emoji);
}

class BuildingComponent {
  final String id; final ComponentType type; final String name;
  final double length, width, height; final int count;
  const BuildingComponent({required this.id, required this.type,
    required this.name, required this.length, required this.width,
    required this.height, this.count = 1});
  double get volume => length * width * height * count;
  Map<String, dynamic> toMap() => {'id': id, 'type': type.name,
    'name': name, 'length': length, 'width': width, 'height': height, 'count': count};
  factory BuildingComponent.fromMap(Map<String, dynamic> m) => BuildingComponent(
    id: m['id'], type: ComponentType.values.firstWhere((e) => e.name == m['type'],
      orElse: () => ComponentType.column),
    name: m['name'], length: (m['length'] as num).toDouble(),
    width: (m['width'] as num).toDouble(), height: (m['height'] as num).toDouble(),
    count: (m['count'] as int?) ?? 1);
}

class MaterialQuantity {
  final String name, unit, icon; final double quantity, unitPrice; final String? note;
  const MaterialQuantity({required this.name, required this.unit, required this.quantity,
    required this.unitPrice, required this.icon, this.note});
  double get totalCost => quantity * unitPrice;
}

/// نسب خلط الخرسانة — تُمرَّر من AppSettingsProvider
class MixParameters {
  final double cementKgPerM3, sandM3PerM3, gravelM3PerM3, waterLPerM3, steelKgPerM3;
  final double cementBagKg;
  const MixParameters({required this.cementKgPerM3, required this.sandM3PerM3,
    required this.gravelM3PerM3, required this.waterLPerM3,
    required this.steelKgPerM3, this.cementBagKg = 50.0});
  static const MixParameters defaultMix = MixParameters(
    cementKgPerM3: 350, sandM3PerM3: 0.45, gravelM3PerM3: 0.75,
    waterLPerM3: 175, steelKgPerM3: 100);
}

/// أسعار المواد — تُمرَّر من AppSettingsProvider
class PriceSheet {
  final double cementPerBag, sandPerM3, gravelPerM3, steelPerKg, waterPerM3;
  final String currencySymbol;
  const PriceSheet({this.cementPerBag = 50.0, this.sandPerM3 = 150.0,
    this.gravelPerM3 = 180.0, this.steelPerKg = 4.0, this.waterPerM3 = 5.0,
    this.currencySymbol = 'ر.س'});
}

class Project {
  final String id; String name; BuildingType buildingType;
  int floors; String city; final DateTime createdAt;
  List<BuildingComponent> components;
  String? buildingCodeName; String? concreteGrade;

  Project({required this.id, required this.name, required this.buildingType,
    required this.floors, required this.city, required this.createdAt,
    List<BuildingComponent>? components, this.buildingCodeName, this.concreteGrade})
    : components = components ?? [];

  double get totalVolume => components.fold(0.0, (s, c) => s + c.volume);

  List<MaterialQuantity> calculateMaterials({
    MixParameters mix = MixParameters.defaultMix,
    PriceSheet prices = const PriceSheet(),
  }) {
    final v = totalVolume;
    if (v <= 0) return [];
    final cementBags = (v * mix.cementKgPerM3 / mix.cementBagKg).ceil().toDouble();
    final sandM3     = _r2(v * mix.sandM3PerM3);
    final gravelM3   = _r2(v * mix.gravelM3PerM3);
    final steelKg    = _r1(v * mix.steelKgPerM3);
    final waterL     = _r0(v * mix.waterLPerM3);
    return [
      MaterialQuantity(name: 'أسمنت', icon: '🪣',
        unit: 'كيس (${mix.cementBagKg.toInt()} كغ)',
        quantity: cementBags, unitPrice: prices.cementPerBag),
      MaterialQuantity(name: 'رمل', icon: '🏖️', unit: 'م³',
        quantity: sandM3, unitPrice: prices.sandPerM3),
      MaterialQuantity(name: 'حجر / زلط', icon: '🪨', unit: 'م³',
        quantity: gravelM3, unitPrice: prices.gravelPerM3),
      MaterialQuantity(name: 'حديد تسليح', icon: '⚙️', unit: 'كغ',
        quantity: steelKg, unitPrice: prices.steelPerKg),
      MaterialQuantity(name: 'ماء', icon: '💧', unit: 'لتر',
        quantity: waterL, unitPrice: prices.waterPerM3 / 1000),
    ];
  }

  double get totalCost => calculateMaterials().fold(0.0, (s, m) => s + m.totalCost);

  double totalCostWith({MixParameters mix = MixParameters.defaultMix,
    PriceSheet prices = const PriceSheet()}) =>
    calculateMaterials(mix: mix, prices: prices).fold(0.0, (s, m) => s + m.totalCost);

  Map<String, dynamic> toMap() => {'id': id, 'name': name,
    'buildingType': buildingType.name, 'floors': floors, 'city': city,
    'createdAt': createdAt.toIso8601String(),
    'components': components.map((c) => c.toMap()).toList(),
    'buildingCodeName': buildingCodeName, 'concreteGrade': concreteGrade};

  factory Project.fromMap(Map<String, dynamic> m) => Project(
    id: m['id'], name: m['name'],
    buildingType: BuildingType.values.firstWhere((e) => e.name == m['buildingType'],
      orElse: () => BuildingType.other),
    floors: (m['floors'] as int?) ?? 1, city: m['city'] ?? '',
    createdAt: DateTime.parse(m['createdAt']),
    components: ((m['components'] as List?) ?? [])
      .map((c) => BuildingComponent.fromMap(c as Map<String, dynamic>)).toList(),
    buildingCodeName: m['buildingCodeName'], concreteGrade: m['concreteGrade']);

  static double _r0(double v) => double.parse(v.toStringAsFixed(0));
  static double _r1(double v) => double.parse(v.toStringAsFixed(1));
  static double _r2(double v) => double.parse(v.toStringAsFixed(2));
}
