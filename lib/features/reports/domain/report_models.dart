/// Models representing aggregated performance statistics and report summaries.
class ReportDataPoint {
  final String label;
  final int quantity;
  final int omset;

  const ReportDataPoint({
    required this.label,
    required this.quantity,
    required this.omset,
  });
}

class ReportPeriodSummary {
  final String id;
  final String title;
  final String comparisonText;
  final String dateRangeLabel;
  final int totalSoldQty;
  final int targetSoldQty;
  final int rawOmset;
  final int cashIn;
  final int receivable;
  final int hpp;
  final int operationalCost;
  final int transportCost;
  final int laborCost;
  final int utilityCost;
  final double profitGrowthPct;
  final List<ReportDataPoint> dataPoints;

  const ReportPeriodSummary({
    required this.id,
    required this.title,
    required this.comparisonText,
    required this.dateRangeLabel,
    required this.totalSoldQty,
    required this.targetSoldQty,
    required this.rawOmset,
    required this.cashIn,
    required this.receivable,
    required this.hpp,
    required this.operationalCost,
    required this.transportCost,
    required this.laborCost,
    required this.utilityCost,
    required this.profitGrowthPct,
    required this.dataPoints,
  });

  factory ReportPeriodSummary.empty({
    required String id,
    required String title,
    required String dateRangeLabel,
  }) {
    return ReportPeriodSummary(
      id: id,
      title: title,
      comparisonText: 'Sinkron Database Supabase',
      dateRangeLabel: dateRangeLabel,
      totalSoldQty: 0,
      targetSoldQty: 100,
      rawOmset: 0,
      cashIn: 0,
      receivable: 0,
      hpp: 0,
      operationalCost: 0,
      transportCost: 0,
      laborCost: 0,
      utilityCost: 0,
      profitGrowthPct: 0.0,
      dataPoints: const [
        ReportDataPoint(label: 'Sen', quantity: 0, omset: 0),
        ReportDataPoint(label: 'Sel', quantity: 0, omset: 0),
        ReportDataPoint(label: 'Rab', quantity: 0, omset: 0),
        ReportDataPoint(label: 'Kam', quantity: 0, omset: 0),
        ReportDataPoint(label: 'Jum', quantity: 0, omset: 0),
      ],
    );
  }

  ReportPeriodSummary copyWith({
    String? id,
    String? title,
    String? comparisonText,
    String? dateRangeLabel,
    int? totalSoldQty,
    int? targetSoldQty,
    int? rawOmset,
    int? cashIn,
    int? receivable,
    int? hpp,
    int? operationalCost,
    int? transportCost,
    int? laborCost,
    int? utilityCost,
    double? profitGrowthPct,
    List<ReportDataPoint>? dataPoints,
  }) {
    return ReportPeriodSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      comparisonText: comparisonText ?? this.comparisonText,
      dateRangeLabel: dateRangeLabel ?? this.dateRangeLabel,
      totalSoldQty: totalSoldQty ?? this.totalSoldQty,
      targetSoldQty: targetSoldQty ?? this.targetSoldQty,
      rawOmset: rawOmset ?? this.rawOmset,
      cashIn: cashIn ?? this.cashIn,
      receivable: receivable ?? this.receivable,
      hpp: hpp ?? this.hpp,
      operationalCost: operationalCost ?? this.operationalCost,
      transportCost: transportCost ?? this.transportCost,
      laborCost: laborCost ?? this.laborCost,
      utilityCost: utilityCost ?? this.utilityCost,
      profitGrowthPct: profitGrowthPct ?? this.profitGrowthPct,
      dataPoints: dataPoints ?? this.dataPoints,
    );
  }

  int get grossProfit => rawOmset - hpp;
  int get netProfit => grossProfit - operationalCost;
  double get grossMarginPct => rawOmset > 0 ? (grossProfit / rawOmset) * 100 : 0.0;
  double get profitMarginPct => rawOmset > 0 ? (netProfit / rawOmset) * 100 : 0.0;

  /// Short formatted text for omset (e.g. "Rp 521,5 jt")
  String get shortOmset {
    if (rawOmset >= 1000000000) {
      final bill = rawOmset / 1000000000;
      return 'Rp ${bill.toStringAsFixed(1).replaceAll('.', ',')} M';
    }
    final mil = rawOmset / 1000000;
    return 'Rp ${mil.toStringAsFixed(1).replaceAll('.', ',')} jt';
  }

  /// Short formatted text for cash in
  String get shortCashIn {
    if (cashIn >= 1000000000) {
      final bill = cashIn / 1000000000;
      return 'Rp ${bill.toStringAsFixed(1).replaceAll('.', ',')} M tunai';
    }
    final mil = cashIn / 1000000;
    return 'Rp ${mil.toStringAsFixed(1).replaceAll('.', ',')} jt tunai';
  }

  /// Short formatted text for net profit
  String get shortNetProfit {
    if (netProfit >= 1000000000) {
      final bill = netProfit / 1000000000;
      return 'Rp ${bill.toStringAsFixed(1).replaceAll('.', ',')} M';
    }
    final mil = netProfit / 1000000;
    return 'Rp ${mil.toStringAsFixed(1).replaceAll('.', ',')} jt';
  }

  /// Short formatted text for receivables
  String get shortReceivable {
    final mil = receivable / 1000000;
    return 'Rp ${mil.toStringAsFixed(1).replaceAll('.', ',')} jt';
  }
}
