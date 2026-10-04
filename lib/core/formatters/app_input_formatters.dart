import 'package:flutter/services.dart';

/// Centralized input formatters to prevent corrupted, fatal, or malicious typing.
/// Handles digits, positive quantities, clean text sanitization, and trimming.
abstract final class AppInputFormatters {
  /// Strictly allows only numbers (0-9).
  /// Hard-blocks dots, commas, spaces, letters, minuses, and symbols.
  static final TextInputFormatter digitsOnly = FilteringTextInputFormatter.digitsOnly;

  /// Quantity formatter: only digits, disallows leading zeros ('00', '05' -> '5').
  static final TextInputFormatter positiveInteger = TextInputFormatter.withFunction((oldValue, newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    // Only allow digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }
    // Remove leading zeros e.g. 05 -> 5, but allow 0 if single character
    final stripped = digitsOnly.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final clean = stripped;
    final diff = clean.length - newValue.text.length;
    final newOffset = (newValue.selection.end + diff).clamp(0, clean.length);

    return TextEditingValue(
      text: clean,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  });

  /// Clean text formatter:
  /// - Prevents leading spaces (cannot start with space)
  /// - Prevents consecutive spaces (converts double/multiple spaces to single space)
  /// - Prevents consecutive dots (spam dots '..' -> '.')
  /// - Prevents consecutive commas (spam commas ',,' -> ',')
  static final TextInputFormatter cleanText = TextInputFormatter.withFunction((oldValue, newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Disallow leading whitespace
    var sanitized = newValue.text.replaceFirst(RegExp(r'^\s+'), '');

    // Prevent double / multiple spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s{2,}'), ' ');

    // Prevent spam dots (e.g. '..', '...')
    sanitized = sanitized.replaceAll(RegExp(r'\.{2,}'), '.');

    // Prevent spam commas (e.g. ',,')
    sanitized = sanitized.replaceAll(RegExp(r'\,{2,}'), ',');

    final diff = sanitized.length - newValue.text.length;
    final newOffset = (newValue.selection.end + diff).clamp(0, sanitized.length);

    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  });

  /// Formats numbers with 3-digit thousand separator (dot: 1000 -> 1.000, 100000 -> 100.000).
  static const TextInputFormatter thousands = ThousandsSeparatorInputFormatter();

  /// Sanitizes string safely: trims leading & trailing whitespace.
  static String trim(String input) => input.trim();

  /// Parses number safely, removing all dots, spaces, and non-digits (e.g. "19.000" -> 19000).
  static int parseNumber(String? text, {int defaultValue = 0}) {
    if (text == null || text.trim().isEmpty) return defaultValue;
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits) ?? defaultValue;
  }

  /// Parses quantity safely with minimum guaranteed value (default: 1), stripping formatters.
  static int parseQuantity(String? text, {int min = 1, int defaultValue = 1}) {
    if (text == null || text.trim().isEmpty) return defaultValue;
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    final parsed = int.tryParse(digits);
    if (parsed == null || parsed < min) return min;
    return parsed;
  }
}

/// 3-digit thousand separator input formatter for Indonesian IDR & quantity numbers.
/// Display while typing: 1000 -> 1.000; 100000 -> 100.000; 1000000 -> 1.000.000.
/// Properly handles cursor position on addition, deletion, and pasting.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only allow digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Strip redundant leading zeros (e.g. 05 -> 5, but allow single '0')
    final stripped = digitsOnly.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    // Format with dots every 3 digits from right
    final chars = stripped.split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(chars[i]);
    }
    final formatted = buffer.toString().split('').reversed.join();

    // Maintain cursor position by tracking digits before cursor
    final rawCursor = newValue.selection.end.clamp(0, newValue.text.length);
    final digitsBeforeCursor = newValue.text
        .substring(0, rawCursor)
        .replaceAll(RegExp(r'[^\d]'), '')
        .length;

    int newOffset = 0;
    int digitsSeen = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (digitsSeen == digitsBeforeCursor) {
        newOffset = i;
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitsSeen++;
      }
      newOffset = i + 1;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset.clamp(0, formatted.length)),
    );
  }
}
