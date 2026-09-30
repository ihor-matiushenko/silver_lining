import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// 🔐 TwoFactorAuthForm: Clean, single-responsibility 2FA OTP verification form
class TwoFactorAuthForm extends StatelessWidget {
  final TextEditingController otpController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onVerify;

  const TwoFactorAuthForm({
    super.key,
    required this.otpController,
    required this.isLoading,
    required this.onVerify,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.shield_outlined, size: 48, color: AppColors.warning),
        const SizedBox(height: 12),
        const Text(
          'Two-Factor Authentication',
          style: AppTypography.titleBold,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter the 6-digit code from your Authenticator app',
          style: AppTypography.bodyMuted,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: AppTypography.titleBold.copyWith(letterSpacing: 8),
          decoration: InputDecoration(
            hintText: '000000',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
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

        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading ? null : onVerify,
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
              : const Text('Verify Code', style: AppTypography.buttonText),
        ),
      ],
    );
  }
}
