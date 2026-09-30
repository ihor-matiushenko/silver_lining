import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_lining_app/models/history_item.dart';
import 'package:silver_lining_app/models/reframe_response.dart';
import 'package:silver_lining_app/widgets/cards/guest_history_banner.dart';
import 'package:silver_lining_app/widgets/cards/history_card.dart';

void main() {
  group('HistoryCard Widget Tests', () {
    testWidgets('renders prompt, reframed text, and triggers favorite callback', (tester) async {
      bool favoriteToggled = false;
      bool deleted = false;

      final testItem = HistoryItem(
        id: 'test_1',
        dateString: 'Today, 14:00',
        promptText: 'I feel exhausted',
        response: const ReframeResponse(
          isSafe: true,
          safetyCategory: 'none',
          reframedText: 'Resting is a form of self-care.',
          crisisTriggered: false,
        ),
        isFavorite: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(
              item: testItem,
              onToggleFavorite: () => favoriteToggled = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.text('"I feel exhausted"'), findsOneWidget);
      expect(find.text('Resting is a form of self-care.'), findsOneWidget);
      expect(find.text('Today, 14:00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(favoriteToggled, isTrue);

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);
    });
  });

  group('GuestHistoryBanner Widget Tests', () {
    testWidgets('renders banner and triggers sign in callback', (tester) async {
      bool signInPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GuestHistoryBanner(
              onSignInPressed: () => signInPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Guest Mode: History on device.'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      await tester.tap(find.text('Sign In'));
      expect(signInPressed, isTrue);
    });
  });
}
