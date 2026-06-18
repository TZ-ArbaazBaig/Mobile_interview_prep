import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../settings/screens/privacy_policy_screen.dart';
import '../../settings/screens/terms_screen.dart';
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

  Future<void> _confirmLogout(BuildContext context) async {
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
            'Log Out?',
            style: AppTextStyles.h3(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
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
                backgroundColor: AppColors.violet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final webUrl = dotenv.env['WEB_APP_URL'] ?? 'https://interviewprep-production-d031.up.railway.app';
    
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
            'Delete Account?',
            style: AppTextStyles.h3(color: AppColors.error),
          ),
          content: Text(
            'To comply with Google Play Policy, account deletion is managed securely on our web dashboard. We will redirect you to your settings page where you can delete your profile, credentials, and all practice data.',
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
              child: const Text('Go to Web Dashboard'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final deleteUri = Uri.parse('$webUrl/profile');
      if (await canLaunchUrl(deleteUri)) {
        await launchUrl(deleteUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open account deletion link.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final clerkUser = ClerkAuth.userOf(context);
        final email = (clerkUser?.emailAddresses != null && clerkUser!.emailAddresses!.isNotEmpty)
            ? clerkUser.emailAddresses!.first.emailAddress
            : '';

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Settings & Account',
                  style: AppTextStyles.h3(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (clerkUser != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgTertiary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.violet.withValues(alpha: 0.2),
                          backgroundImage: clerkUser.imageUrl != null 
                              ? NetworkImage(clerkUser.imageUrl!) 
                              : null,
                          child: clerkUser.imageUrl == null
                              ? const Icon(Icons.person, color: AppColors.violetLight)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${clerkUser.firstName ?? ''} ${clerkUser.lastName ?? ''}'.trim(),
                                style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.violetLight),
                  title: Text('Privacy Policy', style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
                const Divider(color: AppColors.border, height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.violetLight),
                  title: Text('Terms of Service', style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const TermsScreen()),
                    );
                  },
                ),
                const Divider(color: AppColors.border, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                  title: Text('Log Out', style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmLogout(context);
                  },
                ),
                const Divider(color: AppColors.border, height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                  title: Text('Delete Account', style: AppTextStyles.bodyMedium(color: AppColors.error)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDeleteAccount(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
      child: GradientScaffold(
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
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.violet.withValues(alpha: 0.2),
                                backgroundImage: clerkUser?.imageUrl != null 
                                    ? NetworkImage(clerkUser!.imageUrl!) 
                                    : null,
                                child: clerkUser?.imageUrl == null
                                    ? const Icon(Icons.person, color: AppColors.violetLight)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Hello, $displayName 👋',
                                  style: AppTextStyles.h3(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary),
                          tooltip: 'Settings & Account',
                          onPressed: () => _showSettingsBottomSheet(context),
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
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Completed Preps',
                                    style: AppTextStyles.bodySmall(color: AppColors.textMuted),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$totalCompleted',
                                    style: AppTextStyles.h2(),
                                  ),
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
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Average Score',
                                      style: AppTextStyles.bodySmall(color: AppColors.textMuted),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      totalCompleted > 0 ? '${avgScore.toStringAsFixed(1)}/10' : '--',
                                      style: AppTextStyles.h2(
                                        color: totalCompleted > 0 ? AppColors.violetLight : AppColors.textPrimary,
                                      ),
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
                        Expanded(
                          child: Text(
                            'Recent Sessions',
                            style: AppTextStyles.h3(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => context.push('/history'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('View All'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => context.push('/new-session'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Start New'),
                            ),
                          ],
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
                        itemCount: sessionProvider.sessions.length > 3 ? 3 : sessionProvider.sessions.length,
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
    ));
  }
}
