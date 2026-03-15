# ==============================================
#  قواعد ProGuard لتحسين حجم APK
# ==============================================

# ── Firebase ───────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ── Flutter ───────────────────────────────────-
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ── Google Maps ───────────────────────────────
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

# ── Hive ───────────────────────────────────────
-keep class org.hive.** { *; }
-keep class io.hive.** { *; }

# ── Provider ─────────────────────────────────--
-keep class provider.** { *; }

# ──_keep enum classes ─────────────────────────-
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ── إزالة log في الإنتاج ─────────────────────-
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ── تجنب خطأ Duplicate ─────────────────────---
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit**
-dontwarn okhttp3.**
-dontwarn okio.**

# ── حماية النماذج ─────────────────────────────-
-keep class com.bannaa.bannaa_app.models.** { *; }
-keep class com.bannaa.bannaa_app.services.** { *; }
