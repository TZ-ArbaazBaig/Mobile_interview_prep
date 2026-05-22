import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../models/question_model.dart';
import '../services/results_service.dart';

class ResultsProvider extends ChangeNotifier {
  final ResultsService _resultsService;

  SessionModel? _completedSession;
  bool _isLoading = false;
  String? _error;

  ResultsProvider(this._resultsService);

  SessionModel? get session => _completedSession;
  SessionModel? get completedSession => _completedSession;
  List<QuestionModel> get questions => _completedSession?.questions ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get overallScore => _completedSession?.overallScore ?? 0.0;

  double get technicalAvg => _categoryAverage('Technical');
  double get behavioralAvg => _categoryAverage('Behavioral');
  double get systemDesignAvg => _categoryAverage('System Design');

  double _categoryAverage(String category) {
    if (_completedSession == null) return 0.0;
    final categoryQuestions = _completedSession!.questions
        .where((q) => q.category.toLowerCase() == category.toLowerCase())
        .map((q) => q.id)
        .toSet();

    if (categoryQuestions.isEmpty) return 0.0;

    final categoryEvaluations = _completedSession!.evaluations
        .where((e) => categoryQuestions.contains(e.questionId));

    if (categoryEvaluations.isEmpty) return 0.0;

    final sum = categoryEvaluations.fold<int>(0, (prev, e) => prev + e.score);
    return sum / categoryEvaluations.length;
  }

  Future<void> fetchResults(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _completedSession = await _resultsService.getSessionResults(sessionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadResults(String sessionId) => fetchResults(sessionId);

  void clearResults() {
    _completedSession = null;
    _error = null;
    notifyListeners();
  }
}
