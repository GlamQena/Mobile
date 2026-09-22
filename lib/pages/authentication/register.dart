import "package:flutter/material.dart";
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app/custom_widgets/auth_toggle.dart';
import 'package:mobile_app/custom_widgets/form_group.dart';
import 'package:mobile_app/messages_mappers/google_sign_messages.dart';
import 'package:mobile_app/models/auth/google_sign.dart';
import 'package:mobile_app/public/app_effects.dart';
import '../../custom_widgets/gradient_button.dart';
import '../../custom_widgets/show_snack_bar.dart';
import '../../models/auth/register.dart';
import '../../services/api_client.dart';
import '../../services/auth/auth.dart';
import '../../services/auth/google_auth.dart';
import '../../messages_mappers/register_error_messages.dart';
import '../../messages_mappers/register_success_messages.dart';
import "../../services/auth/auth_state.dart";

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> registerKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  final Map<String, TextEditingController> controllers = {
    "username": TextEditingController(),
    "email": TextEditingController(),
    "phone": TextEditingController(),
    "dob": TextEditingController(),
    "city": TextEditingController(),
    "street": TextEditingController(),
    "area": TextEditingController(),
    "password": TextEditingController(),
    "confirmPassword": TextEditingController(),
  };

  String selectedGender = "female";
  late List<bool> isSelected;
  bool _isSubmitting = false;
  late bool isPurple;

  @override
  void initState() {
    super.initState();
    isSelected = [false, true]; // female selected by default
  }

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

  String _formatBirthdate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return "";

    final parts = trimmed.split("/");
    if (parts.length != 3) return trimmed;

    final day = parts[0].padLeft(2, "0");
    final month = parts[1].padLeft(2, "0");
    final year = parts[2];

    return "$year-$month-$day";
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!registerKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final RegisterRequestBody requestBody = RegisterRequestBody.fromForm(
        username: controllers["username"]!.text,
        email: controllers["email"]!.text,
        password: controllers["password"]!.text,
        confirmPassword: controllers["confirmPassword"]!.text,
        phoneNumber: controllers["phone"]!.text,
        birthdate: _formatBirthdate(controllers["dob"]!.text),
        gender: selectedGender,
        role: "client",
        city: controllers["city"]!.text,
        district: controllers["area"]!.text,
        street: controllers["street"]!.text,
        sessionId: await secureStorage.read(key: "sessionId"),
      );

      final String successMessage =
      await _authService.register(requestBody.toJson());
      AuthState.setLoggedIn();

      if (!mounted) return;

      showSnackBarCustom(
        context: context,
        message:
        RegisterSuccessMessages.getLocalizedSuccess(successMessage),
        isSuccess: true,
        isPurpleMode: isPurple,
      );
    } catch (ex) {
      final String errorMessage =
      _apiClient.extractResponseMessage(ex.toString());

      if (!mounted) return;

      showSnackBarCustom(
        context: context,
        message: RegisterErrorMessages.getLocalizedError(errorMessage),
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
      final GoogleSignInAccount? googleAccount =
      await googleAuthService.signIn();

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

      final String successMessage =
      await _authService.googleSign(googleRequestBody.toJson());
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
      final String raw = ex.toString();
      final String errorMessage = _apiClient.extractResponseMessage(raw);

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
              Icon(Icons.person_add_alt_1, color: t.primary, size: 36),
              const SizedBox(height: AppSpacing.md),
              Text(
                "register_title".tr(),
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
                "register_subtitle".tr(),
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
            key: registerKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ----- Toggle -----
                AuthToggle(isLoginSelected: false, isPurpleMode: isPurple),

                const SizedBox(height: AppSpacing.xl),

                // ----- Username -----
                FormGroup(
                  isPurpleMode: isPurple,
                  controller: controllers["username"]!,
                  label: "register_username_label".tr(),
                  isRequired: true,
                  prefixIcon: Icon(Icons.person_outline,
                      color: t.textMuted, size: 17),
                  hintText: "register_username_placeholder".tr(),
                  errorMaxLines: 3,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "register_username_required".tr();
                    }
                    if (val.trim().length > 64) {
                      return "register_username_max_length".tr();
                    }
                    if (val.trim().contains(RegExp(r'[^a-z0-9_]'))) {
                      return "register_username_format".tr();
                    }
                    if (val.trim().length < 3) {
                      return "register_username_min_length".tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ----- Email -----
                FormGroup(
                  isPurpleMode: isPurple,
                  controller: controllers["email"]!,
                  label: "register_email_label".tr(),
                  isRequired: true,
                  prefixIcon: Icon(Icons.mail_outline,
                      color: t.textMuted, size: 17),
                  hintText: "register_email_placeholder".tr(),
                  errorMaxLines: 3,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "register_email_required".tr();
                    }
                    if (val.trim().length > 254) {
                      return "register_email_max_length".tr();
                    }
                    final emailRegex = RegExp(
                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                    );
                    if (!emailRegex.hasMatch(val.trim())) {
                      return "register_email_format".tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ----- Phone -----
                FormGroup(
                  isPurpleMode: isPurple,
                  controller: controllers["phone"]!,
                  label: "register_phone_label".tr(),
                  isRequired: false,
                  prefixIcon: Icon(Icons.phone,
                      color: t.textMuted, size: 17),
                  hintText: "register_phone_placeholder".tr(),
                  errorMaxLines: 2,
                  maxLength: 11,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    final phoneRegex = RegExp(r"^01[0125][0-9]{8}$");
                    if (!phoneRegex.hasMatch(val.trim())) {
                      return "register_phone_format".tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ----- DOB -----
                FormGroup(
                  isPurpleMode: isPurple,
                  controller: controllers["dob"]!,
                  label: "register_dob_label".tr(),
                  isRequired: false,
                  prefixIcon: Icon(Icons.calendar_today,
                      color: t.textMuted, size: 17),
                  hintText: "register_dob_placeholder".tr(),
                  helperText: "register_dob_helper".tr(),
                  errorMaxLines: 2,
                  isDob: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    final dobRegex = RegExp(
                      r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19[0-9]{2}|20[0-9]{2})$',
                    );
                    if (!dobRegex.hasMatch(val.trim())) {
                      return "register_dob_format".tr();
                    }
                    try {
                      final parts = val.trim().split("/");
                      final parsed = _tryParseDate(
                        int.parse(parts[2]),
                        int.parse(parts[1]),
                        int.parse(parts[0]),
                      );
                      if (parsed == null) {
                        return "register_dob_validation".tr();
                      }
                      if (parsed.isAfter(DateTime.now())) {
                        return "register_dob_future".tr();
                      }
                      return null;
                    } catch (_) {
                      return "register_dob_format".tr();
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ----- Gender -----
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "register_gender_label".tr(),
                        style: TextStyle(
                          color: t.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth = constraints.maxWidth;
                          return Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: t.surfaceVariant,
                              border: Border.all(
                                  color: t.border, width: 0.8),
                              borderRadius:
                              BorderRadius.circular(AppRadii.md),
                              boxShadow: AppShadows.toggleInset(
                                  isPurple: isPurple),
                            ),
                            child: ToggleButtons(
                              isSelected: isSelected,
                              onPressed: (index) {
                                setState(() {
                                  for (int i = 0;
                                  i < isSelected.length;
                                  i++) {
                                    isSelected[i] = i == index;
                                  }
                                  selectedGender =
                                  index == 0 ? "male" : "female";
                                });
                              },
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              color: t.textMuted,
                              selectedColor: Colors.white,
                              fillColor: t.primary,
                              borderRadius:
                              BorderRadius.circular(AppRadii.sm),
                              borderWidth: 0.0,
                              borderColor: Colors.transparent,
                              constraints: BoxConstraints(
                                minWidth: (maxWidth - 12) / 2,
                                maxWidth: (maxWidth - 12) / 2,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  child: Text(
                                      "register_gender_male".tr()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  child: Text(
                                      "register_gender_female".tr()),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ----- Address -----
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_sharp,
                              color: t.textSecondary, size: 17),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            "register_address_title".tr(),
                            style: TextStyle(
                              color: t.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: FormGroup(
                            isPurpleMode: isPurple,
                            controller: controllers["city"]!,
                            label: "register_city_label".tr(),
                            isRequired: false,
                            maxLength: 50,
                            prefixIcon: Icon(Icons.location_city_sharp,
                                color: t.textMuted, size: 17),
                            hintText: "register_city_label".tr(),
                            errorMaxLines: 2,
                            validator: (val) {
                              if (val != null && val.length > 50) {
                                return "register_city_maxLength".tr();
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: FormGroup(
                            isPurpleMode: isPurple,
                            controller: controllers["area"]!,
                            label: "register_area_label".tr(),
                            maxLength: 50,
                            isRequired: false,
                            prefixIcon: Icon(Icons.map_outlined,
                                color: t.textMuted, size: 17),
                            hintText: "register_area_label".tr(),
                            errorMaxLines: 2,
                            validator: (val) {
                              if (val != null && val.length > 50) {
                                return "register_area_maxLength".tr();
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FormGroup(
                      isPurpleMode: isPurple,
                      maxLength: 100,
                      controller: controllers["street"]!,
                      label: "register_street_label".tr(),
                      isRequired: false,
                      prefixIcon: Icon(Icons.broadcast_on_home_rounded,
                          color: t.textMuted, size: 17),
                      hintText: "register_street_label".tr(),
                      errorMaxLines: 2,
                      validator: (val) {
                        if (val != null && val.length > 100) {
                          return "register_street_maxLength".tr();
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ----- Password -----
                FormGroup(
                  isPurpleMode: isPurple,
                  controller: controllers["password"]!,
                  label: "register_password_label".tr(),
                  isRequired: true,
                  prefixIcon: Icon(Icons.lock_outline,
                      color: t.textMuted, size: 17),
                  hintText: "register_password_placeholder".tr(),
                  errorMaxLines: 3,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "register_password_required".tr();
                    }
                    if (val.length < 8) {
                      return "register_password_min_length".tr();
                    }
                    if (val.length > 64) {
                      return "register_password_max_length".tr();
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(val)) {
                      return "register_password_uppercase".tr();
                    }
                    if (!RegExp(r'[a-z]').hasMatch(val)) {
                      return "register_password_lowercase".tr();
                    }
                    if (!RegExp(r'[0-9]').hasMatch(val)) {
                      return "register_password_digit".tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ----- Confirm password -----
                FormGroup(
                  isPurpleMode: isPurple,
                  controller: controllers["confirmPassword"]!,
                  label: "register_confirm_password_label".tr(),
                  isRequired: true,
                  prefixIcon: Icon(Icons.lock_clock_outlined,
                      color: t.textMuted, size: 17),
                  hintText: "register_confirm_password_placeholder".tr(),
                  errorMaxLines: 3,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "register_confirm_password_required".tr();
                    }
                    if (val != controllers["password"]?.text) {
                      return "register_confirm_password_match".tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // ----- Submit -----
                GradientElevatedButton(
                  context: context,
                  isPurpleMode: isPurple,
                  width: double.infinity,
                  borderRadius: AppRadii.md,
                  backgroundGradient: t.buttonGradient,
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    ),
                  )
                      : Text(
                    "register_create_account_button".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ----- Divider -----
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: t.border, height: 0.7)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                      child: Text(
                        "or".tr(),
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(color: t.border, height: 0.7)),
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

  DateTime? _tryParseDate(int year, int month, int day) {
    final parsed = DateTime(year, month, day);
    if (parsed.year != year ||
        parsed.month != month ||
        parsed.day != day) {
      return null;
    }
    return parsed;
  }
}