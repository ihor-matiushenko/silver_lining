import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/forms/primary_auth_form.dart';
import '../widgets/forms/two_factor_auth_form.dart';
import '../widgets/glass_card.dart';

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

    // Verify 2FA Code (Simulating TOTP check)
    await Future.delayed(const Duration(milliseconds: 600));
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
              child: GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(28),
                backgroundColor: AppColors.surface,
                borderColor: AppColors.primary,
                child: _requires2FA
                    ? TwoFactorAuthForm(
                        otpController: _otpController,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        onVerify: _handle2FAVerify,
                      )
                    : PrimaryAuthForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        isSignUpMode: _isSignUpMode,
                        obscurePassword: _obscurePassword,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        onModeChanged: (val) => setState(() => _isSignUpMode = val),
                        onToggleObscurePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                        onSubmit: _handleSubmit,
                        onContinueAsGuest: widget.onContinueAsGuest,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
