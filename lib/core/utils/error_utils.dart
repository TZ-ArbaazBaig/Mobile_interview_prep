import 'package:clerk_auth/clerk_auth.dart';
import 'package:dio/dio.dart';
import '../api/api_exception.dart';

class ErrorUtils {
  static String cleanErrorMessage(dynamic e) {
    if (e == null) return 'An unexpected error occurred.';

    try {
      // If it's a ClerkError, it usually has an 'errors' collection or 'argument'
      if (e is ClerkError) {
        if (e.errors != null && e.errors!.errors != null && e.errors!.errors!.isNotEmpty) {
          final first = e.errors!.errors!.first;
          final msg = first.longMessage ?? first.message;
          if (msg != null && msg.isNotEmpty) {
            return msg;
          }
        }
        if (e.argument != null && e.argument!.isNotEmpty) {
          return e.argument!;
        }
        if (e.message.isNotEmpty && !e.message.contains('{arg}')) {
          return e.message;
        }
      }
    } catch (_) {}

    try {
      // Sometimes errors are thrown directly as an object with 'errors'
      final dynamic err = e;
      if (err.errors != null && err.errors.errors != null) {
        final List errors = err.errors.errors;
        if (errors.isNotEmpty) {
          final first = errors.first;
          final longMsg = first.longMessage;
          if (longMsg != null && longMsg.toString().isNotEmpty) {
            return longMsg.toString();
          }
          return first.message.toString();
        }
      }
      if (err.argument != null && err.argument.toString().isNotEmpty) {
        return err.argument.toString();
      }
    } catch (_) {}

    if (e is ApiException) {
      return e.message;
    }

    if (e is DioException) {
      return ApiException.fromDioError(e).message;
    }

    // Fallback: use toString() and strip Clerk's internal template suffixes
    String errStr = e.toString();
    if (errStr.contains('Exception: ')) {
      errStr = errStr.replaceFirst('Exception: ', '');
    }
    // Remove Clerk SDK template noise
    errStr = errStr
        .replaceAll('(ERROR RECEIVED FROM SERVER)', '')
        .replaceAll('(EXTERNAL ERROR)', '')
        .trim();
        
    return errStr;
  }
}
