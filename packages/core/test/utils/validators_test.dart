import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('Validators.phone', () {
    test('returns null for valid E.164 phone', () {
      expect(Validators.phone('+1234567890123'), null);
    });

    test('returns error for empty string', () {
      expect(Validators.phone(''), 'Phone number is required');
    });

    test('returns error for null', () {
      expect(Validators.phone(null), 'Phone number is required');
    });

    test('returns error for missing country code', () {
      expect(Validators.phone('1234567890'), isNotNull);
    });

    test('returns error for letters', () {
      expect(Validators.phone('+abcdefghij'), isNotNull);
    });
  });

  group('Validators.email', () {
    test('returns null for valid email', () {
      expect(Validators.email('test@example.com'), null);
    });

    test('returns null for empty (optional)', () {
      expect(Validators.email(''), null);
    });

    test('returns null for null (optional)', () {
      expect(Validators.email(null), null);
    });

    test('returns error for invalid email', () {
      expect(Validators.email('notanemail'), isNotNull);
    });

    test('returns error for missing domain', () {
      expect(Validators.email('test@'), isNotNull);
    });
  });

  group('Validators.name', () {
    test('returns null for valid name', () {
      expect(Validators.name('John'), null);
    });

    test('returns error for empty', () {
      expect(Validators.name(''), 'Name is required');
    });

    test('returns error for too long', () {
      expect(Validators.name('A' * 51), isNotNull);
    });

    test('returns null for max length 50', () {
      expect(Validators.name('A' * 50), null);
    });
  });

  group('Validators.address', () {
    test('returns null for valid address', () {
      expect(Validators.address('123 Main St'), null);
    });

    test('returns error for empty', () {
      expect(Validators.address(''), isNotNull);
    });

    test('returns error for too long', () {
      expect(Validators.address('A' * 201), isNotNull);
    });
  });

  group('Validators.description', () {
    test('returns null for empty (optional)', () {
      expect(Validators.description(''), null);
    });

    test('returns null for valid description', () {
      expect(Validators.description('A nice product'), null);
    });

    test('returns error for too long', () {
      expect(Validators.description('A' * 1001), isNotNull);
    });
  });

  group('Validators.price', () {
    test('returns null for valid price', () {
      expect(Validators.price('9.99'), null);
    });

    test('returns error for empty', () {
      expect(Validators.price(''), isNotNull);
    });

    test('returns error for negative', () {
      expect(Validators.price('-1'), isNotNull);
    });

    test('returns error for too high', () {
      expect(Validators.price('1000000'), isNotNull);
    });

    test('returns error for non-numeric', () {
      expect(Validators.price('abc'), isNotNull);
    });
  });

  group('Validators.quantity', () {
    test('returns null for valid quantity', () {
      expect(Validators.quantity('5'), null);
    });

    test('returns error for empty', () {
      expect(Validators.quantity(''), isNotNull);
    });

    test('returns error for zero', () {
      expect(Validators.quantity('0'), isNotNull);
    });

    test('returns error for too high', () {
      expect(Validators.quantity('100'), isNotNull);
    });

    test('returns error for non-numeric', () {
      expect(Validators.quantity('abc'), isNotNull);
    });
  });

  group('Validators.required', () {
    test('returns null for non-empty', () {
      expect(Validators.required('value'), null);
    });

    test('returns error for empty', () {
      expect(Validators.required(''), 'This field is required');
    });

    test('uses custom field name', () {
      expect(Validators.required('', 'Email'), 'Email is required');
    });
  });
}
