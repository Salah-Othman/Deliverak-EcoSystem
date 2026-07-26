import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('Formatters.currency', () {
    test('formats zero', () {
      expect(Formatters.currency(0), '\$0.00');
    });

    test('formats positive amount', () {
      expect(Formatters.currency(1234.56), '\$1,234.56');
    });

    test('formats small amount', () {
      expect(Formatters.currency(9.9), '\$9.90');
    });
  });

  group('Formatters.compact', () {
    test('formats small number', () {
      expect(Formatters.compact(42), '42');
    });

    test('formats large number', () {
      expect(Formatters.compact(1500), '1.5K');
    });
  });

  group('Formatters.date', () {
    test('formats date correctly', () {
      final date = DateTime(2024, 3, 15);
      expect(Formatters.date(date), 'Mar 15, 2024');
    });
  });

  group('Formatters.time', () {
    test('formats time correctly', () {
      final time = DateTime(2024, 1, 1, 14, 30);
      expect(Formatters.time(time), '2:30 PM');
    });
  });

  group('Formatters.dateTime', () {
    test('formats datetime correctly', () {
      final dt = DateTime(2024, 3, 15, 14, 30);
      expect(Formatters.dateTime(dt), 'Mar 15, 2024 2:30 PM');
    });
  });

  group('Formatters.phone', () {
    test('formats 10-digit phone', () {
      expect(Formatters.phone('1234567890'), '(123) 456-7890');
    });

    test('returns as-is for non-10-digit', () {
      expect(Formatters.phone('+1234567890123'), '+1234567890123');
    });
  });

  group('Formatters.rating', () {
    test('formats whole number', () {
      expect(Formatters.rating(5.0), '5.0');
    });

    test('formats decimal', () {
      expect(Formatters.rating(4.75), '4.8');
    });
  });

  group('Formatters.distance', () {
    test('formats meters for < 1km', () {
      expect(Formatters.distance(0.5), '500m');
    });

    test('formats kilometers for >= 1km', () {
      expect(Formatters.distance(5.0), '5.0km');
    });

    test('formats fractional km', () {
      expect(Formatters.distance(2.5), '2.5km');
    });
  });
}
