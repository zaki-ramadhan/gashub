import 'package:intl/intl.dart';

/// Centralized Indonesian currency, quantity, and date formatters.
/// Strictly follows GasHub_Final_Specification_FINAL/03_DESIGN/INPUT_FORMATTERS.md
abstract final class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('id_ID');
  static final DateFormat _dateFormat = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _dayFormat = DateFormat('EEEE', 'id_ID');
  static final DateFormat _fullDateFormat = DateFormat('d MMMM yyyy', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');

  /// Formats an integer amount into Rupiah, e.g. Rp 1.000.000
  static String currency(int amount) {
    return _currencyFormat.format(amount);
  }

  /// Formats quantity with Indonesian thousands separator, e.g. 1.250
  static String number(int value) {
    return _numberFormat.format(value);
  }

  /// Formats date to Indonesian human format, e.g. 3 Okt 2026
  static String date(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Formats day of week in Indonesian, e.g. "Sabtu"
  static String dayOfWeek(DateTime dateTime) {
    return _dayFormat.format(dateTime);
  }

  /// Formats full date in Indonesian, e.g. "3 Oktober 2026"
  static String fullDate(DateTime dateTime) {
    return _fullDateFormat.format(dateTime);
  }

  /// Formats time, e.g. 14:30 WIB
  static String time(DateTime dateTime) {
    return '${_timeFormat.format(dateTime)} WIB';
  }

  /// Formats date with relative day header (Hari Ini, Kemarin, or Hari, d MMM yyyy)
  static String relativeDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (target == today) {
      return 'Hari Ini, ${date(dateTime)}';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return 'Kemarin, ${date(dateTime)}';
    } else {
      return '${dayOfWeek(dateTime)}, ${date(dateTime)}';
    }
  }
}
