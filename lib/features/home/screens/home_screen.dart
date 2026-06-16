import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.bgSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            title: Text('Exit App?', style: AppTextStyles.h3(color: AppColors.textPrimary)),
            content: Text('Are you sure you want to exit the app?', style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel', style: AppTextStyles.label(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldPop == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              AppColors.bgSecondary,
              AppColors.bgPrimary,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Shimmer Glow
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet.withOpacity(0.08),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    
                    // App Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.violet.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.violet.withOpacity(0.3), width: 1.5),
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            color: AppColors.violetLight,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'InterviewPrep AI',
                          style: AppTextStyles.h2(color: AppColors.textPrimary),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.15, end: 0),

                    const SizedBox(height: 48),

                    // Headline
                    Text(
                      'Ace Your Next Interview with AI-Powered Practice',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1().copyWith(
                        height: 1.25,
                        fontSize: 32,
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 16),

                    // Tagline
                    Text(
                      'Generate tailored mock interview questions, practice answering, and receive instant, granular scoring with model answers.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                    const SizedBox(height: 40),

                    // Two CTAs (Row or Column depending on space)
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          child: AppButton(
                            text: 'Get Started',
                            onPressed: () => context.push('/sign-up'),
                            variant: AppButtonVariant.primary,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: AppButton(
                            text: 'Sign In',
                            onPressed: () => context.push('/sign-in'),
                            variant: AppButtonVariant.secondary,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 450.ms, duration: 600.ms),

                    const SizedBox(height: 64),

                    // Features Section Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Core Features',
                        style: AppTextStyles.h3(color: AppColors.textPrimary),
                      ),
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 20),

                    // Responsive Features Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth >= 720;
                        
                        final card1 = _buildFeatureCard(
                          icon: Icons.search_rounded,
                          title: 'RAG-powered Questions',
                          description: 'Tailored AI questions constructed directly from your pasted job description details.',
                        );
                        
                        final card2 = _buildFeatureCard(
                          icon: Icons.auto_awesome_rounded,
                          title: 'Instant Feedback',
                          description: 'Granular grading (1-10) explaining your strengths, flaws, and ideal model answers.',
                        );
                        
                        final card3 = _buildFeatureCard(
                          icon: Icons.analytics_rounded,
                          title: 'Track Progress',
                          description: 'Comprehensive sessions dashboard to review past results and track growth over time.',
                        );

                        if (isTablet) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: card1),
                              const SizedBox(width: 16),
                              Expanded(child: card2),
                              const SizedBox(width: 16),
                              Expanded(child: card3),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              card1,
                              const SizedBox(height: 16),
                              card2,
                              const SizedBox(height: 16),
                              card3,
                            ],
                          );
                        }
                      },
                    ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

                    const SizedBox(height: 48),

                    // Footer
                    Text(
                      '© 2026 InterviewPrep AI. Powered by Advanced LLMs.',
                      style: AppTextStyles.bodySmall(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.violet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.violetLight, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.h4(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
