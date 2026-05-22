import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String? error;
  final String? message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.error,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final String displayError = message ?? error ?? 'An unknown error occurred';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.charcoalCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Something Went Wrong',
                style: AppTextStyles.h4(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                displayError,
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                AppButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                  variant: AppButtonVariant.secondary,
                  width: 140,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
