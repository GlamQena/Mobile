import 'package:flutter/material.dart';

/// Vibrant Lumina color system — Dark + Light
class AppColors {
  AppColors._();

  // ---------- Primary (Purple) ----------
  static const Color primary = Color(0xFFBD55ED);
  static const Color primaryDark = Color(0xFF6B1FA0);
  static const Color primaryLight = Color(0xFFE9C6F9);

  static const List<Color> primaryShades = [
    Color(0xFF3D0A5C),
    Color(0xFF5A1187),
    Color(0xFF7A1FB0),
    Color(0xFF9A34D6),
    Color(0xFFBD55ED),
    Color(0xFFCE7BF2),
    Color(0xFFDE9FF6),
    Color(0xFFEEC3FA),
    Color(0xFFF9E7FD),
  ];

  // ---------- Secondary (Pink) ----------
  static const Color secondary = Color(0xFFF472B6);
  static const Color secondaryDark = Color(0xFF9D1D53);
  static const Color secondaryLight = Color(0xFFFBD1E4);

  static const List<Color> secondaryShades = [
    Color(0xFF5C0A2A),
    Color(0xFF87113D),
    Color(0xFFB01754),
    Color(0xFFD63472),
    Color(0xFFF472B6),
    Color(0xFFF690C6),
    Color(0xFFF8AED6),
    Color(0xFFFACCE6),
    Color(0xFFFDEAF3),
  ];

  // ---------- Tertiary (Deep Violet) ----------
  static const Color tertiary = Color(0xFF7C3AED);
  static const Color tertiaryDark = Color(0xFF33116B);
  static const Color tertiaryLight = Color(0xFFD9C6FA);

  static const List<Color> tertiaryShades = [
    Color(0xFF1E0A4D),
    Color(0xFF2E1177),
    Color(0xFF4517A6),
    Color(0xFF5F26C8),
    Color(0xFF7C3AED),
    Color(0xFF9560F0),
    Color(0xFFAF86F4),
    Color(0xFFCAADF8),
    Color(0xFFE6D6FC),
  ];

  // ---------- Neutral (Gray) ----------
  static const Color neutral = Color(0xFF7E747F);
  static const Color neutralDark = Color(0xFF1A171B);
  static const Color neutralLight = Color(0xFFE6E3E6);

  static const List<Color> neutralShades = [
    Color(0xFF141214),
    Color(0xFF2A262B),
    Color(0xFF433D44),
    Color(0xFF5E5760),
    Color(0xFF7E747F),
    Color(0xFF9A929E),
    Color(0xFFB8B2BB),
    Color(0xFFD5D1D7),
    Color(0xFFEDEBEE),
  ];

  // ---------- Semantic (shared across modes) ----------
  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);

  // ---------- Gradients ----------
  static const List<Color> brandGradient = [primary, secondary];

  static const LinearGradient diagonalGradient = LinearGradient(
    colors: brandGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient darkBackgroundGradient = RadialGradient(
    center: Alignment.topRight, // Origin point: Top Right
    radius: 1.2, // How wide the glow spreads. 1.0 means it fills the screen, 1.2 pushes it slightly further out.
    colors: [
      Color(0xFF5A1187), // Bright purple glow (AppColors.primaryShades[1])
      Color(0xFF141214), // Deep neutral dark (AppColors.neutralShades[0])
    ],
    stops: [0.1, 0.9], // 0.1 = Glow starts immediately, 0.9 = Fades into dark near the bottom
  );

  static const RadialGradient lightBackgroundGradient = RadialGradient(
    center: Alignment.topLeft, // Origin point: Top Left
    radius: 1.2,
    colors: [
      Color(0xFFFACCE6), // Light pink glow (AppColors.secondaryShades[7])
      Colors.white,      // Pure white
    ],
    stops: [0.1, 0.9],
  );
}

/// Dark-mode-only surface & text tokens
class AppColorsDark {
  AppColorsDark._();

  static const Color background = Color(0xFF121014); //for page
  static const Color surface = Color(0xFF1C1A1F); //for dialogs
  static const Color surfaceVariant = Color(0xFF262229); //for input fields
  static const Color border = Color(0xFF322D35);

  static const Color textPrimary = Color(0xFFF5F3F6);
  static const Color textSecondary = Color(0xFFB8B2BB); //for labels and prefix or suffix icons
  static const Color textDisabled = Color(0xFF6E6771); //for hint text

  static const List<Color> heroGradient = [
    Color(0xFF3D0A5C),
    Color(0xFF8E1FA0),
  ]; //buttons gradient
}

/// Light-mode-only surface & text tokens
class AppColorsLight {
  AppColorsLight._();

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFFFBFD);
  static const Color border = Color(0xFFF3AFD1);

  static const Color textPrimary = Color(0xFF2A1F30);
  static const Color textSecondary = Color(0xFF8A7F91);
  static const Color textDisabled = Color(0xFFC9C1CE);

  static const Color requiredAsterisk = Color(0xFFF43F5E); //for required error message (field borders, writing cursor and message text)
  static const Color link = Color(0xFFEA5FAE);
}

/// Dark ThemeData with gradient buttons
ThemeData buildVibrantLuminaDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColorsDark.surface,
      surfaceContainerHighest: AppColorsDark.surfaceVariant,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColorsDark.textPrimary,
      outline: AppColorsDark.border,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColorsDark.textPrimary,
      displayColor: AppColorsDark.textPrimary,
      fontFamily: 'Hanken Grotesk',
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.surfaceVariant,
      hintStyle: const TextStyle(color: AppColorsDark.textSecondary),
      labelStyle: const TextStyle(color: AppColorsDark.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColorsDark.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColorsDark.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // Transparent for gradient
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        // Transparent to apply gradient using ShaderMask
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsDark.textPrimary,
        side: const BorderSide(color: AppColorsDark.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    cardColor: AppColorsDark.surface,
    dividerColor: AppColorsDark.border,
  );
}

/// Light ThemeData with gradient buttons
ThemeData buildVibrantLuminaLightTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColorsLight.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColorsLight.surface,
      surfaceContainerHighest: AppColorsLight.surfaceVariant,
      error: AppColorsLight.requiredAsterisk,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColorsLight.textPrimary,
      outline: AppColorsLight.border,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColorsLight.textPrimary,
      displayColor: AppColorsLight.textPrimary,
      fontFamily: 'Hanken Grotesk',
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.surfaceVariant,
      hintStyle: const TextStyle(color: AppColorsLight.textSecondary),
      labelStyle: const TextStyle(color: AppColorsLight.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColorsLight.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColorsLight.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColorsLight.requiredAsterisk),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // Transparent for gradient
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        // Apply gradient using ShaderMask when used in the app
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsLight.textPrimary,
        side: const BorderSide(color: AppColorsLight.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    cardColor: AppColorsLight.surface,
    dividerColor: AppColorsLight.border,
  );
}