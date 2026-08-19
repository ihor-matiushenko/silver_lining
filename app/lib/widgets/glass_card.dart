import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 🎨 Styled Component Equivalent: Reusable Glassmorphism Card Container.
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.borderColor = AppColors.primary,
    this.backgroundColor = AppColors.surface,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
