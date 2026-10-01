import 'package:flutter/material.dart';
import '../../screens/auth_screen.dart';
import '../../services/auth_service.dart';
import '../../services/dynamic_localization_service.dart';
import '../../theme/app_colors.dart';
import '../dialogs/language_selector_modal.dart';
import '../dialogs/legal_info_dialog.dart';

/// 🔝 Reusable Home Screen AppBar Component
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (confirmCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Delete Account?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account?\n\nAll your saved reflections, favorites, and cloud history will be permanently erased. This action cannot be undone.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(confirmCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(confirmCtx).pop(); // dismiss confirm
              Navigator.of(context).pop();    // dismiss account dialog
              await AuthService().deleteAccount();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: const Text('Account and personal data permanently deleted.'),
                  ),
                );
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAccountDialog(BuildContext context) {
    final email = AuthService().currentUserEmail ?? 'User';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.account_circle, color: AppColors.secondary),
            SizedBox(width: 8),
            Text('Account & Legal', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Signed in as:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            const Text('☁️ Cloud History Sync Active', style: TextStyle(color: AppColors.success, fontSize: 13)),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),

            // Store Compliance Legal & Medical Links
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ActionChip(
                  label: const Text('Medical Disclaimer', style: TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.background,
                  onPressed: () => LegalInfoDialog.showMedicalDisclaimer(context),
                ),
                ActionChip(
                  label: const Text('Privacy Policy', style: TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.background,
                  onPressed: () => LegalInfoDialog.showPrivacyPolicy(context),
                ),
                ActionChip(
                  label: const Text('Terms of Service', style: TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.background,
                  onPressed: () => LegalInfoDialog.showTermsOfService(context),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // In-App Account Deletion (Apple 5.1.1(v) & Google Play Data Deletion)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.delete_forever, size: 16),
            label: const Text('Delete Account', style: TextStyle(fontSize: 12)),
            onPressed: () => _confirmDeleteAccount(context),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Sign Out'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthService().signOut();
            },
          ),
        ],
      ),
    );
  }


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
              tooltip: isAuth ? 'Account: ${AuthService().currentUserEmail ?? 'User'}' : 'Sign In / Register',
              icon: Icon(
                isAuth ? Icons.account_circle : Icons.login,
                color: isAuth ? AppColors.secondary : Colors.white70,
              ),
              onPressed: () {
                if (isAuth) {
                  _showAccountDialog(context);
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
