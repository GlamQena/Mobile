import 'package:flutter/material.dart';

// Vibrant Lumina unified color system
// Default theme: PINK (light, cosmetic)
// Alternate theme: PURPLE (dark, glamorous)
class AppColors {
  AppColors._();

  // ---------- Brand Core ----------
  static const Color purpleBrandLogo = Color(0xFF6B008A);
  static const Color purpleDark = Color(0xFF7E00A6);
  static const Color pinkMain = Color(0xFFFF69B4);
  static const Color goldMain = Color(0xFFD4AF37);

  // ---------- Legacy Alias Mapping ----------
  // Pink is the DEFAULT brand identity.
  static const Color primary = pinkMain;
  static const Color primaryDark = Color(0xFFFF479D);  // secondaryDark
  static const Color primaryLight = Color(0xFFFF82C4); // secondaryLight

  // Purple is the ALTERNATE brand identity.
  static const Color secondary = purpleDark;
  static const Color secondaryDark = Color(0xFF6B008A); // purpleBrandLogo
  static const Color secondaryLight = Color(0xFF9200C2);

  static const Color tertiary = Color(0xFF7C3AED);

  // ---------- Shades ----------
  static const List<Color> purpleShades = [
    Color(0xFF07040F),
    Color(0xFF0E0516),
    Color(0xFF180824),
    Color(0xFF1C0A2B),
    Color(0xFF2E1065),
    Color(0xFF7E00A6),
    Color(0xFF9200C2),
    Color(0xFFCBAEDC),
    Color(0xFFF8F7FA),
  ];

  static const List<Color> pinkShades = [
    Color(0xFFFFF8FB),
    Color(0xFFFDF0F6),
    Color(0xFFFBE2EF),
    Color(0xFFF8E4EE),
    Color(0xFFFF69B4),
    Color(0xFFFF479D),
    Color(0xFFFF82C4),
    Color(0xFF68487A),
    Color(0xFF251030),
  ];

  // ---------- Status Colors ----------
  static const Color success = Color(0xFF22C55E);
  static const Color successSubtle = Color(0x1A22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSubtle = Color(0x1AEF4444);
  static const Color warning = Color(0xFFD4AF37);
  static const Color warningSubtle = Color(0x26D4AF37);
  static const Color neutral = Color(0xFF79578C);

  /// Default brand gradient — PINK.
  /// Use this for active sidebar tiles, primary CTAs, badges, etc.
  static const List<Color> brandGradient = [
    Color(0xFFFF69B4), // pinkMain      — mid brand
    Color(0xFFff8da1)
  ];

  /// Default hero gradient — PINK over light surfaces.
  /// Use this for hero banners / headers on light backgrounds.
  static const List<Color> heroGradient = [
    Color(0xFFFF69B4), // pinkMain
    Color(0xFFFF82C4), // secondaryLight
    Color(0xFFFBE2EF), // pinkShades[2]
    Color(0xFFFFF8FB), // background
  ];

  /// Purple brand gradient — luminous lavender → deep violet.
  static const List<Color> purpleBrandGradient = [
    Color(0xFF7E00A6), // deep violet (brand anchor)
    Color(0xFF5A0080), // deeper violet (bottom-right depth)
  ];

  /// Purple hero gradient — deep violet → near-black plum.
  /// Use for hero banners / headers on dark backgrounds.
  static const List<Color> purpleHeroGradient = [
    Color(0xFF7E00A6), // deep violet
    Color(0xFF1C0A2B), // near-black plum for depth
  ];

  static const List<Color> purpleSidebarActiveGradient = [
    Color(0xFF9200C2), // rich violet — top-left lift
    Color(0xFF7E00A6), // deep royal purple — brand anchor
  ];

  // ---------- Warm sidebar active gradient (pink mode) ----------
  static const List<Color> pinkSidebarActiveGradient = [
    Color(0xFFFF69B4), // pinkMain — brand anchor
    Color(0xFFFF479D), // deeper rose — bottom-right depth
  ];

  // ================================================================
  // BACKGROUND GRADIENTS
  // ================================================================

  /// Default background gradient — PINK.
  static final Gradient pinkBackgroundGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomCenter,
    colors: const [
      Color(0xFFFDF0F6),
      Color(0xFFFFF8FB),
      Color(0xFFF8E4EE),
    ],
    stops: const [0.0, 0.5, 1.0],
  );

  /// Alternate background gradient — PURPLE.
  static final Gradient purpleBackgroundGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomCenter,
    colors: const [
      Color(0xFF0E0516),
      Color(0xFF07040F),
      Color(0xFF1C0A2B),
    ],
    stops: const [0.0, 0.5, 1.0],
  );
}

// ================================================================
// PURPLE THEME — Dark, glamorous, nocturnal
// ================================================================
class PurpleTheme {
  PurpleTheme._();

  static const Color primaryMain   = AppColors.purpleDark;              // #7E00A6
  static const Color primarySubtle = Color(0x267E00A6);                 // rgba(126,0,166,0.15)
  static const Color borderProminent = Color(0x407E00A6);               // rgba(126,0,166,0.25)
  static const Color errorSubtle = Color(0x1AEF4444);                   // rgba(239,68,68,0.10)

  // Surface Colors
  static const Color background = Color(0xFF07040F);
  static const Color sidebarBackground = Color(0xFF0E0516);
  static const Color surface = Color(0xFF1C0A2B);
  static const Color surfaceVariant = Color(0xFF0E0516);
  static const Color border = Color(0x407E00A6);

  // Navigation
  static const Color navbarBackground = Color(0xD907040F);
  static const Color navbarBorder = Color(0x267E00A6);

  // Typography
  static const Color textPrimary = Color(0xFFF8F7FA);
  static const Color textSecondary = Color(0xFFCBAEDC);
  static const Color textMuted = Color(0xFF79578C);
  static const Color textPlaceholder = Color(0xFF452857);

  // Input
  static const Color inputBackground = Color(0xFF0E0516);
  static const Color inputFocusBackground = Color(0xFF180824);

  // Avatar
  static const Color avatarBg = Color(0xFF2E1065);
  static const Color avatarFg = Color(0xFFF472B6);

  // Status
  static const Color success = AppColors.success;
  static const Color error = AppColors.error;
  static const Color link = AppColors.purpleDark; // purple link in dark mode

  static const LinearGradient sidebarActiveGradient = LinearGradient(
    colors: AppColors.purpleSidebarActiveGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: AppColors.purpleBrandGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ================================================================
// PINK THEME — Light, cosmetic, daytime (DEFAULT)
// ================================================================
class PinkTheme {
  PinkTheme._();

  static const Color primaryMain   = AppColors.pinkMain;                // #FF69B4
  static const Color primarySubtle = Color(0x1AFF69B4);                 // rgba(255,105,180,0.10)
  static const Color borderProminent = Color(0x40FF69B4);               // rgba(255,105,180,0.25)
  static const Color errorSubtle = Color(0x1AEF4444);

  // Surface Colors
  static const Color background = Color(0xFFFFF8FB);
  static const Color sidebarBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFDF0F6);
  static const Color border = Color(0x40FF69B4);

  // Navigation
  static const Color navbarBackground = Color(0xE6FFF8FB);
  static const Color navbarBorder = Color(0x1EFF69B4);

  // Typography
  static const Color textPrimary = Color(0xFF251030);
  static const Color textSecondary = Color(0xFF68487A);
  static const Color textMuted = Color(0xFFA084B3);
  static const Color textPlaceholder = Color(0xFFD1BFDD);

  // Input
  static const Color inputBackground = Color(0xFFFDF0F6);
  static const Color inputFocusBackground = Color(0xFFFBE2EF);

  // Avatar
  static const Color avatarBg = Color(0x1FEC4899);
  static const Color avatarFg = Color(0xFFDB2777);

  // Status
  static const Color success = AppColors.success;
  static const Color error = AppColors.error;
  static const Color link = AppColors.pinkMain;

  static const LinearGradient sidebarActiveGradient = LinearGradient(
    colors: AppColors.pinkSidebarActiveGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: AppColors.brandGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ==========================================
// FLUTTER THEME BUILDERS
// ==========================================

ThemeData buildPurpleTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: PurpleTheme.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purpleDark,
      secondary: AppColors.pinkMain,
      tertiary: AppColors.goldMain,
      surface: PurpleTheme.surface,
      surfaceContainerHighest: PurpleTheme.surfaceVariant,
      error: PurpleTheme.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: PurpleTheme.textPrimary,
      outline: PurpleTheme.border,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: PurpleTheme.textPrimary,
      displayColor: PurpleTheme.textPrimary,
      fontFamily: 'Hanken Grotesk',
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PurpleTheme.inputBackground,
      hintStyle: const TextStyle(color: PurpleTheme.textMuted),
      labelStyle: const TextStyle(color: PurpleTheme.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PurpleTheme.border, width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PurpleTheme.border, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.purpleDark, width: 1.5),
      ),
    ),
    cardColor: PurpleTheme.surface,
    dividerColor: PurpleTheme.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: PurpleTheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

ThemeData buildPinkTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: PinkTheme.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.pinkMain,
      secondary: AppColors.purpleDark,
      tertiary: AppColors.goldMain,
      surface: PinkTheme.surface,
      surfaceContainerHighest: PinkTheme.surfaceVariant,
      error: PinkTheme.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: PinkTheme.textPrimary,
      outline: PinkTheme.border,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: PinkTheme.textPrimary,
      displayColor: PinkTheme.textPrimary,
      fontFamily: 'Hanken Grotesk',
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PinkTheme.inputBackground,
      hintStyle: const TextStyle(color: PinkTheme.textMuted),
      labelStyle: const TextStyle(color: PinkTheme.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PinkTheme.border, width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PinkTheme.border, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.pinkMain, width: 1.5),
      ),
    ),
    cardColor: PinkTheme.surface,
    dividerColor: PinkTheme.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: PinkTheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
  );
}