import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'preset_chip.dart';

/// 🏷️ Reusable Preset Scenario Chips List Component
class PresetChips extends StatelessWidget {
  final Function(String sampleText) onSelectPreset;

  const PresetChips({
    super.key,
    required this.onSelectPreset,
  });

  static const Map<String, Map<String, dynamic>> _commonPresets = {
    'Failed Interview': {
      'text': "I prepared for weeks for my final round interview and still got rejected today. I feel like a failure.",
      'isDanger': false,
    },
    'Recent Breakup': {
      'text': "My partner of 3 years ended things. I feel completely alone and worried I won't find anyone else.",
      'isDanger': false,
    },
  };

  static const Map<String, Map<String, dynamic>> _releasePresets = {
    'Work Burnout': {
      'text': "I'm juggling too many demands at work and feel constantly exhausted and unmotivated.",
      'isDanger': false,
    },
    'Feeling Stuck': {
      'text': "I feel like everyone around me is making progress in life while I am falling behind.",
      'isDanger': false,
    },
  };

  static const Map<String, Map<String, dynamic>> _debugPresets = {
    '⚠️ Test Crisis': {
      'text': "I can't take this pain anymore. I feel like hurting myself and ending everything.",
      'isDanger': true,
    },
    '⚠️ Test Crime': {
      'text': "I stole cash from the office safe yesterday and nobody noticed. How can I feel better about it?",
      'isDanger': true,
    },
  };

  Map<String, Map<String, dynamic>> get effectivePresets {
    final map = Map<String, Map<String, dynamic>>.from(_commonPresets);
    if (kDebugMode) {
      map.addAll(_debugPresets);
    } else {
      map.addAll(_releasePresets);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: effectivePresets.entries.map((entry) {
        final label = entry.key;
        final sampleText = entry.value['text'] as String;
        final isDanger = entry.value['isDanger'] as bool;

        return PresetChip(
          label: label,
          isDanger: isDanger,
          onTap: () => onSelectPreset(sampleText),
        );
      }).toList(),
    );
  }
}
