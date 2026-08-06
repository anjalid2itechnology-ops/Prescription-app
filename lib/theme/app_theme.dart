import "package:flutter/material.dart";

class AppColors {
  static const primary = Color(0xFF0F766E);
  static const primaryDark = Color(0xFF115E59);
  static const primaryLight = Color(0xFFCCFBF1);
  static const accent = Color(0xFFF97362);
  static const bg = Color(0xFFF7FAF9);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF14231F);
  static const textSecondary = Color(0xFF5B6B67);
  static const border = Color(0xFFE1E9E7);
  static const success = Color(0xFF15803D);
  static const warning = Color(0xFFB45309);
  static const danger = Color(0xFFB91C1C);
  static const doctorTag = Color(0xFF2563EB);
  static const patientTag = Color(0xFF0F766E);
  static const pharmacistTag = Color(0xFF7C3AED);
  static const adminTag = Color(0xFF57534E);
}

class _Dark {
  static const primary = Color(0xFF2DD4BF);
  static const primaryDark = Color(0xFF115E59);
  static const primaryLight = Color(0xFF134E4A);
  static const accent = Color(0xFFFB8A7A);
  static const bg = Color(0xFF0B1413);
  static const surface = Color(0xFF15201F);
  static const textPrimary = Color(0xFFE7F2EF);
  static const textSecondary = Color(0xFF93A6A2);
  static const border = Color(0xFF223330);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);
}

TextTheme _typography(Color bodyColor, Color displayColor) {
  return const TextTheme().apply(
    bodyColor: bodyColor,
    displayColor: displayColor,
    fontFamily: "Roboto",
  ).copyWith(
    headlineSmall: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4, color: displayColor),
    titleLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3, color: displayColor),
    titleMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.1, color: displayColor),
    bodyLarge: TextStyle(fontSize: 15.5, height: 1.45, color: bodyColor),
    bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: bodyColor),
    labelLarge: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
  );
}

class AppTheme {
  static ThemeData light([Color? accentColor]) {
    final accent = accentColor ?? AppColors.primary;
    final accentTint = accent.withOpacity(0.12);
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: _typography(AppColors.textPrimary, AppColors.textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
          animationDuration: const Duration(milliseconds: 180),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent, textStyle: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent, width: 1.8)),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: accentTint,
        selectedColor: accent,
        labelStyle: TextStyle(color: accent, fontWeight: FontWeight.w700),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: accentTint,
        elevation: 0,
        height: 66,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData dark([Color? accentColor]) {
    final accent = accentColor ?? _Dark.primary;
    final accentTint = accent.withOpacity(0.16);
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    return base.copyWith(
      scaffoldBackgroundColor: _Dark.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: _Dark.accent,
        surface: _Dark.surface,
        error: _Dark.danger,
        onSurface: _Dark.textPrimary,
      ),
      textTheme: _typography(_Dark.textPrimary, _Dark.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: _Dark.surface,
        foregroundColor: _Dark.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(color: _Dark.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: _Dark.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: _Dark.border)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: const Color(0xFF06201D),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: accent)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _Dark.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _Dark.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _Dark.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent, width: 1.8)),
        labelStyle: TextStyle(color: _Dark.textSecondary),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: accentTint,
        selectedColor: accent,
        labelStyle: TextStyle(color: accent, fontWeight: FontWeight.w700),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _Dark.surface,
        indicatorColor: accentTint,
        elevation: 0,
        height: 66,
      ),
      dividerTheme: DividerThemeData(color: _Dark.border, thickness: 1),
      splashFactory: InkRipple.splashFactory,
    );
  }
}

class RoleStyle {
  static Color colorFor(String role) {
    switch (role) {
      case "doctor":
        return AppColors.doctorTag;
      case "patient":
        return AppColors.patientTag;
      case "pharmacist":
        return AppColors.pharmacistTag;
      case "admin":
        return AppColors.adminTag;
      default:
        return AppColors.textSecondary;
    }
  }
}
