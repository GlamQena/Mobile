import 'package:flutter/material.dart';
import '../public/app_colors.dart';
import '../public/app_effects.dart';

Future<void> showSnackBarCustom({
  required BuildContext context,
  required String message,
  required bool isSuccess,
  required bool isPurpleMode,
}) async {
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final Color accent = isSuccess ? AppColors.success : AppColors.error;

  final Color baseSurface = isPurpleMode
      ? PurpleTheme.surface       // #1C0A2B
      : PinkTheme.surface;        // #FFFFFF

  final Color tintedBackground =
      Color.alphaBlend(accent.withValues(alpha: 0.10), baseSurface);

  final Color borderColor = accent.withValues(alpha: 0.30);

  final Color foreground = accent;

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.down,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        decoration: BoxDecoration(
          color: tintedBackground,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: isPurpleMode
                  ? Colors.black.withValues(alpha: 0.55)
                  : AppColors.pinkMain.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: accent.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ----- Left accent bar-----
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent,
                        accent.withValues(alpha: 0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.sm,
                    top: AppSpacing.md,
                    bottom: AppSpacing.md,
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    color: accent,
                    size: 22,
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.sm,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        message,
                        style: TextStyle(
                          color: foreground,  
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: IconButton(
                    splashRadius: 18,
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    color: accent.withValues(alpha: 0.70),
                    onPressed: messenger.hideCurrentSnackBar,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}