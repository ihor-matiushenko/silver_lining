import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 🏷️ Configurable Single Preset Chip Component
class PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const PresetChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDanger 
              ? AppColors.danger.withValues(alpha: 0.15) 
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDanger 
                ? AppColors.danger.withValues(alpha: 0.4) 
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDanger ? Colors.redAccent : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
