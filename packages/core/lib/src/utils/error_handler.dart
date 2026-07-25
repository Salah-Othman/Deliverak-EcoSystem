import 'exceptions/app_exception.dart';

String mapExceptionToMessage(dynamic error) {
  if (error is AppException) {
    return error.message;
  }

  final errorString = error.toString().toLowerCase();

  if (errorString.contains('network') || errorString.contains('socket')) {
    return 'No internet connection. Check your network.';
  }

  if (errorString.contains('timeout')) {
    return 'Request timed out. Please try again.';
  }

  if (errorString.contains('permission-denied')) {
    return 'You don\'t have access to this.';
  }

  if (errorString.contains('not-found') || errorString.contains('not found')) {
    return 'Item not found.';
  }

  if (errorString.contains('quota-exceeded') || errorString.contains('quota')) {
    return 'Storage limit reached. Contact support.';
  }

  return 'Something went wrong. Please try again.';
}

bool isRetryableError(dynamic error) {
  if (error is AppException) {
    return error.isRetryable;
  }

  final errorString = error.toString().toLowerCase();
  return errorString.contains('network') ||
      errorString.contains('timeout') ||
      errorString.contains('socket');
}

Future<T> retryWithBackoff<T>(
  Future<T> Function() action, {
  int maxRetries = 3,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await action();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      if (!isRetryableError(e)) rethrow;
      await Future.delayed(Duration(seconds: 1 * (1 << i)));
    }
  }
  throw const UnknownException();
}
