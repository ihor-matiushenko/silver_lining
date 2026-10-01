import 'package:flutter/material.dart';
import '../../models/app_language.dart';
import '../../services/dynamic_localization_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// 🌐 Modern Glassmorphism Language Selector Modal Bottom Sheet
class LanguageSelectorModal extends StatelessWidget {
  const LanguageSelectorModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LanguageSelectorModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DynamicLocalizationService.instance;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🌐', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    l10n.translate('languageTitle'),
                    style: AppTypography.titleBold.copyWith(fontSize: 20),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Text(
                  l10n.currentLangCode.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Language options list
          ...AppLanguage.supportedLanguages.map((lang) {
            final isSelected = l10n.selectedLanguage == lang.code;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await l10n.setLanguage(lang.code);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.nativeName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              if (lang.code != 'system' && lang.nativeName != lang.displayName) ...[
                                const SizedBox(height: 2),
                                Text(
                                  lang.displayName,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
