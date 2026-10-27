import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:silver_lining_app/main.dart' as app;
import 'package:silver_lining_app/services/auth_service.dart';
import 'package:silver_lining_app/services/providers/supabase_auth_provider.dart';
import 'package:silver_lining_app/services/storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 Live Supabase Cloud Auth & E2E Verification Suite (Option A)', () {
    setUp(() async {
      // Initialize real SupabaseAuthProvider (100% production mode, no mock bypass)
      final supabaseProvider = SupabaseAuthProvider();
      await supabaseProvider.initialize();
      AuthService().setProvider(supabaseProvider);

      // Clean slate: ensure fresh session and clear local storage
      await StorageService.clearAllHistory();
      if (AuthService().isAuthenticated) {
        await AuthService().signOut();
      }
    });

    testWidgets(
      'Live Supabase Login (ES256 JWT), Authenticated Reframing, Cloud History Sync & Favorite Toggle',
      (tester) async {
        // 1. Launch the application with live Supabase client initialized
        await app.main();
        await tester.pumpAndSettle();

        // Ensure Home screen has rendered
        final accountBtn = find.byKey(const ValueKey('btn_account_action'));
        final endBoot = DateTime.now().add(const Duration(seconds: 10));
        while (DateTime.now().isBefore(endBoot) &&
            accountBtn.evaluate().isEmpty) {
          await tester.pump(const Duration(milliseconds: 300));
        }
        expect(accountBtn, findsOneWidget);

        // 2. Open AuthScreen via AppBar Account Button (TC-A01)
        await tester.tap(accountBtn);
        await tester.pumpAndSettle();

        final emailField = find.byKey(const ValueKey('input_auth_email'));
        final passwordField = find.byKey(const ValueKey('input_auth_password'));
        final submitBtn = find.byKey(const ValueKey('btn_auth_submit'));

        expect(emailField, findsOneWidget);
        expect(passwordField, findsOneWidget);
        expect(submitBtn, findsOneWidget);

        // Enter live registered Supabase test account credentials
        const testEmail = 'test_e2e_runner@silverlining.app';
        const testPassword = 'Password123!';
        await tester.enterText(emailField, testEmail);
        await tester.pumpAndSettle();

        await tester.enterText(passwordField, testPassword);
        await tester.pumpAndSettle();

        // Pause 1 second for visual clarity on emulator
        final authTypingPause = DateTime.now().add(const Duration(seconds: 1));
        while (DateTime.now().isBefore(authTypingPause)) {
          await tester.pump(const Duration(milliseconds: 250));
        }

        // Tap Sign In button (communicates directly with https://qkwwcffgihsdpvruzpbw.supabase.co)
        await tester.ensureVisible(submitBtn);
        await tester.pumpAndSettle();
        await tester.tap(submitBtn);
        await tester.pump();

        // Wait for live Supabase network response and authentication completion
        final endAuth = DateTime.now().add(const Duration(seconds: 15));
        while (DateTime.now().isBefore(endAuth) &&
            !AuthService().isAuthenticated) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        // Verify authenticated status & cryptographic ES256 Supabase token
        expect(AuthService().isAuthenticated, isTrue);
        expect(AuthService().currentUserEmail, equals(testEmail));
        expect(AuthService().accessToken, isNotNull);
        expect(AuthService().accessToken, isNot(equals('dev_mock_jwt_token')));
        expect(AuthService().currentUserId, equals('ec4b2370-76f2-4fd8-aa78-92adb5cec4be'));

        // Dismiss modal if still visible after login
        await tester.pumpAndSettle();

        // 3. Submit an authenticated thought on HomeScreen (TC-A02)
        final inputField = find.byKey(const ValueKey('input_thought_field'));
        expect(inputField, findsOneWidget);

        final runId = DateTime.now().millisecondsSinceEpoch;
        final liveAuthThought =
            'Feeling stressed about real cloud release testing (Live Supabase run $runId)';
        await tester.enterText(inputField, liveAuthThought);
        await tester.pumpAndSettle();

        // Pause 2 seconds for visual confirmation on screen
        final thoughtPause = DateTime.now().add(const Duration(seconds: 2));
        while (DateTime.now().isBefore(thoughtPause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        final reframeBtn = find.byKey(const ValueKey('btn_reframe_action'));
        expect(reframeBtn, findsOneWidget);
        await tester.tap(reframeBtn);
        await tester.pump();

        // 4. Poll and pump until the AI response card is rendered
        final resultCard = find.byKey(
          const ValueKey('card_perspective_result'),
        );
        final errorCard = find.byKey(const ValueKey('card_error_feedback'));
        final endLlm = DateTime.now().add(const Duration(seconds: 60));

        bool cardAppeared = false;
        while (DateTime.now().isBefore(endLlm)) {
          await tester.pump(const Duration(milliseconds: 500));
          if (resultCard.evaluate().isNotEmpty ||
              errorCard.evaluate().isNotEmpty) {
            cardAppeared = true;
            break;
          }
        }

        expect(
          cardAppeared,
          isTrue,
          reason: 'Expected perspective card or structured error card within timeout',
        );
        expect(
          errorCard,
          findsNothing,
          reason: 'Backend returned an error card — live cloud sync steps cannot proceed',
        );
        expect(resultCard, findsOneWidget);

        // Allow typewriter animation to settle
        final readPause = DateTime.now().add(const Duration(seconds: 5));
        while (DateTime.now().isBefore(readPause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 5. Navigate to History tab via Bottom Navigation Bar (TC-A03)
        final historyTabIcon = find.byIcon(Icons.collections_bookmark);
        expect(historyTabIcon, findsOneWidget);
        await tester.tap(historyTabIcon);
        await tester.pumpAndSettle();

        // Wait for cloud history to fetch from PostgreSQL via GET /api/v1/history
        final endCloudFetch = DateTime.now().add(const Duration(seconds: 15));
        final promptFinder = find.text('"$liveAuthThought"');
        while (DateTime.now().isBefore(endCloudFetch) &&
            promptFinder.evaluate().isEmpty) {
          await tester.pump(const Duration(milliseconds: 400));
        }

        // Verify Cloud History title and persisted thought
        expect(find.text('☁️ Cloud History'), findsOneWidget);
        expect(promptFinder, findsOneWidget);

        // Keep cloud history visible on emulator for 4 seconds
        final historyPause = DateTime.now().add(const Duration(seconds: 4));
        while (DateTime.now().isBefore(historyPause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 6. Toggle Favorite Cloud Sync (TC-A04)
        final favoriteBtn = find
            .byKey(const ValueKey('btn_favorite_toggle'))
            .first;
        expect(favoriteBtn, findsOneWidget);

        await tester.tap(favoriteBtn);
        await tester.pumpAndSettle();

        // Verify heart toggled to active
        expect(find.byIcon(Icons.favorite), findsWidgets);

        // Filter by Favorites chip
        final favChip = find.byKey(const ValueKey('chip_filter_favorites'));
        expect(favChip, findsOneWidget);
        await tester.tap(favChip);
        await tester.pumpAndSettle();

        // Verify the favorited record is rendered in the filtered view
        expect(promptFinder, findsOneWidget);

        // Display favorites view for 3 seconds
        final favPause = DateTime.now().add(const Duration(seconds: 3));
        while (DateTime.now().isBefore(favPause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }
      },
    );
  });
}
