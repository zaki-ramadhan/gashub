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
          invoice: '#${d['transaction_number'] ?? ''}',
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
}
