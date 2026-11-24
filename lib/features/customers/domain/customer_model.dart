import '../../../core/core.dart';

/// Transaction record associated with a specific store.
class CustomerTransaction {
  final String id;
  final String invoice;
  final DateTime date;
  final String items;
  final int qty;
  final int totalAmount;
  final int paidAmount;
  final String statusLabel;
  final BadgeType statusType;

  const CustomerTransaction({
    required this.id,
    required this.invoice,
    required this.date,
    required this.items,
    required this.qty,
    required this.totalAmount,
    required this.paidAmount,
    required this.statusLabel,
    required this.statusType,
  });

  bool get isUnpaid => paidAmount < totalAmount;

  CustomerTransaction copyWith({
    String? id,
    String? invoice,
    DateTime? date,
    String? items,
    int? qty,
    int? totalAmount,
    int? paidAmount,
    String? statusLabel,
    BadgeType? statusType,
  }) {
    return CustomerTransaction(
      id: id ?? this.id,
      invoice: invoice ?? this.invoice,
      date: date ?? this.date,
      items: items ?? this.items,
      qty: qty ?? this.qty,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      statusLabel: statusLabel ?? this.statusLabel,
      statusType: statusType ?? this.statusType,
    );
  }
}

/// Domain model representing a customer / partner warung.
class CustomerModel {
  final String id;
  final String name;
  final String owner;
  final String phone;
  final String address;
  final int activeDebt;
  final int totalCylinders;
  final DateTime? lastOrderDate;
  final List<CustomerTransaction> transactions;

  const CustomerModel({
    required this.id,
    required this.name,
    this.owner = '',
    required this.phone,
    required this.address,
    this.activeDebt = 0,
    this.totalCylinders = 0,
    this.lastOrderDate,
    this.transactions = const [],
  });

  bool get hasDebt => activeDebt > 0;
  String get displayName {
    if (name.trim().isEmpty) return '-';
    return name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
  int get totalOrders => transactions.length;
  int get totalSpending => transactions.fold<int>(0, (sum, tx) => sum + tx.totalAmount);
  int get unpaidTransactionsCount {
    final count = transactions.where((t) => t.isUnpaid).length;
    return count > 0 ? count : (hasDebt ? 1 : 0);
  }

  /// Total cylinders ordered in current month
  int get currentMonthCylinders {
    final now = DateTime.now();
    return transactions.where((tx) {
      return tx.date.year == now.year && tx.date.month == now.month;
    }).fold<int>(0, (sum, tx) => sum + tx.qty);
  }

  /// Total spending in current month
  int get currentMonthSpending {
    final now = DateTime.now();
    return transactions.where((tx) {
      return tx.date.year == now.year && tx.date.month == now.month;
    }).fold<int>(0, (sum, tx) => sum + tx.totalAmount);
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? owner,
    String? phone,
    String? address,
    int? activeDebt,
    int? totalCylinders,
    DateTime? lastOrderDate,
    List<CustomerTransaction>? transactions,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      activeDebt: activeDebt ?? this.activeDebt,
      totalCylinders: totalCylinders ?? this.totalCylinders,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      transactions: transactions ?? this.transactions,
    );
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    final receivablesList = (map['receivables'] as List<dynamic>?) ?? [];
    int totalDebt = 0;
    for (final r in receivablesList) {
      if (r is Map<String, dynamic>) {
        totalDebt += (r['remaining_amount'] as num?)?.toInt() ?? 0;
      }
    }

    final distributionsList = (map['distributions'] as List<dynamic>?) ?? [];
    final List<CustomerTransaction> txs = [];
    int totalCylinders = 0;
    DateTime? latestDate;

    for (final d in distributionsList) {
      if (d is Map<String, dynamic>) {
        final date = DateTime.tryParse(d['business_date']?.toString() ?? '') ?? DateTime.now();
        if (latestDate == null || date.isAfter(latestDate)) {
          latestDate = date;
        }

        final items = (d['distribution_items'] as List<dynamic>?) ?? [];
        int txQty = 0;
        for (final it in items) {
          if (it is Map<String, dynamic>) {
            txQty += (it['quantity'] as num?)?.toInt() ?? 0;
          }
        }
        totalCylinders += txQty;

        final status = d['payment_status']?.toString() ?? 'unpaid';
        final statusLabel = status == 'paid'
            ? 'Lunas'
            : (status == 'partial' ? 'Sebagian' : 'Belum Bayar');
        final statusType = status == 'paid'
            ? BadgeType.success
            : (status == 'partial' ? BadgeType.warning : BadgeType.danger);

        txs.add(CustomerTransaction(
          id: d['id']?.toString() ?? '',
          invoice: 'Penjualan',
          date: date,
          items: '$txQty tabung',
          qty: txQty,
          totalAmount: (d['total'] as num?)?.toInt() ?? 0,
          paidAmount: (d['amount_paid'] as num?)?.toInt() ?? 0,
          statusLabel: statusLabel,
          statusType: statusType,
        ));
      }
    }

    // Sort transactions latest first
    txs.sort((a, b) => b.date.compareTo(a.date));

    return CustomerModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      owner: map['notes']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      activeDebt: totalDebt,
      totalCylinders: totalCylinders,
      lastOrderDate: latestDate,
      transactions: txs,
    );
  }

  static List<CustomerModel> skeleton() {
    return [
      CustomerModel(
        id: 'skel_c1',
        name: 'Warung Barokah Sejahtera',
        owner: 'Hj. Siti Aminah',
        phone: '081234567890',
        address: 'Jl. Melati No. 12',
        totalCylinders: 45,
        activeDebt: 0,
        transactions: List.generate(
          6,
          (i) => CustomerTransaction(
            id: 'tx_skel_1_$i',
            invoice: 'INV-00$i',
            date: DateTime.now(),
            items: '8 tabung',
            qty: 8,
            totalAmount: 135000,
            paidAmount: 135000,
            statusLabel: 'Lunas',
            statusType: BadgeType.success,
          ),
        ),
      ),
      CustomerModel(
        id: 'skel_c2',
        name: 'Toko Sumber Rezeki Makmur',
        owner: 'Pak Joko Santoso',
        phone: '081298765432',
        address: 'Jl. Mawar No. 5',
        totalCylinders: 30,
        activeDebt: 0,
        transactions: List.generate(
          4,
          (i) => CustomerTransaction(
            id: 'tx_skel_2_$i',
            invoice: 'INV-00$i',
            date: DateTime.now(),
            items: '7 tabung',
            qty: 7,
            totalAmount: 135000,
            paidAmount: 135000,
            statusLabel: 'Lunas',
            statusType: BadgeType.success,
          ),
        ),
      ),
      CustomerModel(
        id: 'skel_c3',
        name: 'Pangkalan Gas Mitra Mandiri',
        owner: 'Ibu Ratna',
        phone: '081311223344',
        address: 'Jl. Kenanga No. 8',
        totalCylinders: 20,
        activeDebt: 0,
        transactions: List.generate(
          3,
          (i) => CustomerTransaction(
            id: 'tx_skel_3_$i',
            invoice: 'INV-00$i',
            date: DateTime.now(),
            items: '6 tabung',
            qty: 6,
            totalAmount: 120000,
            paidAmount: 120000,
            statusLabel: 'Lunas',
            statusType: BadgeType.success,
          ),
        ),
      ),
    ];
  }
}
