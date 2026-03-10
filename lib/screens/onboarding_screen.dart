// ══════════════════════════════════════════════════════════
//  screens/onboarding_screen.dart
//  شاشات الترحيب — تُعرض مرة واحدة للمستخدم الجديد
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

  void _next() {
    if (_current < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: 400.ms, curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() async {
    // حفظ أن المستخدم رأى الـ onboarding
    final box = await Hive.openBox('settings');
    await box.put('onboarding_done', true);
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الصفحات
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _PageView(page: _pages[i], isActive: i == _current),
          ),

          // التحكم السفلي
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildControls(),
          ),

          // زر تخطي
          if (_current < _pages.length - 1)
            Positioned(
              top: 52, left: 20,
              child: GestureDetector(
                onTap: _finish,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border)),
                  child: Text('تخطي', style: GoogleFonts.cairo(
                    fontSize: 12, color: AppTheme.textMuted)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppTheme.background.withOpacity(0.97)],
        ),
      ),
      child: Column(children: [
        // مؤشرات الصفحة
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
                color: active
                    ? _pages[_current].color
                    : AppTheme.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // زر التالي / ابدأ
        GestureDetector(
          onTap: _next,
          child: AnimatedContainer(
            duration: 300.ms,
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_pages[_current].color,
                  _pages[_current].color.withOpacity(0.75)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: _pages[_current].color.withOpacity(0.35),
                blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  _current == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                  style: GoogleFonts.cairo(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: Colors.black)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                  color: Colors.black, size: 14),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── صفحة Onboarding واحدة ─────────────────────────────────
class _PageView extends StatelessWidget {
  final _OnboardPage page;
  final bool isActive;
  const _PageView({required this.page, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 0.9,
          colors: [
            page.color.withOpacity(0.15),
            AppTheme.background,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة الكبيرة
              Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: page.color.withOpacity(0.3), width: 2),
                  boxShadow: [BoxShadow(
                    color: page.color.withOpacity(0.2),
                    blurRadius: 40, spreadRadius: 4)],
                ),
                child: Center(
                  child: Text(page.emoji,
                    style: const TextStyle(fontSize: 52)),
                ),
              ).animate(target: isActive ? 1.0 : 0.0)
               .scale(begin: const Offset(0.8, 0.8), duration: 500.ms,
                 curve: Curves.elasticOut),

              const SizedBox(height: 32),

              // العنوان
              Text(page.title,
                style: GoogleFonts.cairo(
                  fontSize: 26, fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary, height: 1.2),
                textAlign: TextAlign.center,
              ).animate(target: isActive ? 1.0 : 0.0)
               .fadeIn(duration: 400.ms, delay: 100.ms)
               .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 12),

              // الوصف
              Text(page.subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 14, color: AppTheme.textMuted,
                  height: 1.7),
                textAlign: TextAlign.center,
              ).animate(target: isActive ? 1.0 : 0.0)
               .fadeIn(duration: 400.ms, delay: 200.ms),

              // المميزات
              if (page.features.isNotEmpty) ...[
                const SizedBox(height: 28),
                ...page.features.asMap().entries.map((e) =>
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border)),
                    child: Row(children: [
                      Text(e.value.$1, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(e.value.$2, style: GoogleFonts.cairo(
                        fontSize: 13, color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600)),
                    ]),
                  ).animate(target: isActive ? 1.0 : 0.0)
                   .fadeIn(delay: Duration(milliseconds: 300 + e.key * 80))
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

class _OnboardPage {
  final String emoji, title, subtitle;
  final Color color;
  final List<(String, String)> features;
  const _OnboardPage({
    required this.emoji, required this.title,
    required this.subtitle, required this.color,
    required this.features,
  });
}
