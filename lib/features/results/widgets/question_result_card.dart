import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/question_model.dart';
import '../../../models/evaluation_model.dart';
import '../../../providers/interview_provider.dart';
import 'model_answer_sheet.dart';

class QuestionResultCard extends StatefulWidget {
  final QuestionModel question;
  final EvaluationModel evaluation;
  final int index;

  const QuestionResultCard({
    super.key,
    required this.question,
    required this.evaluation,
    required this.index,
  });

  @override
  State<QuestionResultCard> createState() => _QuestionResultCardState();
}

class _QuestionResultCardState extends State<QuestionResultCard> {
  bool _isExpanded = false;

  Color _getScoreColor(int score) {
    if (score >= 8) return const Color(0xFF34D399); // emerald
    if (score >= 5) return const Color(0xFFA855F7); // violet
    return const Color(0xFFFB7185); // rose
  }

  void _showModelAnswer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: ModelAnswerSheet(
          modelAnswer: widget.evaluation.modelAnswer,
          questionText: widget.question.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSkipped = widget.evaluation.userAnswer.trim().isEmpty;
    final scoreColor = isSkipped ? AppColors.textMuted : _getScoreColor(widget.evaluation.score);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? AppColors.violet.withValues(alpha: 0.4) : AppColors.border,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsed Header Tap Area
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QUESTION ${widget.index + 1}',
                          style: AppTextStyles.label(color: AppColors.textMuted).copyWith(
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.question.text,
                          maxLines: _isExpanded ? 10 : 2,
                          overflow: _isExpanded ? null : TextOverflow.ellipsis,
                          style: AppTextStyles.h4(color: Colors.white).copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: scoreColor.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Text(
                          isSkipped ? 'SKIPPED' : '${widget.evaluation.score}/10',
                          style: AppTextStyles.label(color: scoreColor).copyWith(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Icon(
                        _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Feedback Section
          if (_isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSkipped) ...[
                    Text(
                      'Skipped during session',
                      style: AppTextStyles.bodyMedium(color: AppColors.textSecondary).copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    // User answer
                    Text(
                      'YOUR RESPONSE',
                      style: AppTextStyles.label(color: AppColors.textMuted).copyWith(fontSize: 11, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.evaluation.userAnswer,
                      style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 24),

                    // AI Evaluation feedback
                    Text(
                      'AI FEEDBACK & ANALYSIS',
                      style: AppTextStyles.label(color: AppColors.violetLight).copyWith(fontSize: 11, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.evaluation.feedback,
                      style: AppTextStyles.bodyMedium(color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Study button
                    OutlinedButton.icon(
                      onPressed: _showModelAnswer,
                      icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.violetLight),
                      label: const Text('Study Model Answer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.violetLight,
                        side: const BorderSide(color: AppColors.violet, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Retry button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
                      await interviewProvider.retryQuestion(widget.index);
                      if (context.mounted) {
                        context.push('/interview/${interviewProvider.activeSession!.id}');
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                    label: const Text('Retry Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
