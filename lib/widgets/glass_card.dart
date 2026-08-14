import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tarjeta con efecto glassmorphism (vidrio esmerilado).
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blur;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 18,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.blur = 12,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.glassBackground,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: 1,
              ),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Tarjeta con gradiente sin efecto blur.
class GradientCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<Color>? gradientColors;

  const GradientCard({
    super.key,
    required this.child,
    this.borderRadius = 18,
    this.padding,
    this.margin,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [AppColors.card, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: child,
    );
  }
}
