import 'package:flutter/material.dart';
import '../../screens/auth_screen.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';

/// 🔝 Reusable Home Screen AppBar Component
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

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
            Text('Account', style: TextStyle(color: Colors.white, fontSize: 18)),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger.withValues(alpha: 0.8),
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
      listenable: AuthService(),
      builder: (context, _) {
        final isAuth = AuthService().isAuthenticated;
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
              const Text('Silver Lining AI', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
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
