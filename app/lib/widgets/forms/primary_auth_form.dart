import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../dialogs/legal_info_dialog.dart';

/// 📝 PrimaryAuthForm: Clean, single-responsibility form component for Sign In and Sign Up
class PrimaryAuthForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSignUpMode;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<bool> onModeChanged;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onSubmit;
  final VoidCallback onContinueAsGuest;

  const PrimaryAuthForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isSignUpMode,
    required this.obscurePassword,
    required this.isLoading,
    required this.errorMessage,
    required this.onModeChanged,
    required this.onToggleObscurePassword,
    required this.onSubmit,
    required this.onContinueAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo & Header Title
          const Icon(
            Icons.wb_sunny_rounded,
            size: 48,
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          const Text(
            'Silver Lining AI',
            style: AppTypography.titleBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isSignUpMode
                ? 'Create a free account for unlimited cloud reframings'
                : 'Welcome back! Sign in to access your cloud history',
            style: AppTypography.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Sign In vs Sign Up Segment Switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onModeChanged(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isSignUpMode ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Sign In',
                        style: AppTypography.buttonText.copyWith(
                          color: !isSignUpMode ? Colors.white : Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onModeChanged(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSignUpMode ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Create Account',
                        style: AppTypography.buttonText.copyWith(
                          color: isSignUpMode ? Colors.white : Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Email Field
          const Text('Email Address', style: AppTypography.subtitle),
          const SizedBox(height: 6),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTypography.body,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
              hintText: 'name@example.com',
              hintStyle: AppTypography.bodyMuted,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Email is required';
              if (!value.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          const Text('Password', style: AppTypography.subtitle),
          const SizedBox(height: 6),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            style: AppTypography.body,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white70,
                ),
                onPressed: onToggleObscurePassword,
              ),
              hintText: '••••••••••••',
              hintStyle: AppTypography.bodyMuted,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          // Error Banner
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger),
              ),
              child: Text(
                errorMessage!,
                style: AppTypography.bodyMuted.copyWith(color: AppColors.danger),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    isSignUpMode ? 'Create Account' : 'Sign In',
                    style: AppTypography.buttonText,
                  ),
          ),
          const SizedBox(height: 16),

          // Guest Mode Link Button
          TextButton(
            onPressed: onContinueAsGuest,
            child: Text(
              'Continue as Guest (5 free daily reframings) ➔',
              style: AppTypography.bodyMuted.copyWith(color: AppColors.warning),
            ),
          ),
          const SizedBox(height: 12),

          // Legal Terms & Privacy Policy Links (Store Compliance)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => LegalInfoDialog.showTermsOfService(context),
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text('  •  ', style: TextStyle(color: Colors.white24, fontSize: 11)),
              GestureDetector(
                onTap: () => LegalInfoDialog.showPrivacyPolicy(context),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
