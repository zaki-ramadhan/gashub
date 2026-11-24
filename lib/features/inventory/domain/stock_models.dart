/// Strongly typed domain entity for physical gas cylinder stock summary.
class StockSummary {
  const StockSummary({
    required this.filled,
    required this.empty,
    required this.loaned,
    int? sellingPrice,
    int? purchasePrice,
  })  : sellingPrice = sellingPrice ?? 19000,
        purchasePrice = purchasePrice ?? 16000;

  final int filled;
  final int empty;
  final int loaned;
  final int sellingPrice;
  final int purchasePrice;

  int get totalTabung => filled + empty + loaned;
  int get unitMargin => sellingPrice - purchasePrice;

  const StockSummary.zero()
      : filled = 0,
        empty = 0,
        loaned = 0,
        sellingPrice = 19000,
        purchasePrice = 16000;
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
        title: 'Pasokan Tabung Gas Masuk',
        qty: 100,
        isMasuk: true,
        date: now,
        time: '14:30 WIB',
      ),
      StockLogItem(
        id: 'skel_2',
        title: 'Penjualan ke Mitra Pangkalan',
        qty: 25,
        isMasuk: false,
        date: now,
        time: '11:15 WIB',
      ),
      StockLogItem(
        id: 'skel_3',
        title: 'Pasokan Tabung Gas Masuk',
        qty: 50,
        isMasuk: true,
        date: now,
        time: '09:00 WIB',
      ),
    ];
  }
}
