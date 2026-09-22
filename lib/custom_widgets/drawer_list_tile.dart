import 'package:flutter/material.dart';
import '../public/app_colors.dart';
import '../public/app_effects.dart';

class DrawerListTile extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isPurpleMode;
  final bool? enabled;
  final Color? titleColor;

  /// Mirrors `.drawer-logout` — red fg + `--error-subtle` tap tint.
  final bool isDestructive;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isSelected,
    required this.isPurpleMode,
    this.titleColor,
    this.enabled,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AuthThemeColors.of(context, isPurple: isPurpleMode);
    final bool isEnabled = enabled ?? true;
    final double opacity = isEnabled ? 1.0 : 0.45;

    final Color primary =
        isPurpleMode ? PurpleTheme.primaryMain : PinkTheme.primaryMain;
    final Color subtleBg = AppShadows.drawerActiveBg(isPurple: isPurpleMode);
    final Color rim      = AppShadows.drawerActiveRim(isPurple: isPurpleMode);
    final Color tapBg    = isDestructive
        ? AppShadows.drawerLogoutBg()   // --error-subtle
        : subtleBg;                     // --primary-subtle

    // Foreground priority: explicit > destructive > selected > default.
    final Color fgColor = titleColor ??
        (isDestructive
            ? t.error
            : isSelected
                ? primary
                : t.textPrimary);

    /// `.drawer-link.active` background; null = transparent container.
    final Color? bgColor =
        (isSelected && !isDestructive) ? subtleBg : null;

    final Border? border = isSelected
        ? Border.all(color: rim, width: 1.0)
        : null;

    final List<BoxShadow>? shadow =
        isSelected ? AppShadows.drawerActiveGlow(isPurple: isPurpleMode) : null;

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: border,
          boxShadow: shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
            splashColor: tapBg,
            highlightColor: tapBg,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Center(
                      child: IconTheme(
                        data: IconThemeData(color: fgColor, size: 18),
                        child: icon,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 14.5,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (isSelected && !isDestructive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.55),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
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
}