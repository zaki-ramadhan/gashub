import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/customer_model.dart';

/// Clean transaction list item for CustomerDetailSheet.
class CustomerOrderItemRow extends StatelessWidget {
  const CustomerOrderItemRow({
    super.key,
    required this.transaction,
    this.showDivider = true,
  });

  final CustomerTransaction transaction;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border, width: 0.8))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction.invoice} | ${AppFormatters.date(transaction.date)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.items,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(transaction.totalAmount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              StatusBadge(
                label: transaction.statusLabel,
                type: transaction.statusType,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

