import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../public/app_effects.dart';

class AuthToggle extends StatelessWidget {
  /// `true` = Login selected, `false` = Register selected.
  final bool isLoginSelected;
  final bool isPurpleMode;

  const AuthToggle({
    super.key,
    required this.isLoginSelected,
    required this.isPurpleMode,
  });

  @override
  Widget build(BuildContext context) {
    final t = AuthThemeColors.of(context, isPurple: isPurpleMode);
    final selected = [isLoginSelected, !isLoginSelected];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: t.border, width: 0.8),
        boxShadow: AppShadows.toggleInset(isPurple: isPurpleMode),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => ToggleButtons(
          constraints: BoxConstraints(
            maxWidth: (constraints.maxWidth - 3) / 2,
            minWidth: (constraints.maxWidth - 3) / 2,
          ),
          borderRadius: BorderRadius.circular(AppRadii.md),
          selectedColor: Colors.white,
          color: t.unselectedFg,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          isSelected: selected,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          fillColor: Colors.transparent,
          borderColor: Colors.transparent,
          selectedBorderColor: Colors.transparent,
          onPressed: (index) {
            final wantsLogin = index == 0;
            if (wantsLogin == isLoginSelected) return; // already there
            Navigator.of(context).pushReplacementNamed(
              wantsLogin ? "/login" : "/register",
            );
          },
          children: [
            _toggleChild(
              label: "login".tr(),
              selected: selected[0],
              gradient: t.buttonGradient,
              unselectedFg: t.unselectedFg,
            ),
            _toggleChild(
              label: "new_account".tr(),
              selected: selected[1],
              gradient: t.buttonGradient,
              unselectedFg: t.unselectedFg,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleChild({
    required String label,
    required bool selected,
    required Gradient gradient,
    required Color unselectedFg,
  }) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: selected ? gradient : null,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : unselectedFg,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}