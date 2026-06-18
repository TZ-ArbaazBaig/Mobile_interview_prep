import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';

class ChatResponse {
  final String question;
  final String answer;
  final int chunksUsed;

  ChatResponse({
    required this.question,
    required this.answer,
    required this.chunksUsed,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      chunksUsed: json['chunksUsed'] as int? ?? json['chunks_used'] as int? ?? 0,
    );
  }
}

class ChatService {
  final DioClient _dioClient;

  ChatService(this._dioClient);

  Future<ChatResponse> askQuestion(String sessionId, String question) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.chat(sessionId),
        data: {
          'question': question,
        },
      );
      return ChatResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
