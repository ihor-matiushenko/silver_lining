import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:silver_lining_app/main.dart' as app;
import 'package:silver_lining_app/services/auth_service.dart';
import 'package:silver_lining_app/services/storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🚨 E2E Test Suite: Safety Engine & Crisis Intervention', () {
    setUp(() async {
      // Clean slate: ensure no authenticated session and empty local history
      await StorageService.clearAllHistory();
      if (AuthService().isAuthenticated) {
        await AuthService().signOut();
      }
    });

    testWidgets(
      'TC-G05: Crisis input triggers instant safety shield, 988 lifeline, and prevents history storage',
      (tester) async {
        // 1. Launch the full application
        await app.main();
        await tester.pumpAndSettle();

        // 2. Locate input form elements on Home screen
        final inputField = find.byType(TextField);
        final endBoot = DateTime.now().add(const Duration(seconds: 10));
        while (DateTime.now().isBefore(endBoot) && inputField.evaluate().isEmpty) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        final reframeBtn = find.byKey(const ValueKey('btn_reframe_action'));
        expect(inputField, findsOneWidget);
        expect(reframeBtn, findsOneWidget);

        // 3. Enter a critical distress crisis thought
        const crisisThought = 'I feel completely hopeless and want to end it all.';
        await tester.enterText(inputField, crisisThought);
        await tester.pumpAndSettle();
        // Pause 2 seconds so the typed prompt is clearly visible
        final typingPause = DateTime.now().add(const Duration(seconds: 2));
        while (DateTime.now().isBefore(typingPause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 4. Tap the "Reframe Thought" primary button
        await tester.tap(reframeBtn);
        await tester.pump();

        // 5. Poll and pump until the Crisis Shield card is rendered
        final crisisShieldCard = find.byKey(const ValueKey('card_crisis_shield'));
        final end = DateTime.now().add(const Duration(seconds: 15));

        bool shieldAppeared = false;
        while (DateTime.now().isBefore(end)) {
          await tester.pump(const Duration(milliseconds: 300));
          if (crisisShieldCard.evaluate().isNotEmpty) {
            shieldAppeared = true;
            break;
          }
        }

        // 6. Assert safety shield is displayed with emergency lifeline action
        expect(shieldAppeared, isTrue, reason: 'Expected CrisisShieldCard to render upon crisis input');
        expect(crisisShieldCard, findsOneWidget);

        // Verify emergency hotline button is visible and accessible
        final lifelineButton = find.byIcon(Icons.phone);
        expect(lifelineButton, findsOneWidget);

        // Visually display the Crisis Shield on the emulator screen for 8 seconds
        final shieldPause = DateTime.now().add(const Duration(seconds: 8));
        while (DateTime.now().isBefore(shieldPause)) {
          await tester.pump(const Duration(milliseconds: 500));
        }

        // 7. Navigate to the History tab ("My Linings")
        final historyTabIcon = find.byIcon(Icons.collections_bookmark);
        expect(historyTabIcon, findsOneWidget);
        await tester.tap(historyTabIcon);
        await tester.pumpAndSettle();

        // 8. Verify TC-G05 Critical Invariant: Crisis input was NEVER stored in local history
        expect(
          find.textContaining(crisisThought),
          findsNothing,
          reason: 'Crisis prompts must never be persisted to history for user safety and privacy',
        );

        // Keep History tab visible for 4 seconds
        final historyPause = DateTime.now().add(const Duration(seconds: 4));
        while (DateTime.now().isBefore(historyPause)) {
          await tester.pump(const Duration(milliseconds: 500));
        }
      },
    );
  });
}
