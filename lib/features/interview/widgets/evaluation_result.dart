import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/evaluation_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EvaluationResult extends StatefulWidget {
  final EvaluationModel evaluation;

  const EvaluationResult({super.key, required this.evaluation});

  @override
  State<EvaluationResult> createState() => _EvaluationResultState();
}

class _EvaluationResultState extends State<EvaluationResult> {

  Color get _scoreColor {
    final score = widget.evaluation.score;
    if (score >= 8) return const Color(0xFF34D399); // emerald
    if (score >= 5) return const Color(0xFFA855F7); // violet
    return const Color(0xFFFB7185); // rose
  }

  Color get _scoreBgColor {
    return _scoreColor.withValues(alpha: 0.05);
  }

  Color get _scoreBorderColor {
    return _scoreColor.withValues(alpha: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Box
            Container(
              width: 120,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: _scoreBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _scoreBorderColor, width: 1.5),
              ),
              child: Column(
                children: [
                  Text('YOUR SCORE', style: AppTextStyles.label(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.evaluation.score}',
                    style: AppTextStyles.h1(color: _scoreColor).copyWith(fontStyle: FontStyle.italic, fontSize: 48),
                  ),
                  Text('/ 10', style: AppTextStyles.label(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // AI Feedback
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.violetLight, size: 20),
                        const SizedBox(width: 8),
                        Text('AI FEEDBACK', style: AppTextStyles.label(color: AppColors.violetLight)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"${widget.evaluation.feedback}"',
                      style: AppTextStyles.bodyLarge(color: Colors.white).copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Model Answer Accordion
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.violet.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bolt, color: AppColors.violetLight, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('VIEW MODEL ANSWER', style: AppTextStyles.label(color: Colors.white)),
                  ],
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Text(
                      widget.evaluation.modelAnswer.isNotEmpty 
                          ? widget.evaluation.modelAnswer 
                          : 'No model answer provided.',
                      style: AppTextStyles.bodyMedium(color: AppColors.textSecondary).copyWith(height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
