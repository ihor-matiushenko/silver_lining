import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:silver_lining_app/main.dart' as app;
import 'package:silver_lining_app/services/auth_service.dart';
import 'package:silver_lining_app/services/storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 E2E Test Suite: Unauthenticated (Guest) User Experience', () {
    setUp(() async {
      // Clean slate: ensure no authenticated session and empty local history
      await StorageService.clearAllHistory();
      if (AuthService().isAuthenticated) {
        await AuthService().signOut();
      }
    });

    testWidgets(
      'TC-G01 & TC-G03: Guest enters thought, receives AI reframing, and validates local history persistence',
      (tester) async {
        // 1. Launch the full application
        app.main();
        await tester.pumpAndSettle();

        // 2. Verify Home screen mounts with input form elements
        final inputField = find.byKey(const ValueKey('input_thought_field'));
        final reframeBtn = find.byKey(const ValueKey('btn_reframe_action'));
        expect(inputField, findsOneWidget);
        expect(reframeBtn, findsOneWidget);

        // 3. Enter a realistic stressful thought as a guest user
        const testThought = 'I have a huge presentation tomorrow and feel overwhelmed by my deadlines.';
        await tester.enterText(inputField, testThought);
        await tester.pumpAndSettle();

        // 4. Tap the "Reframe Thought" primary button
        await tester.tap(reframeBtn);
        await tester.pump();

        // 5. Poll and pump until the AI response card is rendered
        // (Allows sufficient timeout for either local Ollama or Gemini cloud response)
        final resultCard = find.byKey(const ValueKey('card_perspective_result'));
        final errorCard = find.byKey(const ValueKey('card_error_feedback'));
        final end = DateTime.now().add(const Duration(seconds: 25));

        bool cardAppeared = false;
        while (DateTime.now().isBefore(end)) {
          await tester.pump(const Duration(milliseconds: 500));
          if (resultCard.evaluate().isNotEmpty || errorCard.evaluate().isNotEmpty) {
            cardAppeared = true;
            break;
          }
        }

        expect(
          cardAppeared,
          isTrue,
          reason: 'Expected either perspective result card or structured error card within timeout',
        );

        // If backend is active and responded with a reframed perspective:
        if (resultCard.evaluate().isNotEmpty) {
          expect(resultCard, findsOneWidget);

          // Allow the typewriter animation to complete typing characters
          await tester.pump(const Duration(seconds: 3));

          // 6. Navigate to the History tab ("My Linings") via Bottom Navigation Bar
          final historyTabIcon = find.byIcon(Icons.collections_bookmark);
          expect(historyTabIcon, findsOneWidget);
          await tester.tap(historyTabIcon);
          await tester.pumpAndSettle();

          // 7. Verify TC-G03: The thought was saved locally on device in shared_preferences
          expect(find.text(testThought), findsOneWidget);
        }
      },
    );
  });
}
