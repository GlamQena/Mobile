import "package:flutter/material.dart";
import '../../custom_widgets/gradient_button.dart';
import '../../custom_widgets/show_snack_bar.dart';
import '../../public/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/api_client.dart';
import '../../services/auth.dart';
import '../../services/messages_mappers/verify_email_messages.dart';

class VerifyEmail extends StatefulWidget {
  final bool isDarkMode;
  String selectedDrawerTile;

  VerifyEmail({super.key, required this.isDarkMode, required this.selectedDrawerTile});

  @override
  State<VerifyEmail> createState() => VerifyEmailState();
}

class VerifyEmailState extends State<VerifyEmail> {
  bool isVerifying = true;
  bool isSucceeded = false;
  bool isInvalid = false;
  bool isExpired = false;
  bool isAlreadyVerified = false;
  bool isResending = false;
  bool isFailedResend = false;
  bool isRedirecting = false;
  String message = "";

  @override
  void initState() {
    super.initState();
    widget.selectedDrawerTile = "";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _verifyEmail();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    setState(() {
      isVerifying = true;
      message = "";
      isFailedResend = false;
    });

    final uri = Uri.base;
    final email = uri.queryParameters["email"];
    final token = uri.queryParameters["token"];

    if (email == null || token == null) {
      setState(() {
        isVerifying = false;
        isInvalid = true;
      });
      return;
    }

    final AuthService authService = AuthService();
    final ApiClient apiClient = ApiClient();

    try {
      message = await authService.verifyEmailLink(email: email, token: token);

      setState(() {
        isVerifying = false;
        isSucceeded = true;
      });

      if (mounted) {
        _showSnackBar(
          message: VerifyEmailMessages.getLocalizedMessage(message),
          isSuccess: true,
        );
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isSucceeded = false;
            isRedirecting = true;
          });
        }
      });

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed("/stores");
        }
      });

    } catch (ex) {
      setState(() {
        isVerifying = false;
      });

      message = apiClient.extractResponseMessage(ex.toString());
      String localizedMessage = VerifyEmailMessages.getLocalizedMessage(message);

      if (VerifyEmailMessages.isAlreadyVerified(message)) {
        setState(() {
          isAlreadyVerified = true;
        });
      } else if (VerifyEmailMessages.isExpired(message)) {
        setState(() {
          isExpired = true;
        });
      } else if (VerifyEmailMessages.isInvalid(message)) {
        setState(() {
          isInvalid = true;
        });
      }

      if (mounted) {
        _showSnackBar(
          message: localizedMessage,
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _sendVerificationLink() async {
    if (isResending) return;

    final uri = Uri.base;
    final email = uri.queryParameters["email"];

    if (email == null) {
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
      message = await authService.emailVerificationRequest(email);

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
          setState(() {
            isResending = false;
            isExpired = false;
            isInvalid = false;
          });
          _verifyEmail();
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
      isDarkMode: widget.isDarkMode,
    );
  }

  void _handleRetry() {
    if (isVerifying) return;
    _verifyEmail();
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
    final Color textPrimary = widget.isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final Color textSecondary = widget.isDarkMode ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final Color textMuted = widget.isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final Color linkColor = widget.isDarkMode ? AppColorsDark.link : AppColorsLight.link;

    final dynamic icon;
    final Color iconColor;
    final Color iconBackgroundColor;
    final String title;
    final String subtitle;
    final bool showResendButton;
    final bool showRetryButton;
    final bool showDashboardButton;

    if (isVerifying) {
      icon = Icons.hourglass_top_rounded;
      iconColor = widget.isDarkMode ? AppColors.primary : AppColors.secondary;
      iconBackgroundColor = widget.isDarkMode ? AppColors.primaryShades[3] : AppColors.secondaryShades[3];
      title = "verify_email_checking".tr();
      subtitle = "verify_email_checking_subtitle".tr();
      showResendButton = false;
      showRetryButton = false;
      showDashboardButton = false;
    } else if (isRedirecting) {
      icon = Icons.hourglass_top_rounded;
      iconColor = widget.isDarkMode ? AppColors.primary : AppColors.secondary;
      iconBackgroundColor = widget.isDarkMode ? AppColors.primaryShades[3] : AppColors.secondaryShades[3];
      title = "verify_email_redirecting".tr();
      subtitle = "verify_email_redirecting_subtitle".tr();
      showResendButton = false;
      showRetryButton = false;
      showDashboardButton = false;
    } else if (isSucceeded) {
      icon = Icons.verified_rounded;
      iconColor = widget.isDarkMode ? AppColors.primary : Colors.green[400]!;
      iconBackgroundColor = widget.isDarkMode ? AppColors.primaryShades[3] : Colors.green[200]!;
      title = "verify_email_success_title".tr();
      subtitle = "verify_email_success_subtitle".tr();
      showResendButton = false;
      showRetryButton = false;
      showDashboardButton = false;
    } else if (isInvalid) {
      icon = Icons.error_outline_rounded;
      iconColor = Colors.red[400]!;
      iconBackgroundColor = Colors.red[200]!;
      title = "verify_email_invalid_title".tr();
      subtitle = "verify_email_invalid_subtitle".tr();
      showResendButton = true;
      showRetryButton = false;
      showDashboardButton = false;
    } else if (isAlreadyVerified) {
      icon = Icons.verified_outlined;
      iconColor = Colors.deepOrange[400]!;
      iconBackgroundColor = Colors.deepOrange[200]!;
      title = "verify_email_already_verified".tr();
      subtitle = "verify_email_already_verified_subtitle".tr();
      showResendButton = false;
      showRetryButton = false;
      showDashboardButton = true;
    } else if (isFailedResend) {
      icon = Icons.cancel_schedule_send_rounded;
      iconColor = Colors.red[400]!;
      iconBackgroundColor = Colors.red[200]!;
      title = "verify_email_resend_error_title".tr();
      subtitle = "verify_email_resend_error_subtitle".tr();
      showResendButton = true;
      showRetryButton = false;
      showDashboardButton = false;
    } else {
      icon = Icons.timer_off_outlined;
      iconColor = Colors.deepOrange[400]!;
      iconBackgroundColor = Colors.deepOrange[200]!;
      title = "verify_email_expired_title".tr();
      subtitle = "verify_email_expired_subtitle".tr();
      showResendButton = true;
      showRetryButton = false;
      showDashboardButton = false;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: isVerifying || isRedirecting
                ? SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: iconColor,
                strokeWidth: 3,
              ),
            )
                : Icon(icon, size: 30, color: iconColor),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          if (showDashboardButton) ...[
            GradientElevatedButton(
              onPressed: _goToDashboard,
              context: context,
              backgroundGradient: widget.isDarkMode
                  ? AppColorsDark.sidebarActiveGradient
                  : AppColorsLight.sidebarActiveGradient,
              width: double.infinity,
              child: Text(
                'verify_email_go_to_dashboard'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          if (showResendButton) ...[
            GradientElevatedButton(
              onPressed: isResending ? null : _handleResend,
              context: context,
              backgroundGradient: widget.isDarkMode
                  ? AppColorsDark.sidebarActiveGradient
                  : AppColorsLight.sidebarActiveGradient,
              width: double.infinity,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          if (showRetryButton) ...[
            GradientElevatedButton(
              onPressed: _handleRetry,
              context: context,
              backgroundGradient: widget.isDarkMode
                  ? AppColorsDark.sidebarActiveGradient
                  : AppColorsLight.sidebarActiveGradient,
              width: double.infinity,
              child: Text(
                'verify_email_retry_button'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          if (!isSucceeded && !isRedirecting && !isVerifying) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "verify_email_not_redirect".tr(),
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _handleRetry,
                  child: Text(
                    "verify_email_retry".tr(),
                    style: TextStyle(
                      color: linkColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "verify_email_no_credentials".tr(),
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _handleResend,
                  child: Text(
                    "verify_email_resend".tr(),
                    style: TextStyle(
                      color: linkColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}