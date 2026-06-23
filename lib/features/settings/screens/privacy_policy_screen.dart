import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _launchEmail() async {
    final uri = Uri(scheme: 'mailto', path: 'arbaazbaig98@gmail.com');
    try {
      await launchUrl(uri);
    } catch (_) {
      // Fail-soft if no email app is installed
    }
  }

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
                  const Icon(Icons.shield_outlined,
                      size: 12, color: AppColors.violetLight),
                  const SizedBox(width: 6),
                  Text(
                    'COMPLIANCE PROTOCOL ACTIVE',
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
                    text: 'Privacy ',
                    style: GoogleFonts.sora(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                  ),
                  TextSpan(
                    text: 'Policy',
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
                  // Section 1: Overview
                  _buildSectionHeader(
                      '1. Overview & Data Security', AppColors.violet),
                  const SizedBox(height: 12),
                  Text(
                    'At Vault AI (InterviewPrep), we prioritize the protection and security of your personal data. This document outlines how we collect, store, share, and manage your information when you access our mock interview preparation platform both via our web dashboard and Google Play Store mobile applications.',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.textSecondary, height: 1.7),
                  ),

                  const SizedBox(height: 32),

                  // Section 2: Data We Collect
                  _buildSectionHeader('2. Data We Collect', AppColors.violet),
                  const SizedBox(height: 16),
                  _buildDataCard(
                    Icons.lock_outline,
                    'Auth Metadata',
                    'Email addresses, name variables, and profile pictures synchronized securely through Clerk identity providers.',
                  ),
                  const SizedBox(height: 12),
                  _buildDataCard(
                    Icons.storage_outlined,
                    'Practice Logs',
                    'Pasted job descriptions, AI-generated questions, candidate answers, performance scoring, and feedback.',
                  ),
                  const SizedBox(height: 12),
                  _buildDataCard(
                    Icons.visibility_outlined,
                    'RAG Context',
                    'Temporary, in-memory keyword indexing segments created from your uploaded job descriptions for the contextual chat.',
                  ),

                  const SizedBox(height: 32),

                  // Section 3: AI Processing
                  _buildSectionHeader(
                      '3. Processing via Artificial Intelligence',
                      AppColors.violet),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall(
                          color: AppColors.textSecondary, height: 1.7),
                      children: [
                        const TextSpan(
                            text:
                                'Your job descriptions and mock interview responses are securely processed via the '),
                        TextSpan(
                          text: 'Groq API',
                          style: AppTextStyles.bodySmall(
                                  color: Colors.white, height: 1.7)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' using the '),
                        TextSpan(
                          text: 'Llama-3.3-70b-versatile',
                          style: AppTextStyles.bodySmall(
                                  color: Colors.white, height: 1.7)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                            text:
                                ' model. These interactions are strictly query-response pipelines. Groq does not retain your transcripts or personal data to train public models.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section 4: Data Retention & Deletion
                  _buildSectionHeader(
                      '4. Data Retention & Permanent Deletion Policy',
                      const Color(0xFFFB7185)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFB7185).withValues(alpha: 0.05),
                      border: Border.all(
                          color:
                              const Color(0xFFFB7185).withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.delete_outline,
                                size: 18, color: Color(0xFFFB7185)),
                            const SizedBox(width: 8),
                            Text(
                              'PURGE PROTECTION ENABLED',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFB7185),
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'In compliance with Google Play Store User Data policies, users can initiate immediate and permanent deletion of their account and all associated data.',
                          style: AppTextStyles.bodySmall(
                              color: AppColors.textSecondary, height: 1.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'HOW TO EXECUTE DELETION:',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You can delete your account inside the mobile app settings or by clicking the Delete Account option next to your avatar in the web dashboard header. This action completely deletes:',
                          style: AppTextStyles.bodySmall(
                              color: AppColors.textSecondary, height: 1.7),
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint(
                            'Your profile and registration credentials in Clerk.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint(
                            'Your primary User entity in our database.'),
                        const SizedBox(height: 6),
                        _buildBulletPoint(
                            'All historical mock sessions, generated questions, and cumulative performance scores.'),
                        const SizedBox(height: 16),
                        Text(
                          '*Caution: This operation is destructive and cannot be undone. All data is purged permanently from our database.',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFFFB7185),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section 5: Contact
                  _buildSectionHeader(
                      '5. Contacts & Inquiries', AppColors.violet),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall(
                          color: AppColors.textSecondary, height: 1.7),
                      children: [
                        const TextSpan(
                            text:
                                'If you have any questions or data protection queries regarding our policies or third-party SDK implementations (Clerk, MongoDB), reach out via email: '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: _launchEmail,
                            child: Text(
                              'arbaazbaig98@gmail.com',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.violetLight,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
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

  Widget _buildDataCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary.withValues(alpha: 0.6),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.violetLight),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
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
