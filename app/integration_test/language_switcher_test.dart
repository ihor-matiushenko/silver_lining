import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:silver_lining_app/main.dart' as app;
import 'package:silver_lining_app/services/dynamic_localization_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 E2E Test Suite: Dynamic In-App Language Selector', () {
    testWidgets(
      'User opens LanguageSelectorModal, switches to Ukrainian, asserts UI re-renders, and switches back to English',
      (tester) async {
        await app.main();
        await tester.pumpAndSettle();

        final l10n = DynamicLocalizationService.instance;
        final langBtn = find.byKey(const ValueKey('btn_language_action'));

        final endBoot = DateTime.now().add(const Duration(seconds: 10));
        while (DateTime.now().isBefore(endBoot) && langBtn.evaluate().isEmpty) {
          await tester.pump(const Duration(milliseconds: 300));
        }
        expect(langBtn, findsOneWidget);

        // 1. Open Language Selector Modal
        await tester.tap(langBtn);
        await tester.pumpAndSettle();

        // 2. Select Ukrainian (Українська)
        final ukrainianOption = find.text('Українська');
        expect(ukrainianOption, findsOneWidget);
        await tester.tap(ukrainianOption);
        await tester.pumpAndSettle();

        // Wait for dynamic localization service to fetch/switch to Ukrainian
        final endUkSwitch = DateTime.now().add(const Duration(seconds: 10));
        while (DateTime.now().isBefore(endUkSwitch) && l10n.currentLangCode != 'uk') {
          await tester.pump(const Duration(milliseconds: 300));
        }

        expect(l10n.currentLangCode, equals('uk'));
        expect(l10n.selectedLanguage, equals('uk'));

        // Pause 3 seconds on emulator so Ukrainian UI is clearly visible
        final pauseUk = DateTime.now().add(const Duration(seconds: 3));
        while (DateTime.now().isBefore(pauseUk)) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 3. Open Language Selector Modal again
        await tester.tap(langBtn);
        await tester.pumpAndSettle();

        // 4. Switch back to English
        final englishOption = find.text('English');
        expect(englishOption, findsOneWidget);
        await tester.tap(englishOption);
        await tester.pumpAndSettle();

        final endEnSwitch = DateTime.now().add(const Duration(seconds: 10));
        while (DateTime.now().isBefore(endEnSwitch) && l10n.currentLangCode != 'en') {
          await tester.pump(const Duration(milliseconds: 300));
        }

        expect(l10n.currentLangCode, equals('en'));

        // Pause 2 seconds for visual confirmation on emulator
        final pauseEn = DateTime.now().add(const Duration(seconds: 2));
        while (DateTime.now().isBefore(pauseEn)) {
          await tester.pump(const Duration(milliseconds: 300));
        }
      },
    );
  });
}
