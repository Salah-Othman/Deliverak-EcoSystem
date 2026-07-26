import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('mapExceptionToMessage', () {
    test('returns message for AppException', () {
      const exception = AuthException(message: 'Login failed');
      expect(mapExceptionToMessage(exception), 'Login failed');
    });

    test('returns network message for network error', () {
      expect(
        mapExceptionToMessage(Exception('network error')),
        'No internet connection. Check your network.',
      );
    });

    test('returns timeout message', () {
      expect(
        mapExceptionToMessage(Exception('connection timeout')),
        'Request timed out. Please try again.',
      );
    });

    test('returns permission message', () {
      expect(
        mapExceptionToMessage(Exception('permission-denied')),
        'You don\'t have access to this.',
      );
    });

    test('returns not-found message', () {
      expect(
        mapExceptionToMessage(Exception('not-found')),
        'Item not found.',
      );
    });

    test('returns quota message', () {
      expect(
        mapExceptionToMessage(Exception('quota-exceeded')),
        'Storage limit reached. Contact support.',
      );
    });

    test('returns generic message for unknown errors', () {
      expect(
        mapExceptionToMessage(Exception('something weird')),
        'Something went wrong. Please try again.',
      );
    });
  });

  group('isRetryableError', () {
    test('returns true for NetworkException', () {
      expect(isRetryableError(const NetworkException()), true);
    });

    test('returns false for AuthException', () {
      expect(isRetryableError(const AuthException(message: 'fail')), false);
    });

    test('returns true for network error string', () {
      expect(isRetryableError(Exception('network issue')), true);
    });

    test('returns true for timeout error string', () {
      expect(isRetryableError(Exception('timeout occurred')), true);
    });

    test('returns false for generic error string', () {
      expect(isRetryableError(Exception('bad input')), false);
    });
  });

  group('retryWithBackoff', () {
    test('returns result on first try', () async {
      int attempts = 0;
      final result = await retryWithBackoff(() async {
        attempts++;
        return 'success';
      });

      expect(result, 'success');
      expect(attempts, 1);
    });

    test('retries on retryable error and throws after max retries', () async {
      int attempts = 0;
      expect(
        () => retryWithBackoff(
          () async {
            attempts++;
            throw const NetworkException();
          },
          maxRetries: 2,
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws after max retries exceeded', () async {
      expect(
        () => retryWithBackoff(
          () async {
            throw const NetworkException();
          },
          maxRetries: 2,
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws immediately on non-retryable error', () async {
      int attempts = 0;
      expect(
        () => retryWithBackoff(
          () async {
            attempts++;
            throw const AuthException(message: 'fail');
          },
          maxRetries: 3,
        ),
        throwsA(isA<AuthException>()),
      );
      expect(attempts, 1);
    });
  });
}
