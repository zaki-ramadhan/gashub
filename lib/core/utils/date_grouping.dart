/// Reusable utility to group a list of items by calendar date (ignoring time).
/// Returns a map where keys are sorted in descending order (latest date first).
Map<DateTime, List<T>> groupItemsByDate<T>(
  Iterable<T> items,
  DateTime Function(T item) getDate,
) {
  final Map<DateTime, List<T>> grouped = {};

  for (final item in items) {
    final rawDate = getDate(item);
    final dateKey = DateTime(rawDate.year, rawDate.month, rawDate.day);
    grouped.putIfAbsent(dateKey, () => []).add(item);
  }

  final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
  final Map<DateTime, List<T>> result = {};
  for (final key in sortedKeys) {
    result[key] = grouped[key]!;
  }

  return result;
}
