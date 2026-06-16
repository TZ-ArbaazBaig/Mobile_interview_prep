import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/session_model.dart';

class SessionService {
  final DioClient _dioClient;

  SessionService(this._dioClient);

  Future<SessionModel> createSession(String jobDescription) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.sessions,
        data: {
          'job_description': jobDescription,
          'jobDescription': jobDescription,
        },
      );
      return SessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<SessionModel>> getSessions() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.sessions);
      dynamic data = response.data;
      List? list;
      if (data is Map<String, dynamic>) {
        list = data['data'] as List? ?? data['sessions'] as List?;
      } else if (data is List) {
        list = data;
      }
      return list?.map((item) => SessionModel.fromJson(item as Map<String, dynamic>)).toList() ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SessionModel> getSessionDetails(String id) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.sessionById(id));
      return SessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      await _dioClient.dio.delete(ApiEndpoints.sessionById(id));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SessionModel> generateQuestions(String sessionId) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.generateQuestions(sessionId),
        options: Options(
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      if (response.data == null) {
        throw ApiException(message: 'Empty response received from the server.');
      }
      return SessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException(message: 'Question generation timed out. Please try again.');
      }
      throw ApiException.fromDioError(e);
    }
  }
}
