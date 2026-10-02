import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import 'legal_info_dialog.dart';

/// 👤 AccountLegalDialog: User profile dialog showing account details, legal links, sign-out, and account deletion
class AccountLegalDialog extends StatelessWidget {
  const AccountLegalDialog({super.key});

  /// Displays the Account & Legal dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AccountLegalDialog(),
    );
  }

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
            Text(
              'Delete Account?',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
              Navigator.of(context).pop(); // dismiss account dialog
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

  @override
  Widget build(BuildContext context) {
    final email = AuthService().currentUserEmail ?? 'User';

    return AlertDialog(
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
          onPressed: () => Navigator.of(context).pop(),
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
            Navigator.of(context).pop();
            await AuthService().signOut();
          },
        ),
      ],
    );
  }
}
