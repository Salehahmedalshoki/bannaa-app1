// ══════════════════════════════════════════════════════════
//  screens/land_projection_screen.dart
//  🗺️ ميزة الإسقاط الجوي للأراضي - النسخة المحدّثة
//  - اختيار المدينة
//  - رسم حدود الأرضية كمضلع على الخريطة (نقر للإضافة)
//  - حساب المساحة والأبعاد تلقائياً من الحدود المرسومة
//  - اختيار عدد الأدوار ونوع الاستخدام
//  - الانتقال لتوليد المخططات المعمارية
// ══════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'land_plan_screen.dart';

class LandProjectionScreen extends StatefulWidget {
  const LandProjectionScreen({super.key});

  @override
  State<LandProjectionScreen> createState() => _LandProjectionScreenState();
}

class _LandProjectionScreenState extends State<LandProjectionScreen>
    with TickerProviderStateMixin {
  // ── خطوات: 0=اختر المدينة, 1=ارسم الحدود, 2=تأكيد ──
  int _step = 0;

  String _selectedCity = '';
  String _searchQuery = '';
  GoogleMapController? _mapController;

  // نقاط حدود الأرضية
  final List<LatLng> _boundaryPoints = [];

  // نتائج الحساب
  double _calculatedArea = 0;
  double _calculatedLength = 0;
  double _calculatedWidth = 0;
  LatLng? _landCenter;

  // خيارات البناء
  int _floors = 1;
  String _buildingUse = 'سكني';

  late final AnimationController _pulseCtrl;

  static const _cities = [
    {'name': 'صنعاء', 'lat': 15.3694, 'lng': 44.1910, 'flag': '🇾🇪'},
    {'name': 'عدن', 'lat': 12.7795, 'lng': 45.0367, 'flag': '🇾🇪'},
    {'name': 'تعز', 'lat': 13.5789, 'lng': 44.0178, 'flag': '🇾🇪'},
    {'name': 'الحديدة', 'lat': 14.7978, 'lng': 42.9540, 'flag': '🇾🇪'},
    {'name': 'إب', 'lat': 13.9748, 'lng': 44.1790, 'flag': '🇾🇪'},
    {'name': 'مأرب', 'lat': 15.4680, 'lng': 45.3240, 'flag': '🇾🇪'},
    {'name': 'الرياض', 'lat': 24.7136, 'lng': 46.6753, 'flag': '🇸🇦'},
    {'name': 'جدة', 'lat': 21.4858, 'lng': 39.1925, 'flag': '🇸🇦'},
    {'name': 'دبي', 'lat': 25.2048, 'lng': 55.2708, 'flag': '🇦🇪'},
    {'name': 'القاهرة', 'lat': 30.0444, 'lng': 31.2357, 'flag': '🇪🇬'},
    {'name': 'عمّان', 'lat': 31.9454, 'lng': 35.9284, 'flag': '🇯🇴'},
    {'name': 'بيروت', 'lat': 33.8938, 'lng': 35.5018, 'flag': '🇱🇧'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ════ الماركرز ════
  Set<Marker> get _markers {
    final m = <Marker>{};
    for (int i = 0; i < _boundaryPoints.length; i++) {
      m.add(Marker(
        markerId: MarkerId('pt_$i'),
        position: _boundaryPoints[i],
        icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange),
        anchor: const Offset(0.5, 0.5),
        infoWindow:
            InfoWindow(title: i == 0 ? '🟢 نقطة البداية' : '📍 نقطة ${i + 1}'),
      ));
    }
    return m;
  }

  // ════ المضلع ════
  Set<Polygon> get _polygons {
    if (_boundaryPoints.length < 3) return {};
    return {
      Polygon(
        polygonId: const PolygonId('land'),
        points: _boundaryPoints,
        fillColor: AppTheme.accent.withValues(alpha: 0.2),
        strokeColor: AppTheme.accent,
        strokeWidth: 3,
      ),
    };
  }

  // ════ الخط المؤقت ════
  Set<Polyline> get _polylines {
    if (_boundaryPoints.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('line'),
        points: _boundaryPoints,
        color: AppTheme.accent,
        width: 3,
      ),
    };
  }

  void _selectCity(Map<String, dynamic> city) {
    setState(() {
      _selectedCity = city['name'] as String;
      _boundaryPoints.clear();
      _step = 1;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(city['lat'] as double, city['lng'] as double), 18));
    });
  }

  void _onMapTap(LatLng pos) {
    HapticFeedback.selectionClick();
    setState(() => _boundaryPoints.add(pos));
  }

  void _undoPoint() {
    if (_boundaryPoints.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _boundaryPoints.removeLast());
  }

  void _resetDrawing() {
    HapticFeedback.mediumImpact();
    setState(() {
      _boundaryPoints.clear();
      if (_step == 2) _step = 1;
    });
  }

  void _closePolygon() {
    if (_boundaryPoints.length < 3) {
      _showError('يرجى تحديد 3 نقاط على الأقل');
      return;
    }
    HapticFeedback.mediumImpact();
    final area = _calcArea(_boundaryPoints);
    final bounds = _calcBounds(_boundaryPoints);
    final center = _calcCenter(_boundaryPoints);
    final len = _dist(LatLng(bounds['minLat']!, bounds['minLng']!),
        LatLng(bounds['maxLat']!, bounds['minLng']!));
    final wid = _dist(LatLng(bounds['minLat']!, bounds['minLng']!),
        LatLng(bounds['minLat']!, bounds['maxLng']!));
    setState(() {
      _calculatedArea = area;
      _calculatedLength = len;
      _calculatedWidth = wid;
      _landCenter = center;
      _step = 2;
    });
  }

  // Shoelace formula → متر مربع
  double _calcArea(List<LatLng> pts) {
    if (pts.length < 3) return 0;
    const mPerDegLat = 111320.0;
    final refLat = pts[0].latitude;
    final mPerDegLng = mPerDegLat * math.cos(refLat * math.pi / 180);
    final xs =
        pts.map((p) => (p.longitude - pts[0].longitude) * mPerDegLng).toList();
    final ys =
        pts.map((p) => (p.latitude - pts[0].latitude) * mPerDegLat).toList();
    double a = 0;
    for (int i = 0; i < pts.length; i++) {
      final j = (i + 1) % pts.length;
      a += xs[i] * ys[j] - xs[j] * ys[i];
    }
    return a.abs() / 2;
  }

  Map<String, double> _calcBounds(List<LatLng> pts) {
    double mnLat = pts[0].latitude, mxLat = pts[0].latitude;
    double mnLng = pts[0].longitude, mxLng = pts[0].longitude;
    for (final p in pts) {
      if (p.latitude < mnLat) mnLat = p.latitude;
      if (p.latitude > mxLat) mxLat = p.latitude;
      if (p.longitude < mnLng) mnLng = p.longitude;
      if (p.longitude > mxLng) mxLng = p.longitude;
    }
    return {'minLat': mnLat, 'maxLat': mxLat, 'minLng': mnLng, 'maxLng': mxLng};
  }

  LatLng _calcCenter(List<LatLng> pts) {
    final lat = pts.map((p) => p.latitude).reduce((a, b) => a + b) / pts.length;
    final lng =
        pts.map((p) => p.longitude).reduce((a, b) => a + b) / pts.length;
    return LatLng(lat, lng);
  }

  double _dist(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;
    final s = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(a.latitude * math.pi / 180) *
            math.cos(b.latitude * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * R * math.atan2(math.sqrt(s), math.sqrt(1 - s));
  }

  void _proceedToPlans() {
    if (_calculatedArea <= 0 || _landCenter == null) {
      _showError('يرجى رسم حدود الأرضية أولاً');
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LandPlanScreen(
            city: _selectedCity,
            location: _landCenter!,
            length: _calculatedLength,
            width: _calculatedWidth,
            floors: _floors,
            buildingUse: _buildingUse,
            landBoundary: _boundaryPoints,
            calculatedArea: _calculatedArea,
          ),
        ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.cairo()),
      backgroundColor: AppTheme.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _appBar(),
      body: AnimatedSwitcher(
        duration: 350.ms,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0.05, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        child: switch (_step) {
          0 => _cityStep(),
          1 => _drawStep(),
          _ => _confirmStep(),
        },
      ),
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppTheme.textPrimary, size: 20),
          onPressed: _step > 0
              ? () {
                  HapticFeedback.selectionClick();
                  setState(() => _step--);
                }
              : () => Navigator.pop(context),
        ),
        title: Text(
          _step == 0
              ? 'اختر المدينة'
              : _step == 1
                  ? 'ارسم حدود الأرضية'
                  : 'تأكيد وخيارات البناء',
          style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary),
        ),
        actions: _step == 1 && _boundaryPoints.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.undo, color: AppTheme.accent),
                  onPressed: _undoPoint,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.danger),
                  onPressed: _resetDrawing,
                ),
              ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Row(
              children: List.generate(
                  3,
                  (i) => Expanded(
                        child: AnimatedContainer(
                          duration: 400.ms,
                          height: 3,
                          color: i <= _step ? AppTheme.accent : AppTheme.border,
                        ),
                      ))),
        ),
      );

  // ══════════ الخطوة 1: اختيار المدينة ══════════
  Widget _cityStep() {
    final filtered = _cities
        .where((c) =>
            _searchQuery.isEmpty ||
            (c['name'] as String).contains(_searchQuery))
        .toList();

    return Column(key: const ValueKey('city'), children: [
      Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.cairo(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'ابحث عن مدينة...',
            hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
            prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ).animate().fadeIn().slideY(begin: -0.2),
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppTheme.accent.withValues(alpha: 0.08),
            AppTheme.accent.withValues(alpha: 0.03)
          ]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Transform.scale(
                scale: 0.9 + 0.1 * _pulseCtrl.value,
                child: const Text('🛰️', style: TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('إسقاط جوي ذكي',
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accent)),
                Text(
                    'ارسم حدود أرضيتك على الخريطة، وسيتم قياسها تلقائياً وتوليد مخططات معمارية مناسبة',
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: AppTheme.textSub, height: 1.4)),
              ])),
        ]),
      ).animate(delay: 100.ms).fadeIn(),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemCount: filtered.length,
          itemBuilder: (ctx, i) => _CityCard(
            city: filtered[i],
            index: i,
            onTap: () => _selectCity(filtered[i]),
          ),
        ),
      ),
    ]);
  }

  // ══════════ الخطوة 2: رسم الحدود (أي شكل - أي عدد نقاط) ══════════
  Widget _drawStep() {
    final cityData = _cities.firstWhere((c) => c['name'] == _selectedCity,
        orElse: () => _cities.first);
    final initPos =
        LatLng(cityData['lat'] as double, cityData['lng'] as double);
    final liveArea =
        _boundaryPoints.length >= 3 ? _calcArea(_boundaryPoints) : 0.0;
    final n = _boundaryPoints.length;

    return Stack(key: const ValueKey('draw'), children: [
      // ══ الخريطة ══
      GoogleMap(
        initialCameraPosition: CameraPosition(target: initPos, zoom: 18),
        mapType: MapType.hybrid,
        onMapCreated: (c) => _mapController = c,
        onTap: _onMapTap,
        markers: _markers,
        polygons: _polygons,
        polylines: _polylines,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        compassEnabled: true,
      ),

      // ══ بانر التعليمات العلوي ══
      Positioned(
        top: 12,
        left: 12,
        right: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.background.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: n == 0
                    ? AppTheme.border
                    : n < 3
                        ? AppTheme.accent.withValues(alpha: 0.4)
                        : AppTheme.success.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35), blurRadius: 14)
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // السطر الأول: أيقونة + نص الحالة
            Row(children: [
              _StatusIcon(n: n),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                n == 0
                    ? 'انقر على حدود الأرضية لتحديد زواياها'
                    : n < 3
                        ? 'أضف ${3 - n} نقطة إضافية على الأقل ثم أغلق الشكل'
                        : 'يمكنك إضافة المزيد من النقاط أو إغلاق الشكل',
                style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: n >= 3 ? AppTheme.success : AppTheme.textPrimary),
              )),
            ]),

            if (n > 0) ...[
              const SizedBox(height: 10),
              // شريط إحصائيات مباشرة
              Row(children: [
                _InfoBadge(
                  icon: '📍',
                  label: 'النقاط',
                  value: '$n',
                  color: AppTheme.accent,
                ),
                const SizedBox(width: 8),
                if (liveArea > 0)
                  _InfoBadge(
                    icon: '📐',
                    label: 'المساحة',
                    value: '${liveArea.toStringAsFixed(0)} م²',
                    color: AppTheme.info,
                  ),
                const Spacer(),
                // مؤشر حالة الشكل
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (n >= 3 ? AppTheme.success : AppTheme.accent)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: (n >= 3 ? AppTheme.success : AppTheme.accent)
                            .withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    n < 3 ? 'يحتاج ${3 - n} نقطة' : 'جاهز ✓',
                    style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: n >= 3 ? AppTheme.success : AppTheme.accent),
                  ),
                ),
              ]),
            ],

            // تلميح: أنواع الأراضي
            if (n == 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Text('💡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(
                    'مناسب لأي شكل: مستطيل، مثلث، شكل L، أو أي أرضية غير منتظمة — بلا حد للنقاط',
                    style: GoogleFonts.cairo(
                        fontSize: 10, color: AppTheme.textMuted, height: 1.4),
                  )),
                ]),
              ),
            ],
          ]),
        ).animate().slideY(begin: -0.3).fadeIn(),
      ),

      // ══ عداد النقاط المرئي على الجانب ══
      if (n > 0)
        Positioned(
          top: 160,
          right: 12,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // زر تراجع
            _MapActionBtn(
              icon: Icons.undo_rounded,
              tooltip: 'تراجع عن آخر نقطة',
              color: AppTheme.accent,
              onTap: _undoPoint,
            ),
            const SizedBox(height: 8),
            // زر مسح الكل
            _MapActionBtn(
              icon: Icons.delete_outline_rounded,
              tooltip: 'مسح كل النقاط',
              color: AppTheme.danger,
              onTap: _resetDrawing,
            ),
          ]),
        ),

      // ══ شريط الأزرار السفلي ══
      Positioned(
        bottom: 24,
        left: 16,
        right: 16,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // زر إضافة نقطة في المنتصف (اختياري للتوضيح)
          if (n >= 3) ...[
            // زر "أضف نقطة أخرى" لتشجيع الإضافة قبل الإغلاق
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('انقر على الخريطة لإضافة نقطة جديدة',
                            style: GoogleFonts.cairo()),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppTheme.surface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_location_alt_outlined,
                                size: 16, color: AppTheme.textSub),
                            const SizedBox(width: 6),
                            Text('انقر على الخريطة لإضافة نقطة',
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: AppTheme.textSub,
                                    fontWeight: FontWeight.w600)),
                          ]),
                    ),
                  ),
                ),
              ]),
            ),
            // زر إغلاق الحدود
            GoldenButton(
              label: 'إغلاق الحدود وقياس الأرضية ($n نقطة)',
              icon: '📐',
              onTap: _closePolygon,
            ).animate().scale(begin: const Offset(0.95, 0.95)),
          ],

          // رسالة توجيه قبل 3 نقاط
          if (n < 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.97),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(n == 0 ? '👆' : '${['1️⃣', '2️⃣', '3️⃣'][n < 3 ? n : 0]}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n == 0
                          ? 'ابدأ بالنقر على أول زاوية في الأرضية'
                          : n == 1
                              ? 'انقر على الزاوية الثانية'
                              : 'انقر على الزاوية الثالثة لإكمال الشكل',
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700),
                    ),
                    if (n == 0)
                      Text(
                        'يدعم أي شكل: مستطيل، L، مثلث، أو شكل غير منتظم',
                        style: GoogleFonts.cairo(
                            fontSize: 10, color: AppTheme.textMuted),
                      ),
                  ],
                )),
              ]),
            ),
        ]),
      ),
    ]);
  }

  // ══════════ الخطوة 3: التأكيد وخيارات البناء ══════════
  Widget _confirmStep() {
    return SingleChildScrollView(
      key: const ValueKey('confirm'),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // بطاقة نتائج القياس
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.success.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.success.withValues(alpha: 0.06),
                  blurRadius: 16)
            ],
          ),
          child: Column(children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('✅', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('تم قياس الأرضية بنجاح',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.success)),
                    Text(
                        '$_selectedCity • ${_boundaryPoints.length} نقطة حدودية',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ])),
              GestureDetector(
                onTap: _resetDrawing,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.edit, size: 13, color: AppTheme.danger),
                    const SizedBox(width: 4),
                    Text('إعادة الرسم',
                        style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: AppTheme.danger,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Expanded(
                    child: _Stat(
                        icon: '📐',
                        label: 'المساحة',
                        value: '${_calculatedArea.toStringAsFixed(1)} م²',
                        accent: true)),
                Container(width: 1, height: 40, color: AppTheme.border),
                Expanded(
                    child: _Stat(
                        icon: '↕️',
                        label: 'الطول',
                        value: '${_calculatedLength.toStringAsFixed(1)} م')),
                Container(width: 1, height: 40, color: AppTheme.border),
                Expanded(
                    child: _Stat(
                        icon: '↔️',
                        label: 'العرض',
                        value: '${_calculatedWidth.toStringAsFixed(1)} م')),
              ]),
            ),
          ]),
        ).animate().fadeIn().slideY(begin: -0.1),

        const SizedBox(height: 20),

        // عدد الأدوار
        Text('عدد الأدوار',
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary))
            .animate(delay: 100.ms)
            .fadeIn(),
        const SizedBox(height: 12),

        Row(
          children: List.generate(
              5,
              (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _floors = i + 1);
                        },
                        child: AnimatedContainer(
                          duration: 250.ms,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _floors == i + 1
                                ? AppTheme.accent
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _floors == i + 1
                                    ? AppTheme.accent
                                    : AppTheme.border),
                          ),
                          child: Column(children: [
                            Text('${i + 1}',
                                style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: _floors == i + 1
                                        ? Colors.black
                                        : AppTheme.textPrimary)),
                            Text('دور',
                                style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    color: _floors == i + 1
                                        ? Colors.black87
                                        : AppTheme.textMuted)),
                          ]),
                        ),
                      ),
                    ),
                  )),
        ).animate(delay: 120.ms).fadeIn(),

        const SizedBox(height: 20),

        // نوع الاستخدام
        Text('نوع الاستخدام',
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary))
            .animate(delay: 140.ms)
            .fadeIn(),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['سكني', 'تجاري', 'مختلط', 'مكتبي']
              .map(
                (use) => GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _buildingUse = use);
                  },
                  child: AnimatedContainer(
                    duration: 250.ms,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _buildingUse == use
                          ? AppTheme.accent.withValues(alpha: 0.15)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _buildingUse == use
                              ? AppTheme.accent
                              : AppTheme.border),
                    ),
                    child: Text(use,
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _buildingUse == use
                                ? AppTheme.accent
                                : AppTheme.textSub,
                            fontWeight: _buildingUse == use
                                ? FontWeight.w700
                                : FontWeight.w500)),
                  ),
                ),
              )
              .toList(),
        ).animate(delay: 160.ms).fadeIn(),

        const SizedBox(height: 16),

        // ملخص
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppTheme.accent.withValues(alpha: 0.3))),
          child: Row(children: [
            Expanded(
                child: _Stat(
                    icon: '🏢',
                    label: 'إجمالي البناء',
                    value:
                        '${(_calculatedArea * _floors).toStringAsFixed(0)} م²',
                    accent: true)),
            Container(width: 1, height: 40, color: AppTheme.border),
            Expanded(
                child: _Stat(
                    icon: '🏗️', label: 'الأدوار', value: '$_floors دور')),
            Container(width: 1, height: 40, color: AppTheme.border),
            Expanded(
                child:
                    _Stat(icon: '🏠', label: 'الاستخدام', value: _buildingUse)),
          ]),
        ).animate(delay: 180.ms).fadeIn(),

        const SizedBox(height: 24),

        GoldenButton(
          label: 'توليد المخططات المعمارية 🏗️',
          icon: '✨',
          onTap: _proceedToPlans,
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

        const SizedBox(height: 8),
        Center(
            child: Text('سيتم اقتراح مخططات تناسب أبعاد أرضيتك تماماً',
                style: GoogleFonts.cairo(
                    fontSize: 10, color: AppTheme.textMuted))),
        const SizedBox(height: 20),
      ]),
    );
  }
}

// ════ Widgets مساعدة ════

// ════════════════════════════════════════════════════════
//  أيقونة الحالة التفاعلية
// ════════════════════════════════════════════════════════
class _StatusIcon extends StatelessWidget {
  final int n;
  const _StatusIcon({required this.n});

  @override
  Widget build(BuildContext context) {
    if (n == 0) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('✏️', style: TextStyle(fontSize: 16))),
      );
    }
    if (n < 3) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.5), width: 2),
        ),
        child: Center(
            child: Text(
          '$n',
          style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppTheme.accent),
        )),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
            color: AppTheme.success.withValues(alpha: 0.5), width: 2),
      ),
      child: Center(
          child: Text(
        '$n',
        style: GoogleFonts.cairo(
            fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.success),
      )),
    );
  }
}

// ════════════════════════════════════════════════════════
//  شارة معلومة مع أيقونة وقيمة
// ════════════════════════════════════════════════════════
class _InfoBadge extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _InfoBadge(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 5),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: GoogleFonts.cairo(
                      fontSize: 12, fontWeight: FontWeight.w800, color: color)),
              Text(label,
                  style: GoogleFonts.cairo(
                      fontSize: 9, color: AppTheme.textMuted)),
            ]),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════
//  زر دائري على الخريطة
// ════════════════════════════════════════════════════════
class _MapActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _MapActionBtn(
      {required this.icon,
      required this.tooltip,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.background.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25), blurRadius: 8)
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String icon, text;
  final bool green;
  const _Chip({required this.icon, required this.text, this.green = false});

  @override
  Widget build(BuildContext context) {
    final color = green ? AppTheme.success : AppTheme.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.cairo(
                fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String icon, label, value;
  final bool accent;
  const _Stat(
      {required this.icon,
      required this.label,
      required this.value,
      this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(value,
          style: GoogleFonts.cairo(
              fontSize: accent ? 13 : 12,
              fontWeight: FontWeight.w800,
              color: accent ? AppTheme.accent : AppTheme.textPrimary)),
      Text(label,
          style: GoogleFonts.cairo(fontSize: 9, color: AppTheme.textMuted),
          textAlign: TextAlign.center),
    ]);
  }
}

class _CityCard extends StatelessWidget {
  final Map<String, dynamic> city;
  final int index;
  final VoidCallback onTap;
  const _CityCard(
      {required this.city, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          Text(city['flag'] as String, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(city['name'] as String,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary))),
          const Icon(Icons.arrow_forward_ios,
              size: 12, color: AppTheme.textMuted),
          const SizedBox(width: 8),
        ]),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn()
        .slideX(begin: 0.1);
  }
}
