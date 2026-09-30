import 'package:flutter/material.dart';
import '../../models/history_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../glass_card.dart';

/// 📜 HistoryCard: Reusable card component displaying a single reframed perspective record
class HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.item,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: item.isFavorite ? AppColors.secondary : AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.dateString, style: AppTypography.subtitle),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: item.isFavorite ? AppColors.secondary : Colors.grey,
                      size: 20,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          Text('"${item.promptText}"', style: AppTypography.titleBold),
          const SizedBox(height: 8),
          Text(item.response.reframedText ?? '', style: AppTypography.bodyMuted),
        ],
      ),
    );
  }
}
