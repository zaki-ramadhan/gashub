import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/distribution_model.dart';
import 'sale_detail_sheet.dart';

/// Renders a single day's transaction group card in Distribution screen.
class DistributionDayGroupCard extends StatelessWidget {
  const DistributionDayGroupCard({
    super.key,
    required this.dateKey,
    required this.items,
    required this.isFirst,
  });

  final DateTime dateKey;
  final List<DistributionModel> items;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final dayQty = items.fold<int>(0, (sum, tx) => sum + tx.qty);
    final dayAmount = items.fold<int>(0, (sum, tx) => sum + tx.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateSectionHeader(
          title: AppFormatters.relativeDateHeader(dateKey),
          trailingText: '$dayQty tabung | ${AppFormatters.currency(dayAmount)}',
          topPadding: isFirst ? AppDimensions.space4 : AppDimensions.space16,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final itemIndex = entry.key;
              final item = entry.value;
              final isLast = itemIndex == items.length - 1;
              return FlatTransactionRow(
                title: item.customerName,
                subtitle: '${item.qty} tabung',
                amount: AppFormatters.currency(item.amount),
                statusLabel: item.statusLabel,
                statusType: item.statusType,
                time: item.time,
                showDivider: !isLast,
                onTap: () => SaleDetailSheet.show(context, item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

