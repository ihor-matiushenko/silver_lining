import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';
import '../app_text_field.dart';
import '../glass_card.dart';
import '../primary_button.dart';

/// 📝 Reusable Glassmorphism Input Form Component
class InputFormCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  const InputFormCard({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's weighing on your mind?", style: AppTypography.subtitle),
          const SizedBox(height: 12),
          AppTextField(
            controller: controller,
            hintText: "Share what happened today, your concerns, or what feels tough...",
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reframe Thought ✨',
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
