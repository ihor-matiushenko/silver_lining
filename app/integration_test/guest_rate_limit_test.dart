import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:silver_lining_app/main.dart' as app;
import 'package:silver_lining_app/services/auth_service.dart';
import 'package:silver_lining_app/services/storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 E2E Test Suite: Guest Rate Limiting (TC-G04)', () {
    setUp(() async {
      await StorageService.clearAllHistory();
      if (AuthService().isAuthenticated) {
        await AuthService().signOut();
      }
    });

    testWidgets(
      'TC-G04: Guest submitting requests hits 5/day rate limit and renders structured ErrorFeedbackCard with CTA',
      (tester) async {
        await app.main();
        await tester.pumpAndSettle();

        final inputField = find.byKey(const ValueKey('input_thought_field'));
        final reframeBtn = find.byKey(const ValueKey('btn_reframe_action'));

        final endBoot = DateTime.now().add(const Duration(seconds: 10));
        while (DateTime.now().isBefore(endBoot) && inputField.evaluate().isEmpty) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        expect(inputField, findsOneWidget);
        expect(reframeBtn, findsOneWidget);

        // Submit thoughts until rate limit (5 allowed, 6th triggers HTTP 429)
        final runTimestamp = DateTime.now().millisecondsSinceEpoch;
        bool encounteredRateLimit = false;

        for (int i = 1; i <= 6; i++) {
          await tester.enterText(
            inputField,
            'Daily struggle test prompt number $i ($runTimestamp)',
          );
          await tester.pumpAndSettle();

          await tester.tap(reframeBtn);
          await tester.pump();

          // Wait for response card
          final resultCard = find.byKey(const ValueKey('card_perspective_result'));
          final errorCard = find.byKey(const ValueKey('card_error_feedback'));
          final timeout = DateTime.now().add(const Duration(seconds: 30));

          while (DateTime.now().isBefore(timeout)) {
            await tester.pump(const Duration(milliseconds: 400));
            if (errorCard.evaluate().isNotEmpty) {
              encounteredRateLimit = true;
              break;
            }
            if (resultCard.evaluate().isNotEmpty) {
              break;
            }
          }

          if (encounteredRateLimit) {
            break;
          }
        }

        // Verify the error card with rate limit badge is visible
        final errorCard = find.byKey(const ValueKey('card_error_feedback'));
        expect(errorCard, findsOneWidget);
        expect(find.text('⏳ Daily Limit Reached'), findsOneWidget);
        expect(
          find.text('Sign In / Register for Unlimited Reframings'),
          findsOneWidget,
        );

        // Keep error card visible on emulator for 3 seconds
        final pause = DateTime.now().add(const Duration(seconds: 3));
        while (DateTime.now().isBefore(pause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }
      },
    );
  });
}
