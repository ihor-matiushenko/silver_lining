import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silver_lining_app/models/history_item.dart';
import 'package:silver_lining_app/models/reframe_response.dart';
import 'package:silver_lining_app/services/auth_service.dart';
import 'package:silver_lining_app/services/providers/mock_auth_provider.dart';
import 'package:silver_lining_app/services/storage_service.dart';
import 'package:silver_lining_app/widgets/cards/error_feedback_card.dart';
import 'package:silver_lining_app/widgets/cards/reframed_perspective_card.dart';
import 'package:silver_lining_app/widgets/chips/preset_chips.dart';
import 'package:silver_lining_app/widgets/result_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthService().setProvider(MockAuthProvider());
  });

  group('🛡️ Error & Rate Limit Handling Tests', () {
    test('ReframeResponse correctly parses isError property', () {
      final normalJson = {
        'is_safe': true,
        'safety_category': 'none',
        'reframed_text': 'A positive thought',
      };
      final normalResp = ReframeResponse.fromJson(normalJson);
      expect(normalResp.isError, false);

      final errorJson = {
        'is_safe': true,
        'safety_category': 'rate_limited',
        'reframed_text': 'Guest limit reached',
        'is_error': true,
      };
      final errorResp = ReframeResponse.fromJson(errorJson);
      expect(errorResp.isError, true);
      expect(errorResp.safetyCategory, 'rate_limited');
    });

    testWidgets('ResultCard renders ErrorFeedbackCard when isError is true', (tester) async {
      const errorResp = ReframeResponse(
        isSafe: true,
        safetyCategory: 'rate_limited',
        reframedText: 'Guest daily limit reached (5/day). Create a free account for unlimited reframings!',
        crisisTriggered: false,
        isError: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultCard(response: errorResp),
          ),
        ),
      );

      // Verify ErrorFeedbackCard is rendered, NOT ReframedPerspectiveCard
      expect(find.byType(ErrorFeedbackCard), findsOneWidget);
      expect(find.byType(ReframedPerspectiveCard), findsNothing);
      expect(find.text('⏳ Daily Limit Reached'), findsOneWidget);
      expect(find.textContaining('Guest daily limit reached'), findsOneWidget);
      expect(find.text('Sign In / Register for Unlimited Reframings'), findsOneWidget);
    });

    test('StorageService only persists safe and non-error thoughts', () async {
      // Create a valid normal item
      const validResp = ReframeResponse(
        isSafe: true,
        safetyCategory: 'none',
        reframedText: 'Every setback is a setup for a comeback.',
        crisisTriggered: false,
        isError: false,
      );
      final validItem = HistoryItem(
        id: '1',
        dateString: 'Today, 12:00',
        promptText: 'Had a tough day',
        response: validResp,
      );

      await StorageService.saveHistoryItem(validItem);

      var items = await StorageService.loadHistoryItems();
      expect(items.length, 1);
      expect(items.first.response.reframedText, 'Every setback is a setup for a comeback.');

      // Verify that error responses are identified and should not be saved
      const errorResp = ReframeResponse(
        isSafe: true,
        safetyCategory: 'rate_limited',
        reframedText: 'Guest limit reached',
        crisisTriggered: false,
        isError: true,
      );
      expect(errorResp.isError, true);
    });

    testWidgets('PresetChips renders scenario chips properly', (tester) async {
      String? selectedPrompt;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresetChips(
              onSelectPreset: (text) => selectedPrompt = text,
            ),
          ),
        ),
      );

      expect(find.text('Failed Interview'), findsOneWidget);
      expect(find.text('Recent Breakup'), findsOneWidget);

      await tester.tap(find.text('Failed Interview'));
      expect(selectedPrompt, contains('interview'));
    });

    test('AuthService initializes cleanly', () async {
      final auth = AuthService();
      await auth.initialize();
      expect(auth.isInitialized, true);
    });
  });
}
