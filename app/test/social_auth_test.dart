import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_lining_app/screens/auth_screen.dart';
import 'package:silver_lining_app/services/auth_service.dart';
import 'package:silver_lining_app/services/providers/mock_auth_provider.dart';
import 'package:silver_lining_app/widgets/forms/primary_auth_form.dart';

void main() {
  setUp(() {
    AuthService().setProvider(MockAuthProvider());
  });

  group('🔐 Social Authentication (Apple & Google) Test Suite', () {
    testWidgets('PrimaryAuthForm renders Apple & Google buttons and handles taps', (WidgetTester tester) async {
      bool googleTapped = false;
      bool appleTapped = false;

      final formKey = GlobalKey<FormState>();
      final emailController = TextEditingController();
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrimaryAuthForm(
                formKey: formKey,
                emailController: emailController,
                passwordController: passwordController,
                isSignUpMode: false,
                obscurePassword: true,
                isLoading: false,
                errorMessage: null,
                onModeChanged: (_) {},
                onToggleObscurePassword: () {},
                onSubmit: () {},
                onGoogleSignIn: () => googleTapped = true,
                onAppleSignIn: () => appleTapped = true,
                onContinueAsGuest: () {},
              ),
            ),
          ),
        ),
      );

      // Verify Social Divider
      expect(find.text('or continue with'), findsOneWidget);

      // Verify Apple Button
      expect(find.byKey(const Key('apple_sign_in_button')), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);

      // Verify Google Button
      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);

      // Tap Apple
      await tester.tap(find.byKey(const Key('apple_sign_in_button')));
      await tester.pump();
      expect(appleTapped, isTrue);

      // Tap Google
      await tester.tap(find.byKey(const Key('google_sign_in_button')));
      await tester.pump();
      expect(googleTapped, isTrue);
    });

    testWidgets('AuthScreen completes social login via AuthService', (WidgetTester tester) async {
      bool authSuccess = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AuthScreen(
            onAuthSuccess: () => authSuccess = true,
            onContinueAsGuest: () {},
          ),
        ),
      );

      // Scroll to Google Login and Tap
      final googleButton = find.byKey(const Key('google_sign_in_button'));
      await tester.ensureVisible(googleButton);
      await tester.pumpAndSettle();

      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      expect(authSuccess, isTrue);
      expect(AuthService().isAuthenticated, isTrue);
      expect(AuthService().currentUserEmail, 'user.mock@gmail.com');
    });

    testWidgets('AuthScreen completes Apple sign-in via AuthService', (WidgetTester tester) async {
      bool authSuccess = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AuthScreen(
            onAuthSuccess: () => authSuccess = true,
            onContinueAsGuest: () {},
          ),
        ),
      );

      // Scroll to Apple Login and Tap
      final appleButton = find.byKey(const Key('apple_sign_in_button'));
      await tester.ensureVisible(appleButton);
      await tester.pumpAndSettle();

      await tester.tap(appleButton);
      await tester.pumpAndSettle();

      expect(authSuccess, isTrue);
      expect(AuthService().isAuthenticated, isTrue);
      expect(AuthService().currentUserEmail, 'user.mock@privaterelay.appleid.com');
    });
  });
}
