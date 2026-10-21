import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:silver_lining_app/main.dart' as app;
import 'package:silver_lining_app/services/auth_service.dart';
import 'package:silver_lining_app/services/providers/mock_auth_provider.dart';
import 'package:silver_lining_app/services/storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🧪 E2E Test Suite: In-App Account Deletion Cascade (TC-A06)', () {
    setUp(() async {
      AuthService().setProvider(MockAuthProvider());
      await StorageService.clearAllHistory();
      if (AuthService().isAuthenticated) {
        await AuthService().signOut();
      }
    });

    testWidgets(
      'TC-A06: User logs in, opens Account & Legal dialog, confirms account deletion, and verifies session cleared',
      (tester) async {
        await app.main();
        await tester.pumpAndSettle();

        // 1. Sign in via AppBar button
        final accountBtn = find.byKey(const ValueKey('btn_account_action'));
        expect(accountBtn, findsOneWidget);
        await tester.tap(accountBtn);
        await tester.pumpAndSettle();

        final emailField = find.byKey(const ValueKey('input_auth_email'));
        final passwordField = find.byKey(const ValueKey('input_auth_password'));
        final submitBtn = find.byKey(const ValueKey('btn_auth_submit'));

        await tester.enterText(emailField, 'user_to_delete@silverlining.app');
        await tester.pumpAndSettle();

        await tester.enterText(passwordField, 'Password123!');
        await tester.pumpAndSettle();

        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(AuthService().isAuthenticated, isTrue);

        // 2. Tap Account button again to open AccountLegalDialog
        await tester.tap(accountBtn);
        await tester.pumpAndSettle();

        expect(find.text('Account & Legal'), findsOneWidget);
        expect(find.text('☁️ Cloud History Sync Active'), findsOneWidget);

        // 3. Tap "Delete Account" button
        final deleteAccountBtn = find.text('Delete Account');
        expect(deleteAccountBtn, findsOneWidget);
        await tester.tap(deleteAccountBtn);
        await tester.pumpAndSettle();

        // 4. Verify confirmation dialog and tap "Delete Permanently"
        expect(find.text('Delete Account?'), findsOneWidget);
        final confirmDeleteBtn = find.text('Delete Permanently');
        expect(confirmDeleteBtn, findsOneWidget);

        await tester.tap(confirmDeleteBtn);
        await tester.pumpAndSettle();

        // 5. Verify user is signed out and redirected to guest state
        expect(AuthService().isAuthenticated, isFalse);
        expect(find.text('Account and personal data permanently deleted.'), findsOneWidget);

        // Keep visual confirmation on emulator for 3 seconds
        final pause = DateTime.now().add(const Duration(seconds: 3));
        while (DateTime.now().isBefore(pause)) {
          await tester.pump(const Duration(milliseconds: 300));
        }
      },
    );
  });
}
