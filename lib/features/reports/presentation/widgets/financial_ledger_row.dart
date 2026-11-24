import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Clean ledger row presenting financial line items with optional subtitle.
class FinancialLedgerRow extends StatelessWidget {
  const FinancialLedgerRow({
    super.key,
    required this.title,
    required this.amount,
    this.isBold = false,
    this.amountColor,
    this.subtitle,
  });

  final String title;
  final String amount;
  final bool isBold;
  final Color? amountColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: amountColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Indicator row with colored status dot for subsidiary financial items.
class FinancialIndicatorSubRow extends StatelessWidget {
  const FinancialIndicatorSubRow({
    super.key,
    required this.title,
    required this.amount,
    required this.dotColor,
    required this.amountColor,
  });

  final String title;
  final String amount;
  final Color dotColor;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

