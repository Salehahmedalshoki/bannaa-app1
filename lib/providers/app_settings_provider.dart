// ══════════════════════════════════════════════════════════
//  providers/app_settings_provider.dart
//  إدارة إعدادات التطبيق: اللغة، العملة، الكود الهندسي
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── أكواد البناء المدعومة ─────────────────────────────────
enum BuildingCode {
  egyptian('الكود المصري (ECP)',   'ECP',  'ar'),
  american('الكود الأمريكي (ACI)', 'ACI',  'en'),
  british ('الكود البريطاني (BS)', 'BS',   'en'),
  european('الكود الأوروبي (EC2)', 'EC2',  'en'),
  saudi   ('الكود السعودي (SBC)',  'SBC',  'ar');

  final String label;
  final String short;
  final String lang;
  const BuildingCode(this.label, this.short, this.lang);
}

// ── نسب الخلط لكل كود ────────────────────────────────────
class MixRatios {
  final double cementKgPerM3;   // كغ أسمنت / م³
  final double sandM3PerM3;     // م³ رمل / م³ خرسانة
  final double gravelM3PerM3;   // م³ حجر / م³ خرسانة
  final double waterLPerM3;     // لتر ماء / م³
  final double steelKgPerM3;    // كغ حديد / م³ (متوسط)
  final String grade;           // درجة الخرسانة

  const MixRatios({
    required this.cementKgPerM3,
    required this.sandM3PerM3,
    required this.gravelM3PerM3,
    required this.waterLPerM3,
    required this.steelKgPerM3,
    required this.grade,
  });
}

// ── نسب كل كود وكل درجة ─────────────────────────────────
const Map<BuildingCode, Map<String, MixRatios>> kCodeMixes = {

  // ── الكود المصري ECP 203 ─────────────────────────────
  BuildingCode.egyptian: {
    'B200 (C16/20)': MixRatios(
      cementKgPerM3: 300, sandM3PerM3: 0.50, gravelM3PerM3: 0.80,
      waterLPerM3: 180, steelKgPerM3: 80, grade: 'B200'),
    'B250 (C20/25)': MixRatios(
      cementKgPerM3: 350, sandM3PerM3: 0.45, gravelM3PerM3: 0.75,
      waterLPerM3: 175, steelKgPerM3: 100, grade: 'B250'),
    'B300 (C25/30)': MixRatios(
      cementKgPerM3: 380, sandM3PerM3: 0.42, gravelM3PerM3: 0.72,
      waterLPerM3: 170, steelKgPerM3: 110, grade: 'B300'),
    'B350 (C28/35)': MixRatios(
      cementKgPerM3: 420, sandM3PerM3: 0.40, gravelM3PerM3: 0.70,
      waterLPerM3: 165, steelKgPerM3: 120, grade: 'B350'),
    'B400 (C32/40)': MixRatios(
      cementKgPerM3: 450, sandM3PerM3: 0.38, gravelM3PerM3: 0.68,
      waterLPerM3: 160, steelKgPerM3: 130, grade: 'B400'),
  },

  // ── الكود الأمريكي ACI 318 ───────────────────────────
  BuildingCode.american: {
    'f\'c 3000 psi (C21)': MixRatios(
      cementKgPerM3: 310, sandM3PerM3: 0.48, gravelM3PerM3: 0.78,
      waterLPerM3: 182, steelKgPerM3: 85, grade: '3000 psi'),
    'f\'c 4000 psi (C28)': MixRatios(
      cementKgPerM3: 360, sandM3PerM3: 0.44, gravelM3PerM3: 0.74,
      waterLPerM3: 175, steelKgPerM3: 100, grade: '4000 psi'),
    'f\'c 5000 psi (C35)': MixRatios(
      cementKgPerM3: 400, sandM3PerM3: 0.41, gravelM3PerM3: 0.71,
      waterLPerM3: 168, steelKgPerM3: 115, grade: '5000 psi'),
    'f\'c 6000 psi (C42)': MixRatios(
      cementKgPerM3: 440, sandM3PerM3: 0.38, gravelM3PerM3: 0.68,
      waterLPerM3: 162, steelKgPerM3: 125, grade: '6000 psi'),
    'f\'c 8000 psi (C55)': MixRatios(
      cementKgPerM3: 500, sandM3PerM3: 0.35, gravelM3PerM3: 0.65,
      waterLPerM3: 155, steelKgPerM3: 140, grade: '8000 psi'),
  },

  // ── الكود البريطاني BS 8110 ──────────────────────────
  BuildingCode.british: {
    'C20/25': MixRatios(
      cementKgPerM3: 320, sandM3PerM3: 0.47, gravelM3PerM3: 0.76,
      waterLPerM3: 180, steelKgPerM3: 85, grade: 'C20/25'),
    'C25/30': MixRatios(
      cementKgPerM3: 360, sandM3PerM3: 0.44, gravelM3PerM3: 0.73,
      waterLPerM3: 174, steelKgPerM3: 100, grade: 'C25/30'),
    'C30/37': MixRatios(
      cementKgPerM3: 390, sandM3PerM3: 0.42, gravelM3PerM3: 0.71,
      waterLPerM3: 168, steelKgPerM3: 112, grade: 'C30/37'),
    'C35/45': MixRatios(
      cementKgPerM3: 420, sandM3PerM3: 0.40, gravelM3PerM3: 0.69,
      waterLPerM3: 163, steelKgPerM3: 120, grade: 'C35/45'),
    'C40/50': MixRatios(
      cementKgPerM3: 460, sandM3PerM3: 0.37, gravelM3PerM3: 0.66,
      waterLPerM3: 158, steelKgPerM3: 130, grade: 'C40/50'),
  },

  // ── الكود الأوروبي Eurocode 2 ─────────────────────────
  BuildingCode.european: {
    'C16/20': MixRatios(
      cementKgPerM3: 295, sandM3PerM3: 0.51, gravelM3PerM3: 0.80,
      waterLPerM3: 185, steelKgPerM3: 75, grade: 'C16/20'),
    'C20/25': MixRatios(
      cementKgPerM3: 330, sandM3PerM3: 0.47, gravelM3PerM3: 0.76,
      waterLPerM3: 178, steelKgPerM3: 90, grade: 'C20/25'),
    'C25/30': MixRatios(
      cementKgPerM3: 365, sandM3PerM3: 0.44, gravelM3PerM3: 0.73,
      waterLPerM3: 172, steelKgPerM3: 105, grade: 'C25/30'),
    'C30/37': MixRatios(
      cementKgPerM3: 395, sandM3PerM3: 0.41, gravelM3PerM3: 0.71,
      waterLPerM3: 166, steelKgPerM3: 115, grade: 'C30/37'),
    'C35/45': MixRatios(
      cementKgPerM3: 430, sandM3PerM3: 0.39, gravelM3PerM3: 0.68,
      waterLPerM3: 160, steelKgPerM3: 125, grade: 'C35/45'),
  },

  // ── الكود السعودي SBC ─────────────────────────────────
  BuildingCode.saudi: {
    'C20 (B250)': MixRatios(
      cementKgPerM3: 340, sandM3PerM3: 0.46, gravelM3PerM3: 0.75,
      waterLPerM3: 175, steelKgPerM3: 95, grade: 'C20'),
    'C25 (B300)': MixRatios(
      cementKgPerM3: 375, sandM3PerM3: 0.43, gravelM3PerM3: 0.72,
      waterLPerM3: 170, steelKgPerM3: 108, grade: 'C25'),
    'C30 (B350)': MixRatios(
      cementKgPerM3: 410, sandM3PerM3: 0.41, gravelM3PerM3: 0.70,
      waterLPerM3: 164, steelKgPerM3: 118, grade: 'C30'),
    'C35 (B400)': MixRatios(
      cementKgPerM3: 445, sandM3PerM3: 0.39, gravelM3PerM3: 0.67,
      waterLPerM3: 159, steelKgPerM3: 128, grade: 'C35'),
    'C40 (B450)': MixRatios(
      cementKgPerM3: 480, sandM3PerM3: 0.36, gravelM3PerM3: 0.65,
      waterLPerM3: 154, steelKgPerM3: 138, grade: 'C40'),
  },
};

// ── العملات المدعومة ──────────────────────────────────────
class CurrencyInfo {
  final String code, symbol, nameAr, nameEn;
  final double conversionFromSAR; // معامل التحويل من الريال السعودي
  const CurrencyInfo({
    required this.code, required this.symbol,
    required this.nameAr, required this.nameEn,
    required this.conversionFromSAR,
  });
}

const Map<String, CurrencyInfo> kCurrencies = {
  'SAR': CurrencyInfo(code:'SAR', symbol:'ر.س', nameAr:'ريال سعودي', nameEn:'Saudi Riyal', conversionFromSAR: 1.0),
  'AED': CurrencyInfo(code:'AED', symbol:'د.إ', nameAr:'درهم إماراتي', nameEn:'UAE Dirham', conversionFromSAR: 1.02),
  'KWD': CurrencyInfo(code:'KWD', symbol:'د.ك', nameAr:'دينار كويتي', nameEn:'Kuwaiti Dinar', conversionFromSAR: 0.082),
  'USD': CurrencyInfo(code:'USD', symbol:'\$', nameAr:'دولار أمريكي', nameEn:'US Dollar', conversionFromSAR: 0.267),
  'EGP': CurrencyInfo(code:'EGP', symbol:'ج.م', nameAr:'جنيه مصري', nameEn:'Egyptian Pound', conversionFromSAR: 8.5),
  'GBP': CurrencyInfo(code:'GBP', symbol:'£', nameAr:'جنيه إسترليني', nameEn:'British Pound', conversionFromSAR: 0.21),
  'EUR': CurrencyInfo(code:'EUR', symbol:'€', nameAr:'يورو', nameEn:'Euro', conversionFromSAR: 0.245),
  'TRY': CurrencyInfo(code:'TRY', symbol:'₺', nameAr:'ليرة تركية', nameEn:'Turkish Lira', conversionFromSAR: 8.6),
};

// ══════════════════════════════════════════════════════════
//  AppSettingsProvider — Provider الرئيسي للإعدادات
// ══════════════════════════════════════════════════════════
class AppSettingsProvider extends ChangeNotifier {
  static const _boxName = 'app_settings';
  late Box _box;
  bool _initialized = false;

  // ── القيم الافتراضية ─────────────────────────────────
  Locale _locale         = const Locale('ar');
  BuildingCode _code     = BuildingCode.egyptian;
  String _currency       = 'SAR';
  String _selectedGrade  = 'B250 (C20/25)';
  bool _notificationsOn  = true;
  bool _darkMode         = true;

  // ── أسعار المواد القابلة للتعديل (بالريال السعودي) ──
  Map<String, double> _prices = {
    'cement':  50.0,   // كيس 50 كغ
    'sand':   150.0,   // م³
    'gravel': 180.0,   // م³
    'steel':    4.0,   // كغ
    'water':    5.0,   // م³
    'brick':  350.0,   // ألف قطعة
    'plaster': 20.0,   // كيس
    'tiles':   45.0,   // م²
  };

  // ── Getters ──────────────────────────────────────────
  Locale         get locale           => _locale;
  BuildingCode   get buildingCode     => _code;
  String         get currency         => _currency;
  String         get selectedGrade    => _selectedGrade;
  bool           get notificationsOn  => _notificationsOn;
  bool           get darkMode         => _darkMode;
  Map<String, double> get prices      => Map.unmodifiable(_prices);
  CurrencyInfo   get currencyInfo     => kCurrencies[_currency]!;
  bool           get isInitialized    => _initialized;

  MixRatios get currentMix {
    final grades = kCodeMixes[_code]!;
    return grades[_selectedGrade] ?? grades.values.first;
  }

  List<String> get gradesForCode =>
    kCodeMixes[_code]!.keys.toList();

  // ── تهيئة ────────────────────────────────────────────
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _loadFromBox();
    _initialized = true;
    notifyListeners();
  }

  void _loadFromBox() {
    final langCode = _box.get('locale', defaultValue: 'ar') as String;
    _locale = Locale(langCode);
    _code = BuildingCode.values[_box.get('buildingCode', defaultValue: 0) as int];
    _currency = _box.get('currency', defaultValue: 'SAR') as String;
    _notificationsOn = _box.get('notifications', defaultValue: true) as bool;
    _darkMode = _box.get('darkMode', defaultValue: true) as bool;

    // استرجاع الأسعار
    final savedPrices = _box.get('prices');
    if (savedPrices != null) {
      _prices = Map<String, double>.from(savedPrices);
    }

    // التحقق من grade
    final grades = kCodeMixes[_code]!;
    _selectedGrade = _box.get('grade', defaultValue: grades.keys.first) as String;
    if (!grades.containsKey(_selectedGrade)) {
      _selectedGrade = grades.keys.first;
    }
  }

  // ── تغيير اللغة ──────────────────────────────────────
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _box.put('locale', locale.languageCode);
    notifyListeners();
  }

  // ── تغيير كود البناء ─────────────────────────────────
  Future<void> setBuildingCode(BuildingCode code) async {
    _code = code;
    _selectedGrade = kCodeMixes[code]!.keys.first;
    await _box.put('buildingCode', code.index);
    await _box.put('grade', _selectedGrade);
    notifyListeners();
  }

  // ── تغيير درجة الخرسانة ──────────────────────────────
  Future<void> setGrade(String grade) async {
    _selectedGrade = grade;
    await _box.put('grade', grade);
    notifyListeners();
  }

  // ── تغيير العملة ─────────────────────────────────────
  Future<void> setCurrency(String code) async {
    _currency = code;
    await _box.put('currency', code);
    notifyListeners();
  }

  // ── تغيير سعر مادة ───────────────────────────────────
  Future<void> setPrice(String key, double value) async {
    _prices[key] = value;
    await _box.put('prices', Map<String, double>.from(_prices));
    notifyListeners();
  }

  // ── إعادة ضبط الأسعار ────────────────────────────────
  Future<void> resetPrices() async {
    _prices = {
      'cement': 50.0, 'sand': 150.0, 'gravel': 180.0,
      'steel': 4.0,   'water': 5.0,  'brick': 350.0,
      'plaster': 20.0,'tiles': 45.0,
    };
    await _box.put('prices', Map<String, double>.from(_prices));
    notifyListeners();
  }

  // ── تغيير الإشعارات ──────────────────────────────────
  Future<void> setNotifications(bool v) async {
    _notificationsOn = v;
    await _box.put('notifications', v);
    notifyListeners();
  }

  // ── تغيير الوضع الداكن ───────────────────────────────
  Future<void> setDarkMode(bool v) async {
    _darkMode = v;
    await _box.put('darkMode', v);
    notifyListeners();
  }

  // ── تحويل المبلغ للعملة المحددة ──────────────────────
  double convertFromSAR(double amountSAR) =>
    amountSAR * (kCurrencies[_currency]?.conversionFromSAR ?? 1.0);

  String formatAmount(double amountSAR) {
    final converted = convertFromSAR(amountSAR);
    final symbol = currencyInfo.symbol;
    if (converted >= 1000000) {
      return '${(converted / 1000000).toStringAsFixed(2)}م $symbol';
    } else if (converted >= 1000) {
      return '${(converted / 1000).toStringAsFixed(1)}k $symbol';
    }
    return '${converted.toStringAsFixed(0)} $symbol';
  }
}

// ── اللغات المدعومة ───────────────────────────────────────
const kSupportedLocales = [
  {'locale': Locale('ar'), 'flag': '🇸🇦', 'name': 'العربية', 'nameEn': 'Arabic'},
  {'locale': Locale('en'), 'flag': '🇺🇸', 'name': 'English', 'nameEn': 'English'},
  {'locale': Locale('fr'), 'flag': '🇫🇷', 'name': 'Français', 'nameEn': 'French'},
  {'locale': Locale('tr'), 'flag': '🇹🇷', 'name': 'Türkçe', 'nameEn': 'Turkish'},
];
