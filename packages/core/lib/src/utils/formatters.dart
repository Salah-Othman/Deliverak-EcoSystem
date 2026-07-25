import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _compactFormat = NumberFormat.compact();
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _timeFormat = DateFormat('h:mm a');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');

  static String currency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String compact(int number) {
    return _compactFormat.format(number);
  }

  static String date(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String time(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String dateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String phone(String phone) {
    if (phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
    }
    return phone;
  }

  static String rating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static String distance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()}m';
    }
    return '${km.toStringAsFixed(1)}km';
  }
}
