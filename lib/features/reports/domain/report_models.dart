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
