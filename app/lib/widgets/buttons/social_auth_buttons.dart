import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';

/// 🌐 SocialAuthButtons: Clean, reusable buttons for Apple and Google OAuth sign-in
class SocialAuthButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onAppleSignIn;

  const SocialAuthButtons({
    super.key,
    required this.isLoading,
    this.onGoogleSignIn,
    this.onAppleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Divider with subtle text
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: AppTypography.bodyMuted.copyWith(fontSize: 12),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
          ],
        ),
        const SizedBox(height: 16),

        // Sign in with Apple Button (Apple HIG: Black pill with white logo)
        OutlinedButton.icon(
          key: const Key('apple_sign_in_button'),
          onPressed: isLoading ? null : onAppleSignIn,
          icon: const Icon(Icons.apple, color: Colors.white, size: 22),
          label: const Text(
            'Sign in with Apple',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.black,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),

        // Sign in with Google Button (Clean white surface with G badge)
        OutlinedButton(
          key: const Key('google_sign_in_button'),
          onPressed: isLoading ? null : onGoogleSignIn,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    fontFamily: 'sans-serif',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Continue with Google',
                style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
