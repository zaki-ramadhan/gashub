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
}
