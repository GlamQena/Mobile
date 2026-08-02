import 'package:flutter/material.dart';
import '../public/app_colors.dart';

class GradientElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;

  const GradientElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.colors = const [AppColors.primary, AppColors.secondary],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius = 30.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
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