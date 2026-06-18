import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/session_model.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(session.createdAt);
    
    final answeredCount = session.evaluations.length;
    final totalCount = session.questions.isEmpty ? 10 : session.questions.length;
    final progressVal = answeredCount / totalCount;

    return InkWell(
      onTap: () {
        // Navigate to the practice console
        context.push('/practice/${session.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(answeredCount, totalCount),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.jobTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              session.jobDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            
            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressVal,
                      minHeight: 6,
                      backgroundColor: AppColors.bgPrimary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        session.isCompleted || answeredCount == totalCount
                            ? const Color(0xFF34D399) // emerald
                            : AppColors.violetLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$answeredCount/$totalCount',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  answeredCount == totalCount ? 'View Results' : 'Practice Console',
                  style: GoogleFonts.spaceGrotesk(
                    color: answeredCount == totalCount ? const Color(0xFF34D399) : AppColors.violetLight,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: answeredCount == totalCount ? const Color(0xFF34D399) : AppColors.violetLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int answered, int total) {
    Color textColor;
    Color borderColor;
    Color bgColor;
    String label;

    if (answered == 0) {
      label = 'NEW';
      textColor = const Color(0xFFA855F7); // #A855F7
      borderColor = const Color(0xFF8F00FF).withValues(alpha: 0.2);
      bgColor = const Color(0xFF8F00FF).withValues(alpha: 0.1);
    } else if (answered == total || session.isCompleted) {
      label = 'COMPLETED';
      textColor = const Color(0xFF34D399); // #34D399
      borderColor = const Color(0xFF34D399).withValues(alpha: 0.2);
      bgColor = const Color(0xFF34D399).withValues(alpha: 0.05);
    } else {
      label = 'IN PROGRESS';
      textColor = const Color(0xFFE2E8F0); // #E2E8F0
      borderColor = const Color(0xFF1A1A1A);
      bgColor = const Color(0xFF121212);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
