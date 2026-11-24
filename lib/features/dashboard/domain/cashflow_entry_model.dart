/// Model representing an individual cashflow ledger entry.
class CashflowEntryModel {
  final String id;
  final String direction; // 'in' or 'out'
  final String category; // 'sales', 'receivable', 'operations', 'transport', 'labor', 'rent', etc.
  final String sourceType; // 'distribution', 'receivable', 'expense', 'restock'
  final String? sourceId;
  final String businessDate;
  final DateTime createdAt;
  final int amount;
  final String method; // 'cash', 'transfer', etc.
  final String? notes;

  const CashflowEntryModel({
    required this.id,
    required this.direction,
    required this.category,
    required this.sourceType,
    this.sourceId,
    required this.businessDate,
    required this.createdAt,
    required this.amount,
    required this.method,
    this.notes,
  });

  bool get isInflow => direction == 'in';

  String get categoryDisplay {
    switch (category.toLowerCase()) {
      case 'sales':
        return 'Penjualan Gas';
      case 'receivable':
        return 'Pelunasan Bon';
      case 'operations':
      case 'operational':
        return 'Operasional';
      case 'transport':
        return 'Transport / Bensin';
      case 'labor':
        return 'Gaji / Upah Karyawan';
      case 'restock':
        return 'Pembelian Pasokan Gas';
      case 'rent':
        return 'Sewa Tempat';
      default:
        return category.isNotEmpty ? category : 'Lainnya';
    }
  }

  factory CashflowEntryModel.fromJson(Map<String, dynamic> json) {
    return CashflowEntryModel(
      id: json['id']?.toString() ?? '',
      direction: json['direction']?.toString() ?? 'out',
      category: json['category']?.toString() ?? 'operations',
      sourceType: json['source_type']?.toString() ?? 'expense',
      sourceId: json['source_id']?.toString(),
      businessDate: json['business_date']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      method: json['method']?.toString() ?? 'cash',
      notes: json['notes']?.toString(),
    );
  }

  static List<CashflowEntryModel> skeleton() {
    return List.generate(
      5,
      (i) => CashflowEntryModel(
        id: 'skel_$i',
        direction: i.isEven ? 'in' : 'out',
        category: i.isEven ? 'Penjualan Gas' : 'Operasional',
        sourceType: i.isEven ? 'distribution' : 'expense',
        businessDate: '2026-11-23',
        createdAt: DateTime.now(),
        amount: i.isEven ? 285000 : 50000,
        method: 'Tunai',
        notes: i.isEven ? 'Penjualan Toko Berkah' : 'Beli bensin motor delivery',
      ),
    );
  }
}

