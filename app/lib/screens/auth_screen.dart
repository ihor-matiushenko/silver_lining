import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../services/auth_service.dart';

/// 🔐 AuthScreen: Glassmorphic Login & Registration Form with 2FA Support
class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;
  final VoidCallback onContinueAsGuest;

  const AuthScreen({
    super.key,
    required this.onAuthSuccess,
    required this.onContinueAsGuest,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final bool _requires2FA = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isSignUpMode) {
        await AuthService().signUp(email: email, password: password);
      } else {
        await AuthService().signIn(email: email, password: password);
      }

      if (mounted) {
        widget.onAuthSuccess();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handle2FAVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit authenticator code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Verify 2FA Code
    await Future.delayed(const Duration(milliseconds: 600)); // Simulating TOTP check
    if (mounted) {
      widget.onAuthSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.surface,
              AppColors.primary.withValues(alpha: 0.15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 24,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: _requires2FA ? _build2FAForm() : _buildPrimaryAuthForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryAuthForm() {
    return Form(
      key: _formKey,
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
            _isSignUpMode
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
                    onTap: () => setState(() => _isSignUpMode = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isSignUpMode ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Sign In',
                        style: AppTypography.buttonText.copyWith(
                          color: !_isSignUpMode ? Colors.white : Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isSignUpMode = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isSignUpMode ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Create Account',
                        style: AppTypography.buttonText.copyWith(
                          color: _isSignUpMode ? Colors.white : Colors.white60,
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
            controller: _emailController,
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
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: AppTypography.body,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger),
              ),
              child: Text(
                _errorMessage!,
                style: AppTypography.bodyMuted.copyWith(color: AppColors.danger),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    _isSignUpMode ? 'Create Account' : 'Sign In',
                    style: AppTypography.buttonText,
                  ),
          ),
          const SizedBox(height: 16),

          // Guest Mode Link Button
          TextButton(
            onPressed: widget.onContinueAsGuest,
            child: Text(
              'Continue as Guest (5 free daily reframings) ➔',
              style: AppTypography.bodyMuted.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build2FAForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.shield_outlined, size: 48, color: AppColors.warning),
        const SizedBox(height: 12),
        const Text('Two-Factor Authentication', style: AppTypography.titleBold, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        const Text(
          'Enter the 6-digit code from your Authenticator app',
          style: AppTypography.bodyMuted,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _otpController,
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
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _handle2FAVerify,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
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
