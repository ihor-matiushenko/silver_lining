import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../glass_card.dart';
import '../status_badge.dart';

/// ✨ Standalone Card Component for Safe Positive AI Perspective Output
class ReframedPerspectiveCard extends StatelessWidget {
  final String text;

  const ReframedPerspectiveCard({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusBadge(label: '✨ Silver Lining Perspective', color: AppColors.success),
          const SizedBox(height: 12),
          Text(
            text,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
