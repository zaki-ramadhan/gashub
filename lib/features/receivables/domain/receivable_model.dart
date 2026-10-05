import '../../../core/core.dart';

/// Strongly typed domain entity for outstanding customer debt (receivable).
class ReceivableModel {
  const ReceivableModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.phone = '',
    required this.remainingAmount,
    required this.originalAmount,
    required this.paidAmount,
    required this.date,
    required this.invoiceNumber,
    required this.status,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String phone;
  final int remainingAmount;
  final int originalAmount;
  final int paidAmount;
  final DateTime date;
  final String invoiceNumber;
  final String status; // 'unpaid', 'partial', 'paid'

  String get statusLabel => status == 'partial' ? 'Cicilan Sebagian' : 'Belum Bayar';

  BadgeType get statusType => status == 'partial' ? BadgeType.warning : BadgeType.danger;

  static List<ReceivableModel> skeleton() {
    final now = DateTime.now();
    return [
      ReceivableModel(
        id: 'rec_skel_1',
        customerId: '',
        customerName: '------------------',
        invoiceNumber: 'INV-----------',
        date: now,
        originalAmount: 0,
        paidAmount: 0,
        remainingAmount: 0,
        status: 'unpaid',
      ),
      ReceivableModel(
        id: 'rec_skel_2',
        customerId: '',
        customerName: '-----------------------',
        invoiceNumber: 'INV-----------',
        date: now,
        originalAmount: 0,
        paidAmount: 0,
        remainingAmount: 0,
        status: 'unpaid',
      ),
      ReceivableModel(
        id: 'rec_skel_3',
        customerId: '',
        customerName: '---------------------',
        invoiceNumber: 'INV-----------',
        date: now,
        originalAmount: 0,
        paidAmount: 0,
        remainingAmount: 0,
        status: 'unpaid',
      ),
    ];
  }
}
