import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../public/app_colors.dart';
import '../../public/app_effects.dart';

class FormGroup extends StatefulWidget {
  final bool isPurpleMode;
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final String hintText;
  final String? helperText;
  final int? maxLength;
  final int? maxLines;
  final Widget? prefixIcon;
  final int? errorMaxLines;
  final String? Function(String?)? validator;
  final bool isDob;
  final bool isPassword;

  const FormGroup({
    super.key,
    required this.isPurpleMode,
    required this.controller,
    required this.label,
    required this.isRequired,
    this.maxLength,
    this.maxLines,
    this.prefixIcon,
    required this.hintText,
    this.helperText,
    this.errorMaxLines,
    this.validator,
    this.isDob = false,
    this.isPassword = false,
  });

  @override
  State<FormGroup> createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  /// Password visibility lives in State — NOT in the widget.
  /// Mutating widget fields is an anti-pattern; State is the right home.
  late bool _hidePassword;

  @override
  void initState() {
    super.initState();
    _hidePassword = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final t = AuthThemeColors.of(context, isPurple: widget.isPurpleMode);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Label row ----------
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: t.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                if (widget.isRequired) ...[
                  const SizedBox(width: AppSpacing.xs),
                  FaIcon(
                    FontAwesomeIcons.asterisk,
                    color: t.error,
                    size: 6,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ---------- Input ----------
          TextFormField(
            controller: widget.controller,
            maxLength: widget.maxLength,
            minLines: 1,
            maxLines: _hidePassword ? 1 : widget.maxLines,
            cursorColor: t.primary,
            cursorErrorColor: t.error,
            obscureText: _hidePassword,
            style: TextStyle(
              color: t.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              prefixIcon: widget.prefixIcon,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: t.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              helperText: widget.helperText ?? "",
              helperMaxLines: 2,
              helperStyle: TextStyle(
                color: t.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              errorMaxLines: widget.errorMaxLines,
              errorStyle: TextStyle(
                color: t.error,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              isDense: true,
              filled: true,
              fillColor: t.surfaceVariant,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: t.border, width: 0.8),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: t.primary, width: 1.2),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: t.error, width: 0.8),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: t.error, width: 1.2),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              suffix: _buildSuffix(t),
            ),
            validator: widget.validator,
          ),
        ],
      ),
    );
  }

  // ---------- Suffix (calendar / eye / empty) ----------
  Widget _buildSuffix(AuthThemeColors t) {
    if (widget.isDob) {
      return GestureDetector(
        onTap: () => _pickDate(context),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Icon(
            Icons.calendar_month,
            color: t.textMuted,
            size: 18,
          ),
        ),
      );
    }

    if (widget.isPassword) {
      return GestureDetector(
        onTap: () => setState(() => _hidePassword = !_hidePassword),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Icon(
            _hidePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: t.textMuted,
            size: 18,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ---------- Date picker ----------
  Locale get _egyptLocale => context.locale.languageCode == 'ar'
      ? const Locale('ar', 'EG')
      : const Locale('en', 'EG');

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
      confirmText: "ok".tr(),
      cancelText: "cancel".tr(),
      helpText: "register_dob_picker".tr(),
      locale: _egyptLocale,
      builder: (context, child) {
        // Optional: keep the picker consistent with the current theme.
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: widget.isPurpleMode
                  ? AppColors.purpleDark
                  : AppColors.pinkMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        widget.controller.text = _formatDate(pickedDate, _egyptLocale);
      });
    }
  }

  String _formatDate(DateTime date, Locale locale) {
    // Force DD/MM/YYYY regardless of locale default.
    return DateFormat('dd/MM/yyyy', locale.toString()).format(date);
    //this method declared in intl package but the easyLocalization package is sufficient as it re-exports the intl API
  }
}