import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(DioException dioException) {
    String message = 'An unexpected error occurred';
    int? statusCode = dioException.response?.statusCode;

    switch (dioException.type) {
      case DioExceptionType.cancel:
        message = 'Request to the server was cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        message = 'Connection to the server timed out';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server response timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout in connection with the server';
        break;
      case DioExceptionType.badResponse:
        final data = dioException.response?.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else if (data is Map && data.containsKey('error')) {
          message = data['error'];
        } else {
          message = 'Server error: ${dioException.response?.statusMessage ?? statusCode}';
        }
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network and try again.';
        break;
      default:
        message = 'Something went wrong: ${dioException.message}';
        break;
    }
    return ApiException(message: message, statusCode: statusCode);
  }

  @override
  String toString() => message;
}
