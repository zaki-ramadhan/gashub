/// Strongly typed domain entity for cash flow summary on the dashboard.
class CashflowSummary {
  const CashflowSummary({
    required this.netCashflow,
    required this.cashIn,
    required this.cashOut,
  });

  final int netCashflow;
  final int cashIn;
  final int cashOut;

  const CashflowSummary.zero()
      : netCashflow = 0,
        cashIn = 0,
        cashOut = 0;

  factory CashflowSummary.fromMap(Map<String, dynamic> map) {
    return CashflowSummary(
      netCashflow: (map['netCashflow'] as num?)?.toInt() ?? 0,
      cashIn: (map['cashIn'] as num?)?.toInt() ?? 0,
      cashOut: (map['cashOut'] as num?)?.toInt() ?? 0,
    );
  }
}
