import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_lining_app/models/app_language.dart';
import 'package:silver_lining_app/services/dynamic_localization_service.dart';
import 'package:silver_lining_app/widgets/dialogs/language_selector_modal.dart';

void main() {
  group('🌐 Language & Localization Tests', () {
    test('AppLanguage.fromCode maps languages and flags correctly', () {
      final uk = AppLanguage.fromCode('uk');
      expect(uk.displayName, 'Ukrainian');
      expect(uk.nativeName, 'Українська');
      expect(uk.flag, '🇺🇦');

      final es = AppLanguage.fromCode('es');
      expect(es.displayName, 'Spanish');
      expect(es.nativeName, 'Español');
      expect(es.flag, '🇪🇸');

      final system = AppLanguage.fromCode('system');
      expect(system.displayName, 'System Default');
      expect(system.nativeName, 'Follow Device');
      expect(system.flag, '📱');
    });

    test('DynamicLocalizationService translates fallback keys cleanly', () {
      final l10n = DynamicLocalizationService();
      expect(l10n.translate('appTitle'), 'Silver Lining');
      expect(l10n.translate('reframePrompt'), 'What is weighing on your mind?');
      expect(l10n.translate('languageTitle'), 'Language');
      // Non-existent key returns key itself as fallback
      expect(l10n.translate('unmappedKey123'), 'unmappedKey123');
    });

    testWidgets('LanguageSelectorModal renders all supported languages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LanguageSelectorModal(),
          ),
        ),
      );

      // Verify header
      expect(find.text('Language'), findsOneWidget);

      // Verify language options are listed
      expect(find.text('Follow Device'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Українська'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Deutsch'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
    });

    testWidgets('Tapping a language option selects it and dismisses modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => LanguageSelectorModal.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Ukrainian
      expect(find.text('Українська'), findsOneWidget);
      await tester.tap(find.text('Українська'));
      await tester.pumpAndSettle();

      // Modal should be dismissed
      expect(find.text('Language'), findsNothing);
    });
  });
}
