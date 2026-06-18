// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../router/app_router.dart';
import '../../providers/auth_provider.dart';
import 'api_endpoints.dart';

class DioClient {
  final Dio _dio;

  // Static callback to fetch Clerk session token dynamically
  static Future<String?> Function()? tokenGetter;

  static String _resolveBaseUrl() {
    String? url = dotenv.env['API_BASE_URL'] ?? dotenv.env['VITE_API_URL'];
    if (url == null || url.isEmpty) {
      return ApiEndpoints.baseUrl;
    }

    // Map localhost to emulator loopback IP on Android
    if (defaultTargetPlatform == TargetPlatform.android && url.contains('localhost')) {
      url = url.replaceAll('localhost', '10.0.2.2');
    }

    // Ensure /api suffix is appended
    if (!url.endsWith('/api') && !url.endsWith('/api/')) {
      final separator = url.endsWith('/') ? '' : '/';
      url = '$url${separator}api';
    }

    return url;
  }

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _resolveBaseUrl(),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (tokenGetter != null) {
            try {
              final token = await tokenGetter!();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              // Token retrieval failed, continue without authorization header
            }
          }

          // Log request (Frontend Sending) in Yellow (\x1B[33m)
          final reqBuf = StringBuffer();
          reqBuf.writeln('=================== FRONTEND SENDING ===================');
          reqBuf.writeln('URI: ${options.method} ${options.uri}');
          if (options.headers.isNotEmpty) {
            reqBuf.writeln('Headers: ${options.headers}');
          }
          if (options.queryParameters.isNotEmpty) {
            reqBuf.writeln('Query Params: ${options.queryParameters}');
          }
          if (options.data != null) {
            reqBuf.writeln('Body: ${options.data}');
          }
          reqBuf.writeln('========================================================');
          print('\x1B[33m${reqBuf.toString()}\x1B[0m');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response (Backend Returning) in Green (\x1B[32m)
          final resBuf = StringBuffer();
          resBuf.writeln('=================== BACKEND RESPONSE ===================');
          resBuf.writeln('Status: ${response.statusCode} ${response.statusMessage}');
          resBuf.writeln('URI: ${response.requestOptions.method} ${response.requestOptions.uri}');
          if (response.data != null) {
            resBuf.writeln('Body: ${response.data}');
          }
          resBuf.writeln('========================================================');
          print('\x1B[32m${resBuf.toString()}\x1B[0m');

          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Log error response (Backend Returning Error) in Green (\x1B[32m) or Red (\x1B[31m)
          final resBuf = StringBuffer();
          if (e.response != null) {
            resBuf.writeln('=================== BACKEND RESPONSE (ERROR) ===================');
            resBuf.writeln('Status: ${e.response?.statusCode} ${e.response?.statusMessage}');
            resBuf.writeln('URI: ${e.requestOptions.method} ${e.requestOptions.uri}');
            if (e.response?.data != null) {
              resBuf.writeln('Body: ${e.response?.data}');
            }
            resBuf.writeln('================================================================');
            print('\x1B[32m${resBuf.toString()}\x1B[0m');
          } else {
            resBuf.writeln('=================== BACKEND CONNECTION ERROR ===================');
            resBuf.writeln('URI: ${e.requestOptions.method} ${e.requestOptions.uri}');
            resBuf.writeln('Error: ${e.message}');
            resBuf.writeln('================================================================');
            print('\x1B[31m${resBuf.toString()}\x1B[0m');
          }

          if (e.response?.statusCode == 401) {
            final retried = e.requestOptions.extra['retried'] == true;
            if (!retried) {
              e.requestOptions.extra['retried'] = true;

              // Attempt to refresh / fetch a new token
              String? newToken;
              if (tokenGetter != null) {
                try {
                  newToken = await tokenGetter!();
                } catch (_) {}
              }

              if (newToken != null && newToken.isNotEmpty) {
                e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                
                // Retry the request once
                try {
                  final response = await _dio.fetch(e.requestOptions);
                  return handler.resolve(response);
                } on DioException catch (retryError) {
                  _triggerSignOut();
                  return handler.next(retryError);
                } catch (retryError) {
                  _triggerSignOut();
                  return handler.reject(
                    DioException(
                      requestOptions: e.requestOptions,
                      error: retryError,
                    ),
                  );
                }
              } else {
                _triggerSignOut();
              }
            } else {
              _triggerSignOut();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  static void _triggerSignOut() {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      try {
        Provider.of<AuthProvider>(context, listen: false).signOut();
      } catch (_) {}
    }
  }

  Dio get dio => _dio;
}
