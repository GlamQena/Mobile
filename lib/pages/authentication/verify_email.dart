import "package:flutter/material.dart";
import 'package:mobile_app/services/auth/auth_state.dart';
import '../../custom_widgets/gradient_button.dart';
import '../../custom_widgets/show_snack_bar.dart';
import '../../public/app_colors.dart';
import '../../public/app_effects.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/api_client.dart';
import '../../services/auth/auth.dart';
import '../../messages_mappers/verify_email_messages.dart';

class _VerifyState {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String titleKey;
  final String subtitleKey;
  final bool isLoading;         // render spinner instead of icon
  final bool showResendButton;
  final bool showRetryButton;
  final bool showDashboardButton;
  final bool showWaitingForLink;

  const _VerifyState({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.titleKey,
    required this.subtitleKey,
    this.isLoading = false,
    this.showResendButton = false,
    this.showRetryButton = false,
    this.showDashboardButton = false,
    this.showWaitingForLink = false,
  });
}

/// Status tone — drives the icon color/background consistently.
enum _Tone { loading, success, warning, error, info }

extension on _Tone {
  Color iconColor(bool isPurple) {
    switch (this) {
      case _Tone.loading:
      case _Tone.info:
        return isPurple ? AppColors.purpleDark : AppColors.pinkMain;
      case _Tone.success:
        return AppColors.success;
      case _Tone.warning:
        return AppColors.warning;
      case _Tone.error:
        return AppColors.error;
    }
  }

  Color background(bool isPurple) {
    switch (this) {
      case _Tone.loading:
      case _Tone.info:
        return isPurple ? PurpleTheme.surfaceVariant : PinkTheme.surfaceVariant;
      case _Tone.success:
        return AppColors.successSubtle;
      case _Tone.warning:
        return AppColors.warningSubtle;
      case _Tone.error:
        return AppColors.errorSubtle;
    }
  }
}

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({ super.key });

  @override
  State<VerifyEmail> createState() => VerifyEmailState();
}

class VerifyEmailState extends State<VerifyEmail> {
  /// Maximum user-triggered retries for the SAME link before we stop
  /// offering retry and nudge the user to the dashboard instead.
  static const int _maxRetryAttempts = 3;

  String? _email;
  String? _token;
  late bool isPurple;
  int? _lastDeliveryId;
  bool isVerifying = true;
  bool isSucceeded = false;
  bool isInvalid = false;
  bool isExpired = false;
  bool isAlreadyVerified = false;
  bool isResending = false;
  bool isFailedResend = false;
  bool isRedirecting = false;
  bool isRetryLimitReached = false;
  bool isAwaitingNewLink = false;
  int _retryAttempts = 0;
  String message = "";

  bool _requestInFlight = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    debugPrint("🆔 VerifyEmail.didChangeDependencies — instance hash: ${identityHashCode(this)}, _hasInitialized=$_lastDeliveryId");

    if (mounted) {
      isPurple = Theme.of(context).brightness == Brightness.dark;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) return;

    _email = args["email"] as String?;
    _token = args["token"] as String?;
    final deliveryId = args["delivery_id"] as int?;

    debugPrint("🆔 didChangeDependencies: instance=${identityHashCode(this)}, "
    "delivery_id=$deliveryId, last=$_lastDeliveryId, "
    "isVerifying=$isVerifying, isInvalid=$isInvalid, isExpired=$isExpired");

    if (deliveryId != null && deliveryId == _lastDeliveryId) {
      debugPrint("🆔 same delivery_id=$deliveryId, skipping reset");
      return;
    }
    _lastDeliveryId = deliveryId;

    debugPrint("🆔 new delivery_id=$deliveryId — resetting VerifyEmail state");

    // Reset ALL state so this delivery starts fresh.
    setState(() {
      _email = args["email"] as String?;
      _token = args["token"] as String?;
      isVerifying = true;
      isSucceeded = false;
      isInvalid = false;
      isExpired = false;
      isAlreadyVerified = false;
      isResending = false;
      isFailedResend = false;
      isRedirecting = false;
      isRetryLimitReached = false;
      isAwaitingNewLink = false;
      _retryAttempts = 0;
      _requestInFlight = false;
      message = "";
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) _verifyEmail();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _requestInFlight = false;
  }

    Future<void> _verifyEmail({bool isRetry = false}) async {
    // Guard the *network call*, not the initial loading UI.
    if (_requestInFlight || isSucceeded || isAlreadyVerified || isRedirecting) {
      debugPrint("⏭️ skipping verify — request in flight or already resolved");
      return;
    }

    // Once an error has settled, only a user-triggered retry may proceed.
    if (!isRetry && (isInvalid || isExpired || isFailedResend)) {
      debugPrint("⏭️ skipping auto-verify — error state already displayed");
      return;
    }
    
    _requestInFlight = true;

    setState(() {
      isVerifying = true;
      message = "";
      isFailedResend = false;
      isInvalid = false;
      isExpired = false;
      isAlreadyVerified = false;
    });

    if (_email == null || _token == null) {
      _requestInFlight = false;
      setState(() {
        isVerifying = false;
        isInvalid = true;
      });
      return;
    }

    final AuthService authService = AuthService();
    final ApiClient apiClient = ApiClient();

    try {
      message = await authService.verifyEmailLink(email: _email, token: _token);

      if (!mounted) return;

      setState(() {
        isVerifying = false;
        isSucceeded = true;
        _retryAttempts = 0;
      });

      _showSnackBar(
        message: VerifyEmailMessages.getLocalizedMessage(message),
        isSuccess: true,
      );

      AuthState.setLoggedIn();

      // Give the user time to read the success card.
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted || !isSucceeded) return;
        setState(() {
          isSucceeded = false;
          isRedirecting = true;
        });
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted || !isRedirecting) return;
        Navigator.of(context).pushReplacementNamed("/stores");
      });
    } catch (ex) {
      if (!mounted) return;

      setState(() {
        isVerifying = false;
      });

      message = apiClient.extractResponseMessage(ex.toString());
      String localizedMessage = VerifyEmailMessages.getLocalizedMessage(message);

      if (isRetry) _retryAttempts++;
      final bool hitLimit = _retryAttempts >= _maxRetryAttempts;

      if (VerifyEmailMessages.isAlreadyVerified(message)) {
        setState(() => isAlreadyVerified = true);
      } else if (VerifyEmailMessages.isExpired(message)) {
        setState(() {
          isExpired = true;
          if (hitLimit) isRetryLimitReached = true;
        });
      } else if (VerifyEmailMessages.isInvalid(message)) {
        setState(() {
          isInvalid = true;
          if (hitLimit) isRetryLimitReached = true;
        });
      } else {
        if (hitLimit) {
          setState(() {
            isExpired = true;
            isRetryLimitReached = true;
          });
        }
      }

      _showSnackBar(message: localizedMessage, isSuccess: false);
    } finally {
      _requestInFlight = false;
    }
  }

  Future<void> _sendVerificationLink() async {
    if (isResending) return;

    if (_email == null) {
      if (mounted) {
        _showSnackBar(
          message: 'verify_email_resend_email_required'.tr(),
          isSuccess: false,
        );
      }
      return;
    }

    setState(() {
      isResending = true;
      isFailedResend = false;
    });

    final ApiClient apiClient = ApiClient();

    try {
      final AuthService authService = AuthService();
      message = await authService.emailVerificationRequest(_email);

      setState(() {
        isResending = false;
      });

      if (mounted) {
        _showSnackBar(
          message: VerifyEmailMessages.getLocalizedMessage(message),
          isSuccess: true,
        );
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          if (isSucceeded || isAlreadyVerified) return; 
          setState(() {
            isResending = false;
            isFailedResend = false;
            // Clear the old link's error flags — the user has a new email
            // coming and shouldn't stare at the previous failure.
            isExpired = false;
            isInvalid = false;
            // Keep the retry counter reset — a fresh link deserves a clean slate.
            _retryAttempts = 0;
            isRetryLimitReached = false;
            // Transition into the "check your inbox" state.
            isAwaitingNewLink = true;
            isVerifying = false;
          });
        }
      });
    } catch (ex) {
      String exceptionMessage = apiClient.extractResponseMessage(ex.toString());

      setState(() {
        isResending = false;
        isFailedResend = true;
      });

      if (mounted) {
        _showSnackBar(
          message: VerifyEmailMessages.getLocalizedMessage(exceptionMessage),
          isSuccess: false,
        );
      }
    }
  }

  void _showSnackBar({required String message, required bool isSuccess}) {
    if (!mounted) return;
    showSnackBarCustom(
      context: context,
      message: message,
      isSuccess: isSuccess,
      isPurpleMode: isPurple,
    );
  }

  void _handleRetry() {
    if (_requestInFlight) return;
    if (isSucceeded) return;
    if (isAlreadyVerified) return;
    if (isRedirecting) return;
    if (isRetryLimitReached) return;
    _verifyEmail(isRetry: true);
  }

  void _handleResend() {
    if (isResending) return;
    _sendVerificationLink();
  }

  void _goToDashboard() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed("/stores");
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AuthThemeColors.of(context, isPurple: isPurple);
    final state = _resolveState();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        width: MediaQuery.of(context).size.width * 0.86,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: AppShadows.cardGlow(isPurple: isPurple),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Icon badge ----------
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: state.iconBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.border, width: 0.8),
                  boxShadow: AppShadows.toggleInset(isPurple: isPurple),
                ),
                alignment: Alignment.center,
                child: state.isLoading
                    ? SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          color: state.iconColor,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(state.icon, size: 32, color: state.iconColor),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ---------- Title ----------
            Text(
              state.titleKey.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: t.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ---------- Subtitle ----------
            Text(
              state.subtitleKey.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: t.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ---------- Dashboard button (already verified) ----------
            if (state.showDashboardButton) ...[
              GradientElevatedButton(
                onPressed: _goToDashboard,
                context: context,
                isPurpleMode: isPurple,
                backgroundGradient: t.buttonGradient,
                width: double.infinity,
                borderRadius: AppRadii.md,
                child: Text(
                  'verify_email_go_to_dashboard'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],

            // ---------- Resend button ----------
            if (state.showResendButton) ...[
              GradientElevatedButton(
                onPressed: isResending ? null : _handleResend,
                context: context,
                isPurpleMode: isPurple,
                backgroundGradient: t.buttonGradient,
                width: double.infinity,
                borderRadius: AppRadii.md,
                child: isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'verify_email_resend_button'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ],

            // ---------- Retry button (same-link re-verification) ----------
            if (state.showRetryButton && !state.showDashboardButton) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: _handleRetry,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(
                    color: t.border.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                child: Text(
                  'verify_email_retry_button'.tr(),
                  style: TextStyle(
                    color: t.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],

            // ---------- Retry limit reached: Dashboard + verify-later note ----------
            if (state.showDashboardButton && isRetryLimitReached) ...[
              // Already renders the dashboard button above.
              const SizedBox(height: AppSpacing.md),
              Text(
                'verify_email_verify_later_from_profile'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: t.textMuted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],

            // ---------- Secondary "help" links ----------
            if (!isSucceeded &&
                !isRedirecting &&
                !isVerifying &&
                !isAwaitingNewLink && 
                !state.showDashboardButton) ...[
              const SizedBox(height: AppSpacing.xl),
              if (state.showRetryButton)
                _helpRow(
                  prompt: "verify_email_help_retry_prompt".tr(),
                  action: "verify_email_help_retry_action".tr(),
                  onTap: _handleRetry,
                  t: t,
                ),
              if (state.showRetryButton) const SizedBox(height: AppSpacing.md),
              _helpRow(
                prompt: "verify_email_help_resend_prompt".tr(),
                action: "verify_email_help_resend_action".tr(),
                onTap: _handleResend,
                t: t,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Maps the current boolean flags to a single visual + behavioral state.
  _VerifyState _resolveState() {
    if (isVerifying) {
      return _VerifyState(
        icon: Icons.hourglass_top_rounded,
        iconColor: _Tone.loading.iconColor(isPurple),
        iconBackgroundColor: _Tone.loading.background(isPurple),
        titleKey: "verify_email_checking",
        subtitleKey: "verify_email_checking_subtitle",
        isLoading: true,
      );
    }
    if (isRedirecting) {
      return _VerifyState(
        icon: Icons.hourglass_top_rounded,
        iconColor: _Tone.loading.iconColor(isPurple),
        iconBackgroundColor: _Tone.loading.background(isPurple),
        titleKey: "verify_email_redirecting",
        subtitleKey: "verify_email_redirecting_subtitle",
        isLoading: true,
      );
    }
    if (isSucceeded) {
      return _VerifyState(
        icon: Icons.verified_rounded,
        iconColor: _Tone.success.iconColor(isPurple),
        iconBackgroundColor: _Tone.success.background(isPurple),
        titleKey: "verify_email_success_title",
        subtitleKey: "verify_email_success_subtitle",
      );
    }

    // ---- Retry limit reached: only "go to dashboard" + "verify later" note ----
    if (isRetryLimitReached) {
      return _VerifyState(
        icon: Icons.timer_off_outlined,
        iconColor: _Tone.warning.iconColor(isPurple),
        iconBackgroundColor: _Tone.warning.background(isPurple),
        titleKey: "verify_email_retry_limit_title",
        subtitleKey: "verify_email_retry_limit_subtitle",
        showDashboardButton: true,
      );
    }

    if (isInvalid) {
      return _VerifyState(
        icon: Icons.error_outline_rounded,
        iconColor: _Tone.error.iconColor(isPurple),
        iconBackgroundColor: _Tone.error.background(isPurple),
        titleKey: "verify_email_invalid_title",
        subtitleKey: "verify_email_invalid_subtitle",
        showResendButton: true,
        showRetryButton: true,
      );
    }
    if (isAlreadyVerified) {
      return _VerifyState(
        icon: Icons.verified_outlined,
        iconColor: _Tone.info.iconColor(isPurple),
        iconBackgroundColor: _Tone.info.background(isPurple),
        titleKey: "verify_email_already_verified",
        subtitleKey: "verify_email_already_verified_subtitle",
        showDashboardButton: true,
      );
    }
    if (isFailedResend) {
      return _VerifyState(
        icon: Icons.cancel_schedule_send_rounded,
        iconColor: _Tone.error.iconColor(isPurple),
        iconBackgroundColor: _Tone.error.background(isPurple),
        titleKey: "verify_email_resend_error_title",
        subtitleKey: "verify_email_resend_error_subtitle",
        showResendButton: true,
      );
    }
    if (isAwaitingNewLink) {
      return _VerifyState(
        icon: Icons.mark_email_unread_outlined,
        iconColor: _Tone.info.iconColor(isPurple),
        iconBackgroundColor: _Tone.info.background(isPurple),
        titleKey: "verify_email_waiting_title",    
        subtitleKey: "verify_email_waiting_subtitle", 
        showWaitingForLink: true,
        showResendButton: true,   // allow resending again if the email never arrives
      );
    }
    // Default → expired
    return _VerifyState(
      icon: Icons.timer_off_outlined,
      iconColor: _Tone.warning.iconColor(isPurple),
      iconBackgroundColor: _Tone.warning.background(isPurple),
      titleKey: "verify_email_expired_title",
      subtitleKey: "verify_email_expired_subtitle",
      showResendButton: true,
      showRetryButton: true,
    );
  }

  /// "Prompt + link" row used at the bottom of the card.
  Widget _helpRow({
    required String prompt,
    required String action,
    required VoidCallback onTap,
    required AuthThemeColors t,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prompt,
          style: TextStyle(
            color: t.textMuted,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: TextStyle(
              color: t.link,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}