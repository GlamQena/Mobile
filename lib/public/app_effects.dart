import 'package:flutter/material.dart';
import '../public/app_colors.dart';

/// Unified spacing scale
class AppSpacing {
  AppSpacing._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
}

/// Unified radii - for border radius
class AppRadii {
  AppRadii._();
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 15.0;
  static const double pill = 30.0;
}

/// Unified shadows — identical across all form pages.
class AppShadows {
  AppShadows._();

  /// Outer glow used by the auth card (login / register).
  static List<BoxShadow> cardGlow({required bool isPurple}) => [
    BoxShadow(
      color: isPurple
          ? Colors.black.withValues(alpha: 0.55)
          : AppColors.pinkMain.withValues(alpha: 0.18),
      blurRadius: 60,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  /// Subtle elevation for inputs / inner surfaces.
  static List<BoxShadow> inputSoft({required bool isPurple}) => [
    BoxShadow(
      color: isPurple
          ? Colors.black.withValues(alpha: 0.35)
          : AppColors.pinkMain.withValues(alpha: 0.06),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  /// Toggle / segmented control inner shadow.
  static List<BoxShadow> toggleInset({required bool isPurple}) => [
    BoxShadow(
      color: isPurple
          ? Colors.black.withValues(alpha: 0.45)
          : AppColors.pinkMain.withValues(alpha: 0.10),
      blurRadius: 6,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];
  
  static Color drawerActiveBg({required bool isPurple}) =>
      isPurple ? PurpleTheme.primarySubtle : PinkTheme.primarySubtle;

  static Color drawerActiveRim({required bool isPurple}) =>
      isPurple ? PurpleTheme.borderProminent : PinkTheme.borderProminent;

  static Color drawerActiveDot({required bool isPurple}) =>
      isPurple ? PurpleTheme.primaryMain : PinkTheme.primaryMain;

  static Color drawerLogoutBg() => AppColors.errorSubtle;

  static List<BoxShadow> drawerActiveGlow({
    required bool isPurple,
    double intensity = 1.0,
  }) {
    final Color primary =
        isPurple ? PurpleTheme.primaryMain : PinkTheme.primaryMain;
    return [
      BoxShadow(
        color: primary.withValues(alpha: 0.10 * intensity),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

class AuthThemeColors {
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color link;
  final Color error;
  final Color unselectedFg;
  final Gradient buttonGradient;

  const AuthThemeColors({
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.link,
    required this.error,
    required this.unselectedFg,
    required this.buttonGradient,
  });

  factory AuthThemeColors.of(BuildContext context, {required bool isPurple}) {
    if (isPurple) {
      return AuthThemeColors(
        surface: PurpleTheme.surface,
        surfaceVariant: PurpleTheme.surfaceVariant,
        border: PurpleTheme.border,
        textPrimary: PurpleTheme.textPrimary,
        textSecondary: PurpleTheme.textSecondary,
        textMuted: PurpleTheme.textMuted,
        primary: AppColors.purpleDark,
        link: PurpleTheme.link,
        error: PurpleTheme.error,
        unselectedFg:
        PurpleTheme.textSecondary.withValues(alpha: 0.40),
        buttonGradient: PurpleTheme.buttonGradient,
      );
    }
    return AuthThemeColors(
      surface: PinkTheme.surface,
      surfaceVariant: PinkTheme.surfaceVariant,
      border: PinkTheme.border,
      textPrimary: PinkTheme.textPrimary,
      textSecondary: PinkTheme.textSecondary,
      textMuted: PinkTheme.textMuted,
      primary: AppColors.pinkMain,
      link: PinkTheme.link,
      error: PinkTheme.error,
      unselectedFg: PinkTheme.textSecondary.withValues(alpha: 0.40),
      buttonGradient: PinkTheme.buttonGradient,
    );
  }
}