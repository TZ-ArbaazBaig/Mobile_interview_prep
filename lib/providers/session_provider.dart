import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';

class SessionProvider extends ChangeNotifier {
  final SessionService _sessionService;
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  SessionProvider(this._sessionService);

  SessionService get sessionService => _sessionService;

  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _sessionService.getSessions();
      // Sort sessions with newest first
      _sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SessionModel?> createSession(String jobDescription) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSession = await _sessionService.createSession(jobDescription);
      _sessions.insert(0, newSession);
      return newSession;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSession(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _sessionService.deleteSession(sessionId);
      _sessions.removeWhere((s) => s.id == sessionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<SessionModel?> generateQuestions(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedSession = await _sessionService.generateQuestions(sessionId);
      final idx = _sessions.indexWhere((s) => s.id == sessionId);
      if (idx != -1) {
        _sessions[idx] = updatedSession;
      }
      return updatedSession;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
