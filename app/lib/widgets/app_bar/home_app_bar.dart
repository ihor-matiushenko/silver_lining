import 'package:flutter/material.dart';
import '../../screens/auth_screen.dart';
import '../../services/auth_service.dart';
import '../../services/dynamic_localization_service.dart';
import '../../theme/app_colors.dart';
import '../dialogs/account_legal_dialog.dart';
import '../dialogs/language_selector_modal.dart';

/// 🔝 Reusable Home Screen AppBar Component
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthService(),
        DynamicLocalizationService.instance,
      ]),
      builder: (context, _) {
        final isAuth = AuthService().isAuthenticated;
        final l10n = DynamicLocalizationService.instance;

        return AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('✨', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.translate('appTitle'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // 🌐 Language Selector Button
            IconButton(
              tooltip: l10n.translate('languageTitle'),
              icon: const Icon(Icons.language, color: Colors.white70),
              onPressed: () => LanguageSelectorModal.show(context),
            ),

            // 👤 Account / Login Button
            IconButton(
              tooltip: isAuth
                  ? 'Account: ${AuthService().currentUserEmail ?? 'User'}'
                  : 'Sign In / Register',
              icon: Icon(
                isAuth ? Icons.account_circle : Icons.login,
                color: isAuth ? AppColors.secondary : Colors.white70,
              ),
              onPressed: () {
                if (isAuth) {
                  AccountLegalDialog.show(context);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AuthScreen(
                        onAuthSuccess: () => Navigator.of(context).pop(),
                        onContinueAsGuest: () => Navigator.of(context).pop(),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
