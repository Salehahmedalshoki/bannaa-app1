// ══════════════════════════════════════════════════════════
//  screens/land_plan_screen.dart
//  🏗️ توليد المخططات المعمارية + حساب التكاليف
// ══════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'land_cost_screen.dart';

// ════════════════════════════════════════════════════════
//  موديل المخطط المعماري
// ════════════════════════════════════════════════════════
class ArchitecturalPlan {
  final String id;
  final String name;
  final String description;
  final String style;
  final String icon;
  final List<String> features;
  final double efficiencyScore; // نسبة استغلال المساحة
  final Map<String, double> roomDistribution; // توزيع الغرف

  const ArchitecturalPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.style,
    required this.icon,
    required this.features,
    required this.efficiencyScore,
    required this.roomDistribution,
  });
}

// ════════════════════════════════════════════════════════
//  شاشة المخططات والتكاليف
// ════════════════════════════════════════════════════════
class LandPlanScreen extends StatefulWidget {
  final String city;
  final LatLng location;
  final double length, width;
  final int floors;
  final String buildingUse;
  // البيانات الجديدة من رسم الحدود
  final List<LatLng> landBoundary;
  final double calculatedArea;

  const LandPlanScreen({
    super.key,
    required this.city,
    required this.location,
    required this.length,
    required this.width,
    required this.floors,
    required this.buildingUse,
    this.landBoundary = const [],
    this.calculatedArea = 0,
  });

  @override
  State<LandPlanScreen> createState() => _LandPlanScreenState();
}

class _LandPlanScreenState extends State<LandPlanScreen>
    with TickerProviderStateMixin {
  bool _isGenerating = true;
  List<ArchitecturalPlan> _plans = [];
  int _selectedPlanIndex = 0;
  late AnimationController _loadingCtrl;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _loadingCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();

    _generatePlans();
  }

  @override
  void dispose() {
    _loadingCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── توليد المخططات المعمارية (محاكاة ذكاء اصطناعي) ──
  Future<void> _generatePlans() async {
    // محاكاة وقت المعالجة
    await Future.delayed(const Duration(seconds: 3));

    // استخدام المساحة المحسوبة من الحدود إن وُجدت
    final area = widget.calculatedArea > 0
        ? widget.calculatedArea
        : widget.length * widget.width;
    final plans = _buildPlansForLand(area, widget.floors, widget.buildingUse);

    if (mounted) {
      setState(() {
        _plans = plans;
        _isGenerating = false;
      });
      _loadingCtrl.stop();
    }
  }

  // ── بناء المخططات حسب مساحة الأرض ──
  List<ArchitecturalPlan> _buildPlansForLand(
      double area, int floors, String use) {
    final isSmall = area < 150;
    final isMedium = area >= 150 && area < 350;
    final isCommercial = use == 'تجاري' || use == 'مكتبي';

    if (isCommercial) {
      return [
        ArchitecturalPlan(
          id: 'com1',
          name: 'مبنى تجاري حديث',
          description: 'واجهة زجاجية مع أدوار مكتبية مفتوحة وخدمات مشتركة',
          style: 'حديث',
          icon: '🏢',
          features: [
            'واجهة زجاجية',
            'لوبي رئيسي',
            'مصعدان',
            'مواقف سيارات',
            'نظام أمان متكامل'
          ],
          efficiencyScore: 0.82,
          roomDistribution: {'مكاتب': 65, 'ممرات': 15, 'خدمات': 10, 'لوبي': 10},
        ),
        ArchitecturalPlan(
          id: 'com2',
          name: 'مجمع تجاري مختلط',
          description: 'محلات تجارية بالأدوار السفلية ومكاتب بالعلوية',
          style: 'مختلط',
          icon: '🏬',
          features: [
            'محلات أرضي',
            'مكاتب علوية',
            'مخازن خلفية',
            'بوابة خلفية للتوريد'
          ],
          efficiencyScore: 0.78,
          roomDistribution: {
            'محلات': 50,
            'مكاتب': 30,
            'مخازن': 10,
            'ممرات': 10
          },
        ),
        ArchitecturalPlan(
          id: 'com3',
          name: 'برج مكتبي',
          description: 'تصميم عمودي مضغوط لتعظيم المساحة المكتبية',
          style: 'برجي',
          icon: '🏙️',
          features: [
            'طابق مكتبي كامل',
            'غرفة اجتماعات',
            'مطبخ مشترك',
            'إطلالات بانورامية'
          ],
          efficiencyScore: 0.88,
          roomDistribution: {'مكاتب': 75, 'اجتماعات': 10, 'خدمات': 15},
        ),
      ];
    }

    if (isSmall) {
      return [
        ArchitecturalPlan(
          id: 'sm1',
          name: 'فيلا أنيقة',
          description: 'تصميم ذكي يستغل كل متر بكفاءة عالية مع مساحات مريحة',
          style: 'كلاسيكي',
          icon: '🏠',
          features: [
            'غرفتان رئيسيتان',
            'صالة معيشة',
            'مطبخ أوبن',
            '2 حمام',
            'فناء خلفي'
          ],
          efficiencyScore: 0.87,
          roomDistribution: {
            'غرف نوم': 40,
            'معيشة': 25,
            'مطبخ': 15,
            'حمامات': 10,
            'مداخل': 10
          },
        ),
        ArchitecturalPlan(
          id: 'sm2',
          name: 'منزل دوبلكس',
          description: 'دورين منفصلين مع إمكانية الاستقلالية أو التأجير',
          style: 'دوبلكس',
          icon: '🏘️',
          features: [
            'وحدتان مستقلتان',
            'مدخلان منفصلان',
            'مطبخان',
            'إمكانية التأجير'
          ],
          efficiencyScore: 0.82,
          roomDistribution: {'غرف نوم': 45, 'معيشة': 30, 'خدمات': 25},
        ),
        ArchitecturalPlan(
          id: 'sm3',
          name: 'شقة عائلية واسعة',
          description: 'دور واحد مفتوح مع تصميم عصري وإضاءة طبيعية ممتازة',
          style: 'عصري',
          icon: '🛋️',
          features: ['3 غرف نوم', 'صالة مفتوحة كبيرة', 'بلكونة', 'غرفة غسيل'],
          efficiencyScore: 0.79,
          roomDistribution: {
            'غرف نوم': 38,
            'معيشة': 35,
            'مطبخ': 15,
            'حمامات': 12
          },
        ),
      ];
    }

    if (isMedium) {
      return [
        ArchitecturalPlan(
          id: 'md1',
          name: 'فيلا عائلية فاخرة',
          description: 'تصميم كلاسيكي فاخر مع حديقة وجراج ومسبح اختياري',
          style: 'فاخر',
          icon: '🏡',
          features: [
            '4 غرف نوم رئيسية',
            'مجلس رجال',
            'مجلس نساء',
            'غرفة خادمة',
            'جراج 3 سيارات',
            'حديقة أمامية وخلفية'
          ],
          efficiencyScore: 0.75,
          roomDistribution: {
            'غرف نوم': 35,
            'مجالس': 20,
            'معيشة': 20,
            'خارجي': 15,
            'خدمات': 10
          },
        ),
        ArchitecturalPlan(
          id: 'md2',
          name: 'بيت عربي تقليدي',
          description: 'تصميم معماري أصيل مع فناء داخلي وإيوانات',
          style: 'تراثي',
          icon: '🕌',
          features: [
            'فناء داخلي مكشوف',
            'إيوان رئيسي',
            'مشربية',
            'نوافير',
            'تهوية طبيعية ممتازة'
          ],
          efficiencyScore: 0.70,
          roomDistribution: {
            'غرف نوم': 30,
            'مجالس': 25,
            'فناء': 20,
            'ممرات': 15,
            'خدمات': 10
          },
        ),
        ArchitecturalPlan(
          id: 'md3',
          name: 'مجمع سكني بسيط',
          description:
              'وحدتان سكنيتان مستقلتان مثاليتان للإيجار أو الأسرة الممتدة',
          style: 'استثماري',
          icon: '🏢',
          features: [
            'وحدتان مستقلتان',
            'مداخل منفصلة',
            '3 غرف لكل وحدة',
            'إيجار مجزٍ'
          ],
          efficiencyScore: 0.84,
          roomDistribution: {
            'غرف نوم': 42,
            'معيشة': 28,
            'مطابخ': 15,
            'حمامات': 15
          },
        ),
      ];
    }

    // أرض كبيرة (350+ م²)
    return [
      ArchitecturalPlan(
        id: 'lg1',
        name: 'قصر عائلي فاخر',
        description: 'تصميم راقٍ مع كل المرافق والخدمات، إطلالة ومدخل مهيب',
        style: 'قصري',
        icon: '🏰',
        features: [
          '6+ غرف نوم',
          'مسبح خاص',
          'ملعب أطفال',
          'جراج 5 سيارات',
          'غرف خدم',
          'مصلى',
          'قاعة احتفالات'
        ],
        efficiencyScore: 0.68,
        roomDistribution: {
          'غرف نوم': 30,
          'مجالس': 20,
          'مرافق': 15,
          'خارجي': 20,
          'خدمات': 15
        },
      ),
      ArchitecturalPlan(
        id: 'lg2',
        name: 'مجمع متعدد الوحدات',
        description: 'عمارة سكنية متعددة الطوابق بعائد إيجاري مرتفع',
        style: 'استثماري',
        icon: '🏗️',
        features: ['6-8 شقق', 'مصعد', 'موقف سيارات', 'حارس', 'نظام أمان'],
        efficiencyScore: 0.88,
        roomDistribution: {'شقق سكنية': 70, 'ممرات': 15, 'خدمات': 15},
      ),
      ArchitecturalPlan(
        id: 'lg3',
        name: 'مجمع صحي أو تعليمي',
        description: 'مناسب للعيادات والمدارس والمراكز المتخصصة',
        style: 'متخصص',
        icon: '🏥',
        features: [
          'قاعات واسعة',
          'انتظار كبير',
          'مواقف',
          'مداخل متعددة',
          'بنية تحتية متكاملة'
        ],
        efficiencyScore: 0.80,
        roomDistribution: {
          'قاعات رئيسية': 60,
          'انتظار': 20,
          'إدارة': 10,
          'خدمات': 10
        },
      ),
    ];
  }

  // ══════════════════════════════════════════════════════
  //  بناء الواجهة
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('المخططات المعمارية',
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
      ),
      body: _isGenerating ? _buildLoadingView() : _buildPlansView(),
    );
  }

  // ── شاشة التوليد ──────────────────────────────────────
  Widget _buildLoadingView() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ── رسم متحرك للذكاء الاصطناعي ──
        AnimatedBuilder(
          animation: _loadingCtrl,
          builder: (_, __) {
            return Stack(alignment: Alignment.center, children: [
              Transform.rotate(
                angle: _loadingCtrl.value * 2 * math.pi,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(colors: [
                        AppTheme.accent,
                        AppTheme.accentDark,
                        AppTheme.accent.withValues(alpha: 0)
                      ])),
                ),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                    color: AppTheme.background, shape: BoxShape.circle),
                child: const Center(
                    child: Text('🏗️', style: TextStyle(fontSize: 34))),
              ),
            ]);
          },
        ),
        const SizedBox(height: 24),
        Text('جارٍ توليد المخططات...',
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 800.ms),
        const SizedBox(height: 10),
        Text(
            'يحلل الذكاء الاصطناعي أبعاد أرضيتك\n'
            'ويولّد أفضل المخططات المعمارية',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
                fontSize: 12, color: AppTheme.textMuted, height: 1.6)),
        const SizedBox(height: 32),
        // ── خطوات المعالجة ──
        for (final step in [
          widget.calculatedArea > 0
              ? '🔍 تحليل مساحة الأرض: ${(widget.calculatedArea).toStringAsFixed(0)} م² (مقاسة)'
              : '🔍 تحليل أبعاد الأرض: ${widget.length}×${widget.width} م',
          '🧱 دراسة الاستخدام: ${widget.buildingUse}',
          '🏢 تحليل ${widget.floors} ${widget.floors == 1 ? "دور" : "أدوار"}',
          '✨ توليد المخططات الأمثل...',
        ])
          _LoadingStep(text: step),
      ]),
    );
  }

  // ── عرض المخططات ──────────────────────────────────────
  Widget _buildPlansView() {
    return Column(children: [
      // ── رأس المعلومات ──
      _buildInfoHeader(),
      // ── قائمة المخططات ──
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: _plans.length,
          itemBuilder: (ctx, i) => _PlanCard(
            plan: _plans[i],
            index: i,
            isSelected: i == _selectedPlanIndex,
            onSelect: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPlanIndex = i);
            },
          ),
        ),
      ),
      // ── زر المتابعة ──
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            border: const Border(top: BorderSide(color: AppTheme.border))),
        child: GoldenButton(
          label: 'حساب الكميات والتكاليف',
          icon: '💰',
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LandCostScreen(
                  city: widget.city,
                  location: widget.location,
                  length: widget.length,
                  width: widget.width,
                  floors: widget.floors,
                  buildingUse: widget.buildingUse,
                  selectedPlan: _plans[_selectedPlanIndex],
                ),
              )),
        ),
      ),
    ]);
  }

  Widget _buildInfoHeader() {
    // استخدام المساحة المحسوبة من الحدود إن وُجدت
    final area = widget.calculatedArea > 0
        ? widget.calculatedArea
        : widget.length * widget.width;
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3))),
      child: Row(children: [
        const Text('✅', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(
                widget.calculatedArea > 0
                    ? '${widget.city} • ${area.toStringAsFixed(0)} م² (مقاسة من الخريطة) • ${widget.floors} دور'
                    : '${widget.city} • ${widget.length}×${widget.width}م • ${area.toStringAsFixed(0)}م² × ${widget.floors} دور',
                style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppTheme.textSub,
                    fontWeight: FontWeight.w600))),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Text('${_plans.length} مخططات',
                style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: AppTheme.success,
                    fontWeight: FontWeight.w700))),
      ]),
    ).animate().fadeIn();
  }
}

// ════════════════════════════════════════════════════════
//  بطاقة المخطط المعماري
// ════════════════════════════════════════════════════════
class _PlanCard extends StatelessWidget {
  final ArchitecturalPlan plan;
  final int index;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PlanCard(
      {required this.plan,
      required this.index,
      required this.isSelected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? AppTheme.accent : AppTheme.border,
                width: isSelected ? 2 : 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppTheme.accent.withValues(alpha: 0.15),
                        blurRadius: 12)
                  ]
                : null),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── الرأس ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accent.withValues(alpha: 0.15)
                          : AppTheme.accentGlow,
                      borderRadius: BorderRadius.circular(13)),
                  child: Center(
                      child: Text(plan.icon,
                          style: const TextStyle(fontSize: 26)))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name,
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(plan.description,
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.textMuted, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              )),
              if (isSelected)
                Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                        color: AppTheme.accent, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.check, size: 14, color: Colors.black)),
            ]),
          ),

          // ── نسبة الكفاءة ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              Text('كفاءة الاستغلال:',
                  style: GoogleFonts.cairo(
                      fontSize: 10, color: AppTheme.textMuted)),
              const SizedBox(width: 8),
              Expanded(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                          value: plan.efficiencyScore,
                          backgroundColor: AppTheme.border,
                          valueColor: AlwaysStoppedAnimation(
                              plan.efficiencyScore > 0.8
                                  ? AppTheme.success
                                  : AppTheme.accent),
                          minHeight: 5))),
              const SizedBox(width: 8),
              Text('${(plan.efficiencyScore * 100).round()}%',
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent)),
            ]),
          ),

          const SizedBox(height: 12),

          // ── المزايا ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: plan.features
                    .take(4)
                    .map(
                      (f) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(f,
                            style: GoogleFonts.cairo(
                                fontSize: 10, color: AppTheme.textSub)),
                      ),
                    )
                    .toList()),
          ),

          // ── تسمية النمط ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent.withValues(alpha: 0.06)
                    : AppTheme.background,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15))),
            child: Center(
                child: Text('🎨 نمط: ${plan.style}',
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppTheme.textSub,
                        fontWeight: FontWeight.w600))),
          ),
        ]),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn()
        .slideY(begin: 0.15);
  }
}

// ════════════════════════════════════════════════════════
//  خطوة التحميل
// ════════════════════════════════════════════════════════
class _LoadingStep extends StatefulWidget {
  final String text;
  const _LoadingStep({required this.text});

  @override
  State<_LoadingStep> createState() => _LoadingStepState();
}

class _LoadingStepState extends State<_LoadingStep> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration(milliseconds: 600 + (math.Random().nextInt(4) * 500)), () {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
      child: Row(children: [
        AnimatedSwitcher(
          duration: 300.ms,
          child: _done
              ? const Text('✅',
                  key: ValueKey('done'), style: TextStyle(fontSize: 14))
              : const SizedBox(
                  width: 14,
                  height: 14,
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.accent))),
        ),
        const SizedBox(width: 10),
        Text(widget.text,
            style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textSub)),
      ]),
    );
  }
}
