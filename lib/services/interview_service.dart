import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/session_model.dart';
import '../models/evaluation_model.dart';

class InterviewService {
  final DioClient _dioClient;

  InterviewService(this._dioClient);

  Future<EvaluationModel?> submitAnswer(String sessionId, String questionId, String answerText) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.submitAnswer(sessionId, questionId),
        data: {
          'answer_text': answerText,
        },
      );
      if (response.data != null) {
        return EvaluationModel.fromJson(response.data as Map<String, dynamic>);
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
