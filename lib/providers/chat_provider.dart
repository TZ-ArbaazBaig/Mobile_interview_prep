import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final int? chunksUsed;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    this.chunksUsed,
    required this.timestamp,
  });
}

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;
  final Map<String, List<ChatMessage>> _sessionMessages = {};
  bool _isSending = false;
  String? _error;

  ChatProvider(this._chatService);

  bool get isSending => _isSending;
  String? get error => _error;

  List<ChatMessage> getMessagesForSession(String sessionId) {
    return _sessionMessages[sessionId] ?? [];
  }

  Future<void> sendMessage(String sessionId, String questionText) async {
    final query = questionText.trim();
    if (query.isEmpty) return;

    // Append user message immediately
    final userMsg = ChatMessage(
      content: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    if (!_sessionMessages.containsKey(sessionId)) {
      _sessionMessages[sessionId] = [];
    }
    _sessionMessages[sessionId]!.add(userMsg);
    
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _chatService.askQuestion(sessionId, query);
      
      final assistantMsg = ChatMessage(
        content: response.answer,
        isUser: false,
        chunksUsed: response.chunksUsed,
        timestamp: DateTime.now(),
      );
      
      _sessionMessages[sessionId]!.add(assistantMsg);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      
      // Append an error message so the conversation flow isn't completely broken
      final errorMsg = ChatMessage(
        content: 'Sorry, I encountered an error while processing your request. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _sessionMessages[sessionId]!.add(errorMsg);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clearConversation(String sessionId) {
    _sessionMessages[sessionId] = [];
    notifyListeners();
  }
}
