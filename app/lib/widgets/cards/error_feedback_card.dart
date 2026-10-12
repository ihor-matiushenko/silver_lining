import 'package:flutter/material.dart';
import '../../models/reframe_response.dart';
import '../../screens/auth_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../glass_card.dart';
import '../status_badge.dart';

/// ⚠️ Standalone Card Component for Rate Limiting & Network Error Feedback
class ErrorFeedbackCard extends StatelessWidget {
  final ReframeResponse response;

  const ErrorFeedbackCard({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    final isRateLimit = response.safetyCategory == 'rate_limited';
    final borderColor = isRateLimit ? AppColors.secondary : AppColors.warning;
    final badgeLabel = isRateLimit ? '⏳ Daily Limit Reached' : '⚠️ Service Notice';

    return GlassCard(
      borderColor: borderColor,
      backgroundColor: borderColor.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(label: badgeLabel, color: borderColor),
          const SizedBox(height: 12),
          Text(
            response.reframedText ?? 'Unable to process your thought right now.',
            style: AppTypography.body,
          ),
          if (isRateLimit) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.lock_open, color: Colors.white, size: 18),
              label: const Text(
                'Sign In / Register for Unlimited Reframings',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AuthScreen(
                      onAuthSuccess: () => Navigator.of(context).pop(),
                      onContinueAsGuest: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
