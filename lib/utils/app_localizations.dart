// ══════════════════════════════════════════════════════════
//  utils/app_localizations.dart
//  نظام الترجمة الكامل — يدعم 4 لغات بدون code generation
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class BannaaLocalizations {
  final Locale locale;
  BannaaLocalizations(this.locale);

  static BannaaLocalizations of(BuildContext context) {
    return Localizations.of<BannaaLocalizations>(
            context, BannaaLocalizations) ??
        BannaaLocalizations(const Locale('ar'));
  }

  static const LocalizationsDelegate<BannaaLocalizations> delegate =
      _BannaaLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('tr'),
  ];

  // ── جدول الترجمة الكامل ────────────────────────────────
  static const Map<String, Map<String, String>> _translations = {
    // ── الواجهة الرئيسية ─────────────────────────────────
    'home': {
      'ar': 'الرئيسية',
      'en': 'Home',
      'fr': 'Accueil',
      'tr': 'Ana Sayfa'
    },
    'myProjects': {
      'ar': 'مشاريعي',
      'en': 'My Projects',
      'fr': 'Mes Projets',
      'tr': 'Projelerim'
    },
    'calculator': {
      'ar': 'الحاسبة',
      'en': 'Calculator',
      'fr': 'Calculatrice',
      'tr': 'Hesaplama'
    },
    'profile': {
      'ar': 'حسابي',
      'en': 'Profile',
      'fr': 'Profil',
      'tr': 'Hesabım'
    },

    // ── أزرار مشتركة ─────────────────────────────────────
    'next': {'ar': 'التالي', 'en': 'Next', 'fr': 'Suivant', 'tr': 'İleri'},
    'back': {'ar': 'رجوع', 'en': 'Back', 'fr': 'Retour', 'tr': 'Geri'},
    'save': {'ar': 'حفظ', 'en': 'Save', 'fr': 'Enregistrer', 'tr': 'Kaydet'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel', 'fr': 'Annuler', 'tr': 'İptal'},
    'delete': {'ar': 'حذف', 'en': 'Delete', 'fr': 'Supprimer', 'tr': 'Sil'},
    'edit': {'ar': 'تعديل', 'en': 'Edit', 'fr': 'Modifier', 'tr': 'Düzenle'},
    'calculate': {
      'ar': 'احسب',
      'en': 'Calculate',
      'fr': 'Calculer',
      'tr': 'Hesapla'
    },
    'export': {
      'ar': 'تصدير',
      'en': 'Export',
      'fr': 'Exporter',
      'tr': 'Dışa Aktar'
    },
    'share': {'ar': 'مشاركة', 'en': 'Share', 'fr': 'Partager', 'tr': 'Paylaş'},
    'confirm': {
      'ar': 'تأكيد',
      'en': 'Confirm',
      'fr': 'Confirmer',
      'tr': 'Onayla'
    },
    'yes': {'ar': 'نعم', 'en': 'Yes', 'fr': 'Oui', 'tr': 'Evet'},
    'no': {'ar': 'لا', 'en': 'No', 'fr': 'Non', 'tr': 'Hayır'},
    'loading': {
      'ar': 'جاري التحميل...',
      'en': 'Loading...',
      'fr': 'Chargement...',
      'tr': 'Yükleniyor...'
    },

    // ── المشروع ───────────────────────────────────────────
    'newProject': {
      'ar': 'مشروع جديد',
      'en': 'New Project',
      'fr': 'Nouveau Projet',
      'tr': 'Yeni Proje'
    },
    'projectName': {
      'ar': 'اسم المشروع',
      'en': 'Project Name',
      'fr': 'Nom du Projet',
      'tr': 'Proje Adı'
    },
    'buildingType': {
      'ar': 'نوع المنشأ',
      'en': 'Building Type',
      'fr': 'Type de Bâtiment',
      'tr': 'Bina Tipi'
    },
    'floors': {
      'ar': 'الطوابق',
      'en': 'Floors',
      'fr': 'Étages',
      'tr': 'Kat Sayısı'
    },
    'city': {'ar': 'المدينة', 'en': 'City', 'fr': 'Ville', 'tr': 'Şehir'},
    'components': {
      'ar': 'المكوّنات',
      'en': 'Components',
      'fr': 'Composants',
      'tr': 'Bileşenler'
    },
    'noProjects': {
      'ar': 'لا توجد مشاريع',
      'en': 'No projects yet',
      'fr': 'Aucun projet',
      'tr': 'Proje yok'
    },
    'deleteProject': {
      'ar': 'حذف المشروع',
      'en': 'Delete Project',
      'fr': 'Supprimer Projet',
      'tr': 'Projeyi Sil'
    },
    'deleteConfirm': {
      'ar': 'هل تريد الحذف؟',
      'en': 'Delete project?',
      'fr': 'Supprimer?',
      'tr': 'Silmek ister misin?'
    },

    // ── أنواع المباني ─────────────────────────────────────
    'villa': {'ar': 'فيلا سكنية', 'en': 'Villa', 'fr': 'Villa', 'tr': 'Villa'},
    'apartment': {
      'ar': 'شقة سكنية',
      'en': 'Apartment',
      'fr': 'Appartement',
      'tr': 'Daire'
    },
    'commercial': {
      'ar': 'مبنى تجاري',
      'en': 'Commercial Building',
      'fr': 'Bâtiment Comm.',
      'tr': 'Ticari Bina'
    },
    'warehouse': {
      'ar': 'مستودع',
      'en': 'Warehouse',
      'fr': 'Entrepôt',
      'tr': 'Depo'
    },
    'other': {'ar': 'أخرى', 'en': 'Other', 'fr': 'Autre', 'tr': 'Diğer'},

    // ── مكوّنات البناء ────────────────────────────────────
    'column': {'ar': 'عمود', 'en': 'Column', 'fr': 'Colonne', 'tr': 'Kolon'},
    'slab': {'ar': 'سقف / بلاطة', 'en': 'Slab', 'fr': 'Dalle', 'tr': 'Döşeme'},
    'foundation': {
      'ar': 'أساس',
      'en': 'Foundation',
      'fr': 'Fondation',
      'tr': 'Temel'
    },
    'wall': {'ar': 'جدار', 'en': 'Wall', 'fr': 'Mur', 'tr': 'Duvar'},
    'beam': {'ar': 'كمرة', 'en': 'Beam', 'fr': 'Poutre', 'tr': 'Kiriş'},

    // ── أبعاد ─────────────────────────────────────────────
    'length': {
      'ar': 'الطول',
      'en': 'Length',
      'fr': 'Longueur',
      'tr': 'Uzunluk'
    },
    'width': {'ar': 'العرض', 'en': 'Width', 'fr': 'Largeur', 'tr': 'Genişlik'},
    'height': {
      'ar': 'الارتفاع',
      'en': 'Height',
      'fr': 'Hauteur',
      'tr': 'Yükseklik'
    },
    'depth': {
      'ar': 'العمق',
      'en': 'Depth',
      'fr': 'Profondeur',
      'tr': 'Derinlik'
    },
    'count': {'ar': 'العدد', 'en': 'Count', 'fr': 'Nombre', 'tr': 'Adet'},
    'meter': {'ar': 'م', 'en': 'm', 'fr': 'm', 'tr': 'm'},

    // ── المواد ───────────────────────────────────────────
    'cement': {'ar': 'أسمنت', 'en': 'Cement', 'fr': 'Ciment', 'tr': 'Çimento'},
    'sand': {'ar': 'رمل', 'en': 'Sand', 'fr': 'Sable', 'tr': 'Kum'},
    'gravel': {
      'ar': 'حجر / زلط',
      'en': 'Gravel',
      'fr': 'Gravier',
      'tr': 'Çakıl'
    },
    'steel': {
      'ar': 'حديد تسليح',
      'en': 'Reinf. Steel',
      'fr': 'Acier Armature',
      'tr': 'Donatı Çeliği'
    },
    'water': {'ar': 'ماء', 'en': 'Water', 'fr': 'Eau', 'tr': 'Su'},
    'concreteVolume': {
      'ar': 'حجم الخرسانة',
      'en': 'Concrete Volume',
      'fr': 'Volume Béton',
      'tr': 'Beton Hacmi'
    },
    'materials': {
      'ar': 'المواد',
      'en': 'Materials',
      'fr': 'Matériaux',
      'tr': 'Malzemeler'
    },
    'bag50kg': {
      'ar': 'كيس (50 كغ)',
      'en': 'bag (50 kg)',
      'fr': 'sac (50 kg)',
      'tr': 'çuval (50 kg)'
    },
    'perM3': {'ar': 'م³', 'en': 'm³', 'fr': 'm³', 'tr': 'm³'},
    'kg': {'ar': 'كغ', 'en': 'kg', 'fr': 'kg', 'tr': 'kg'},
    'liter': {'ar': 'لتر', 'en': 'L', 'fr': 'L', 'tr': 'L'},

    // ── الحسابات ─────────────────────────────────────────
    'results': {
      'ar': 'النتائج',
      'en': 'Results',
      'fr': 'Résultats',
      'tr': 'Sonuçlar'
    },
    'totalCost': {
      'ar': 'التكلفة الإجمالية',
      'en': 'Total Cost',
      'fr': 'Coût Total',
      'tr': 'Toplam Maliyet'
    },
    'estimatedCost': {
      'ar': 'تكلفة تقديرية',
      'en': 'Estimated Cost',
      'fr': 'Coût Estimé',
      'tr': 'Tahmini Maliyet'
    },
    'concreteGrade': {
      'ar': 'درجة الخرسانة',
      'en': 'Concrete Grade',
      'fr': 'Classe de Béton',
      'tr': 'Beton Sınıfı'
    },
    'buildingCode': {
      'ar': 'كود البناء',
      'en': 'Building Code',
      'fr': 'Code Construction',
      'tr': 'Yapı Yönetmeliği'
    },
    'mixRatio': {
      'ar': 'نسب الخلط',
      'en': 'Mix Ratios',
      'fr': 'Dosage de Mélange',
      'tr': 'Karışım Oranları'
    },

    // ── أكواد البناء ─────────────────────────────────────
    'egyptianCode': {
      'ar': 'الكود المصري (ECP)',
      'en': 'Egyptian Code (ECP)',
      'fr': 'Code Égyptien (ECP)',
      'tr': 'Mısır Kodu (ECP)'
    },
    'americanCode': {
      'ar': 'الكود الأمريكي (ACI)',
      'en': 'American Code (ACI)',
      'fr': 'Code Américain (ACI)',
      'tr': 'Amerikan Kodu (ACI)'
    },
    'britishCode': {
      'ar': 'الكود البريطاني (BS)',
      'en': 'British Code (BS)',
      'fr': 'Code Britannique (BS)',
      'tr': 'İngiliz Kodu (BS)'
    },
    'europeanCode': {
      'ar': 'الكود الأوروبي (EC2)',
      'en': 'Eurocode 2 (EC2)',
      'fr': 'Eurocode 2 (EC2)',
      'tr': 'Eurocode 2 (EC2)'
    },
    'saudiCode': {
      'ar': 'الكود السعودي (SBC)',
      'en': 'Saudi Code (SBC)',
      'fr': 'Code Saoudien (SBC)',
      'tr': 'Suudi Kodu (SBC)'
    },

    // ── التقرير ───────────────────────────────────────────
    'report': {'ar': 'التقرير', 'en': 'Report', 'fr': 'Rapport', 'tr': 'Rapor'},
    'generateReport': {
      'ar': 'إنشاء التقرير',
      'en': 'Generate Report',
      'fr': 'Créer Rapport',
      'tr': 'Rapor Oluştur'
    },
    'pdfReport': {
      'ar': 'تقرير PDF',
      'en': 'PDF Report',
      'fr': 'Rapport PDF',
      'tr': 'PDF Raporu'
    },
    'copied': {
      'ar': 'تم النسخ ✓',
      'en': 'Copied ✓',
      'fr': 'Copié ✓',
      'tr': 'Kopyalandı ✓'
    },

    // ── الحاسبة السريعة ───────────────────────────────────
    'concreteCalc': {
      'ar': 'الخرسانة',
      'en': 'Concrete',
      'fr': 'Béton',
      'tr': 'Beton'
    },
    'materialsCalc': {
      'ar': 'المواد',
      'en': 'Materials',
      'fr': 'Matériaux',
      'tr': 'Malzeme'
    },
    'steelCalc': {'ar': 'الحديد', 'en': 'Steel', 'fr': 'Acier', 'tr': 'Çelik'},
    'priceList': {
      'ar': 'الأسعار',
      'en': 'Prices',
      'fr': 'Prix',
      'tr': 'Fiyatlar'
    },
    'weightPerMeter': {
      'ar': 'وزن المتر',
      'en': 'kg/m',
      'fr': 'kg/m',
      'tr': 'kg/m'
    },

    // ── الإعدادات ─────────────────────────────────────────
    'settings': {
      'ar': 'الإعدادات',
      'en': 'Settings',
      'fr': 'Paramètres',
      'tr': 'Ayarlar'
    },
    'language': {'ar': 'اللغة', 'en': 'Language', 'fr': 'Langue', 'tr': 'Dil'},
    'currency': {
      'ar': 'العملة',
      'en': 'Currency',
      'fr': 'Devise',
      'tr': 'Para Birimi'
    },
    'region': {'ar': 'المنطقة', 'en': 'Region', 'fr': 'Région', 'tr': 'Bölge'},
    'notifications': {
      'ar': 'الإشعارات',
      'en': 'Notifications',
      'fr': 'Notifications',
      'tr': 'Bildirimler'
    },
    'darkMode': {
      'ar': 'الوضع الداكن',
      'en': 'Dark Mode',
      'fr': 'Mode Sombre',
      'tr': 'Karanlık Mod'
    },
    'prices': {
      'ar': 'إدارة الأسعار',
      'en': 'Manage Prices',
      'fr': 'Gérer Prix',
      'tr': 'Fiyatları Yönet'
    },
    'resetPrices': {
      'ar': 'إعادة ضبط الأسعار',
      'en': 'Reset Prices',
      'fr': 'Réinitialiser',
      'tr': 'Fiyatları Sıfırla'
    },
    'generalSettings': {
      'ar': 'الإعدادات العامة',
      'en': 'General Settings',
      'fr': 'Paramètres Gén.',
      'tr': 'Genel Ayarlar'
    },
    'accountSettings': {
      'ar': 'إعدادات الحساب',
      'en': 'Account Settings',
      'fr': 'Paramètres Cpt.',
      'tr': 'Hesap Ayarları'
    },
    'aboutApp': {
      'ar': 'حول التطبيق',
      'en': 'About',
      'fr': 'À Propos',
      'tr': 'Hakkında'
    },
    'version': {
      'ar': 'الإصدار',
      'en': 'Version',
      'fr': 'Version',
      'tr': 'Sürüm'
    },
    'changeLanguage': {
      'ar': 'تغيير اللغة',
      'en': 'Change Language',
      'fr': 'Changer Langue',
      'tr': 'Dil Değiştir'
    },

    // ── المصادقة ──────────────────────────────────────────
    'login': {
      'ar': 'تسجيل الدخول',
      'en': 'Sign In',
      'fr': 'Se Connecter',
      'tr': 'Giriş Yap'
    },
    'register': {
      'ar': 'إنشاء حساب',
      'en': 'Create Account',
      'fr': 'Créer Compte',
      'tr': 'Hesap Oluştur'
    },
    'email': {
      'ar': 'البريد الإلكتروني',
      'en': 'Email',
      'fr': 'Email',
      'tr': 'E-posta'
    },
    'password': {
      'ar': 'كلمة المرور',
      'en': 'Password',
      'fr': 'Mot de Passe',
      'tr': 'Şifre'
    },
    'googleSignIn': {
      'ar': 'الدخول بـ Google',
      'en': 'Sign in with Google',
      'fr': 'Se connecter Google',
      'tr': 'Google ile Giriş'
    },
    'haveAccount': {
      'ar': 'لديك حساب؟',
      'en': 'Have an account?',
      'fr': 'Déjà un compte?',
      'tr': 'Hesabın var mı?'
    },
    'resetPassword': {
      'ar': 'إعادة تعيين كلمة المرور',
      'en': 'Reset Password',
      'fr': 'Réinitialiser mot de passe',
      'tr': 'Şifreyi Sıfırla'
    },
    'sendResetLink': {
      'ar': 'إرسال رابط التغيير',
      'en': 'Send Reset Link',
      'fr': 'Envoyer lien',
      'tr': 'Sıfırlama bağlantısı gönder'
    },

    // ── أخطاء التحقق ─────────────────────────────────────
    'errorRequired': {
      'ar': 'هذا الحقل مطلوب',
      'en': 'Required field',
      'fr': 'Champ obligatoire',
      'tr': 'Bu alan zorunludur'
    },
    'errorInvalidEmail': {
      'ar': 'بريد إلكتروني غير صحيح',
      'en': 'Invalid email',
      'fr': 'Email invalide',
      'tr': 'Geçersiz e-posta'
    },
    'errorWeakPassword': {
      'ar': 'كلمة المرور ضعيفة (6+)',
      'en': 'Password too short (6+)',
      'fr': 'Mot de passe trop court',
      'tr': 'Şifre çok kısa (6+)'
    },
    'errorPasswordMismatch': {
      'ar': 'كلمتا المرور غير متطابقتين',
      'en': 'Passwords don\'t match',
      'fr': 'Mots de passe différents',
      'tr': 'Şifreler eşleşmiyor'
    },
    'errorNameShort': {
      'ar': 'الاسم قصير جداً',
      'en': 'Name too short',
      'fr': 'Nom trop court',
      'tr': 'Ad çok kısa'
    },

    // ── رسائل النجاح ─────────────────────────────────────
    'savedSuccess': {
      'ar': 'تم الحفظ ✓',
      'en': 'Saved ✓',
      'fr': 'Sauvegardé ✓',
      'tr': 'Kaydedildi ✓'
    },
    'deletedSuccess': {
      'ar': 'تم الحذف ✓',
      'en': 'Deleted ✓',
      'fr': 'Supprimé ✓',
      'tr': 'Silindi ✓'
    },
    'sentSuccess': {
      'ar': 'تم الإرسال ✓',
      'en': 'Sent ✓',
      'fr': 'Envoyé ✓',
      'tr': 'Gönderildi ✓'
    },

    // ── ملف شخصي ─────────────────────────────────────────
    'editProfile': {
      'ar': 'تعديل الملف الشخصي',
      'en': 'Edit Profile',
      'fr': 'Modifier Profil',
      'tr': 'Profili Düzenle'
    },
    'changePassword': {
      'ar': 'تغيير كلمة المرور',
      'en': 'Change Password',
      'fr': 'Changer Mot Passe',
      'tr': 'Şifre Değiştir'
    },
    'totalProjects': {
      'ar': 'إجمالي المشاريع',
      'en': 'Total Projects',
      'fr': 'Total Projets',
      'tr': 'Toplam Proje'
    },
    'totalConcrete': {
      'ar': 'إجمالي الخرسانة',
      'en': 'Total Concrete',
      'fr': 'Total Béton',
      'tr': 'Toplam Beton'
    },
    'activeAccount': {
      'ar': 'حساب نشط',
      'en': 'Active Account',
      'fr': 'Compte Actif',
      'tr': 'Aktif Hesap'
    },
    'termsOfUse': {
      'ar': 'شروط الاستخدام',
      'en': 'Terms of Use',
      'fr': 'Conditions d\'utilisation',
      'tr': 'Kullanım Koşulları'
    },
    'privacyPolicy': {
      'ar': 'سياسة الخصوصية',
      'en': 'Privacy Policy',
      'fr': 'Politique Confidentialité',
      'tr': 'Gizlilik Politikası'
    },
    'rateApp': {
      'ar': 'قيّم التطبيق',
      'en': 'Rate App',
      'fr': 'Évaluer App',
      'tr': 'Uygulamayı Değerlendir'
    },
    'deleteAllProjects': {
      'ar': 'حذف جميع المشاريع',
      'en': 'Delete All Projects',
      'fr': 'Supprimer tous projets',
      'tr': 'Tüm projeleri sil'
    },
    'logoutConfirm': {
      'ar': 'هل أنت متأكد من الخروج؟',
      'en': 'Sure you want to sign out?',
      'fr': 'Voulez-vous vous déconnecter?',
      'tr': 'Çıkmak istediğinize emin misiniz?'
    },

    // ── onboarding ───────────────────────────────────────
    'welcome': {
      'ar': 'مرحباً في بنّاء',
      'en': 'Welcome to Bannaa',
      'fr': 'Bienvenue à Bannaa',
      'tr': 'Bannaa\'ya Hoş Geldiniz'
    },
    'welcomeSub': {
      'ar': 'تطبيقك الذكي لحساب كميات البناء',
      'en': 'Your smart construction calculator',
      'fr': 'Votre calculateur intelligent',
      'tr': 'Akıllı inşaat hesaplayıcınız'
    },
    'startNow': {
      'ar': 'ابدأ الآن',
      'en': 'Get Started',
      'fr': 'Commencer',
      'tr': 'Başla'
    },
    'skip': {'ar': 'تخطي', 'en': 'Skip', 'fr': 'Passer', 'tr': 'Atla'},
    'next2': {
      'ar': 'التالي →',
      'en': 'Next →',
      'fr': 'Suivant →',
      'tr': 'İleri →'
    },

    // ── مواد وترجمات إضافية ──────────────────────────────
    'brick': {'ar': 'طابوق', 'en': 'Brick', 'fr': 'Brique', 'tr': 'Tuğla'},
    'plaster': {
      'ar': 'جبس/بياض',
      'en': 'Plaster',
      'fr': 'Plâtre',
      'tr': 'Alçı'
    },
    'tiles': {'ar': 'بلاط', 'en': 'Tiles', 'fr': 'Carrelage', 'tr': 'Fayans'},
    'brickUnit': {
      'ar': 'ألف قطعة',
      'en': '1000 pcs',
      'fr': '1000 pièces',
      'tr': '1000 adet'
    },
    'perM2': {'ar': 'م²', 'en': 'm²', 'fr': 'm²', 'tr': 'm²'},
    'user': {
      'ar': 'مستخدم',
      'en': 'User',
      'fr': 'Utilisateur',
      'tr': 'Kullanıcı'
    },

    // ── الحاسبة السريعة ──────────────────────────────────
    'quickCalc': {
      'ar': 'الحاسبة السريعة 🧮',
      'en': 'Quick Calculator 🧮',
      'fr': 'Calculatrice Rapide 🧮',
      'tr': 'Hızlı Hesap 🧮'
    },
    'quickCalcSub': {
      'ar': 'احسب فورياً بدون حفظ مشروع',
      'en': 'Calculate instantly without saving',
      'fr': 'Calculer sans sauvegarder',
      'tr': 'Kaydetmeden hesapla'
    },
    'tabConcrete': {
      'ar': 'الخرسانة',
      'en': 'Concrete',
      'fr': 'Béton',
      'tr': 'Beton'
    },
    'tabMaterials': {
      'ar': 'المواد',
      'en': 'Materials',
      'fr': 'Matériaux',
      'tr': 'Malzemeler'
    },
    'tabSteel': {'ar': 'الحديد', 'en': 'Steel', 'fr': 'Acier', 'tr': 'Çelik'},
    'tabPrices': {
      'ar': 'الأسعار',
      'en': 'Prices',
      'fr': 'Prix',
      'tr': 'Fiyatlar'
    },
    'concreteDimTitle': {
      'ar': 'أبعاد العنصر الخرساني',
      'en': 'Concrete Element Dimensions',
      'fr': 'Dimensions de l\'élément',
      'tr': 'Beton Eleman Boyutları'
    },
    'enterConcreteVol': {
      'ar': 'أدخل حجم الخرسانة',
      'en': 'Enter Concrete Volume',
      'fr': 'Entrer Volume Béton',
      'tr': 'Beton Hacmi Girin'
    },
    'totalConcreteVol': {
      'ar': 'الحجم الكلي للخرسانة',
      'en': 'Total Concrete Volume',
      'fr': 'Volume Total Béton',
      'tr': 'Toplam Beton Hacmi'
    },
    'customMixRatios': {
      'ar': 'تخصيص نسب الخلط يدوياً',
      'en': 'Customize Mix Ratios Manually',
      'fr': 'Personnaliser les ratios',
      'tr': 'Karışım Oranlarını Özelleştir'
    },
    'resetCodeRatios': {
      'ar': 'إعادة نسب الكود الأصلية',
      'en': 'Reset Original Code Ratios',
      'fr': 'Réinitialiser les ratios',
      'tr': 'Orijinal Kod Oranlarını Sıfırla'
    },
    'calcMaterials': {
      'ar': 'احسب المواد',
      'en': 'Calculate Materials',
      'fr': 'Calculer Matériaux',
      'tr': 'Malzemeleri Hesapla'
    },
    'materialQty': {
      'ar': 'كميات المواد',
      'en': 'Material Quantities',
      'fr': 'Quantités de Matériaux',
      'tr': 'Malzeme Miktarları'
    },
    'steelCalcTitle': {
      'ar': 'حاسبة الحديد والتسليح',
      'en': 'Steel & Rebar Calculator',
      'fr': 'Calculatrice Acier',
      'tr': 'Çelik & Demir Hesaplama'
    },
    'diameter': {
      'ar': 'القطر (مم)',
      'en': 'Diameter (mm)',
      'fr': 'Diamètre (mm)',
      'tr': 'Çap (mm)'
    },
    'barLength': {
      'ar': 'طول القضيب',
      'en': 'Bar Length',
      'fr': 'Longueur de barre',
      'tr': 'Demir Uzunluğu'
    },
    'barCount': {
      'ar': 'عدد القضبان',
      'en': 'Number of Bars',
      'fr': 'Nombre de barres',
      'tr': 'Demir Sayısı'
    },
    'barUnit': {'ar': 'قضيب', 'en': 'bar', 'fr': 'barre', 'tr': 'demir'},
    'meterWeightInfo': {
      'ar': 'وزن المتر',
      'en': 'Weight per meter',
      'fr': 'Poids par mètre',
      'tr': 'Metre ağırlığı'
    },
    'calcSteel': {
      'ar': 'احسب الحديد',
      'en': 'Calculate Steel',
      'fr': 'Calculer Acier',
      'tr': 'Çeliği Hesapla'
    },
    'steelResult': {
      'ar': 'نتيجة الحديد',
      'en': 'Steel Result',
      'fr': 'Résultat Acier',
      'tr': 'Çelik Sonucu'
    },
    'selectedDiameter': {
      'ar': 'القطر المختار',
      'en': 'Selected Diameter',
      'fr': 'Diamètre Sélectionné',
      'tr': 'Seçilen Çap'
    },
    'totalLength': {
      'ar': 'إجمالي الطول',
      'en': 'Total Length',
      'fr': 'Longueur Totale',
      'tr': 'Toplam Uzunluk'
    },
    'priceListTitle': {
      'ar': 'أسعار مواد البناء',
      'en': 'Construction Material Prices',
      'fr': 'Prix Matériaux Construction',
      'tr': 'İnşaat Malzeme Fiyatları'
    },
    'tapToEditPrice': {
      'ar': 'اضغط على أي مادة لتعديل سعرها · الأسعار تُحفظ تلقائياً',
      'en': 'Tap any material to edit its price · Prices auto-saved',
      'fr': 'Appuyez pour modifier · Prix sauvegardés auto',
      'tr': 'Fiyat düzenlemek için dokunun · Otomatik kaydedilir'
    },
    'resetDefaultPrices': {
      'ar': 'إعادة الأسعار الافتراضية',
      'en': 'Reset Default Prices',
      'fr': 'Réinitialiser Prix par Défaut',
      'tr': 'Varsayılan Fiyatları Sıfırla'
    },
    'concreteVolResult': {
      'ar': 'حجم الخرسانة',
      'en': 'Concrete Volume',
      'fr': 'Volume Béton',
      'tr': 'Beton Hacmi'
    },
    'gradeLabel': {
      'ar': 'الدرجة',
      'en': 'Grade',
      'fr': 'Classe',
      'tr': 'Sınıf'
    },
    'cementBag50': {
      'ar': 'أسمنت (كيس 50كغ)',
      'en': 'Cement (50kg bag)',
      'fr': 'Ciment (sac 50kg)',
      'tr': 'Çimento (50kg)'
    },
    'costEstim': {
      'ar': 'تكلفة تقديرية',
      'en': 'Estimated Cost',
      'fr': 'Coût Estimé',
      'tr': 'Tahmini Maliyet'
    },
    'costLabel': {'ar': 'التكلفة', 'en': 'Cost', 'fr': 'Coût', 'tr': 'Maliyet'},
    'cementPortland': {
      'ar': 'أسمنت بورتلاندي',
      'en': 'Portland Cement',
      'fr': 'Ciment Portland',
      'tr': 'Portland Çimentosu'
    },
    'sandBuild': {
      'ar': 'رمل بناء',
      'en': 'Building Sand',
      'fr': 'Sable de construction',
      'tr': 'İnşaat Kumu'
    },
    'gravelMix': {
      'ar': 'حجر / زلط',
      'en': 'Gravel / Crushed Stone',
      'fr': 'Gravier / Pierre concassée',
      'tr': 'Çakıl / Kırma Taş'
    },
    'steelRebar': {
      'ar': 'حديد تسليح',
      'en': 'Steel Rebar',
      'fr': 'Acier d\'armature',
      'tr': 'İnşaat Demiri'
    },
    'brickRed': {
      'ar': 'طابوق أحمر / أسمنتي',
      'en': 'Red / Concrete Brick',
      'fr': 'Brique rouge / Ciment',
      'tr': 'Kırmızı / Beton Tuğla'
    },
    'plasterMat': {
      'ar': 'جبس / بياض',
      'en': 'Plaster / Whitewash',
      'fr': 'Plâtre / Badigeon',
      'tr': 'Alçı / Badana'
    },
    'tilesCeramic': {
      'ar': 'بلاط / سيراميك',
      'en': 'Tiles / Ceramic',
      'fr': 'Carrelage / Céramique',
      'tr': 'Fayans / Seramik'
    },
    'bag50unit': {
      'ar': 'كيس 50 كغ',
      'en': '50 kg bag',
      'fr': 'sac 50 kg',
      'tr': '50 kg çuval'
    },
    'bag40unit': {
      'ar': 'كيس 40 كغ',
      'en': '40 kg bag',
      'fr': 'sac 40 kg',
      'tr': '40 kg çuval'
    },
    'thousandPcs': {
      'ar': 'ألف قطعة',
      'en': '1000 pieces',
      'fr': '1000 pièces',
      'tr': '1000 adet'
    },

    // ── تحسينات الحاسبة ──────────────────────────────────
    'liveResults': {
      'ar': 'نتائج مباشرة',
      'en': 'Live Results',
      'fr': 'Résultats en direct',
      'tr': 'Canlı Sonuçlar'
    },
    'calcHistory': {
      'ar': 'السجل',
      'en': 'History',
      'fr': 'Historique',
      'tr': 'Geçmiş'
    },
    'clearHistory': {
      'ar': 'مسح السجل',
      'en': 'Clear History',
      'fr': 'Effacer',
      'tr': 'Geçmişi Temizle'
    },
    'noHistory': {
      'ar': 'لا توجد حسابات سابقة',
      'en': 'No previous calculations',
      'fr': 'Aucun calcul',
      'tr': 'Hesaplama yok'
    },
    'dimGuide': {
      'ar': 'دليل الأبعاد',
      'en': 'Dimension Guide',
      'fr': 'Guide des dimensions',
      'tr': 'Boyut Kılavuzu'
    },
    'heightDepth': {
      'ar': 'الارتفاع / العمق',
      'en': 'Height / Depth',
      'fr': 'Hauteur / Profondeur',
      'tr': 'Yükseklik / Derinlik'
    },
    'unitCount': {'ar': 'وحدة', 'en': 'unit', 'fr': 'unité', 'tr': 'adet'},
    'savedToHistory': {
      'ar': 'حُفظ في السجل',
      'en': 'Saved to history',
      'fr': 'Sauvegardé',
      'tr': 'Geçmişe kaydedildi'
    },
    'timeNow': {
      'ar': 'الآن',
      'en': 'just now',
      'fr': 'maintenant',
      'tr': 'şimdi'
    },
    'timeMinutes': {
      'ar': 'منذ {n} د',
      'en': '{n} min ago',
      'fr': 'il y a {n} min',
      'tr': '{n} dk önce'
    },
    'timeHours': {
      'ar': 'منذ {n} س',
      'en': '{n} hr ago',
      'fr': 'il y a {n} h',
      'tr': '{n} sa önce'
    },
    'mm': {'ar': 'مم', 'en': 'mm', 'fr': 'mm', 'tr': 'mm'},
    'barWeightPerM': {
      'ar': 'وزن المتر',
      'en': 'Weight/m',
      'fr': 'Poids/m',
      'tr': 'Ağırlık/m'
    },
    'totalWeight': {
      'ar': 'الوزن الإجمالي',
      'en': 'Total Weight',
      'fr': 'Poids Total',
      'tr': 'Toplam Ağırlık'
    },

    // ── login_screen ─────────────────────────────────────
    'appName': {'ar': 'بنّاء', 'en': 'Bannaa', 'fr': 'Bannaa', 'tr': 'Bannaa'},
    'appSubtitle': {
      'ar': 'حاسبة كميات البناء',
      'en': 'Construction Calculator',
      'fr': 'Calc. Construction',
      'tr': 'İnşaat Hesaplayıcı'
    },
    'welcomeBack': {
      'ar': 'مرحباً بك 👋',
      'en': 'Welcome Back 👋',
      'fr': 'Bienvenue 👋',
      'tr': 'Hoş Geldiniz 👋'
    },
    'loginSubtitle': {
      'ar': 'سجّل دخولك للمتابعة',
      'en': 'Sign in to continue',
      'fr': 'Connectez-vous pour continuer',
      'tr': 'Devam etmek için giriş yapın'
    },
    'emailLabel': {
      'ar': 'البريد الإلكتروني',
      'en': 'Email',
      'fr': 'Email',
      'tr': 'E-posta'
    },
    'passwordLabel': {
      'ar': 'كلمة المرور',
      'en': 'Password',
      'fr': 'Mot de Passe',
      'tr': 'Şifre'
    },
    'forgotPassword': {
      'ar': 'نسيت كلمة المرور؟',
      'en': 'Forgot password?',
      'fr': 'Mot de passe oublié?',
      'tr': 'Şifreyi unuttunuz mu?'
    },
    'loginBtn': {
      'ar': 'تسجيل الدخول',
      'en': 'Sign In',
      'fr': 'Se Connecter',
      'tr': 'Giriş Yap'
    },
    'orDivider': {'ar': 'أو', 'en': 'or', 'fr': 'ou', 'tr': 'veya'},
    'googleSignInBtn': {
      'ar': 'الدخول بحساب Google',
      'en': 'Continue with Google',
      'fr': 'Continuer avec Google',
      'tr': 'Google ile devam et'
    },
    'noAccount': {
      'ar': 'ليس لديك حساب؟ ',
      'en': 'No account? ',
      'fr': 'Pas de compte? ',
      'tr': 'Hesabınız yok mu? '
    },
    'createNewAccount': {
      'ar': 'إنشاء حساب جديد',
      'en': 'Create Account',
      'fr': 'Créer un compte',
      'tr': 'Hesap Oluştur'
    },

    // ── validation messages ───────────────────────────────
    'errEnterEmail': {
      'ar': 'يرجى إدخال البريد الإلكتروني',
      'en': 'Please enter your email',
      'fr': 'Veuillez saisir votre email',
      'tr': 'Lütfen e-postanızı girin'
    },
    'errInvalidEmail': {
      'ar': 'صيغة البريد الإلكتروني غير صحيحة',
      'en': 'Invalid email format',
      'fr': 'Format d\'email invalide',
      'tr': 'Geçersiz e-posta formatı'
    },
    'errEnterPassword': {
      'ar': 'يرجى إدخال كلمة المرور',
      'en': 'Please enter your password',
      'fr': 'Veuillez saisir votre mot de passe',
      'tr': 'Lütfen şifrenizi girin'
    },
    'errPasswordLength': {
      'ar': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      'en': 'Password must be at least 6 characters',
      'fr': 'Mot de passe: 6 caractères min',
      'tr': 'Şifre en az 6 karakter olmalı'
    },
    'errPasswordMatch': {
      'ar': 'كلمتا المرور غير متطابقتين',
      'en': 'Passwords do not match',
      'fr': 'Les mots de passe ne correspondent pas',
      'tr': 'Şifreler eşleşmiyor'
    },
    'errAgreeTerms': {
      'ar': 'يرجى الموافقة على الشروط والأحكام',
      'en': 'Please agree to the terms',
      'fr': 'Veuillez accepter les conditions',
      'tr': 'Lütfen şartları kabul edin'
    },
    'errRequired': {
      'ar': 'مطلوب',
      'en': 'Required',
      'fr': 'Requis',
      'tr': 'Gerekli'
    },
    'errInvalidNumber': {
      'ar': 'غير صحيح',
      'en': 'Invalid',
      'fr': 'Invalide',
      'tr': 'Geçersiz'
    },
    'errNameLength': {
      'ar': 'يرجى إدخال الاسم كاملاً (3 أحرف على الأقل)',
      'en': 'Name must be at least 3 characters',
      'fr': 'Nom: 3 caractères min',
      'tr': 'Ad en az 3 karakter olmalı'
    },

    // ── register_screen ───────────────────────────────────
    'createAccount': {
      'ar': 'إنشاء حساب جديد',
      'en': 'Create Account',
      'fr': 'Créer un Compte',
      'tr': 'Hesap Oluştur'
    },
    'welcomeRegister': {
      'ar': 'أهلاً بك في بنّاء 🏗️',
      'en': 'Welcome to Bannaa 🏗️',
      'fr': 'Bienvenue sur Bannaa 🏗️',
      'tr': 'Bannaa’ya Hoş Geldiniz 🏗️'
    },
    'registerSubtitle': {
      'ar': 'أنشئ حسابك وابدأ الآن',
      'en': 'Create your account now',
      'fr': 'Créez votre compte',
      'tr': 'Hesabınızı oluşturun'
    },
    'fullName': {
      'ar': 'الاسم الكامل',
      'en': 'Full Name',
      'fr': 'Nom Complet',
      'tr': 'Ad Soyad'
    },
    'fullNameHint': {
      'ar': 'م. أحمد الكناني',
      'en': 'Eng. John Smith',
      'fr': 'Ing. Jean Dupont',
      'tr': 'Müh. Ahmet Kaya'
    },
    'confirmPassword': {
      'ar': 'تأكيد كلمة المرور',
      'en': 'Confirm Password',
      'fr': 'Confirmer Mot de Passe',
      'tr': 'Şifreyi Onayla'
    },
    'agreeToTerms': {
      'ar': 'أوافق على شروط الاستخدام وسياسة الخصوصية',
      'en': 'I agree to Terms of Use and Privacy Policy',
      'fr': 'J\'accepte les conditions',
      'tr': 'Kullanım koşullarını kabul ediyorum'
    },
    'registerBtn': {
      'ar': 'إنشاء الحساب',
      'en': 'Create Account',
      'fr': 'Créer le Compte',
      'tr': 'Hesap Oluştur'
    },
    'hasAccount': {
      'ar': 'لديك حساب بالفعل؟ ',
      'en': 'Already have account? ',
      'fr': 'Déjà un compte? ',
      'tr': 'Hesabınız var mı? '
    },
    'goToLogin': {
      'ar': 'تسجيل الدخول',
      'en': 'Sign In',
      'fr': 'Se Connecter',
      'tr': 'Giriş Yap'
    },
    'checkEmail': {
      'ar': 'تحقق من بريدك الإلكتروني',
      'en': 'Check Your Email',
      'fr': 'Vérifiez Votre Email',
      'tr': 'E-postanızı Kontrol Edin'
    },
    'verifyEmailSent': {
      'ar': 'أرسلنا رابط التحقق إلى',
      'en': 'We sent a verification link to',
      'fr': 'Nous avons envoyé un lien à',
      'tr': 'Doğrulama bağlantısı gönderildi'
    },
    'goToHome': {
      'ar': 'الذهاب للرئيسية',
      'en': 'Go to Home',
      'fr': 'Aller à l\'Accueil',
      'tr': 'Ana Sayfaya Git'
    },
    'passStrengthWeak2': {
      'ar': 'ضعيفة جداً',
      'en': 'Very Weak',
      'fr': 'Très Faible',
      'tr': 'Çok Zayıf'
    },
    'passStrengthWeak': {
      'ar': 'ضعيفة',
      'en': 'Weak',
      'fr': 'Faible',
      'tr': 'Zayıf'
    },
    'passStrengthMedium': {
      'ar': 'متوسطة',
      'en': 'Medium',
      'fr': 'Moyen',
      'tr': 'Orta'
    },
    'passStrengthStrong': {
      'ar': 'قوية ✓',
      'en': 'Strong ✓',
      'fr': 'Fort ✓',
      'tr': 'Güçlü ✓'
    },

    // ── forgot_password_screen ────────────────────────────
    'forgotPasswordTitle': {
      'ar': 'نسيت كلمة المرور',
      'en': 'Forgot Password',
      'fr': 'Mot de Passe Oublié',
      'tr': 'Şifremi Unuttum'
    },
    'resetPasswordTitle': {
      'ar': 'إعادة تعيين كلمة المرور',
      'en': 'Reset Password',
      'fr': 'Réinitialiser Mot de Passe',
      'tr': 'Şifreyi Sıfırla'
    },
    'resetInstructions': {
      'ar': 'أدخل بريدك الإلكتروني وسنرسل لك رابطاً\nلإعادة تعيين كلمة المرور',
      'en': 'Enter your email and we\'ll send a reset link',
      'fr': 'Entrez votre email, nous vous enverrons un lien',
      'tr': 'E-postanızı girin, sıfırlama bağlantısı göndereceğiz'
    },
    'sendResetLinkBtn': {
      'ar': 'إرسال رابط إعادة التعيين',
      'en': 'Send Reset Link',
      'fr': 'Envoyer le Lien',
      'tr': 'Sıfırlama Bağlantısı Gönder'
    },
    'linkSent': {
      'ar': 'تم إرسال الرابط! ✓',
      'en': 'Link Sent! ✓',
      'fr': 'Lien Envoyé! ✓',
      'tr': 'Bağlantı Gönderildi! ✓'
    },
    'checkEmailReset': {
      'ar': 'تحقق من بريدك الإلكتروني\n',
      'en': 'Check your email\n',
      'fr': 'Vérifiez votre email\n',
      'tr': 'E-postanızı kontrol edin\n'
    },
    'resetClickLink': {
      'ar': 'وانقر على الرابط لإعادة تعيين كلمة المرور',
      'en': 'and click the link to reset your password',
      'fr': 'et cliquez sur le lien',
      'tr': 've şifreyi sıfırlamak için bağlantıya tıklayın'
    },
    'resendLink': {
      'ar': 'إعادة الإرسال',
      'en': 'Resend',
      'fr': 'Renvoyer',
      'tr': 'Yeniden Gönder'
    },
    'backToLogin': {
      'ar': 'العودة لتسجيل الدخول',
      'en': 'Back to Sign In',
      'fr': 'Retour à la connexion',
      'tr': 'Girişe Dön'
    },

    // ── dimensions_screen ─────────────────────────────────
    'enterDimensions': {
      'ar': 'إدخال الأبعاد',
      'en': 'Enter Dimensions',
      'fr': 'Saisir les Dimensions',
      'tr': 'Boyutları Girin'
    },
    'dimensionsStep': {
      'ar': 'الأبعاد والمكوّنات',
      'en': 'Dimensions & Components',
      'fr': 'Dimensions & Composants',
      'tr': 'Boyutlar ve Bileşenler'
    },
    'totalVolSoFar': {
      'ar': 'الحجم الكلي حتى الآن',
      'en': 'Total Volume So Far',
      'fr': 'Volume Total Jusqu\'ici',
      'tr': 'Şimdiye Kadar Toplam Hacim'
    },
    'addComponent': {
      'ar': '＋ إضافة مكوّن',
      'en': '＋ Add Component',
      'fr': '＋ Ajouter Composant',
      'tr': '＋ Bileşen Ekle'
    },
    'calculateQty': {
      'ar': 'احسب الكميات',
      'en': 'Calculate Quantities',
      'fr': 'Calculer les Quantités',
      'tr': 'Miktarları Hesapla'
    },
    'addProjectComponents': {
      'ar': 'أضف مكوّنات المشروع',
      'en': 'Add Project Components',
      'fr': 'Ajouter des Composants',
      'tr': 'Proje Bileşenleri Ekleyin'
    },
    'componentsExamples': {
      'ar': 'أعمدة، أسقف، أساسات، جدران...',
      'en': 'Columns, slabs, foundations, walls...',
      'fr': 'Colonnes, dalles, fondations...',
      'tr': 'Kolonlar, plaklar, temeller, duvarlar...'
    },
    'addComponentTitle': {
      'ar': 'إضافة مكوّن',
      'en': 'Add Component',
      'fr': 'Ajouter Composant',
      'tr': 'Bileşen Ekle'
    },
    'addComponentBtn': {
      'ar': 'إضافة المكوّن',
      'en': 'Add Component',
      'fr': 'Ajouter',
      'tr': 'Ekle'
    },
    'depthLabel': {
      'ar': 'العمق (م)',
      'en': 'Depth (m)',
      'fr': 'Profondeur (m)',
      'tr': 'Derinlik (m)'
    },
    'heightDimLabel': {
      'ar': 'الارتفاع (م)',
      'en': 'Height (m)',
      'fr': 'Hauteur (m)',
      'tr': 'Yükseklik (m)'
    },
    'lengthDimLabel': {
      'ar': 'الطول (م)',
      'en': 'Length (m)',
      'fr': 'Longueur (m)',
      'tr': 'Uzunluk (m)'
    },
    'widthDimLabel': {
      'ar': 'العرض (م)',
      'en': 'Width (m)',
      'fr': 'Largeur (m)',
      'tr': 'Genişlik (m)'
    },
    'countDimLabel': {
      'ar': 'العدد',
      'en': 'Count',
      'fr': 'Nombre',
      'tr': 'Adet'
    },
    'errAtLeastOne': {
      'ar': 'يرجى إضافة مكوّن واحد على الأقل',
      'en': 'Please add at least one component',
      'fr': 'Ajoutez au moins un composant',
      'tr': 'En az bir bileşen ekleyin'
    },
    'units': {'ar': 'وحدات', 'en': 'units', 'fr': 'unités', 'tr': 'birim'},

    // ── results_screen ────────────────────────────────────
    'resultsTitle': {
      'ar': 'نتائج الحسابات',
      'en': 'Calculation Results',
      'fr': 'Résultats des Calculs',
      'tr': 'Hesaplama Sonuçları'
    },
    'gradePrefix': {
      'ar': 'الدرجة:',
      'en': 'Grade:',
      'fr': 'Classe:',
      'tr': 'Sınıf:'
    },
    'totalConcreteVolumeTitle': {
      'ar': 'إجمالي حجم الخرسانة',
      'en': 'Total Concrete Volume',
      'fr': 'Volume Total Béton',
      'tr': 'Toplam Beton Hacmi'
    },
    'estimatedCostTitle': {
      'ar': 'التكلفة التقديرية',
      'en': 'Estimated Cost',
      'fr': 'Coût Estimé',
      'tr': 'Tahmini Maliyet'
    },
    'materialDetails': {
      'ar': 'تفاصيل المواد',
      'en': 'Material Details',
      'fr': 'Détails Matériaux',
      'tr': 'Malzeme Detayları'
    },
    'materialsCount': {
      'ar': 'مواد',
      'en': 'materials',
      'fr': 'matériaux',
      'tr': 'malzeme'
    },
    'pdfError': {
      'ar': 'حدث خطأ أثناء إنشاء PDF',
      'en': 'Error generating PDF',
      'fr': 'Erreur génération PDF',
      'tr': 'PDF oluşturma hatası'
    },
    'savedSuccess2': {
      'ar': 'تم الحفظ ✓',
      'en': 'Saved ✓',
      'fr': 'Sauvegardé ✓',
      'tr': 'Kaydedildi ✓'
    },
    'generatePdfBtn': {
      'ar': 'إنشاء تقرير PDF',
      'en': 'Generate PDF Report',
      'fr': 'Générer Rapport PDF',
      'tr': 'PDF Rapor Oluştur'
    },
    'costDistribution': {
      'ar': 'توزيع التكاليف',
      'en': 'Cost Distribution',
      'fr': 'Distribution des coûts',
      'tr': 'Maliyet Dağılımı'
    },
    'materialComparison': {
      'ar': 'مقارنة المواد',
      'en': 'Material Comparison',
      'fr': 'Comparaison des matériaux',
      'tr': 'Malzeme Karşılaştırması'
    },
    'tapSlice': {
      'ar': 'اضغط على الشريحة للتفاصيل',
      'en': 'Tap slice for details',
      'fr': 'Appuyez pour les détails',
      'tr': 'Dilime dokunun'
    },

    // ── report_screen ─────────────────────────────────────
    'finalReport': {
      'ar': 'التقرير النهائي',
      'en': 'Final Report',
      'fr': 'Rapport Final',
      'tr': 'Son Rapor'
    },
    'reportTitle': {
      'ar': 'تقرير كميات البناء',
      'en': 'Construction Quantities Report',
      'fr': 'Rapport de Quantités',
      'tr': 'İnşaat Miktarları Raporu'
    },
    'appBrand': {'ar': 'بنّاء', 'en': 'Bannaa', 'fr': 'Bannaa', 'tr': 'Bannaa'},
    'floorsSuffix': {
      'ar': 'طوابق',
      'en': 'floors',
      'fr': 'étages',
      'tr': 'kat'
    },
    'materialCol': {
      'ar': 'المادة',
      'en': 'Material',
      'fr': 'Matériau',
      'tr': 'Malzeme'
    },
    'quantityCol': {
      'ar': 'الكمية',
      'en': 'Quantity',
      'fr': 'Quantité',
      'tr': 'Miktar'
    },
    'costCol': {'ar': 'التكلفة', 'en': 'Cost', 'fr': 'Coût', 'tr': 'Maliyet'},
    'grandTotal': {
      'ar': 'الإجمالي الكلي',
      'en': 'Grand Total',
      'fr': 'Total Général',
      'tr': 'Genel Toplam'
    },
    'reportNote': {
      'ar':
          '⚠️ الأسعار تقديرية بناءً على أسعار السوق. قد تختلف حسب المورد والمنطقة والكمية.',
      'en':
          '⚠️ Prices are estimates based on market rates. May vary by supplier, region, and quantity.',
      'fr': '⚠️ Prix estimés selon le marché. Peuvent varier.',
      'tr': '⚠️ Fiyatlar piyasa fiyatlarına göre tahmindir.'
    },
    'reportOptions': {
      'ar': 'خيارات التقرير',
      'en': 'Report Options',
      'fr': 'Options du Rapport',
      'tr': 'Rapor Seçenekleri'
    },
    'inclMaterialTable': {
      'ar': 'تضمين جدول المواد',
      'en': 'Include Materials Table',
      'fr': 'Inclure tableau matériaux',
      'tr': 'Malzeme tablosu dahil et'
    },
    'inclPrices': {
      'ar': 'تضمين الأسعار والتكاليف',
      'en': 'Include Prices & Costs',
      'fr': 'Inclure prix et coûts',
      'tr': 'Fiyatları dahil et'
    },
    'inclNote': {
      'ar': 'تضمين ملاحظة التنبيه',
      'en': 'Include Warning Note',
      'fr': 'Inclure note d\'avertissement',
      'tr': 'Uyarı notunu dahil et'
    },
    'downloadPdf': {
      'ar': 'تنزيل وتصدير PDF',
      'en': 'Download & Export PDF',
      'fr': 'Télécharger PDF',
      'tr': 'PDF İndir ve Dışa Aktar'
    },
    'copyText': {
      'ar': 'نسخ النص',
      'en': 'Copy Text',
      'fr': 'Copier le Texte',
      'tr': 'Metni Kopyala'
    },
    'shareBtn': {
      'ar': 'مشاركة',
      'en': 'Share',
      'fr': 'Partager',
      'tr': 'Paylaş'
    },
    'reportCopied': {
      'ar': 'تم نسخ التقرير ✓',
      'en': 'Report copied ✓',
      'fr': 'Rapport copié ✓',
      'tr': 'Rapor kopyalandı ✓'
    },
    'date': {'ar': 'التاريخ', 'en': 'Date', 'fr': 'Date', 'tr': 'Tarih'},
    'estimatedPricesNote': {
      'ar': '* الأسعار تقديرية حسب أسعار السوق',
      'en': '* Prices are market estimates',
      'fr': '* Prix estimés du marché',
      'tr': '* Fiyatlar piyasa tahminleridir'
    },

    // ── home_screen و my_projects_screen ─────────────────
    'greeting': {
      'ar': 'أهلاً،',
      'en': 'Hello,',
      'fr': 'Bonjour,',
      'tr': 'Merhaba,'
    },
    'welcomeUser': {
      'ar': 'مرحباً بك 👷',
      'en': 'Welcome Back 👷',
      'fr': 'Bienvenue 👷',
      'tr': 'Hoş Geldin 👷'
    },
    // ── تحيات الرئيسية حسب الوقت ─────────────────────────
    'greetingMorning': {
      'ar': 'صباح الخير',
      'en': 'Good Morning',
      'fr': 'Bonjour',
      'tr': 'Günaydın'
    },
    'greetingAfternoon': {
      'ar': 'مساء الخير',
      'en': 'Good Afternoon',
      'fr': 'Bon après-midi',
      'tr': 'İyi öğleden sonralar'
    },
    'greetingEvening': {
      'ar': 'مساء النور',
      'en': 'Good Evening',
      'fr': 'Bonsoir',
      'tr': 'İyi akşamlar'
    },
    // ── نصوص الرئيسية ────────────────────────────────────
    'quickToolsTitle': {
      'ar': 'الأدوات',
      'en': 'Tools',
      'fr': 'Outils',
      'tr': 'Araçlar'
    },
    'continueLastProject': {
      'ar': 'تابع آخر مشروع',
      'en': 'Continue Last Project',
      'fr': 'Continuer le dernier projet',
      'tr': 'Son projeye devam et'
    },
    'activeSyncLabel': {
      'ar': 'مزامنة فعّالة',
      'en': 'Live Sync',
      'fr': 'Sync active',
      'tr': 'Aktif senkron'
    },
    'quoteRequestsTitle': {
      'ar': 'طلبات عروض الأسعار',
      'en': 'Quote Requests',
      'fr': 'Demandes de devis',
      'tr': 'Teklif Talepleri'
    },
    'noQuotesYet': {
      'ar': 'لا توجد طلبات بعد',
      'en': 'No requests yet',
      'fr': 'Aucune demande',
      'tr': 'Henüz talep yok'
    },
    'quotesSent': {
      'ar': 'طلب مرسل',
      'en': 'request sent',
      'fr': 'demande envoyée',
      'tr': 'talep gönderildi'
    },
    'newReplies': {
      'ar': 'رد جديد',
      'en': 'new reply',
      'fr': 'nouvelle réponse',
      'tr': 'yeni yanıt'
    },
    'componentCount': {
      'ar': 'مكوّن',
      'en': 'component',
      'fr': 'composant',
      'tr': 'bileşen'
    },
    'deleteProjectConfirmMsg': {
      'ar': 'سيُحذف هذا المشروع نهائياً ولا يمكن التراجع.',
      'en': 'This project will be permanently deleted.',
      'fr': 'Ce projet sera supprimé définitivement.',
      'tr': 'Bu proje kalıcı olarak silinecek.'
    },
    'inProgress': {
      'ar': 'قيد التنفيذ',
      'en': 'In Progress',
      'fr': 'En cours',
      'tr': 'Devam ediyor'
    },
    'lastProjects': {
      'ar': 'آخر المشاريع',
      'en': 'Recent Projects',
      'fr': 'Projets Récents',
      'tr': 'Son Projeler'
    },
    'noProjectsYet': {
      'ar': 'لا توجد مشاريع بعد',
      'en': 'No projects yet',
      'fr': 'Aucun projet',
      'tr': 'Henüz proje yok'
    },
    'startFirst': {
      'ar': 'ابدأ بإنشاء مشروعك الأول الآن',
      'en': 'Start by creating your first project',
      'fr': 'Créez votre premier projet',
      'tr': 'İlk projenizi oluşturun'
    },
    'projectsCount': {
      'ar': 'المشاريع',
      'en': 'Projects',
      'fr': 'Projets',
      'tr': 'Projeler'
    },
    'thisMonth': {
      'ar': 'هذا الشهر',
      'en': 'This Month',
      'fr': 'Ce Mois',
      'tr': 'Bu Ay'
    },
    'totalConcreteM3': {
      'ar': 'إجمالي م³',
      'en': 'Total m³',
      'fr': 'Total m³',
      'tr': 'Toplam m³'
    },
    'completed': {
      'ar': 'مكتمل',
      'en': 'Done',
      'fr': 'Terminé',
      'tr': 'Tamamlandı'
    },
    'sortBy': {
      'ar': 'ترتيب حسب',
      'en': 'Sort By',
      'fr': 'Trier Par',
      'tr': 'Sıralama'
    },
    'searchHint': {
      'ar': 'ابحث بالاسم أو المدينة...',
      'en': 'Search by name or city...',
      'fr': 'Rechercher par nom ou ville...',
      'tr': 'Ad veya şehre göre ara...'
    },
    'allTypes': {'ar': 'الكل', 'en': 'All', 'fr': 'Tous', 'tr': 'Tümü'},
    'noResults': {
      'ar': 'لا توجد نتائج',
      'en': 'No results',
      'fr': 'Aucun résultat',
      'tr': 'Sonuç yok'
    },
    'tryChangeSearch': {
      'ar': 'جرّب تغيير كلمة البحث أو الفلتر',
      'en': 'Try changing your search or filter',
      'fr': 'Essayez de changer votre recherche',
      'tr': 'Arama veya filtreyi değiştirin'
    },
    'sortNewest': {
      'ar': 'الأحدث أولاً',
      'en': 'Newest First',
      'fr': 'Plus Récent',
      'tr': 'En Yeni'
    },
    'sortCost': {
      'ar': 'الأعلى تكلفة',
      'en': 'Highest Cost',
      'fr': 'Coût Le Plus Élevé',
      'tr': 'En Yüksek Maliyet'
    },
    'sortName': {
      'ar': 'الاسم (أبجدي)',
      'en': 'Name (A-Z)',
      'fr': 'Nom (A-Z)',
      'tr': 'Ad (A-Z)'
    },
    'sortDate': {'ar': 'التاريخ', 'en': 'Date', 'fr': 'Date', 'tr': 'Tarih'},
    'sortCostLabel': {
      'ar': 'التكلفة',
      'en': 'Cost',
      'fr': 'Coût',
      'tr': 'Maliyet'
    },
    'sortNameLabel': {'ar': 'الاسم', 'en': 'Name', 'fr': 'Nom', 'tr': 'Ad'},
    'totalCosts': {
      'ar': 'إجمالي التكاليف',
      'en': 'Total Costs',
      'fr': 'Coûts Totaux',
      'tr': 'Toplam Maliyetler'
    },
    'totalConcreteStat': {
      'ar': 'إجمالي الخرسانة',
      'en': 'Total Concrete',
      'fr': 'Béton Total',
      'tr': 'Toplam Beton'
    },
    'mostCommon': {
      'ar': 'الأكثر شيوعاً',
      'en': 'Most Common',
      'fr': 'Le Plus Courant',
      'tr': 'En Yaygın'
    },
    'projectsTotal': {
      'ar': 'مشروع إجمالاً',
      'en': 'projects total',
      'fr': 'projets au total',
      'tr': 'toplam proje'
    },
    'deleteProjectTitle': {
      'ar': 'حذف المشروع',
      'en': 'Delete Project',
      'fr': 'Supprimer Projet',
      'tr': 'Projeyi Sil'
    },
    'deleteProjectConfirm': {
      'ar': 'هل تريد حذف',
      'en': 'Delete',
      'fr': 'Supprimer',
      'tr': 'Silmek ister misin'
    },
    'concrete': {
      'ar': 'خرسانة',
      'en': 'concrete',
      'fr': 'béton',
      'tr': 'beton'
    },
    'component': {
      'ar': 'مكوّن',
      'en': 'component',
      'fr': 'composant',
      'tr': 'bileşen'
    },
    'newProject2': {'ar': 'جديد', 'en': 'New', 'fr': 'Nouveau', 'tr': 'Yeni'},
    'signOutConfirm': {
      'ar': 'هل أنت متأكد من تسجيل الخروج؟',
      'en': 'Sure you want to sign out?',
      'fr': 'Voulez-vous vous déconnecter?',
      'tr': 'Çıkmak istediğinize emin misiniz?'
    },
    'totalCostAll': {
      'ar': 'إجمالي التكاليف',
      'en': 'Total Cost',
      'fr': 'Coût total',
      'tr': 'Toplam Maliyet'
    },
    'smartSuggestion': {
      'ar': 'اقتراح ذكي',
      'en': 'Smart Suggestion',
      'fr': 'Suggestion intelligente',
      'tr': 'Akıllı Öneri'
    },
    'continueProject': {
      'ar': 'تابع آخر مشروع',
      'en': 'Continue Last Project',
      'fr': 'Continuer le projet',
      'tr': 'Projeye devam et'
    },
    'pullRefresh': {
      'ar': 'اسحب للتحديث',
      'en': 'Pull to refresh',
      'fr': 'Tirer pour actualiser',
      'tr': 'Yenilemek için çekin'
    },
    'projectProgress': {
      'ar': 'تقدم المشروع',
      'en': 'Project Progress',
      'fr': 'Avancement du projet',
      'tr': 'Proje ilerlemesi'
    },
    'noComponents': {
      'ar': 'لا توجد مكوّنات بعد',
      'en': 'No components yet',
      'fr': 'Aucun composant',
      'tr': 'Henüz bileşen yok'
    },

    // ── صفحة الملف الشخصي ────────────────────────────────
    'buildingCodeSection': {
      'ar': 'كود البناء والحسابات',
      'en': 'Building Code & Calc',
      'fr': 'Code & Calculs',
      'tr': 'Yapı Kodu & Hesap'
    },
    'pricesSection': {
      'ar': 'أسعار المواد',
      'en': 'Material Prices',
      'fr': 'Prix Matériaux',
      'tr': 'Malzeme Fiyatları'
    },
    'approvedMixRatios': {
      'ar': 'نسب الخلط المعتمدة',
      'en': 'Approved Mix Ratios',
      'fr': 'Ratios Approuvés',
      'tr': 'Onaylı Karışım Oranları'
    },
    'engineeringCode': {
      'ar': 'الكود الهندسي',
      'en': 'Engineering Code',
      'fr': 'Code Ingénierie',
      'tr': 'Mühendislik Kodu'
    },
    'editName': {
      'ar': 'تعديل الاسم',
      'en': 'Edit Name',
      'fr': 'Modifier Nom',
      'tr': 'Adı Düzenle'
    },
    'saveChanges': {
      'ar': 'حفظ التغييرات',
      'en': 'Save Changes',
      'fr': 'Sauvegarder',
      'tr': 'Değişiklikleri Kaydet'
    },
    'sendResetTo': {
      'ar': 'سنرسل رابط إعادة التعيين إلى:',
      'en': 'We will send a reset link to:',
      'fr': 'Nous enverrons un lien à:',
      'tr': 'Sıfırlama bağlantısı gönderilecek:'
    },
    'editPriceTitle': {
      'ar': 'تعديل سعر',
      'en': 'Edit Price',
      'fr': 'Modifier Prix',
      'tr': 'Fiyatı Düzenle'
    },
    'pricePerUnit': {
      'ar': 'السعر لكل',
      'en': 'Price per',
      'fr': 'Prix par',
      'tr': 'Birim fiyat'
    },
    'perUnit': {'ar': 'لكل', 'en': 'per', 'fr': 'par', 'tr': 'başına'},
    'chooseLanguage': {
      'ar': 'اختر اللغة',
      'en': 'Choose Language',
      'fr': 'Choisir Langue',
      'tr': 'Dil Seçin'
    },
    'resetPricesBtn': {
      'ar': 'إعادة ضبط',
      'en': 'Reset',
      'fr': 'Réinitialiser',
      'tr': 'Sıfırla'
    },
    'deleteAllConfirm': {
      'ar':
          'سيتم حذف جميع مشاريعك المحفوظة نهائياً.\nهذا الإجراء لا يمكن التراجع عنه.',
      'en':
          'All your saved projects will be permanently deleted.\nThis action cannot be undone.',
      'fr':
          'Tous vos projets sauvegardés seront supprimés.\nCette action est irréversible.',
      'tr':
          'Tüm kayıtlı projeleriniz kalıcı olarak silinecek.\nBu işlem geri alınamaz.'
    },
    'linkSentSuccess': {
      'ar': 'تم إرسال الرابط ✓',
      'en': 'Link sent ✓',
      'fr': 'Lien envoyé ✓',
      'tr': 'Bağlantı gönderildi ✓'
    },
    'projectsDeleted': {
      'ar': 'تم حذف جميع المشاريع ✓',
      'en': 'All projects deleted ✓',
      'fr': 'Projets supprimés ✓',
      'tr': 'Tüm projeler silindi ✓'
    },
    'projectWord': {
      'ar': 'مشروع',
      'en': 'project',
      'fr': 'projet',
      'tr': 'proje'
    },
    'concreteM3': {
      'ar': 'م³ خرسانة',
      'en': 'm³ concrete',
      'fr': 'm³ béton',
      'tr': 'm³ beton'
    },
    'theCode': {'ar': 'الكود', 'en': 'Code', 'fr': 'Code', 'tr': 'Kod'},
    'logout': {
      'ar': 'تسجيل الخروج',
      'en': 'Sign Out',
      'fr': 'Déconnexion',
      'tr': 'Çıkış Yap'
    },
    'logoutTitle': {
      'ar': 'تسجيل الخروج',
      'en': 'Sign Out',
      'fr': 'Déconnexion',
      'tr': 'Çıkış'
    },
    'areYouSure': {
      'ar': 'هل أنت متأكد؟',
      'en': 'Are you sure?',
      'fr': 'Êtes-vous sûr?',
      'tr': 'Emin misiniz?'
    },
    'signOut': {'ar': 'خروج', 'en': 'Sign Out', 'fr': 'Quitter', 'tr': 'Çık'},

    // ── المرحلة الثانية: الحاسبة ─────────────────────────
    'saveToHistory': {
      'ar': 'حفظ في السجل',
      'en': 'Save to History',
      'fr': 'Sauvegarder dans l\'historique',
      'tr': 'Geçmişe kaydet'
    },
    'compareMode': {
      'ar': 'وضع المقارنة',
      'en': 'Compare Mode',
      'fr': 'Mode comparaison',
      'tr': 'Karşılaştırma modu'
    },
    'calcSavedToHistory': {
      'ar': 'تم حفظ الحساب في السجل',
      'en': 'Saved to history',
      'fr': 'Sauvegardé dans l\'historique',
      'tr': 'Geçmişe kaydedildi'
    },

    // ── المرحلة الثانية: عام ──────────────────────────────
    'excellent': {
      'ar': 'ممتاز',
      'en': 'Excellent',
      'fr': 'Excellent',
      'tr': 'Mükemmel'
    },
    'good': {'ar': 'جيد', 'en': 'Good', 'fr': 'Bien', 'tr': 'İyi'},
    'viewAll': {
      'ar': 'عرض الكل',
      'en': 'View All',
      'fr': 'Voir tout',
      'tr': 'Tümünü gör'
    },
    'close': {'ar': 'إغلاق', 'en': 'Close', 'fr': 'Fermer', 'tr': 'Kapat'},

    // ── شريط التنقل السفلي ────────────────────────────────
    'navHome': {
      'ar': 'الرئيسية',
      'en': 'Home',
      'fr': 'Accueil',
      'tr': 'Ana Sayfa'
    },
    'navProjects': {
      'ar': 'مشاريعي',
      'en': 'Projects',
      'fr': 'Projets',
      'tr': 'Projeler'
    },
    'navCalculator': {
      'ar': 'الحاسبة',
      'en': 'Calculator',
      'fr': 'Calculatrice',
      'tr': 'Hesaplama'
    },
    'navAerial': {
      'ar': 'إسقاط جوي',
      'en': 'Aerial',
      'fr': 'Aérien',
      'tr': 'Havadan'
    },
    'navProfile': {
      'ar': 'حسابي',
      'en': 'Profile',
      'fr': 'Profil',
      'tr': 'Hesabım'
    },

    // ── حذف بالسحب — تأكيد ───────────────────────────────
    'swipeDeleteTitle': {
      'ar': 'حذف المشروع',
      'en': 'Delete Project',
      'fr': 'Supprimer le projet',
      'tr': 'Projeyi Sil'
    },
    'swipeDeleteBody': {
      'ar': 'سيتم حذف هذا المشروع بشكل نهائي ولا يمكن التراجع.',
      'en': 'This project will be permanently deleted and cannot be undone.',
      'fr': 'Ce projet sera définitivement supprimé et ne peut être annulé.',
      'tr': 'Bu proje kalıcı olarak silinecek ve geri alınamaz.'
    },
    'swipeDeleteConfirm': {
      'ar': 'نعم، احذف',
      'en': 'Yes, Delete',
      'fr': 'Oui, supprimer',
      'tr': 'Evet, Sil'
    },
    'calcHistoryClearedMsg': {
      'ar': 'تم مسح سجل الحسابات',
      'en': 'Calculation history cleared',
      'fr': 'Historique effacé',
      'tr': 'Hesap geçmişi temizlendi'
    },

    // ── مفاتيح شاشة التسجيل المُضافة ────────────────────
    'accountTypeLabel': {
      'ar': 'نوع الحساب',
      'en': 'Account type',
      'fr': 'Type de compte',
      'tr': 'Hesap türü'
    },
    'badgeUser': {
      'ar': 'مستخدم عادي',
      'en': 'Regular user',
      'fr': 'Utilisateur',
      'tr': 'Normal kullanıcı'
    },
    'badgeSupplier': {
      'ar': 'مورّد',
      'en': 'Supplier',
      'fr': 'Fournisseur',
      'tr': 'Tedarikçi'
    },
    'userCardSub': {
      'ar': 'احسب كميات\nمواد البناء',
      'en': 'Calculate\nconstruction materials',
      'fr': 'Calculez les\nmatériaux de construction',
      'tr': 'İnşaat malzemelerini\nhesapla'
    },
    'supplierCardSub': {
      'ar': 'انشر عروض\nالمواد والخدمات',
      'en': 'Post material\n& service offers',
      'fr': 'Publiez des offres\nde matériaux',
      'tr': 'Malzeme ve hizmet\nteklifleri yayınla'
    },
    'supplierNameLabel': {
      'ar': 'اسم المتجر / الشركة',
      'en': 'Store / Company name',
      'fr': 'Nom du magasin / entreprise',
      'tr': 'Mağaza / Şirket adı'
    },
    'supplierNameHint': {
      'ar': 'مثال: شركة الخليج للمواد',
      'en': 'e.g. Gulf Materials Co.',
      'fr': 'ex: Matériaux Gulf',
      'tr': 'örn: Gulf Malzemeleri'
    },
    'registerSupplierBtn': {
      'ar': 'إنشاء حساب المورّد',
      'en': 'Create supplier account',
      'fr': 'Créer compte fournisseur',
      'tr': 'Tedarikçi hesabı oluştur'
    },
    'successSupplierTitle': {
      'ar': 'تم إنشاء حساب المورّد!',
      'en': 'Supplier account created!',
      'fr': 'Compte fournisseur créé !',
      'tr': 'Tedarikçi hesabı oluşturuldu!'
    },
    'successUserTitle': {
      'ar': 'تم إنشاء الحساب!',
      'en': 'Account created!',
      'fr': 'Compte créé !',
      'tr': 'Hesap oluşturuldu!'
    },
    'successSupplierBody': {
      'ar':
          'مرحباً بك في منصة بنّاء كمورّد معتمد.\nيمكنك الآن تلقي الطلبات وإدارة عروضك.',
      'en':
          'Welcome to Bannaa as a certified supplier.\nYou can now receive orders and manage your offers.',
      'fr':
          'Bienvenue sur Bannaa en tant que fournisseur.\nVous pouvez recevoir des commandes.',
      'tr':
          'Bannaa\'ya onaylı tedarikçi olarak hoş geldiniz.\nArtık sipariş alabilirsiniz.'
    },
    'successUserBody': {
      'ar': 'مرحباً {name}!\nحسابك جاهز، ابدأ باستخدام التطبيق الآن.',
      'en': 'Welcome {name}!\nYour account is ready, start using the app now.',
      'fr': 'Bienvenue {name} !\nVotre compte est prêt.',
      'tr':
          'Hoş geldiniz {name}!\nHesabınız hazır, uygulamayı kullanmaya başlayın.'
    },
    'goDashboardBtn': {
      'ar': 'الذهاب للوحة التحكم',
      'en': 'Go to dashboard',
      'fr': 'Aller au tableau de bord',
      'tr': 'Panele git'
    },
    'startNowBtn': {
      'ar': 'ابدأ الآن',
      'en': 'Start now',
      'fr': 'Commencer',
      'tr': 'Şimdi başla'
    },

    // ── مفاتيح بطاقات الأدوات السريعة ───────────────────
    'toolCalcTitle': {
      'ar': 'الحاسبة',
      'en': 'Calculator',
      'fr': 'Calculatrice',
      'tr': 'Hesaplama'
    },
    'toolCalcSub': {
      'ar': 'احسب الكميات\nفوراً',
      'en': 'Calculate quantities\ninstantly',
      'fr': 'Calculez les quantités\ninstantanément',
      'tr': 'Miktarları anında\nhesapla'
    },
    'toolMapTitle': {
      'ar': 'إسقاط جوي',
      'en': 'Aerial projection',
      'fr': 'Projection aérienne',
      'tr': 'Hava projeksiyonu'
    },
    'toolMapSub': {
      'ar': 'ارسم أرضك\nعلى الخريطة',
      'en': 'Draw your plot\non the map',
      'fr': 'Dessinez votre terrain\nsur la carte',
      'tr': 'Arazini harita\nüzerinde çiz'
    },
    'projectNameHint': {
      'ar': 'مثال: فيلا العائلة',
      'en': 'e.g. Family Villa',
      'fr': 'ex : Villa de famille',
      'tr': 'örn: Aile Villası'
    },
    'floorsCount': {
      'ar': 'عدد الطوابق',
      'en': 'Number of floors',
      'fr': 'Nombre d\u0027étages',
      'tr': 'Kat sayısı'
    },
    'cityLabel': {
      'ar': 'المنطقة / المدينة',
      'en': 'Region / City',
      'fr': 'Région / Ville',
      'tr': 'Bölge / Şehir'
    },
    'cityHint': {
      'ar': 'مثال: الرياض',
      'en': 'e.g. Riyadh',
      'fr': 'ex : Riyad',
      'tr': 'örn: Riyad'
    },
    'errCityRequired': {
      'ar': 'يرجى إدخال المدينة',
      'en': 'Please enter the city',
      'fr': 'Veuillez entrer la ville',
      'tr': 'Lütfen şehri girin'
    },
    'nextDimensions': {
      'ar': 'التالي: إدخال الأبعاد',
      'en': 'Next: Enter dimensions',
      'fr': 'Suivant : Entrer les dimensions',
      'tr': 'Sonraki: Ölçüleri girin'
    },
    // ── مفاتيح جديدة مضافة من المراجعة ──────────────────
    // project_detail_screen
    'projectDetails': {
      'ar': 'تفاصيل المشروع',
      'en': 'Project Details',
      'fr': 'Détails du Projet',
      'tr': 'Proje Detayları'
    },
    'overviewTab': {
      'ar': 'نظرة عامة',
      'en': 'Overview',
      'fr': 'Aperçu',
      'tr': 'Genel Bakış'
    },
    'componentsTab': {
      'ar': 'المكوّنات',
      'en': 'Components',
      'fr': 'Composants',
      'tr': 'Bileşenler'
    },
    'costsTab': {
      'ar': 'التكاليف',
      'en': 'Costs',
      'fr': 'Coûts',
      'tr': 'Maliyetler'
    },
    'editComponents': {
      'ar': 'تعديل المكوّنات',
      'en': 'Edit components',
      'fr': 'Modifier les composants',
      'tr': 'Bileşenleri düzenle'
    },
    'viewReport': {
      'ar': 'عرض التقرير',
      'en': 'View report',
      'fr': 'Voir le rapport',
      'tr': 'Raporu görüntüle'
    },
    'componentsCount': {
      'ar': 'عدد المكوّنات',
      'en': 'Components',
      'fr': 'Composants',
      'tr': 'Bileşen sayısı'
    },
    'componentSuffix': {
      'ar': 'مكوّن',
      'en': 'comp.',
      'fr': 'comp.',
      'tr': 'bileşen'
    },
    'floorSuffix': {'ar': 'طابق', 'en': 'floor', 'fr': 'étage', 'tr': 'kat'},
    'materialSummary': {
      'ar': 'ملخص المواد',
      'en': 'Materials summary',
      'fr': 'Résumé des matériaux',
      'tr': 'Malzeme özeti'
    },
    'projectInfo': {
      'ar': 'معلومات المشروع',
      'en': 'Project info',
      'fr': 'Infos du projet',
      'tr': 'Proje bilgileri'
    },
    'typeLabel': {'ar': 'النوع', 'en': 'Type', 'fr': 'Type', 'tr': 'Tür'},
    'cityInfo': {'ar': 'المدينة', 'en': 'City', 'fr': 'Ville', 'tr': 'Şehir'},
    'createdDate': {
      'ar': 'تاريخ الإنشاء',
      'en': 'Created',
      'fr': 'Créé le',
      'tr': 'Oluşturulma'
    },
    'projectIdLabel': {'ar': 'المعرّف', 'en': 'ID', 'fr': 'ID', 'tr': 'Kimlik'},
    'totalCostFull': {
      'ar': 'التكلفة التقديرية الكاملة',
      'en': 'Full estimated cost',
      'fr': 'Coût total estimé',
      'tr': 'Toplam tahmini maliyet'
    },
    'addComponents': {
      'ar': 'إضافة مكوّنات',
      'en': 'Add components',
      'fr': 'Ajouter des composants',
      'tr': 'Bileşen ekle'
    },
    'pricesNote': {
      'ar':
          'الأسعار تقديرية وتختلف حسب المورد والمنطقة. يُنصح بمراجعة مهندس مختص.',
      'en':
          'Prices are estimates and vary by supplier and region. Consult a qualified engineer.',
      'fr':
          'Les prix sont estimatifs et varient selon le fournisseur. Consultez un ingénieur.',
      'tr':
          'Fiyatlar tahminidir ve tedarikçiye göre değişir. Uzman bir mühendise danışın.'
    },
  };

  // ── دالة الترجمة ─────────────────────────────────────────
  String tr(String key) {
    final langCode = locale.languageCode;
    return _translations[key]?[langCode] ?? _translations[key]?['ar'] ?? key;
  }

  // ── ترجمة الوقت ─────────────────────────────────────────
  String trTime(int minutes) {
    if (minutes == 0) return tr('timeNow');
    if (minutes < 60) return tr('timeMinutes').replaceAll('{n}', '$minutes');
    return tr('timeHours').replaceAll('{n}', '${(minutes / 60).floor()}');
  }

  // ── خصائص سهلة الوصول ───────────────────────────────────
  bool get isRtl => locale.languageCode == 'ar';
  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;
}

// ── الـ Delegate ──────────────────────────────────────────
class _BannaaLocalizationsDelegate
    extends LocalizationsDelegate<BannaaLocalizations> {
  const _BannaaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en', 'fr', 'tr'].contains(locale.languageCode);

  @override
  Future<BannaaLocalizations> load(Locale locale) async =>
      BannaaLocalizations(locale);

  @override
  bool shouldReload(_BannaaLocalizationsDelegate old) => false;
}
