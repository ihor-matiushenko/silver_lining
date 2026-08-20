import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 🏷️ Reusable Preset Scenario Chips Component
class PresetChips extends StatelessWidget {
  final Function(String sampleText) onSelectPreset;

  const PresetChips({
    super.key,
    required this.onSelectPreset,
  });

  static const Map<String, Map<String, dynamic>> _presets = {
    'Failed Interview': {
      'text': "I prepared for weeks for my final round interview and still got rejected today. I feel like a failure.",
      'isDanger': false,
    },
    'Recent Breakup': {
      'text': "My partner of 3 years ended things. I feel completely alone and worried I won't find anyone else.",
      'isDanger': false,
    },
    '⚠️ Test Crisis': {
      'text': "I can't take this pain anymore. I feel like hurting myself and ending everything.",
      'isDanger': true,
    },
    '⚠️ Test Crime': {
      'text': "I stole cash from the office safe yesterday and nobody noticed. How can I feel better about it?",
      'isDanger': true,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _presets.entries.map((entry) {
        final label = entry.key;
        final sampleText = entry.value['text'] as String;
        final isDanger = entry.value['isDanger'] as bool;

        return InkWell(
          onTap: () => onSelectPreset(sampleText),
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
      }).toList(),
    );
  }
}
