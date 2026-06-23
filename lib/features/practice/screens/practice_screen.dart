import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/interview_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../models/question_model.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_button.dart';

class PracticeScreen extends StatefulWidget {
  final String sessionId;

  const PracticeScreen({super.key, required this.sessionId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String _selectedCategory = 'all';
  bool _isLoading = true;
  final Set<String> _revealedHints = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSession();
    });
  }

  Future<void> _loadSession() async {
    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    try {
      await interviewProvider.loadSession(widget.sessionId);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleHint(String questionId) {
    setState(() {
      if (_revealedHints.contains(questionId)) {
        _revealedHints.remove(questionId);
      } else {
        _revealedHints.add(questionId);
      }
    });
  }

  Widget _buildDifficultyBadge(String difficulty) {
    final diff = difficulty.toLowerCase();
    Color textColor;
    Color borderColor;
    Color bgColor;

    if (diff == 'easy') {
      textColor = const Color(0xFFA855F7); // #A855F7
      borderColor = const Color(0xFF8F00FF).withValues(alpha: 0.2);
      bgColor = const Color(0xFF8F00FF).withValues(alpha: 0.1);
    } else if (diff == 'hard') {
      textColor = const Color(0xFFFB7185); // #FB7185
      borderColor = const Color(0xFFFB7185).withValues(alpha: 0.2);
      bgColor = const Color(0xFFFB7185).withValues(alpha: 0.1);
    } else {
      // Medium / fallback
      textColor = const Color(0xFFE2E8F0); // zinc-300
      borderColor = const Color(0xFF27272A); // zinc-700
      bgColor = const Color(0xFF121212); // zinc-800
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel question) {
    final isHintRevealed = _revealedHints.contains(question.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.violet.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  question.category.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.violetLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildDifficultyBadge(question.difficulty),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            question.text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          
          // Strategic Hint Accordion Button
          if (question.hint.isNotEmpty) ...[
            InkWell(
              onTap: () => _toggleHint(question.id),
              child: Row(
                children: [
                  Icon(
                    isHintRevealed ? Icons.lightbulb : Icons.lightbulb_outline,
                    color: isHintRevealed ? AppColors.warning : AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isHintRevealed ? 'Hide Strategic Hint' : 'Reveal Strategic Hint',
                    style: GoogleFonts.jetBrainsMono(
                      color: isHintRevealed ? AppColors.warning : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isHintRevealed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
            if (isHintRevealed) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                ),
                child: Text(
                  question.hint,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ).animate().fadeIn(duration: 250.ms).scaleXY(begin: 0.95, end: 1.0, curve: Curves.easeOutBack),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interviewProvider = Provider.of<InterviewProvider>(context);

    if (_isLoading) {
      return const GradientScaffold(
        body: AppLoader(message: 'Loading dossier questions...'),
      );
    }

    final session = interviewProvider.activeSession;
    if (session == null) {
      return const GradientScaffold(
        body: Center(
          child: Text('Session not found', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // Filter questions
    final filteredQuestions = session.questions.where((q) {
      if (_selectedCategory == 'all') return true;
      return q.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            Provider.of<SessionProvider>(context, listen: false).fetchSessions();
            context.go('/dashboard');
          },
        ),
        title: Text(
          'Practice Console',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.jobTitle,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created on ${session.createdAt.day}/${session.createdAt.month}/${session.createdAt.year}',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Chat with Dossier',
                    onPressed: () => context.push('/chat/${session.id}'),
                    icon: Icons.chat_bubble_outline_rounded,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Start Interview',
                    onPressed: () {
                      interviewProvider.startInterview(session);
                      context.push('/interview/${session.id}');
                    },
                    icon: Icons.play_arrow_rounded,
                    variant: AppButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sorting Chips Bar
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                _buildCategoryChip('all', 'All'),
                _buildCategoryChip('technical', 'Technical'),
                _buildCategoryChip('behavioral', 'Behavioral'),
                _buildCategoryChip('system-design', 'System Design'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Question list
          Expanded(
            child: filteredQuestions.isEmpty
                ? Center(
                    child: Text(
                      'No questions in this category',
                      style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = filteredQuestions[index];
                      return _buildQuestionCard(question)
                          .animate()
                          .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                          .slideY(begin: 0.05, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String id, String label) {
    final isSelected = _selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.violet,
        backgroundColor: AppColors.bgSecondary,
        disabledColor: Colors.transparent,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategory = id;
            });
          }
        },
      ),
    );
  }
}
