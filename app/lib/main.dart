import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const SilverLiningApp());
}

/// 🎨 Root Application Entry Point
class SilverLiningApp extends StatelessWidget {
  const SilverLiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silver Lining AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
