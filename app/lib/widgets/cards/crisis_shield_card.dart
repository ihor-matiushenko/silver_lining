import 'package:flutter/material.dart';
import '../../services/emergency_launcher_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../glass_card.dart';
import '../status_badge.dart';

/// 🚨 Standalone Card Component for Self-Harm Crisis Intervention
class CrisisShieldCard extends StatelessWidget {
  final String hotlinePhone;
  final VoidCallback? onCallHotline;

  const CrisisShieldCard({
    super.key,
    this.hotlinePhone = '988',
    this.onCallHotline,
  });

  void _handleCall() {
    if (onCallHotline != null) {
      onCallHotline!();
    } else {
      EmergencyLauncherService.makePhoneCall(hotlinePhone);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _handleCall,
            icon: const Icon(Icons.phone, color: Colors.white),
            label: Text('Call $hotlinePhone Crisis Lifeline'),
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
}
