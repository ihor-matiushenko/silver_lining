import 'package:flutter/material.dart';
import '../../services/dynamic_localization_service.dart';
import '../../theme/app_typography.dart';
import '../app_text_field.dart';
import '../chips/preset_chips.dart';
import '../glass_card.dart';
import '../primary_button.dart';

/// 📝 Reusable Glassmorphism Input Form Component
class InputFormCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  const InputFormCard({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  void _onSelectPreset(String sampleText) {
    controller.text = sampleText;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DynamicLocalizationService.instance,
      builder: (context, _) {
        final l10n = DynamicLocalizationService.instance;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('reframePrompt'),
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller,
                hintText: l10n.translate('reframeInputHint'),
              ),
              const SizedBox(height: 14),

              // Preset Scenario Chips (1-tap selection)
              PresetChips(onSelectPreset: _onSelectPreset),
              const SizedBox(height: 16),

              PrimaryButton(
                label: l10n.translate('reframeButtonAction'),
                isLoading: isLoading,
                onPressed: onSubmit,
              ),
            ],
          ),
        );
      },
    );
  }
}
