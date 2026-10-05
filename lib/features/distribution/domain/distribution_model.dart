import '../../../core/core.dart';

/// Strongly typed domain entity for gas distribution transactions.
class DistributionModel {
  const DistributionModel({
    required this.id,
    required this.transactionNumber,
    required this.customerName,
    this.customerId,
    required this.qty,
    required this.date,
    required this.time,
    required this.amount,
    required this.amountPaid,
    required this.status,
    this.notes = '',
  });

  final String id;
  final String transactionNumber;
  final String customerName;
  final String? customerId;
  final int qty;
  final DateTime date;
  final String time;
  final int amount;
  final int amountPaid;
  final String status; // 'paid', 'partial', 'unpaid'
  final String notes;

  String get itemsLabel => '$qty tabung';

  String get statusLabel {
    switch (status) {
      case 'paid':
        return 'Lunas';
      case 'partial':
        return 'Sebagian';
      default:
        return 'Belum Bayar';
    }
  }

  BadgeType get statusType {
    switch (status) {
      case 'paid':
        return BadgeType.success;
      case 'partial':
        return BadgeType.warning;
      default:
        return BadgeType.danger;
    }
  }

  bool get isPaid => status == 'paid';

  static List<DistributionModel> skeleton() {
    final now = DateTime.now();
    return [
      DistributionModel(
        id: 'skel_1',
        transactionNumber: 'DST-------',
        customerName: '------------------',
        qty: 0,
        date: now,
        time: '--:-- WIB',
        amount: 0,
        amountPaid: 0,
        status: 'unpaid',
      ),
      DistributionModel(
        id: 'skel_2',
        transactionNumber: 'DST-------',
        customerName: '-----------------------',
        qty: 0,
        date: now,
        time: '--:-- WIB',
        amount: 0,
        amountPaid: 0,
        status: 'unpaid',
      ),
      DistributionModel(
        id: 'skel_3',
        transactionNumber: 'DST-------',
        customerName: '---------------------',
        qty: 0,
        date: now,
        time: '--:-- WIB',
        amount: 0,
        amountPaid: 0,
        status: 'unpaid',
      ),
    ];
  }
}
