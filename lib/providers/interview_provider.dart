import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/session_model.dart';
import '../models/question_model.dart';
import '../models/evaluation_model.dart';
import '../services/interview_service.dart';

class InterviewProvider extends ChangeNotifier {
  final InterviewService _interviewService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  SessionModel? _activeSession;
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  String _currentAnswer = '';
  bool _isSubmitting = false;
  bool _isLoading = false;
  String? _error;
  final Map<String, EvaluationModel> _evaluations = {};

  InterviewProvider(this._interviewService);

  SessionModel? get activeSession => _activeSession;
  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  String get currentAnswer => _currentAnswer;
  bool get isSubmitting => _isSubmitting;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, EvaluationModel> get evaluations => _evaluations;

  bool get isComplete => _currentIndex >= _questions.length;

  double get progressPercent {
    if (_questions.isEmpty) return 0.0;
    return _currentIndex / _questions.length;
  }

  // Alias for backward compatibility
  double get progress {
    if (_questions.isEmpty) return 0.0;
    return (_currentIndex + 1) / _questions.length;
  }

  bool get isFirstQuestion => _currentIndex == 0;
  bool get isLastQuestion => _questions.isNotEmpty && _currentIndex == _questions.length - 1;

  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;

  Future<void> loadSession(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final session = await _interviewService.getSessionDetails(sessionId);
      _activeSession = session;
      _questions = session.questions;

      // Load evaluations from the fetched session
      _evaluations.clear();
      for (final e in session.evaluations) {
        _evaluations[e.questionId] = e;
      }

      // Restore previously saved currentIndex
      final indexStr = await _secureStorage.read(key: 'session_${sessionId}_index');
      if (indexStr != null) {
        _currentIndex = int.tryParse(indexStr) ?? 0;
      } else {
        // If we have evaluations, resume from the first unanswered question
        int firstUnanswered = 0;
        final answeredIds = session.evaluations.map((e) => e.questionId).toSet();
        for (int i = 0; i < _questions.length; i++) {
          if (!answeredIds.contains(_questions[i].id)) {
            firstUnanswered = i;
            break;
          }
        }
        _currentIndex = firstUnanswered;
      }

      // Load currentAnswer from secure storage or local draft
      if (_currentIndex < _questions.length) {
        final qId = _questions[_currentIndex].id;
        _currentAnswer = await _secureStorage.read(key: 'session_${sessionId}_q_${qId}_draft') ?? '';
      } else {
        _currentAnswer = '';
      }

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startInterview(SessionModel session) {
    _activeSession = session;
    _questions = session.questions;
    _currentIndex = 0;
    _currentAnswer = '';
    _evaluations.clear();
    _error = null;
    _isSubmitting = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveDraft(String questionId, String answerText) async {
    if (_activeSession == null) return;
    _currentAnswer = answerText;
    await _secureStorage.write(key: 'session_${_activeSession!.id}_q_${questionId}_draft', value: answerText);
    notifyListeners();
  }

  Future<bool> submitAnswer(String questionId, String answer) async {
    if (_activeSession == null) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final evaluation = await _interviewService.submitAnswer(_activeSession!.id, questionId, answer);
      if (evaluation != null) {
        _evaluations[questionId] = evaluation;
      }

      // Delete draft for this question
      await _secureStorage.delete(key: 'session_${_activeSession!.id}_q_${questionId}_draft');
      
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> nextQuestion() async {
    if (_activeSession == null) return;
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      await _secureStorage.write(key: 'session_${_activeSession!.id}_index', value: _currentIndex.toString());
      
      final qId = _questions[_currentIndex].id;
      _currentAnswer = await _secureStorage.read(key: 'session_${_activeSession!.id}_q_${qId}_draft') ?? '';
      notifyListeners();
    }
  }

  Future<void> previousQuestion() async {
    if (_activeSession == null) return;
    if (_currentIndex > 0) {
      _currentIndex--;
      await _secureStorage.write(key: 'session_${_activeSession!.id}_index', value: _currentIndex.toString());
      
      final qId = _questions[_currentIndex].id;
      _currentAnswer = await _secureStorage.read(key: 'session_${_activeSession!.id}_q_${qId}_draft') ?? '';
      notifyListeners();
    }
  }

  Future<SessionModel?> submitInterview() async {
    if (_activeSession == null) return null;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final completedSession = await _interviewService.getSessionDetails(_activeSession!.id);
      _activeSession = completedSession;
      
      // Clear secure storage for this session
      await _secureStorage.delete(key: 'session_${_activeSession!.id}_index');
      for (final q in _questions) {
        await _secureStorage.delete(key: 'session_${_activeSession!.id}_q_${q.id}_draft');
      }
      
      _isSubmitting = false;
      notifyListeners();
      return completedSession;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> retryQuestion(int index) async {
    if (_activeSession == null) return;
    _currentIndex = index;
    await _secureStorage.write(key: 'session_${_activeSession!.id}_index', value: index.toString());
    final qId = _questions[index].id;
    _evaluations.remove(qId);
    await _secureStorage.delete(key: 'session_${_activeSession!.id}_q_${qId}_draft');
    notifyListeners();
  }
}
