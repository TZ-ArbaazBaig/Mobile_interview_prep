import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.charcoalCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderDark, width: 1.5),
              ),
              child: Icon(
                icon,
                color: AppColors.violetAccent,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.h3(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: actionText!,
                onPressed: onActionPressed,
                variant: AppButtonVariant.primary,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
