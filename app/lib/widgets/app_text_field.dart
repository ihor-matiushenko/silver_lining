import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 📝 Reusable Styled TextField Component
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: AppColors.background.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
