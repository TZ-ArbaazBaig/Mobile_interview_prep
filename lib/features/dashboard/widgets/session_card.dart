import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/session_model.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(session.createdAt);
    
    return InkWell(
      onTap: () {
        if (session.isCompleted) {
          context.push('/results/${session.id}');
        } else {
          context.push('/interview/${session.id}');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.charcoalCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
                ),
                _buildStatusIndicator(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.jobDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium(color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.help_outline_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${session.questions.length} Questions',
                      style: AppTextStyles.bodySmall(color: AppColors.textMuted),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      session.isCompleted ? 'View Results' : 'Resume Interview',
                      style: AppTextStyles.label(
                        color: session.isCompleted ? AppColors.violetAccent : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: session.isCompleted ? AppColors.violetAccent : AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (session.isCompleted) {
      final scoreVal = session.overallScore;
      final scoreText = scoreVal != null ? scoreVal.toStringAsFixed(1) : 'N/A';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.violetPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.violetPrimary.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: AppColors.violetGlow, size: 14),
            const SizedBox(width: 4),
            Text(
              '$scoreText/10',
              style: AppTextStyles.label(color: AppColors.violetAccent).copyWith(fontSize: 12),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 1),
        ),
        child: Text(
          'In Progress',
          style: AppTextStyles.label(color: AppColors.warning).copyWith(fontSize: 12),
        ),
      );
    }
  }

  String _formatDate(DateTime dt) {
    // Simple custom date formatter
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
