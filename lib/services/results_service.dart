import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/session_model.dart';

class ResultsService {
  final DioClient _dioClient;

  ResultsService(this._dioClient);

  Future<SessionModel> getSessionResults(String id) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.sessionResults(id));
      return SessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Fallback: If your backend returns results on general sessionDetails endpoint, try that.
      try {
        final response = await _dioClient.dio.get(ApiEndpoints.sessionById(id));
        return SessionModel.fromJson(response.data as Map<String, dynamic>);
      } catch (_) {
        throw ApiException.fromDioError(e);
      }
    }
  }
}
