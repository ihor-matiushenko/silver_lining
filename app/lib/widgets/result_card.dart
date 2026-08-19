import 'package:flutter/material.dart';
import '../models/reframe_response.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';
import 'status_badge.dart';

/// 🎯 Reusable Result Card Component for displaying AI outputs, Crisis Shield, or Policy Refusals.
class ResultCard extends StatelessWidget {
  final ReframeResponse response;

  const ResultCard({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    // Case 1: Safety Shield Activated (Self-Harm Crisis)
    if (response.crisisTriggered) {
      return GlassCard(
        borderColor: AppColors.danger,
        backgroundColor: AppColors.danger.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusBadge(label: '🚨 Safety Shield Activated', color: AppColors.danger),
            const SizedBox(height: 10),
            const Text(
              'We hear you, and your life matters. Our AI will not reframe self-harm, but 24/7 support is available.',
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {}, // Will trigger 988 phone call
              icon: const Icon(Icons.phone, color: Colors.white),
              label: const Text('Call 988 Crisis Lifeline'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      );
    }

    // Case 2: Crime Policy Refusal
    if (!response.isSafe) {
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

    // Case 3: Safe Positive Perspective Output
    return GlassCard(
      borderColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusBadge(label: '✨ Silver Lining Perspective', color: AppColors.success),
          const SizedBox(height: 12),
          Text(
            response.reframedText ?? '',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
