import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Flat financial summary of current sale order without heavy card boxes.
class DistributionSummarySection extends StatelessWidget {
  const DistributionSummarySection({
    super.key,
    required this.subtotal,
    required this.qty,
    required this.isPaid,
    required this.remainingDebt,
  });

  final int subtotal;
  final int qty;
  final bool isPaid;
  final int remainingDebt;

  @override
  Widget build(BuildContext context) {
    final cost = qty * 16000;
    final profit = subtotal - cost;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Penjualan',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            Text(
              AppFormatters.currency(subtotal),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.brandPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Modal Beli Tabung',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            Text(
              AppFormatters.currency(cost),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (!isPaid && remainingDebt > 0) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sisa Bon Warung',
                style: TextStyle(fontSize: 13, color: AppColors.dangerText),
              ),
              Text(
                AppFormatters.currency(remainingDebt),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.dangerText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Keuntungan Bersih',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '+${AppFormatters.currency(profit)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

