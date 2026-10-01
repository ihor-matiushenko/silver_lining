import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../animations/typewriter_text.dart';
import '../glass_card.dart';
import '../modals/report_content_modal.dart';
import '../status_badge.dart';

/// ✨ Standalone Card Component for Safe Positive AI Perspective Output (with Typewriter Animation & Reporting)
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StatusBadge(label: '✨ Silver Lining Perspective', color: AppColors.success),
              IconButton(
                icon: const Icon(Icons.flag_outlined, size: 18, color: Colors.white38),
                tooltip: 'Report response',
                visualDensity: VisualDensity.compact,
                onPressed: () => ReportContentModal.show(
                  context,
                  contentSnippet: text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TypewriterText(
            text: text,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

