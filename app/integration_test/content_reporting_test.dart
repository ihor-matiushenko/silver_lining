import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:silver_lining_app/main.dart' as app;
import 'package:silver_lining_app/services/auth_service.dart';
import 'package:silver_lining_app/services/storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 E2E Test Suite: User Content Reporting (TC-S03)', () {
    setUp(() async {
      await StorageService.clearAllHistory();
      if (AuthService().isAuthenticated) {
        await AuthService().signOut();
      }
    });

    testWidgets(
      'TC-S03: User generates reframing, taps flag button, selects reason, and submits report to backend',
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

        // 1. Submit a thought
        await tester.enterText(
          inputField,
          'Testing the objectionable content reporting workflow on perspective card',
        );
        await tester.pumpAndSettle();

        await tester.tap(reframeBtn);
        await tester.pump();

        // 2. Wait for result card
        final resultCard = find.byKey(const ValueKey('card_perspective_result'));
        final timeout = DateTime.now().add(const Duration(seconds: 30));
        while (DateTime.now().isBefore(timeout) && resultCard.evaluate().isEmpty) {
          await tester.pump(const Duration(milliseconds: 400));
        }
        expect(resultCard, findsOneWidget);

        // Allow typewriter animation to finish
        final animPause = DateTime.now().add(const Duration(seconds: 3));
        while (DateTime.now().isBefore(animPause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 3. Tap the report flag icon button
        final flagBtn = find.byIcon(Icons.flag_outlined);
        expect(flagBtn, findsOneWidget);
        await tester.tap(flagBtn);
        await tester.pumpAndSettle();

        // 4. Verify ReportContentModal opened
        expect(find.text('Report AI Response'), findsOneWidget);
        expect(find.text('⚠️ Offensive or Inappropriate'), findsOneWidget);

        // Select a reason option, e.g. "🚨 Harmful or Dangerous Advice"
        final harmfulOption = find.text('🚨 Harmful or Dangerous Advice');
        expect(harmfulOption, findsOneWidget);
        await tester.tap(harmfulOption);
        await tester.pumpAndSettle();

        // Enter optional comment
        final detailsField = find.byType(TextField).last;
        await tester.enterText(detailsField, 'Automated E2E reporting test note');
        await tester.pumpAndSettle();

        // 5. Submit the report
        final submitReportBtn = find.text('Submit Report');
        expect(submitReportBtn, findsOneWidget);
        await tester.ensureVisible(submitReportBtn);
        await tester.pumpAndSettle();
        await tester.tap(submitReportBtn);
        await tester.pump();

        // Wait for network call to POST /api/v1/reports and modal to dismiss
        final endReport = DateTime.now().add(const Duration(seconds: 10));
        while (DateTime.now().isBefore(endReport) &&
            find.text('Report AI Response').evaluate().isNotEmpty) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 6. Verify success confirmation snackbar
        expect(
          find.text('Report submitted. Our safety team will review this response.'),
          findsOneWidget,
        );

        // Keep confirmation visible on emulator for 3 seconds
        final pause = DateTime.now().add(const Duration(seconds: 3));
        while (DateTime.now().isBefore(pause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }
      },
    );
  });
}
