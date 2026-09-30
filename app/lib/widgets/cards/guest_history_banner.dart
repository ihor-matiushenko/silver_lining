import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// ⚠️ GuestHistoryBanner: Notifies guest users that their history is stored only on this device
/// and provides a 1-tap call-to-action to sign in or create an account for cloud backup.
class GuestHistoryBanner extends StatelessWidget {
  final VoidCallback onSignInPressed;

  const GuestHistoryBanner({
    super.key,
    required this.onSignInPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Guest Mode: History on device.',
              style: AppTypography.bodyMuted,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.warning.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            onPressed: onSignInPressed,
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
