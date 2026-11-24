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

  static List<ReceivableModel> skeleton() {
    final now = DateTime.now();
    return [
      ReceivableModel(
        id: 'rec_skel_1',
        customerId: '',
        customerName: 'Warung Barokah Sejahtera',
        invoiceNumber: 'INV-2026-0001',
        date: now,
        originalAmount: 500000,
        paidAmount: 200000,
        remainingAmount: 300000,
        status: 'partial',
      ),
      ReceivableModel(
        id: 'rec_skel_2',
        customerId: '',
        customerName: 'Toko Sumber Rezeki Makmur',
        invoiceNumber: 'INV-2026-0002',
        date: now,
        originalAmount: 450000,
        paidAmount: 0,
        remainingAmount: 450000,
        status: 'unpaid',
      ),
      ReceivableModel(
        id: 'rec_skel_3',
        customerId: '',
        customerName: 'Pangkalan Gas Ibu Siti',
        invoiceNumber: 'INV-2026-0003',
        date: now,
        originalAmount: 360000,
        paidAmount: 0,
        remainingAmount: 360000,
        status: 'unpaid',
      ),
    ];
  }
}
