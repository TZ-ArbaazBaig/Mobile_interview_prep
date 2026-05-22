import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.charcoalCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderDark, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.violetPrimary.withOpacity(0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.violetPrimary),
              strokeWidth: 3.5,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
              ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: const Duration(milliseconds: 300)),
          ],
        ],
      ),
    );
  }
}
