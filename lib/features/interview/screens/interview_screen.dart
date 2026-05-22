import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/interview_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_button.dart';
import '../widgets/category_badge.dart';
import '../widgets/progress_bar.dart';
import '../widgets/answer_input.dart';
import '../../../models/evaluation_model.dart';

class InterviewScreen extends StatefulWidget {
  final String sessionId;

  const InterviewScreen({super.key, required this.sessionId});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isLoadingSession = false;
  Timer? _autosaveTimer;
  EvaluationModel? _flashResult;
  bool _showFlash = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
    _startAutosaveTimer();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _startAutosaveTimer() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _saveDraft();
    });
  }

  Future<void> _saveDraft() async {
    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    final question = interviewProvider.currentQuestion;
    if (question != null && _answerController.text.isNotEmpty) {
      await interviewProvider.saveDraft(question.id, _answerController.text);
    }
  }

  Future<void> _initSession() async {
    setState(() {
      _isLoadingSession = true;
    });

    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    try {
      await interviewProvider.loadSession(widget.sessionId);
      if (mounted) {
        _answerController.text = interviewProvider.currentAnswer;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load session details: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        context.go('/dashboard');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSession = false;
        });
      }
    }
  }

  Future<void> _handleExit() async {
    await _saveDraft();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Quit Mock Interview?', style: AppTextStyles.h3(color: Colors.white)),
        content: Text(
          'Are you sure you want to quit? Progress will be saved.',
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Stay', style: AppTextStyles.label(color: AppColors.violetLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Quit', style: AppTextStyles.label(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _handleSubmit() async {
    await _saveDraft();
    if (!mounted) return;
    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    final question = interviewProvider.currentQuestion;
    if (question == null) return;

    final answerText = _answerController.text.trim();
    if (answerText.length < 20) return;

    final success = await interviewProvider.submitAnswer(question.id, answerText);

    if (!mounted) return;

    if (success) {
      final newEval = interviewProvider.evaluations[question.id];
      setState(() {
        _flashResult = newEval;
        _showFlash = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() {
        _showFlash = false;
      });

      if (interviewProvider.isLastQuestion) {
        final completedSession = await interviewProvider.submitInterview();
        if (mounted) {
          if (completedSession != null) {
            Provider.of<SessionProvider>(context, listen: false).fetchSessions();
            context.replace('/results/${completedSession.id}');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(interviewProvider.error ?? 'Failed to submit. Please try again.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else {
        await interviewProvider.nextQuestion();
        if (mounted) {
          _answerController.text = interviewProvider.currentAnswer;
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(interviewProvider.error ?? 'Failed to submit. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final interviewProvider = Provider.of<InterviewProvider>(context);

    if (_isLoadingSession || interviewProvider.isLoading) {
      return const GradientScaffold(
        body: AppLoader(message: 'Loading your interview questions...'),
      );
    }

    if (interviewProvider.activeSession == null) {
      return const GradientScaffold(
        body: Center(
          child: Text('Interview session not found.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    if (interviewProvider.isSubmitting) {
      return const GradientScaffold(
        body: AppLoader(
          message: 'Evaluating...',
        ),
      );
    }

    final question = interviewProvider.currentQuestion;
    final totalQuestions = interviewProvider.questions.length;
    final currentIndex = interviewProvider.currentIndex;
    final jd = interviewProvider.activeSession?.jobDescription ?? '';
    final truncatedJd = jd.length > 25 ? '${jd.substring(0, 25)}...' : jd;

    final bool isAnswerValid = _answerController.text.trim().length >= 20;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleExit();
      },
      child: Stack(
        children: [
          GradientScaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                onPressed: _handleExit,
              ),
              title: Text(
                'Mock Interview',
                style: AppTextStyles.h4(color: Colors.white),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          truncatedJd,
                          style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Question ${currentIndex + 1} of $totalQuestions',
                        style: AppTextStyles.bodySmall(color: AppColors.violetLight).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ProgressBar(value: interviewProvider.progressPercent),
                  const SizedBox(height: 24),

                  if (question != null) ...[
                    CategoryBadge(category: question.category),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        question.text,
                        style: AppTextStyles.h3(color: Colors.white).copyWith(
                          height: 1.4,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: SingleChildScrollView(
                        child: AnswerInput(
                          controller: _answerController,
                          onChanged: (val) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        if (currentIndex > 0) ...[
                          Expanded(
                            child: AppButton(
                              text: 'Back',
                              onPressed: () async {
                                await _saveDraft();
                                await interviewProvider.previousQuestion();
                                if (mounted) {
                                  _answerController.text = interviewProvider.currentAnswer;
                                }
                              },
                              variant: AppButtonVariant.secondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: interviewProvider.isLastQuestion ? 'Finish Interview' : 'Submit Answer',
                            onPressed: isAnswerValid ? _handleSubmit : null,
                            icon: interviewProvider.isLastQuestion ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                            variant: AppButtonVariant.primary,
                            isDisabled: !isAnswerValid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showFlash && _flashResult != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.65),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.violet.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.violet.withOpacity(0.2),
                          blurRadius: 32,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Good job!',
                          style: AppTextStyles.h2(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Question Score: ${_flashResult!.score}/10',
                          style: AppTextStyles.bodyLarge(color: AppColors.violetLight).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
