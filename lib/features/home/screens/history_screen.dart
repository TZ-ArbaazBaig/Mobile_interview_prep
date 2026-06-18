import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/session_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../dashboard/widgets/session_card.dart';
import '../../../models/session_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'all';
  int _currentPage = 0;
  static const int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SessionProvider>(context, listen: false).fetchSessions();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _currentPage = 0; // Reset pagination on search
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);

    // Apply search filter
    final query = _searchController.text.trim().toLowerCase();
    List<SessionModel> filteredList = sessionProvider.sessions.where((session) {
      final matchesQuery = session.jobTitle.toLowerCase().contains(query);
      if (!matchesQuery) return false;

      final answeredCount = session.evaluations.length;
      final totalCount = session.questions.isEmpty ? 10 : session.questions.length;

      if (_selectedTab == 'in-progress') {
        return answeredCount > 0 && answeredCount < totalCount;
      } else if (_selectedTab == 'completed') {
        return session.isCompleted || answeredCount == totalCount;
      }
      return true; // All
    }).toList();

    // Paginate
    final totalCount = filteredList.length;
    final totalPages = (totalCount / _pageSize).ceil();
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize) < totalCount ? (startIndex + _pageSize) : totalCount;
    final paginatedList = totalCount > 0 ? filteredList.sublist(startIndex, endIndex) : <SessionModel>[];

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(
          'History',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => sessionProvider.fetchSessions(),
        color: AppColors.violet,
        backgroundColor: AppColors.bgSecondary,
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: TextFormField(
                controller: _searchController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by job title...',
                  hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tab Filter Chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  _buildTabChip('all', 'All'),
                  _buildTabChip('in-progress', 'In Progress'),
                  _buildTabChip('completed', 'Completed'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Session List
            Expanded(
              child: sessionProvider.isLoading
                  ? const Center(child: AppLoader(message: 'Loading history...'))
                  : sessionProvider.error != null
                      ? AppErrorWidget(
                          error: sessionProvider.error!,
                          onRetry: () => sessionProvider.fetchSessions(),
                        )
                      : paginatedList.isEmpty
                          ? AppEmptyState(
                              title: 'No Sessions Found',
                              description: query.isNotEmpty
                                  ? 'No mock interviews match your search keyword.'
                                  : 'Start a new prep session to see it in your history.',
                              icon: Icons.history_rounded,
                              actionText: 'Start New Session',
                              onActionPressed: () => context.push('/new-session'),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                                    itemCount: paginatedList.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final session = paginatedList[index];
                                      return SessionCard(session: session)
                                          .animate()
                                          .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                                          .slideY(begin: 0.05, end: 0);
                                    },
                                  ),
                                ),
                                
                                // Pagination Controls
                                if (totalPages > 1) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(color: AppColors.border, width: 1.0),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                                          color: _currentPage > 0 ? Colors.white : AppColors.textMuted,
                                          onPressed: _currentPage > 0
                                              ? () => setState(() => _currentPage--)
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Page ${_currentPage + 1} of $totalPages',
                                          style: GoogleFonts.jetBrainsMono(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                          color: _currentPage < (totalPages - 1) ? Colors.white : AppColors.textMuted,
                                          onPressed: _currentPage < (totalPages - 1)
                                              ? () => setState(() => _currentPage++)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String id, String label) {
    final isSelected = _selectedTab == id;
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
              _selectedTab = id;
              _currentPage = 0; // Reset on tab switch
            });
          }
        },
      ),
    );
  }
}
