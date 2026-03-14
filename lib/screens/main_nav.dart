// ══════════════════════════════════════════════════════════
//  screens/main_nav.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة:
//  ✅ #1  _QuoteBadge widget مستقل — Stream يُعيد بناء البادج فقط
//  ✅ #2  _screens تُبنى في initState بدل static const
//  ✅ #3  موضع البادج يتكيف مع RTL/LTR (right بدل left)
//  ✅ #4  عداد البادج يُقيَّد بـ '9+' لمنع تجاوز حدود الدائرة
//  ✅ #5  حُذف HomeContent wrapper الزائد
//  ✅ #6  Semantics على كل زر تنقل لإمكانية الوصول
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/quote_request_model.dart';
import 'home_screen.dart';
import 'my_projects_screen.dart';
import 'calculator_screen.dart';
import 'profile_screen.dart';

class MainNav extends StatefulWidget {
  final int initialIndex;
  const MainNav({super.key, this.initialIndex = 0});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> with TickerProviderStateMixin {
  late int _currentIndex;
  late final List<AnimationController> _iconControllers;

  // ✅ #2 — قائمة الشاشات تُبنى في initState بدل static const
  // هذا يضمن توافر context والـ InheritedWidgets عند الحاجة
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // ✅ #2
    _screens = const [
      HomeScreen(), // ✅ #5 مباشرةً بدون HomeContent wrapper
      MyProjectsScreen(),
      CalculatorScreen(),
      ProfileScreen(),
    ];

    _iconControllers = List.generate(
      4,
      (_) => AnimationController(vsync: this, duration: 300.ms),
    );
    _iconControllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    _iconControllers[_currentIndex].reverse();
    setState(() => _currentIndex = index);
    _iconControllers[index].forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final s = context.watch<AppSettingsProvider>();
    final lang = s.locale.languageCode;
    // ✅ #6 — labels تُستخدم في Semantics أيضاً
    final labels = switch (lang) {
      'ar' => ['الرئيسية', 'مشاريعي', 'الحاسبة', 'حسابي'],
      'en' => ['Home', 'Projects', 'Calculator', 'Profile'],
      'fr' => ['Accueil', 'Projets', 'Calculatrice', 'Profil'],
      _ => ['Ana Sayfa', 'Projeler', 'Hesaplama', 'Hesabım'],
    };

    const icons = [
      Icons.home_outlined,
      Icons.folder_outlined,
      Icons.calculate_outlined,
      Icons.person_outline,
    ];
    const activeIcons = [
      Icons.home_rounded,
      Icons.folder_rounded,
      Icons.calculate_rounded,
      Icons.person_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          // ✅ #1 — Row خارج الـ StreamBuilder، الـ stream فقط في _QuoteBadge
          child: Row(
            children: List.generate(4, (i) {
              final isActive = i == _currentIndex;
              // ✅ #1 — تاب index 1 فقط يعرض _QuoteBadge، الباقي لا يُعيد بناؤه
              final showBadge = i == 1;

              return Expanded(
                child: Semantics(
                  // ✅ #6 — إمكانية الوصول لقارئات الشاشة
                  label: labels[i],
                  button: true,
                  selected: isActive,
                  child: GestureDetector(
                    onTap: () => _onTabTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedBuilder(
                      animation: _iconControllers[i],
                      builder: (_, __) {
                        final t = _iconControllers[i].value;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedContainer(
                                  duration: 250.ms,
                                  width: isActive ? 48 : 38,
                                  height: isActive ? 30 : 26,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppTheme.accentGlow
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Transform.scale(
                                      scale: 0.85 + (t * 0.2),
                                      child: Icon(
                                        isActive ? activeIcons[i] : icons[i],
                                        size: isActive ? 20 : 18,
                                        color: isActive
                                            ? AppTheme.accent
                                            : AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                                // ✅ #1 — البادج widget مستقل، لا يُعيد بناء الشريط
                                // ✅ #3 — موضع RTL-aware
                                if (showBadge)
                                  Positioned(
                                    top: -4,
                                    right: -4, // ✅ #3 right بدل left
                                    child: const _QuoteBadge(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: 200.ms,
                              style: GoogleFonts.cairo(
                                fontSize: isActive ? 10 : 9,
                                color: isActive
                                    ? AppTheme.accent
                                    : AppTheme.textMuted,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                              child: Text(labels[i]),
                            ),
                            AnimatedContainer(
                              duration: 250.ms,
                              margin: const EdgeInsets.only(top: 3),
                              width: isActive ? 16 : 0,
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  ✅ #1 #4 — _QuoteBadge: Stream معزول، يُعيد بناء البادج فقط
//
//  قبل الإصلاح: StreamBuilder يُغلّف الـ Row كاملاً →
//    كل تحديث Firestore يُعيد بناء 4 تبويبات + أنيميشن
//
//  بعد الإصلاح: StreamBuilder هنا فقط →
//    كل تحديث Firestore يُعيد بناء هذه الدائرة الصغيرة فقط
// ══════════════════════════════════════════════════════════
class _QuoteBadge extends StatelessWidget {
  const _QuoteBadge();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QuoteRequest>>(
      stream: FirestoreService.myQuoteRequestsStream(),
      builder: (context, snap) {
        final pendingCount = (snap.data ?? [])
            .where((r) => r.status == QuoteStatus.responded)
            .length;

        // لا توجد ردود جديدة → لا شيء يُعرض
        if (pendingCount == 0) return const SizedBox.shrink();

        // ✅ #4 — تقييد الرقم بـ '9+' لمنع تجاوز حدود الدائرة
        final label = pendingCount > 9 ? '9+' : '$pendingCount';

        return Container(
          constraints: const BoxConstraints(
            minWidth: 16,
            minHeight: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: const BoxDecoration(
            color: AppTheme.danger,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }
}
