import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              color: AppColors.textSecondary, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'BACK TO BASE',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 3,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: 0.1),
                border:
                    Border.all(color: AppColors.violet.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined,
                      size: 12, color: AppColors.violetLight),
                  const SizedBox(width: 6),
                  Text(
                    'USER AGREEMENT ACTIVE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.violetLight,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Title
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Terms & ',
                    style: GoogleFonts.sora(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                  ),
                  TextSpan(
                    text: 'Conditions',
                    style: GoogleFonts.sora(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.violet,
                      letterSpacing: -1.5,
                      fontStyle: FontStyle.italic,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Effective date
            Text(
              'EFFECTIVE: JUNE 17, 2026',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted.withValues(alpha: 0.4),
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 32),

            // Content Panel
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary.withValues(alpha: 0.4),
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Acceptance
                  _buildSectionHeader(
                      '1. Acceptance of Terms', AppColors.violet),
                  const SizedBox(height: 12),
                  Text(
                    'By accessing or using the Vault AI (InterviewPrep) platform (via the web dashboard or our mobile application published on the Google Play Store), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please terminate your access to the service immediately.',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.textSecondary, height: 1.7),
                  ),

                  const SizedBox(height: 32),

                  // Section 2: Scope of Services
                  _buildSectionHeader(
                      '2. Scope of Services & Fair Use', AppColors.violet),
                  const SizedBox(height: 12),
                  Text(
                    'Vault AI provides automated mock interview generation, job description context extraction using RAG (Retrieval-Augmented Generation), scoring analytics, and interactive chats.',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.textSecondary, height: 1.7),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You agree to use this platform for personal, non-commercial interview preparation. You must not attempt to scrape interview data, overload the API limits, inject malicious payloads, or abuse the free tiers of service.',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.textSecondary, height: 1.7),
                  ),

                  const SizedBox(height: 32),

                  // Section 3: AI Disclaimer
                  _buildSectionHeader(
                      '3. AI Performance & Disclaimers', AppColors.violet),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.05),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 18, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Text(
                              'AI EVALUATION DISCLAIMER',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'All questions, evaluations, grading scores, and better answer models are generated dynamically by artificial intelligence.',
                          style: AppTextStyles.bodySmall(
                              color: AppColors.textSecondary, height: 1.7),
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint(
                            'Scores and feedback are automated recommendations, not professional evaluations.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint(
                            'We do not guarantee that practicing on our platform will secure employment or guarantee matching questions in live corporate interviews.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint(
                            'AI models can occasionally hallucinate or output inaccurate text. Users should cross-reference suggestions with standard engineering best practices.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section 4: User Accounts
                  _buildSectionHeader(
                      '4. User Accounts & Identity Checks', AppColors.violet),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall(
                          color: AppColors.textSecondary, height: 1.7),
                      children: [
                        const TextSpan(text: 'We leverage '),
                        TextSpan(
                          text: 'Clerk',
                          style: AppTextStyles.bodySmall(
                                  color: Colors.white, height: 1.7)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                            text:
                                ' to handle user registration and secure session tokens. You are responsible for keeping your login credentials confidential. We reserve the right to suspend or terminate accounts that violate system protocols or engage in abusive activities.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section 5: Limitation of Liability
                  _buildSectionHeader(
                      '5. Limitation of Liability', AppColors.violet),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgTertiary.withValues(alpha: 0.6),
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.balance_outlined,
                            size: 22, color: AppColors.violetLight),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Vault AI, its developers, and partners shall not be held liable for any indirect, incidental, or consequential damages resulting from your use of, or inability to use, our platform, including but not limited to server downtime, AI generation errors, or loss of historical performance logs.',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              height: 1.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section 6: Modifications
                  _buildSectionHeader(
                      '6. Modifications to Terms', AppColors.violet),
                  const SizedBox(height: 12),
                  Text(
                    'We reserve the right to modify these Terms and Conditions at any time. Your continued use of the platform following modifications constitutes acceptance of the updated terms.',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.textSecondary, height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accentColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
