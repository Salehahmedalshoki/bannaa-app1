// ══════════════════════════════════════════════════════════
//  screens/main_nav.dart
//  الإطار الرئيسي — شريط التنقل السفلي يربط كل الشاشات
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';
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

  final _screens = const [
    HomeContent(),
    MyProjectsScreen(),
    CalculatorScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _iconControllers = List.generate(
      4, (_) => AnimationController(vsync: this, duration: 300.ms));
    _iconControllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    for (final c in _iconControllers) c.dispose();
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    // تعريف عناوين التبويبات حسب اللغة الحالية
    final s = context.watch<AppSettingsProvider>();
    final isAr = s.locale.languageCode == 'ar';
    final isEn = s.locale.languageCode == 'en';
    final isFr = s.locale.languageCode == 'fr';

    final labels = isAr
        ? ['الرئيسية', 'مشاريعي', 'الحاسبة', 'حسابي']
        : isEn
            ? ['Home', 'Projects', 'Calculator', 'Profile']
            : isFr
                ? ['Accueil', 'Projets', 'Calculatrice', 'Profil']
                : ['Ana Sayfa', 'Projeler', 'Hesaplama', 'Hesabım'];

    const icons = ['🏠', '📁', '🧮', '👤'];

    return Container(
      height: 68 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (i) {
            final isActive = i == _currentIndex;
            return Expanded(
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
                        AnimatedContainer(
                          duration: 250.ms,
                          width: isActive ? 44 : 36,
                          height: isActive ? 32 : 28,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.accentGlow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Transform.scale(
                              scale: 0.85 + (t * 0.2),
                              child: Text(icons[i],
                                style: TextStyle(
                                  fontSize: isActive ? 20 : 18)),
                            ),
                          ),
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
                                : FontWeight.normal),
                          child: Text(labels[i]),
                        ),
                        AnimatedContainer(
                          duration: 250.ms,
                          margin: const EdgeInsets.only(top: 3),
                          width: isActive ? 16 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(1)),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  HomeContent — wrapper لـ HomeScreen داخل IndexedStack
// ══════════════════════════════════════════════════════════
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) => const HomeScreen();
}


