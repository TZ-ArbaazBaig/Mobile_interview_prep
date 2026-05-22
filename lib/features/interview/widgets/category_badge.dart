import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    switch (category.toLowerCase()) {
      case 'technical':
        badgeColor = AppColors.violet;
        break;
      case 'behavioral':
        badgeColor = AppColors.success;
        break;
      case 'system design':
        badgeColor = AppColors.info;
        break;
      default:
        badgeColor = AppColors.violet;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1.2),
      ),
      child: Text(
        category.toUpperCase(),
        style: AppTextStyles.label(color: badgeColor).copyWith(
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
