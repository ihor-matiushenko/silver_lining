import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:silver_lining_app/main.dart' as app;
import 'package:silver_lining_app/services/auth_service.dart';
import 'package:silver_lining_app/services/providers/supabase_auth_provider.dart';
import 'package:silver_lining_app/services/storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 Live Supabase E2E Test Suite: Real Account Registration & Deletion Cascade', () {
    setUp(() async {
      // Ensure real SupabaseAuthProvider is active
      final supabaseProvider = SupabaseAuthProvider();
      await supabaseProvider.initialize();
      AuthService().setProvider(supabaseProvider);

      await StorageService.clearAllHistory();
      if (AuthService().isAuthenticated) {
        await AuthService().signOut();
      }
    });

    testWidgets(
      'Live Supabase Registration, Authenticated Reflection, In-App Deletion & Session Invalidation',
      (tester) async {
        await app.main();
        await tester.pumpAndSettle();

        // 1. Open Auth modal
        final accountBtn = find.byKey(const ValueKey('btn_account_action'));
        expect(accountBtn, findsOneWidget);
        await tester.tap(accountBtn);
        await tester.pumpAndSettle();

        // 2. Switch to Create Account mode
        final createAccountTab = find.text('Create Account');
        expect(createAccountTab, findsOneWidget);
        await tester.tap(createAccountTab);
        await tester.pumpAndSettle();

        final emailField = find.byKey(const ValueKey('input_auth_email'));
        final passwordField = find.byKey(const ValueKey('input_auth_password'));
        final submitBtn = find.byKey(const ValueKey('btn_auth_submit'));

        // Generate unique disposable test credentials
        final uniqueTs = DateTime.now().millisecondsSinceEpoch;
        final disposableEmail = 'disposable_user_$uniqueTs@silverlining.app';
        const disposablePassword = 'Password123!';

        await tester.enterText(emailField, disposableEmail);
        await tester.pumpAndSettle();

        await tester.enterText(passwordField, disposablePassword);
        await tester.pumpAndSettle();

        // 3. Submit registration against live Supabase
        await tester.tap(submitBtn);
        await tester.pump();

        // Wait for live Supabase signup & session initialization
        final endAuth = DateTime.now().add(const Duration(seconds: 15));
        while (DateTime.now().isBefore(endAuth) && !AuthService().isAuthenticated) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        expect(AuthService().isAuthenticated, isTrue);
        expect(AuthService().currentUserEmail, equals(disposableEmail));
        expect(AuthService().accessToken, isNotNull);
        expect(AuthService().accessToken, isNot(equals('dev_mock_jwt_token')));

        // Dismiss modal if present
        await tester.pumpAndSettle();

        // 4. Submit an authenticated reflection with real Supabase ES256 Bearer JWT
        final inputField = find.byKey(const ValueKey('input_thought_field'));
        final reframeBtn = find.byKey(const ValueKey('btn_reframe_action'));

        await tester.enterText(
          inputField,
          'Disposable user test thought before account deletion ($uniqueTs)',
        );
        await tester.pumpAndSettle();

        await tester.tap(reframeBtn);
        await tester.pump();

        final resultCard = find.byKey(const ValueKey('card_perspective_result'));
        final errorCard = find.byKey(const ValueKey('card_error_feedback'));
        final timeout = DateTime.now().add(const Duration(seconds: 45));

        while (DateTime.now().isBefore(timeout)) {
          await tester.pump(const Duration(milliseconds: 400));
          if (resultCard.evaluate().isNotEmpty || errorCard.evaluate().isNotEmpty) {
            break;
          }
        }
        expect(errorCard, findsNothing);
        expect(resultCard, findsOneWidget);

        // 5. Open Account & Legal Dialog
        await tester.tap(accountBtn);
        await tester.pumpAndSettle();

        expect(find.text('Account & Legal'), findsOneWidget);
        expect(find.text('☁️ Cloud History Sync Active'), findsOneWidget);

        // 6. Tap "Delete Account"
        final deleteBtn = find.text('Delete Account');
        expect(deleteBtn, findsOneWidget);
        await tester.tap(deleteBtn);
        await tester.pumpAndSettle();

        // 7. Confirm deletion dialog: tap "Delete Permanently"
        expect(find.text('Delete Account?'), findsOneWidget);
        final confirmBtn = find.text('Delete Permanently');
        expect(confirmBtn, findsOneWidget);
        await tester.tap(confirmBtn);
        await tester.pump();

        // Wait for backend cascade deletion and signOut
        final endDelete = DateTime.now().add(const Duration(seconds: 10));
        while (DateTime.now().isBefore(endDelete) && AuthService().isAuthenticated) {
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 8. Assert user is logged out and confirmation snackbar is displayed
        expect(AuthService().isAuthenticated, isFalse);
        expect(
          find.text('Account and personal data permanently deleted.'),
          findsOneWidget,
        );

        // Visual confirmation on emulator for 3 seconds
        final pause = DateTime.now().add(const Duration(seconds: 3));
        while (DateTime.now().isBefore(pause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }
      },
    );
  });
}
