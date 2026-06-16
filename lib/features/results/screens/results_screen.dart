import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/results_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_button.dart';
import '../widgets/score_ring.dart';
import '../widgets/question_result_card.dart';
import '../../../models/evaluation_model.dart';

class ResultsScreen extends StatefulWidget {
  final String sessionId;

  const ResultsScreen({super.key, required this.sessionId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResultsProvider>(context, listen: false).fetchResults(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsProvider = Provider.of<ResultsProvider>(context);

    if (resultsProvider.isLoading) {
      return const GradientScaffold(
        body: AppLoader(message: 'Generating detailed score breakdown...'),
      );
    }

    if (resultsProvider.error != null) {
      return GradientScaffold(
        body: AppErrorWidget(
          error: resultsProvider.error!,
          onRetry: () => Provider.of<ResultsProvider>(context, listen: false).fetchResults(widget.sessionId),
        ),
      );
    }

    final session = resultsProvider.completedSession;
    if (session == null) {
      return const GradientScaffold(
        body: Center(
          child: Text('Results not found.'),
        ),
      );
    }

    final evaluationsWithScores = session.evaluations.where((e) => e.score > 0).toList();
    final averageScore = evaluationsWithScores.isNotEmpty
        ? evaluationsWithScores.fold(0.0, (acc, e) => acc + e.score) / evaluationsWithScores.length
        : 0.0;
        
    final strongCount = session.evaluations.where((e) => e.score >= 8).length;
    final weakCount = session.evaluations.where((e) => e.score < 5 && e.score > 0).length;

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('Session Results', style: AppTextStyles.h4(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            onPressed: () {
              Fluttertoast.showToast(
                msg: "Link copied to clipboard!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: AppColors.bgSecondary,
                textColor: AppColors.textPrimary,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            
            // Overall score ring widget
            ScoreRing(score: averageScore)
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),

            const SizedBox(height: 28),

            Text(
              _getPerformanceTag(averageScore),
              style: AppTextStyles.h2(),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 8),

            Text(
              'Review your score card, feedback summaries, and model answers below to refine your knowledge for live interviews.',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Category score breakdown row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Answered',
                    value: '${evaluationsWithScores.length}/${session.questions.length}',
                    icon: Icons.my_location_rounded,
                    color: AppColors.violet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Strong',
                    value: '$strongCount',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Needs Work',
                    value: '$weakCount',
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: 36),

            // Section divider
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Question Breakdown',
                style: AppTextStyles.h3(),
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 16),

            // Per question expandable evaluation cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: session.questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final q = session.questions[index];
                
                // Find matching evaluation
                final e = session.evaluations.firstWhere(
                  (eval) => eval.questionId == q.id,
                  orElse: () => EvaluationModel(
                    questionId: q.id,
                    score: 0,
                    feedback: 'No evaluation could be processed for this question.',
                    modelAnswer: 'N/A',
                    userAnswer: '',
                  ),
                );

                return QuestionResultCard(
                  question: q,
                  evaluation: e,
                  index: index,
                )
                    .animate()
                    .fadeIn(delay: (450 + (index * 80)).ms, duration: 400.ms)
                    .slideY(begin: 0.05, end: 0);
              },
            ),

            const SizedBox(height: 40),

            // Practice Again CTA
            AppButton(
              text: 'Practice Again',
              onPressed: () {
                context.push('/new-session', extra: session.jobDescription);
              },
              variant: AppButtonVariant.primary,
            ).animate().fadeIn(delay: 750.ms),

            const SizedBox(height: 12),

            // Back to dashboard CTA
            AppButton(
              text: 'Back to Dashboard',
              onPressed: () {
                resultsProvider.clearResults();
                context.go('/dashboard');
              },
              variant: AppButtonVariant.secondary,
            ).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getPerformanceTag(double score) {
    if (score >= 8.0) return 'Great performance!';
    if (score >= 6.0) return 'Good effort!';
    return 'Keep practicing!';
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withOpacity(0.5), size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h2(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.label(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
