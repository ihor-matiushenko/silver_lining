import 'package:flutter/material.dart';
import '../../screens/auth_screen.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';

/// 🔝 Reusable Home Screen AppBar Component
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AuthScreen(
                  onAuthSuccess: () => Navigator.of(context).pop(),
                  onContinueAsGuest: () => Navigator.of(context).pop(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
