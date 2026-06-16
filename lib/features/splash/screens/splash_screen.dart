import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.violet.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.violet.withOpacity(0.3), width: 2),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: AppColors.violetLight,
                size: 64,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 24),
            Text(
              'InterviewPrep AI',
              style: AppTextStyles.h1(color: AppColors.textPrimary),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
