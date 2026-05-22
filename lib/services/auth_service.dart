import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/user_model.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<UserModel> syncUser(String clerkId, String email, String? firstName, String? lastName, String? imageUrl) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.syncUser,
        data: {
          'clerk_id': clerkId,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'image_url': imageUrl,
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
