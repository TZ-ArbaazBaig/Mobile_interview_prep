import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class ModelAnswerSheet extends StatelessWidget {
  final String modelAnswer;
  final String questionText;

  const ModelAnswerSheet({
    super.key,
    required this.modelAnswer,
    required this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.charcoalCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Model Answer',
                style: AppTextStyles.h3(),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: AppColors.violetAccent, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: modelAnswer));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Model answer copied to clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'QUESTION',
            style: AppTextStyles.label(color: AppColors.textMuted).copyWith(fontSize: 11, letterSpacing: 1.0),
          ),
          const SizedBox(height: 6),
          Text(
            questionText,
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderDark),
          const SizedBox(height: 20),
          Text(
            'MODEL ANSWER',
            style: AppTextStyles.label(color: AppColors.violetAccent).copyWith(fontSize: 11, letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                modelAnswer,
                style: AppTextStyles.bodyLarge(color: AppColors.textPrimary).copyWith(height: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Close Sheet',
            onPressed: () => Navigator.pop(context),
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}
