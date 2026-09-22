import 'package:flutter/material.dart';
import '../public/app_colors.dart';

class GradientElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final BuildContext context;
  final bool isPurpleMode;
  final double borderRadius;
  final double? width ;
  final EdgeInsets padding;
  final double elevation;
  final Gradient? backgroundGradient;

  const GradientElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.context,
    required this.isPurpleMode,
    this.backgroundGradient,
    this.borderRadius = 15,
    this.width = double.infinity,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: backgroundGradient ??
          (isPurpleMode ? PurpleTheme.buttonGradient : PinkTheme.buttonGradient),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: padding,
          elevation: elevation,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: child,
      ),
    );
  }
}