import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/distribution_model.dart';

/// Clean, minimal financial summary without redundant cost formulas or technical transaction IDs.
class SaleDetailFinancialSection extends StatelessWidget {
  const SaleDetailFinancialSection({super.key, required this.sale});

  final DistributionModel sale;

  @override
  Widget build(BuildContext context) {
    final isProfitable = sale.netMargin >= 0;
    final marginPercent = sale.amount > 0
        ? ((sale.netMargin / sale.amount) * 100).toStringAsFixed(1)
        : '0.0';
    final hasUnpaidDebt = sale.amountPaid < sale.amount;
    final remainingDebt = sale.amount - sale.amountPaid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Total Penjualan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total penjualan',
              style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
            ),
            Text(
              AppFormatters.currency(sale.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: hasUnpaidDebt ? FontWeight.w500 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),

        // 2. Info DP & Sisa Tagihan (hanya tampil jika belum lunas)
        if (hasUnpaidDebt) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sudah dibayar (DP)',
                style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
              ),
              Text(
                AppFormatters.currency(sale.amountPaid),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sisa tagihan',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.warningText,
                ),
              ),
              Text(
                AppFormatters.currency(remainingDebt),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warningText,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppDimensions.space10),

        // 3. Simple Profit Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isProfitable ? AppColors.brandAccent : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            border: Border.all(
              color: isProfitable
                  ? AppColors.brandSuccess.withValues(alpha: 0.25)
                  : AppColors.dangerText.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isProfitable
                    ? 'Keuntungan bersih ($marginPercent%)'
                    : 'Defisit penjualan ($marginPercent%)',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isProfitable ? AppColors.brandPrimary : AppColors.dangerText,
                ),
              ),
              Text(
                AppFormatters.signedCurrency(sale.netMargin),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isProfitable ? AppColors.brandPrimary : AppColors.dangerText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
