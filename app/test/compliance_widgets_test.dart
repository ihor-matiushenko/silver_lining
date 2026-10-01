import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_lining_app/widgets/animations/typewriter_text.dart';
import 'package:silver_lining_app/widgets/cards/reframed_perspective_card.dart';
import 'package:silver_lining_app/widgets/dialogs/legal_info_dialog.dart';
import 'package:silver_lining_app/widgets/modals/report_content_modal.dart';



void main() {
  group('🏬 Store Compliance Widgets & Dialogs Test Suite', () {
    testWidgets('ReframedPerspectiveCard renders report flag button and opens modal', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReframedPerspectiveCard(
              text: 'This is a positive AI reflection.',
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      // Verify perspective text and status badge
      expect(find.text('✨ Silver Lining Perspective'), findsOneWidget);
      expect(find.byType(TypewriterText), findsOneWidget);

      // Verify report flag icon exists
      final flagButtonFinder = find.byIcon(Icons.flag_outlined);
      expect(flagButtonFinder, findsOneWidget);

      // Tap report button
      await tester.tap(flagButtonFinder);
      await tester.pumpAndSettle();

      // Verify ReportContentModal is displayed
      expect(find.byType(ReportContentModal), findsOneWidget);
      expect(find.text('Report AI Response'), findsOneWidget);
      expect(find.text('⚠️ Offensive or Inappropriate'), findsOneWidget);
      expect(find.text('Submit Report'), findsOneWidget);
    });

    testWidgets('LegalInfoDialog renders medical disclaimer properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => LegalInfoDialog.showMedicalDisclaimer(context),
                child: const Text('Open Disclaimer'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Disclaimer'));
      await tester.pumpAndSettle();

      expect(find.text('🩺 Medical & Wellness Disclaimer'), findsOneWidget);
      expect(find.textContaining('Not Medical Care'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalInfoDialog), findsNothing);
    });

    testWidgets('LegalInfoDialog renders Privacy Policy and Terms of Service', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => LegalInfoDialog.showPrivacyPolicy(context),
                child: const Text('Open Privacy'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Privacy'));
      await tester.pumpAndSettle();

      expect(find.text('🔒 Privacy Policy'), findsOneWidget);
      expect(find.textContaining('Account & Data Deletion'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);
    });
  });
}
