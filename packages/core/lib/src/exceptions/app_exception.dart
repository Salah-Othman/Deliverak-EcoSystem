abstract class AppException implements Exception {
  final String message;
  final String? code;
  final bool isRetryable;

  const AppException({
    required this.message,
    this.code,
    this.isRetryable = false,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Check your network.',
    super.code = 'network',
    super.isRetryable = true,
  });
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'auth',
    super.isRetryable = false,
  });
}

class FirestoreException extends AppException {
  const FirestoreException({
    required super.message,
    super.code = 'firestore',
    super.isRetryable = true,
  });
}

class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'storage',
    super.isRetryable = false,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'validation',
    super.isRetryable = false,
  });
}

class UnknownException extends AppException {
  const UnknownException({
    super.message = 'Something went wrong. Please try again.',
    super.code = 'unknown',
    super.isRetryable = true,
  });
}
