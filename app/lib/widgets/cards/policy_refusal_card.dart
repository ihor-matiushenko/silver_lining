import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../glass_card.dart';
import '../status_badge.dart';

/// 🛡️ Standalone Card Component for Illegal Act / Crime Policy Refusals
class PolicyRefusalCard extends StatelessWidget {
  const PolicyRefusalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.warning,
      backgroundColor: AppColors.warning.withValues(alpha: 0.1),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(label: '🛡️ Safety Policy Notice', color: AppColors.warning),
          SizedBox(height: 10),
          Text(
            'Silver Lining AI cannot provide positive reframing or perspective on illegal activities.',
            style: AppTypography.bodyMuted,
          ),
        ],
      ),
    );
  }
}
