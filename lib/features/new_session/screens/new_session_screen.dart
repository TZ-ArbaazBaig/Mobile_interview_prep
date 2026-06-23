import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../../providers/session_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loader.dart';

class NewSessionScreen extends StatefulWidget {
  final String? prefilledJd;
  const NewSessionScreen({super.key, this.prefilledJd});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final TextEditingController _jdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isGenerating = false;
  String _loadingMessage = 'AI is analyzing the job description...';

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _jdController.addListener(_onTextChanged);
  }

  Future<void> _loadDraft() async {
    if (widget.prefilledJd != null) {
      _jdController.text = widget.prefilledJd!;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final savedDraft = prefs.getString('jd_draft') ?? '';
      if (savedDraft.isNotEmpty) {
        setState(() {
          _jdController.text = savedDraft;
        });
      }
    }
  }

  @override
  void dispose() {
    _jdController.removeListener(_onTextChanged);
    _jdController.dispose();
    super.dispose();
  }

  void _onTextChanged() async {
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jd_draft', _jdController.text);
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _loadingMessage = 'AI is creating your interview profile...';
    });

    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    try {
      // Step 1: Create session (POST /sessions)
      final session = await sessionProvider.createSession(_jdController.text.trim());
      
      if (session == null) {
        throw Exception(sessionProvider.error ?? 'Failed to initialize session.');
      }

      // Clear local storage cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jd_draft');

      // If the backend already generated and returned questions, route to the practice screen directly!
      if (session.questions.isNotEmpty) {
        if (!mounted) return;
        context.replace('/practice/${session.id}');
        return;
      }

      if (!mounted) return;
      setState(() {
        _loadingMessage = 'AI is tailoring 5 custom interview questions...\nThis might take up to 30 seconds.';
      });

      // Step 2: Generate questions (POST /sessions/:id/questions) (for lazy-generation backends)
      final updatedSession = await sessionProvider.generateQuestions(session.id);

      if (!mounted) return;

      if (updatedSession != null && updatedSession.questions.isNotEmpty) {
        context.replace('/practice/${updatedSession.id}');
      } else {
        throw Exception(sessionProvider.error ?? 'Empty response or no questions generated.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorUtils.cleanErrorMessage(e),
              style: AppTextStyles.bodyMedium(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGenerating) {
      return GradientScaffold(
        body: AppLoader(
          message: _loadingMessage,
        ),
      );
    }

    final text = _jdController.text.trim();
    final charCount = text.length;
    final wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final isReady = charCount >= 100 && wordCount <= 3000;

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('New Prep Session', style: AppTextStyles.h4(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste Job Description',
                style: AppTextStyles.h2(),
              ),
              const SizedBox(height: 8),
              Text(
                'Our AI will analyze the responsibilities and requirements of the role to generate 5 tailored mock interview questions.',
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              
              // Custom multiline field layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Job Description',
                      style: AppTextStyles.label(color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_jdController.text.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _jdController.clear();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: AppColors.violetLight, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _jdController,
                keyboardType: TextInputType.multiline,
                minLines: 6,
                maxLines: null,
                style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Paste the job requirements, duties, or full description here...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please paste a job description';
                  }
                  final trimmed = value.trim();
                  if (trimmed.length < 100) {
                    return 'Please enter at least 100 characters';
                  }
                  final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
                  if (words > 3000) {
                    return 'Job description cannot exceed 3000 words';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Counter and character feedback
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    wordCount > 3000
                        ? '$wordCount / 3000 words maximum'
                        : '$charCount / 100 characters minimum',
                    style: AppTextStyles.bodySmall(
                      color: wordCount > 3000
                          ? AppColors.error
                          : (isReady ? AppColors.success : AppColors.textSecondary),
                    ),
                  ),
                  if (charCount > 0 && charCount < 100)
                    Text(
                      'Requires ${100 - charCount} more characters',
                      style: AppTextStyles.bodySmall(color: AppColors.warning),
                    )
                  else if (wordCount > 3000)
                    Text(
                      'Exceeds limit by ${wordCount - 3000} words',
                      style: AppTextStyles.bodySmall(color: AppColors.error),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              
              AppButton(
                text: 'Generate Interview Questions',
                onPressed: isReady ? _handleGenerate : null,
                icon: Icons.auto_awesome,
                variant: AppButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
