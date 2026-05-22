import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/question_model.dart';
import 'category_badge.dart';

class QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int index;
  final int total;

  const QuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.charcoalCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUESTION ${index + 1} OF $total',
                style: AppTextStyles.label(color: AppColors.violetAccent).copyWith(
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              CategoryBadge(category: question.category),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            question.text,
            style: AppTextStyles.h3(color: Colors.white).copyWith(
              height: 1.4,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
