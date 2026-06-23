import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/session_model.dart';
import '../models/evaluation_model.dart';

class InterviewService {
  final DioClient _dioClient;

  InterviewService(this._dioClient);

  Future<EvaluationModel?> submitAnswer(String questionId, String questionText, String answerText) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.evaluate,
        data: {
          'questionId': questionId,
          'userAnswer': answerText,
          'questionText': questionText,
        },
      );
      if (response.data != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data as Map);
        if (!data.containsKey('questionId') && !data.containsKey('question_id')) {
          data['questionId'] = questionId;
        }
        if (!data.containsKey('userAnswer') && !data.containsKey('user_answer')) {
          data['userAnswer'] = answerText;
        }
        return EvaluationModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SessionModel> getSessionDetails(String sessionId) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.sessionById(sessionId));
      return SessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
