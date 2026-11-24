import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/cashflow_entry_model.dart';

/// Single row item representing a cashflow entry in the history sheet.
class CashflowEntryRow extends StatelessWidget {
  const CashflowEntryRow({
    super.key,
    required this.entry,
  });

  final CashflowEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final isInflow = entry.isInflow;
    final timeStr = AppFormatters.time(entry.createdAt);
    final formattedAmount =
        '${isInflow ? '+' : '-'}${AppFormatters.currency(entry.amount)}';

    return FlatTransactionRow(
      title: entry.notes?.isNotEmpty == true
          ? entry.notes!
          : entry.categoryDisplay,
      subtitle: entry.categoryDisplay,
      amount: formattedAmount,
      amountColor: isInflow ? AppColors.brandPrimary : AppColors.dangerText,
      time: timeStr,
    );
  }
}

