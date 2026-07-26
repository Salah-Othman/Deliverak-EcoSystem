import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('AppException', () {
    test('NetworkException has correct defaults', () {
      const e = NetworkException();
      expect(e.message, 'No internet connection. Check your network.');
      expect(e.code, 'network');
      expect(e.isRetryable, true);
    });

    test('AuthException has correct defaults', () {
      const e = AuthException(message: 'Login failed');
      expect(e.message, 'Login failed');
      expect(e.code, 'auth');
      expect(e.isRetryable, false);
    });

    test('FirestoreException has correct defaults', () {
      const e = FirestoreException(message: 'Doc not found');
      expect(e.message, 'Doc not found');
      expect(e.code, 'firestore');
      expect(e.isRetryable, true);
    });

    test('StorageException has correct defaults', () {
      const e = StorageException(message: 'Upload failed');
      expect(e.message, 'Upload failed');
      expect(e.code, 'storage');
      expect(e.isRetryable, false);
    });

    test('ValidationException has correct defaults', () {
      const e = ValidationException(message: 'Invalid input');
      expect(e.message, 'Invalid input');
      expect(e.code, 'validation');
      expect(e.isRetryable, false);
    });

    test('UnknownException has correct defaults', () {
      const e = UnknownException();
      expect(e.message, 'Something went wrong. Please try again.');
      expect(e.code, 'unknown');
      expect(e.isRetryable, true);
    });

    test('toString returns formatted string', () {
      const e = AuthException(message: 'fail', code: 'auth-01');
      expect(e.toString(), 'AppException: fail (code: auth-01)');
    });
  });
}
