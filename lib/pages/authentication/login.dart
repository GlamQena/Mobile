import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app/messages_mappers/google_sign_messages.dart';
import 'package:mobile_app/messages_mappers/login_messages.dart';
import 'package:mobile_app/models/auth/google_sign.dart';
import 'package:mobile_app/public/app_effects.dart';
import "../../custom_widgets/auth_toggle.dart";
import "../../custom_widgets/form_group.dart";
import '../../custom_widgets/gradient_button.dart';
import '../../custom_widgets/show_snack_bar.dart';
import '../../models/auth/login.dart';
import '../../services/api_client.dart';
import '../../services/auth/auth.dart';
import '../../services/auth/google_auth.dart';
import "../../services/auth/auth_state.dart";

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final secureStorage = FlutterSecureStorage();
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  final Map<String, TextEditingController> controllers = {
    "usernameOrEmail": TextEditingController(),
    "password": TextEditingController(),
  };

  bool rememberMe = false;
  bool _isSubmitting = false;
  late bool isPurple;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      isPurple = Theme.of(context).brightness == Brightness.dark;
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final LoginRequestBody requestBody = LoginRequestBody(
        usernameOrEmail: controllers["usernameOrEmail"]!.text.trim(),
        password: controllers["password"]!.text,
        rememberMe: rememberMe,
        sessionId: await secureStorage.read(key: "sessionId"),
      );

      final String successMessage = await _authService.login(
        requestBody.toJson(),
      );
      AuthState.setLoggedIn();
      if (!mounted) return;

      showSnackBarCustom(
        context: context,
        message: LoginMessages.getLocalizedMessage(successMessage),
        isSuccess: true,
        isPurpleMode: isPurple,
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.of(context).pushReplacementNamed("/stores");
      });
    } catch (ex) {
      final String errorMessage = _apiClient.extractResponseMessage(
        ex.toString(),
      );

      if (!mounted) return;

      showSnackBarCustom(
        context: context,
        message: LoginMessages.getLocalizedMessage(errorMessage),
        isSuccess: false,
        isPurpleMode: isPurple,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _googleSign() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final GoogleAuthService googleAuthService = GoogleAuthService();
      final GoogleSignInAccount? googleAccount = await googleAuthService
          .signIn();

      if (googleAccount == null) return;

      final String? idToken = googleAccount.authentication.idToken;
      if (idToken == null) {
        if (!mounted) return;
        showSnackBarCustom(
          message: 'google_sign_error_invalid_token'.tr(),
          isSuccess: false,
          isPurpleMode: isPurple,
          context: context,
        );
        return;
      }

      final GoogleSignRequestBody googleRequestBody = GoogleSignRequestBody(
        idToken: idToken,
        sessionId: await secureStorage.read(key: "sessionId"),
      );

      final String successMessage = await _authService.googleSign(
        googleRequestBody.toJson(),
      );
      AuthState.setLoggedIn();

      if (!mounted) return;
      showSnackBarCustom(
        message: GoogleSignMessages.getLocalizedMessage(successMessage),
        isSuccess: true,
        isPurpleMode: isPurple,
        context: context,
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.of(context).pushReplacementNamed("/stores");
      });
    } catch (ex) {
      final String errorMessage = _apiClient.extractResponseMessage(
        ex.toString(),
      );

      if (!mounted) return;
      showSnackBarCustom(
        message: GoogleSignMessages.getLocalizedMessage(errorMessage),
        isSuccess: false,
        isPurpleMode: isPurple,
        context: context,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AuthThemeColors.of(context, isPurple: isPurple);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---------- Header (outside the card) ----------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: t.surfaceVariant,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.toggleInset(isPurple: isPurple),
                ),
                child: Icon(Icons.person_outline, color: t.primary, size: 24),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "login_title".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: t.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "login_subtitle".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: t.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ---------- Card (form only) ----------
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: AppShadows.cardGlow(isPurple: isPurple),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ----- Toggle -----
                AuthToggle(isLoginSelected: true, isPurpleMode: isPurple),

                const SizedBox(height: AppSpacing.xl),

                // ----- Username / Email -----
                FormGroup(
                  isPurpleMode: isPurple,
                  controller: controllers["usernameOrEmail"]!,
                  label: "login_usernameOrEmail_label".tr(),
                  hintText: "login_usernameOrEmail_placeholder".tr(),
                  isRequired: true,
                  maxLines: 1,
                  errorMaxLines: 3,
                  validator: (val) {
                    val = val!.trim();
                    if (val.isEmpty) {
                      return "login_error_username_or_email_required".tr();
                    }
                    final emailRegex = RegExp(
                      r"^(?!\.)(?!.*\.\.)([A-Z0-9_'+\.\-]*)[A-Z0-9_+\-]@([A-Z0-9][A-Z0-9\-]*\.)+[A-Z]{2,}$",
                      caseSensitive: false,
                    );
                    final usernameRegex = RegExp(r"^[a-z0-9_]{3,64}$");

                    if (val.contains("@")) {
                      if (val.length > 254) {
                        return "login_error_email_max_length".tr();
                      }
                      if (!emailRegex.hasMatch(val)) {
                        return "login_error_email_invalid".tr();
                      }
                    } else {
                      if (val.length < 3) {
                        return "login_error_username_too_short".tr();
                      }
                      if (val.length > 64) {
                        return "login_error_username_too_long".tr();
                      }
                      if (!usernameRegex.hasMatch(val)) {
                        return "login_error_username_invalid_chars".tr();
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // ----- Password -----
                FormGroup(
                  isPurpleMode: isPurple,
                  controller: controllers["password"]!,
                  label: "login_password_label".tr(),
                  hintText: "login_password_placeholder".tr(),
                  maxLength: 64,
                  errorMaxLines: 2,
                  isRequired: true,
                  isPassword: true,
                  validator: (val) {
                    val = val!.trim();
                    if (val.isEmpty) {
                      return "login_error_password_required".tr();
                    }
                    if (val.length < 8) {
                      return "login_error_password_too_short".tr();
                    }
                    if (val.length > 64) {
                      return "login_error_password_too_long".tr();
                    }
                    if (!RegExp(r"[A-Z]").hasMatch(val)) {
                      return "login_error_password_no_uppercase".tr();
                    }
                    if (!RegExp(r"[a-z]").hasMatch(val)) {
                      return "login_error_password_no_lowercase".tr();
                    }
                    if (!RegExp(r"[0-9]").hasMatch(val)) {
                      return "login_error_password_no_digit".tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // ----- Forgot / Remember me -----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed("/forget_password"),
                      child: Text(
                        "login_forgot_password".tr(),
                        style: TextStyle(
                          color: t.link,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "login_remember_me".tr(),
                          style: TextStyle(
                            color: t.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: (v) => setState(() => rememberMe = v!),
                            activeColor: t.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.sm / 2,
                              ),
                            ),
                            side: BorderSide(color: t.border, width: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ----- Login button -----
                GradientElevatedButton(
                  onPressed: _submit,
                  context: context,
                  isPurpleMode: isPurple,
                  child: Text(
                    "login_login_button".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ----- Divider -----
                Row(
                  children: [
                    Expanded(child: Divider(color: t.border, height: 0.7)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        "or".tr(),
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: t.border, height: 0.7)),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // ----- Google sign-in -----
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _googleSign,
                  label: Text(
                    "google_sign".tr(),
                    style: TextStyle(
                      color: t.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: t.border, width: 1),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    backgroundColor: t.surfaceVariant,
                    foregroundColor: t.textPrimary,
                    elevation: 0,
                  ),
                  icon: FaIcon(
                    FontAwesomeIcons.google,
                    size: 18,
                    color: t.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
