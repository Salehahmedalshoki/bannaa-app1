// ══════════════════════════════════════════════════════════
//  screens/profile_screen.dart — مُراجَع بالكامل مع الترجمة
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'auth_wrapper.dart';
import 'my_quotes_screen.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            const SizedBox(height: 16),
            _ProfileCard(),
            const SizedBox(height: 20),
            _GeneralSettingsSection(),
            const SizedBox(height: 14),
            _BuildingCodeSection(),
            const SizedBox(height: 14),
            _PricesSection(),
            const SizedBox(height: 14),
            _AccountSection(),
            const SizedBox(height: 14),
            _AboutSection(),
            const SizedBox(height: 20),
            _LogoutButton(),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }
}

// ════ بطاقة الملف الشخصي ═════════════════════════════════
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final user = AuthService.currentUser;
    final name = user?.displayName ?? t.tr('user');
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'م';
    // نستخدم StreamBuilder للإحصائيات الحية
    return StreamBuilder(
      stream: FirestoreService.projectsStream(),
      builder: (context, snap) {
        final projects = snap.data ?? [];
        final projectsCount = projects.length;
        final totalVol = projects.fold(0.0, (s, p) => s + p.totalVolume);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.accent.withValues(alpha: 0.15),
              AppTheme.accentDark.withValues(alpha: 0.05),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
          ),
          child: Column(children: [
            Row(children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accentDark]),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Center(
                    child: Text(initial,
                        style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.black))),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(email,
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  FutureBuilder<String>(
                    future: FirestoreService.getUserType(),
                    builder: (_, snap) {
                      final isSupplier = snap.data == 'supplier';
                      return Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppTheme.success
                                        .withValues(alpha: 0.3))),
                            child: Text('✓ ${t.tr('activeAccount')}',
                                style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w700))),
                        if (isSupplier) ...[
                          const SizedBox(width: 6),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFF3B82F6)
                                          .withValues(alpha: 0.3))),
                              child: Text('🏪 مورّد',
                                  style: GoogleFonts.cairo(
                                      fontSize: 9,
                                      color: const Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w700))),
                        ],
                      ]);
                    },
                  ),
                ],
              )),
            ]),
            const SizedBox(height: 16),
            Container(height: 1, color: AppTheme.border.withValues(alpha: 0.5)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stat('📁', '$projectsCount', t.tr('projectWord')),
              Container(width: 1, height: 32, color: AppTheme.border),
              _stat('🧱', '${totalVol.toStringAsFixed(0)}', t.tr('concreteM3')),
              Container(width: 1, height: 32, color: AppTheme.border),
              Consumer<AppSettingsProvider>(
                  builder: (_, s, __) =>
                      _stat('🏗️', s.buildingCode.short, t.tr('theCode'))),
            ]),
          ]),
        ).animate().fadeIn(duration: 400.ms);
      },
    );
  }

  Widget _stat(String icon, String val, String lbl) => Column(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(val,
            style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.accent)),
        Text(lbl,
            style: GoogleFonts.cairo(fontSize: 9, color: AppTheme.textMuted)),
      ]);
}

// ════ الإعدادات العامة ════════════════════════════════════
class _GeneralSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();

    return _Section(
      title: t.tr('generalSettings'),
      children: [
        _Tile(
          icon: '🌐',
          label: t.tr('language'),
          trailing: _currentLangBadge(s.locale),
          onTap: () => _showLanguagePicker(context, s),
        ),
        _Tile(
          icon: '💰',
          label: t.tr('currency'),
          trailing: _dropdownWidget(
            context: context,
            value: s.currency,
            items:
                kCurrencies.map((k, v) => MapEntry(k, '${v.symbol} ${v.code}')),
            onChanged: (v) => s.setCurrency(v!),
          ),
        ),
        _Tile(
          icon: '🔔',
          label: t.tr('notifications'),
          trailing: Switch(
            value: s.notificationsOn,
            onChanged: s.setNotifications,
            activeColor: AppTheme.accent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        _Tile(
          icon: '🌙',
          label: t.tr('darkMode'),
          trailing: Switch(
            value: s.darkMode,
            onChanged: s.setDarkMode,
            activeColor: AppTheme.accent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _currentLangBadge(Locale locale) {
    final lang = kSupportedLocales.firstWhere(
      (l) => (l['locale'] as Locale).languageCode == locale.languageCode,
      orElse: () => kSupportedLocales.first,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: AppTheme.accentGlow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(lang['flag'] as String, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 5),
        Text(lang['name'] as String,
            style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppTheme.accent,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

  void _showLanguagePicker(BuildContext context, AppSettingsProvider s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LanguagePickerSheet(settings: s),
    );
  }

  Widget _dropdownWidget({
    required BuildContext context,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          dropdownColor: AppTheme.surface,
          style: GoogleFonts.cairo(
              fontSize: 11,
              color: AppTheme.accent,
              fontWeight: FontWeight.w700),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppTheme.textMuted, size: 14),
          items: items.entries
              .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value,
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppTheme.textPrimary)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ════ اختيار اللغة ════════════════════════════════════════
class _LanguagePickerSheet extends StatelessWidget {
  final AppSettingsProvider settings;
  const _LanguagePickerSheet({required this.settings});

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text(t.tr('chooseLanguage'),
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 20),
        ...kSupportedLocales.map((lang) {
          final locale = lang['locale'] as Locale;
          final isSelected =
              settings.locale.languageCode == locale.languageCode;
          return GestureDetector(
            onTap: () async {
              await settings.setLocale(locale);
              if (context.mounted) Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentGlow : AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isSelected ? AppTheme.accent : AppTheme.border,
                    width: isSelected ? 1.5 : 1),
              ),
              child: Row(children: [
                Text(lang['flag'] as String,
                    style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang['name'] as String,
                        style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppTheme.accent
                                : AppTheme.textPrimary)),
                    Text(lang['nameEn'] as String,
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ],
                )),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                        color: AppTheme.accent, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.check, color: Colors.black, size: 14),
                  ),
              ]),
            ),
          );
        }),
      ]),
    );
  }
}

// ════ كود البناء ══════════════════════════════════════════
class _BuildingCodeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();
    final grades = s.gradesForCode;

    return _Section(
      title: t.tr('buildingCodeSection'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.tr('engineeringCode'),
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSub)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BuildingCode.values.map((code) {
                  final sel = s.buildingCode == code;
                  return GestureDetector(
                    onTap: () => s.setBuildingCode(code),
                    child: AnimatedContainer(
                      duration: 180.ms,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color:
                              sel ? AppTheme.accentGlow : AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: sel ? AppTheme.accent : AppTheme.border)),
                      child: Text(code.short,
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: sel ? AppTheme.accent : AppTheme.textMuted,
                              fontWeight:
                                  sel ? FontWeight.w800 : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 4),
              Text(s.buildingCode.label,
                  style: GoogleFonts.cairo(
                      fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ),
        Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: AppTheme.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.tr('concreteGrade'),
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSub)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: s.selectedGrade,
                    dropdownColor: AppTheme.surface,
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: AppTheme.textPrimary),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.textMuted),
                    items: grades
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g,
                                  style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: AppTheme.textPrimary)),
                            ))
                        .toList(),
                    onChanged: (v) => s.setGrade(v!),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _MixRatiosCard(mix: s.currentMix),
            ],
          ),
        ),
      ],
    );
  }
}

class _MixRatiosCard extends StatelessWidget {
  final MixRatios mix;
  const _MixRatiosCard({required this.mix});

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border)),
      child: Column(children: [
        Row(children: [
          const Text('📊', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(t.tr('approvedMixRatios'),
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _ratioChip('🪣 ${t.tr('cement')}',
              '${mix.cementKgPerM3.toInt()} ${t.tr('kg')}/${t.tr('perM3')}'),
          _ratioChip(
              '🏖️ ${t.tr('sand')}', '${mix.sandM3PerM3} ${t.tr('perM3')}'),
          _ratioChip(
              '🪨 ${t.tr('gravel')}', '${mix.gravelM3PerM3} ${t.tr('perM3')}'),
          _ratioChip('⚙️ ${t.tr('steel')}',
              '${mix.steelKgPerM3.toInt()} ${t.tr('kg')}/${t.tr('perM3')}'),
          _ratioChip('💧 ${t.tr('water')}',
              '${mix.waterLPerM3.toInt()} ${t.tr('liter')}/${t.tr('perM3')}'),
        ]),
      ]),
    );
  }

  Widget _ratioChip(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: GoogleFonts.cairo(fontSize: 9, color: AppTheme.textSub)),
          const SizedBox(width: 4),
          Text(value,
              style: GoogleFonts.cairo(
                  fontSize: 9,
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

// ════ إدارة الأسعار ═══════════════════════════════════════
class _PricesSection extends StatelessWidget {
  static const _materials = [
    ('cement', '🪣', 'cement', 'bag50kg'),
    ('sand', '🏖️', 'sand', 'perM3'),
    ('gravel', '🪨', 'gravel', 'perM3'),
    ('steel', '⚙️', 'steel', 'kg'),
    ('water', '💧', 'water', 'perM3'),
    ('brick', '🧱', 'brick', 'brickUnit'),
    ('plaster', '🪣', 'plaster', 'bag50kg'),
    ('tiles', '⬜', 'tiles', 'perM2'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();
    final sym = s.currencyInfo.symbol;

    // مفاتيح ترجمة إضافية للمواد
    final matNames = {
      'cement': t.tr('cement'),
      'sand': t.tr('sand'),
      'gravel': t.tr('gravel'),
      'steel': t.tr('steel'),
      'water': t.tr('water'),
      'brick': '🧱 ${t.tr('brick')}',
      'plaster': t.tr('plaster'),
      'tiles': t.tr('tiles'),
    };
    final unitNames = {
      'bag50kg': t.tr('bag50kg'),
      'perM3': t.tr('perM3'),
      'kg': t.tr('kg'),
      'brickUnit': t.tr('brickUnit'),
      'perM2': t.tr('perM2'),
    };

    return _Section(
      title: t.tr('pricesSection'),
      trailing: GestureDetector(
        onTap: s.resetPrices,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
              border:
                  Border.all(color: AppTheme.danger.withValues(alpha: 0.3))),
          child: Text(t.tr('resetPricesBtn'),
              style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      children: _materials
          .map((m) => _PriceTile(
                key: ValueKey(m.$1),
                matKey: m.$1,
                icon: m.$2,
                name: matNames[m.$1] ?? m.$3,
                unit: unitNames[m.$4] ?? m.$4,
                price: s.prices[m.$1] ?? 0,
                symbol: sym,
                editTitle: t.tr('editPriceTitle'),
                pricePerUnit: t.tr('pricePerUnit'),
                cancelLabel: t.tr('cancel'),
                saveLabel: t.tr('save'),
                onEdit: (newPrice) => s.setPrice(m.$1, newPrice),
              ))
          .toList(),
    );
  }
}

class _PriceTile extends StatelessWidget {
  final String matKey, icon, name, unit, symbol;
  final String editTitle, pricePerUnit, cancelLabel, saveLabel;
  final double price;
  final ValueChanged<double> onEdit;

  const _PriceTile({
    super.key,
    required this.matKey,
    required this.icon,
    required this.name,
    required this.unit,
    required this.price,
    required this.symbol,
    required this.editTitle,
    required this.pricePerUnit,
    required this.cancelLabel,
    required this.saveLabel,
    required this.onEdit,
  });

  void _showEditDialog(BuildContext context) {
    final ctrl = TextEditingController(
        text: price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('$icon $editTitle $name',
            style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$pricePerUnit $unit',
              style:
                  GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary),
            decoration: InputDecoration(suffixText: symbol),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelLabel,
                  style: GoogleFonts.cairo(color: AppTheme.textMuted))),
          TextButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text);
                if (v != null && v >= 0) onEdit(v);
                Navigator.pop(context);
              },
              child: Text(saveLabel,
                  style: GoogleFonts.cairo(
                      color: AppTheme.accent, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return GestureDetector(
      onTap: () => _showEditDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              Text('${t.tr('perUnit')} $unit',
                  style: GoogleFonts.cairo(
                      fontSize: 10, color: AppTheme.textMuted)),
            ],
          )),
          Text(
              '${price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2)} $symbol',
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          const Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 14),
        ]),
      ),
    );
  }
}

// ════ إعدادات الحساب ══════════════════════════════════════
class _AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final user = AuthService.currentUser;
    return _Section(
      title: t.tr('accountSettings'),
      children: [
        // ── طلبات عروض الأسعار ──
        _Tile(
            icon: '📬',
            label: 'طلبات عروض الأسعار',
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 13, color: AppTheme.textMuted),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyQuotesScreen()))),
        _Tile(
            icon: '✏️',
            label: t.tr('editProfile'),
            onTap: () => _editProfileSheet(context, user, t)),
        _Tile(
            icon: '🔑',
            label: t.tr('changePassword'),
            onTap: () => _changePasswordSheet(context, user, t)),
        _Tile(
            icon: '📧',
            label: t.tr('email'),
            trailing: Text(user?.email ?? '—',
                style: GoogleFonts.cairo(
                    fontSize: 11, color: AppTheme.textMuted))),
        _Tile(
            icon: '🗑️',
            label: t.tr('deleteAllProjects'),
            labelColor: AppTheme.danger,
            onTap: () => _deleteAllProjects(context, t)),
      ],
    );
  }

  void _editProfileSheet(
      BuildContext context, dynamic user, BannaaLocalizations t) {
    final ctrl = TextEditingController(text: user?.displayName ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 14),
          Text(t.tr('editName'),
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 14),
          TextFormField(
              controller: ctrl,
              autofocus: true,
              style: GoogleFonts.cairo(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppTheme.textMuted))),
          const SizedBox(height: 14),
          GoldenButton(
              label: t.tr('saveChanges'),
              icon: '✓',
              onTap: () async {
                await user?.updateDisplayName(ctrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _changePasswordSheet(
      BuildContext context, dynamic user, BannaaLocalizations t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 14),
          Text(t.tr('changePassword'),
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('${t.tr('sendResetTo')}\n${user?.email ?? ''}',
              style: GoogleFonts.cairo(
                  fontSize: 12, color: AppTheme.textMuted, height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GoldenButton(
              label: t.tr('sendResetLink'),
              icon: '📧',
              onTap: () async {
                if (user?.email != null) {
                  await AuthService.resetPassword(user!.email!);
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(t.tr('linkSentSuccess'),
                          style: GoogleFonts.cairo(color: Colors.white)),
                      backgroundColor: AppTheme.success,
                      behavior: SnackBarBehavior.floating));
                }
              }),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _deleteAllProjects(BuildContext context, BannaaLocalizations t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(t.tr('deleteAllProjects'),
            style: GoogleFonts.cairo(
                color: AppTheme.danger, fontWeight: FontWeight.w700)),
        content: Text(t.tr('deleteAllConfirm'),
            style: GoogleFonts.cairo(color: AppTheme.textSub, height: 1.6)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.tr('cancel'),
                  style: GoogleFonts.cairo(color: AppTheme.textMuted))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.tr('delete'),
                  style: GoogleFonts.cairo(
                      color: AppTheme.danger, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final projects = await FirestoreService.getProjects();
      for (final p in projects) {
        await FirestoreService.deleteProject(p.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t.tr('projectsDeleted'),
              style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating));
    }
  }
}

// ════ حول التطبيق ════════════════════════════════════════
class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return _Section(
      title: t.tr('aboutApp'),
      children: [
        _Tile(
            icon: '📱',
            label: t.tr('version'),
            trailing: Text('1.0.0 (Build 1)',
                style: GoogleFonts.cairo(
                    fontSize: 11, color: AppTheme.textMuted))),
        _Tile(icon: '📄', label: t.tr('termsOfUse'), onTap: () {}),
        _Tile(icon: '🔒', label: t.tr('privacyPolicy'), onTap: () {}),
        _Tile(icon: '⭐', label: t.tr('rateApp'), onTap: () {}),
      ],
    );
  }
}

// ════ زر تسجيل الخروج ════════════════════════════════════
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return GestureDetector(
      onTap: () => _logout(context, t),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
            color: AppTheme.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout, color: AppTheme.danger, size: 18),
          const SizedBox(width: 8),
          Text(t.tr('logout'),
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    ).animate(delay: 400.ms).fadeIn();
  }

  void _logout(BuildContext context, BannaaLocalizations t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(t.tr('logoutTitle'),
            style: GoogleFonts.cairo(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(t.tr('areYouSure'),
            style: GoogleFonts.cairo(color: AppTheme.textSub)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.tr('cancel'),
                  style: GoogleFonts.cairo(color: AppTheme.textMuted))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.tr('signOut'),
                  style: GoogleFonts.cairo(
                      color: AppTheme.danger, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await AuthService.signOut();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const AuthWrapper()), (_) => false);
    }
  }
}

// ════ ودجات مساعدة ════════════════════════════════════════
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  const _Section({required this.title, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(title,
            style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        if (trailing != null) ...[const Spacer(), trailing!],
      ]),
      const SizedBox(height: 8),
      DarkCard(
        padding: EdgeInsets.zero,
        child: Column(
            children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(children: [
            e.value,
            if (!isLast)
              Container(
                  height: 1,
                  margin: const EdgeInsets.only(right: 50),
                  color: AppTheme.border),
          ]);
        }).toList()),
      ),
    ]).animate().fadeIn(delay: 100.ms);
  }
}

class _Tile extends StatelessWidget {
  final String icon, label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor;
  const _Tile(
      {required this.icon,
      required this.label,
      this.trailing,
      this.onTap,
      this.labelColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: labelColor ?? AppTheme.textPrimary,
                      fontWeight: FontWeight.w500))),
          if (trailing != null)
            trailing!
          else if (onTap != null)
            const Icon(Icons.arrow_forward_ios,
                color: AppTheme.textMuted, size: 13),
        ]),
      ),
    );
  }
}

Widget _sheetHandle() => Center(
    child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
            color: AppTheme.border, borderRadius: BorderRadius.circular(2))));
