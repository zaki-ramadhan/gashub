/// Strongly typed domain entity for physical gas cylinder stock summary.
class StockSummary {
  const StockSummary({
    required this.filled,
    required this.empty,
    required this.loaned,
    required this.sellingPrice,
  });

  final int filled;
  final int empty;
  final int loaned;
  final int sellingPrice;

  int get totalTabung => filled + empty + loaned;

  const StockSummary.zero()
      : filled = 0,
        empty = 0,
        loaned = 0,
        sellingPrice = 19000;
}

/// Strongly typed domain entity for cylinder movement logs (in/out).
class StockLogItem {
  const StockLogItem({
    required this.id,
    required this.title,
    required this.qty,
    required this.isMasuk,
    required this.date,
    required this.time,
  });

  final String id;
  final String title;
  final int qty;
  final bool isMasuk;
  final DateTime date;
  final String time;

  static List<StockLogItem> skeleton() {
    final now = DateTime.now();
    return [
      StockLogItem(
        id: 'skel_1',
        title: '------------------',
        qty: 0,
        isMasuk: true,
        date: now,
        time: '--:-- WIB',
      ),
      StockLogItem(
        id: 'skel_2',
        title: '-----------------------',
        qty: 0,
        isMasuk: false,
        date: now,
        time: '--:-- WIB',
      ),
      StockLogItem(
        id: 'skel_3',
        title: '---------------------',
        qty: 0,
        isMasuk: false,
        date: now,
        time: '--:-- WIB',
      ),
    ];
  }
}
