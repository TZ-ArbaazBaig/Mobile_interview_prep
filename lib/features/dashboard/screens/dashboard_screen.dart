import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../widgets/session_card.dart';
import '../widgets/session_shimmer.dart';
import '../../../models/session_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAndLoad();
    });
  }

  Future<void> _syncAndLoad() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
    if (mounted) {
      Provider.of<SessionProvider>(context, listen: false).fetchSessions();
    }
  }

  Future<void> _confirmDelete(BuildContext context, SessionModel session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bgSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          title: Text(
            'Delete Session?',
            style: AppTextStyles.h3(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to delete this prep session? This action cannot be undone.',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTextStyles.label(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      await sessionProvider.deleteSession(session.id);
      if (context.mounted) {
        final success = sessionProvider.error == null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Session deleted successfully' : 'Failed to delete session',
              style: AppTextStyles.bodyMedium(color: Colors.white),
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    final clerkUser = ClerkAuth.userOf(context);

    // Calculate quick stats
    final completedSessions = sessionProvider.sessions.where((s) => s.isCompleted).toList();
    final totalCompleted = completedSessions.length;
    double avgScore = 0.0;
    if (totalCompleted > 0) {
      final sum = completedSessions.fold(0.0, (prev, s) => prev + (s.overallScore ?? 0.0));
      avgScore = sum / totalCompleted;
    }

    final displayName = clerkUser?.firstName ?? authProvider.currentUser?.firstName ?? 'User';

    return GradientScaffold(
      body: authProvider.isLoading
          ? const AppLoader(message: 'Syncing profile with database...')
          : RefreshIndicator(
              onRefresh: () => sessionProvider.fetchSessions(),
              color: AppColors.violet,
              backgroundColor: AppColors.bgSecondary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top header: Profile + Logout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.violet.withOpacity(0.2),
                              backgroundImage: clerkUser?.imageUrl != null 
                                  ? NetworkImage(clerkUser!.imageUrl!) 
                                  : null,
                              child: clerkUser?.imageUrl == null
                                  ? const Icon(Icons.person, color: AppColors.violetLight)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Hello, $displayName 👋',
                              style: AppTextStyles.h3(color: Colors.white),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                          tooltip: 'Logout',
                          onPressed: () async {
                            await Provider.of<AuthProvider>(context, listen: false).signOut();
                          },
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 32),

                    // Quick Stats section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Completed Preps',
                                  style: AppTextStyles.bodySmall(color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$totalCompleted',
                                  style: AppTextStyles.h2(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            color: AppColors.border,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Average Score',
                                    style: AppTextStyles.bodySmall(color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    totalCompleted > 0 ? '${avgScore.toStringAsFixed(1)}/10' : '--',
                                    style: AppTextStyles.h2(
                                      color: totalCompleted > 0 ? AppColors.violetLight : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 36),

                    // Title header and New Session CTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your History',
                          style: AppTextStyles.h3(),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/new-session'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Start New'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    // Main session history body
                    if (sessionProvider.isLoading)
                      const Column(
                        children: [
                          SessionShimmer(),
                          SizedBox(height: 16),
                          SessionShimmer(),
                          SizedBox(height: 16),
                          SessionShimmer(),
                        ],
                      ).animate().fadeIn(duration: 300.ms)
                    else if (sessionProvider.error != null)
                      AppErrorWidget(
                        error: sessionProvider.error!,
                        onRetry: () => sessionProvider.fetchSessions(),
                      )
                    else if (sessionProvider.sessions.isEmpty)
                      AppEmptyState(
                        title: 'No Prep Sessions Yet',
                        description: 'Paste a job description to generate AI-tailored questions and start practicing.',
                        icon: Icons.assignment_outlined,
                        actionText: 'Start First Prep',
                        onActionPressed: () => context.push('/new-session'),
                      ).animate().fadeIn(delay: 300.ms)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sessionProvider.sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final session = sessionProvider.sessions[index];
                          return GestureDetector(
                            onLongPress: () => _confirmDelete(context, session),
                            child: SessionCard(session: session),
                          )
                              .animate()
                              .fadeIn(delay: (250 + (index * 50)).ms, duration: 400.ms)
                              .slideX(begin: 0.04, end: 0);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
