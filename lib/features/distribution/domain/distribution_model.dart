import '../../../core/core.dart';

/// Item detail inside a distribution / sale order.
class DistributionItemDetail {
  const DistributionItemDetail({
    required this.productId,
    required this.productName,
    required this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost,
    required this.subtotalSales,
    required this.subtotalCost,
  });

  final String productId;
  final String productName;
  final String variant;
  final int quantity;
  final int unitPrice;
  final int unitCost;
  final int subtotalSales;
  final int subtotalCost;

  int get subtotalMargin => subtotalSales - subtotalCost;
}

/// Strongly typed domain entity for gas sales and distribution transactions.
class DistributionModel {
  const DistributionModel({
    required this.id,
    required this.transactionNumber,
    required this.customerName,
    this.customerId,
    required this.qty,
    required this.date,
    required this.time,
    required this.amount, // Total Penjualan
    required this.amountPaid, // Pemasukan Diterima
    required this.status, // 'paid'
    this.totalCost = 0, // Total Modal (HPP Tabung)
    this.paymentMethod = 'Tunai',
    this.items = const [],
    this.notes = '',
  });

  final String id;
  final String transactionNumber;
  final String customerName;
  final String? customerId;
  final int qty; // Total Jumlah Order Tabung
  final DateTime date; // Tanggal Order
  final String time; // Waktu Order
  final int amount; // Total Penjualan (Omset)
  final int amountPaid; // Pemasukan
  final String status; // 'paid'
  final int totalCost; // Total Modal Beli
  final String paymentMethod; // Tunai / Transfer
  final List<DistributionItemDetail> items;
  final String notes;

  /// Sisa Margin / Keuntungan Bersih dari transaksi ini
  int get netMargin => amount - totalCost;

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
        transactionNumber: 'DST-2026-0001',
        customerName: 'Warung Barokah Sejahtera',
        qty: 25,
        date: now,
        time: '14:30 WIB',
        amount: 450000,
        amountPaid: 450000,
        status: 'paid',
        totalCost: 375000,
      ),
      DistributionModel(
        id: 'skel_2',
        transactionNumber: 'DST-2026-0002',
        customerName: 'Toko Sumber Rezeki Makmur',
        qty: 15,
        date: now,
        time: '11:15 WIB',
        amount: 270000,
        amountPaid: 270000,
        status: 'paid',
        totalCost: 225000,
      ),
      DistributionModel(
        id: 'skel_3',
        transactionNumber: 'DST-2026-0003',
        customerName: 'Pangkalan Gas Ibu Siti',
        qty: 30,
        date: now,
        time: '09:00 WIB',
        amount: 540000,
        amountPaid: 540000,
        status: 'paid',
        totalCost: 450000,
      ),
      DistributionModel(
        id: 'skel_4',
        transactionNumber: 'DST-2026-0004',
        customerName: 'Kedai Berkah Bersama',
        qty: 10,
        date: now,
        time: '07:45 WIB',
        amount: 180000,
        amountPaid: 180000,
        status: 'paid',
        totalCost: 150000,
      ),
    ];
  }
}
