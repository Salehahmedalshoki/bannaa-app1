// ══════════════════════════════════════════════════════════
//  screens/onboarding_screen.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة:
//  ✅ #1 try/catch شامل في _finish() — لا تجميد عند فشل Hive
//  ✅ #2 mounted check قبل أي عملية async وبعدها
//  ✅ #3 guard ضد الضغط المتكرر (_finishing flag)
//  ✅ #4 زر "تخطي" يحترم SafeArea على جميع الأجهزة
//  ✅ #5 سهم الزر يتكيف مع اتجاه RTL/LTR تلقائياً
//  ✅ #6 padding سفلي يعتمد على MediaQuery بدل قيمة ثابتة
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current = 0;

  // ✅ #3 — guard ضد الضغط المتكرر
  bool _finishing = false;

  static const _pages = [
    _OnboardPage(
      emoji: '🏗️',
      title: 'مرحباً في بنّاء',
      subtitle: 'تطبيقك الذكي لحساب\nكميات الخرسانة ومواد البناء',
      color: Color(0xFFF59E0B),
      features: [],
    ),
    _OnboardPage(
      emoji: '📐',
      title: 'أدخل الأبعاد بسهولة',
      subtitle: 'أدخل أبعاد أي مكوّن بنائي\nوسيحسب التطبيق كل شيء تلقائياً',
      color: Color(0xFF3B82F6),
      features: [
        ('🏛️', 'الأعمدة والكمرات'),
        ('⬜', 'الأسقف والبلاطات'),
        ('🔲', 'الأساسات والجدران'),
      ],
    ),
    _OnboardPage(
      emoji: '🧮',
      title: 'نتائج دقيقة فورية',
      subtitle: 'احصل على كميات جميع المواد\nوتقدير دقيق للتكاليف في ثوانٍ',
      color: Color(0xFF10B981),
      features: [
        ('🪣', 'الأسمنت والرمل والحجر'),
        ('⚙️', 'الحديد والتسليح'),
        ('💰', 'تقدير التكاليف الكاملة'),
      ],
    ),
    _OnboardPage(
      emoji: '📄',
      title: 'تقارير احترافية',
      subtitle: 'صدّر تقاريرك كـ PDF\nوشاركها مع فريقك أو العميل',
      color: Color(0xFFF59E0B),
      features: [
        ('💾', 'حفظ المشاريع محلياً'),
        ('📤', 'مشاركة التقارير'),
        ('🔄', 'تحديث الأسعار يدوياً'),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _pageCtrl.nextPage(duration: 400.ms, curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  // ✅ #1 #2 #3 — _finish() آمنة بالكامل
  Future<void> _finish() async {
    if (_finishing) return; // ✅ #3 منع الضغط المتكرر
    setState(() => _finishing = true);

    // ✅ #1 — try/catch حول كل عمليات Hive
    try {
      final box = await Hive.openBox('settings');
      // ✅ #2 — تحقق mounted قبل أي عملية تعتمد على context
      if (!mounted) return;
      await box.put('onboarding_done', true);
    } catch (_) {
      // فشل Hive لا يوقف المستخدم — يكمل للتسجيل
      // عند الفتح التالي ستظهر onboarding مرة أخرى وهذا مقبول
    }

    // ✅ #2 — تحقق mounted قبل Navigator
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: 500.ms,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ #4 — قراءة SafeArea padding مرة واحدة هنا
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // ── الصفحات ──────────────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) =>
                _PageView(page: _pages[i], isActive: i == _current),
          ),

          // ── أزرار التحكم السفلية ─────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildControls(context),
          ),

          // ── زر تخطي — يحترم SafeArea ✅ #4 ─────────────
          if (_current < _pages.length - 1)
            Positioned(
              // topPadding + 12 بدل القيمة الثابتة 52
              top: topPadding + 12,
              left: 20,
              child: GestureDetector(
                onTap: _finishing ? null : _finish,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    'تخطي',
                    style: GoogleFonts.cairo(
                        fontSize: 12, color: AppTheme.textMuted),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    // ✅ #6 — padding سفلي يعتمد على safe area الجهاز
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isLastPage = _current == _pages.length - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.background.withValues(alpha: 0.97),
          ],
        ),
      ),
      child: Column(children: [
        // ── مؤشرات الصفحة ──────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: 300.ms,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? _pages[_current].color : AppTheme.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // ── زر التالي / ابدأ ───────────────────────────────
        GestureDetector(
          onTap: _finishing ? null : _next,
          child: AnimatedContainer(
            duration: 300.ms,
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _pages[_current].color,
                  _pages[_current].color.withValues(alpha: 0.75),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _pages[_current].color.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  isLastPage ? 'ابدأ الآن' : 'التالي',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                // ✅ #5 — السهم يتكيف مع اتجاه التطبيق RTL/LTR
                Icon(
                  isLastPage
                      ? Icons.check_rounded
                      : (isRtl
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.arrow_forward_ios_rounded),
                  color: Colors.black,
                  size: 14,
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  _PageView — صفحة Onboarding واحدة
// ══════════════════════════════════════════════════════════
class _PageView extends StatelessWidget {
  final _OnboardPage page;
  final bool isActive;
  const _PageView({required this.page, required this.isActive});

  @override
  Widget build(BuildContext context) {
    // ✅ #6 — حساب المساحة المتاحة ديناميكياً
    final bottomSpace = MediaQuery.of(context).size.height * 0.22;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 0.9,
          colors: [
            page.color.withValues(alpha: 0.15),
            AppTheme.background,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(28, 60, 28, bottomSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── الأيقونة الكبيرة ────────────────────────
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: page.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                      color: page.color.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: page.color.withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(page.emoji, style: const TextStyle(fontSize: 52)),
                ),
              ).animate(target: isActive ? 1.0 : 0.0).scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 500.ms,
                  curve: Curves.elasticOut),

              const SizedBox(height: 32),

              // ── العنوان ─────────────────────────────────
              Text(
                page.title,
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(target: isActive ? 1.0 : 0.0)
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 12),

              // ── الوصف ───────────────────────────────────
              Text(
                page.subtitle,
                style: GoogleFonts.cairo(
                    fontSize: 14, color: AppTheme.textMuted, height: 1.7),
                textAlign: TextAlign.center,
              )
                  .animate(target: isActive ? 1.0 : 0.0)
                  .fadeIn(duration: 400.ms, delay: 200.ms),

              // ── المميزات ─────────────────────────────────
              if (page.features.isNotEmpty) ...[
                const SizedBox(height: 28),
                ...page.features.asMap().entries.map(
                      (e) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(children: [
                          Text(e.value.$1,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Text(
                            e.value.$2,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]),
                      )
                          .animate(target: isActive ? 1.0 : 0.0)
                          .fadeIn(
                              delay: Duration(milliseconds: 300 + e.key * 80))
                          .slideX(begin: 0.2, end: 0),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  _OnboardPage — نموذج البيانات
// ══════════════════════════════════════════════════════════
class _OnboardPage {
  final String emoji, title, subtitle;
  final Color color;
  final List<(String, String)> features;
  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.features,
  });
}
