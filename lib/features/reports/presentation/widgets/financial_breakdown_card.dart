import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/report_models.dart';
import 'financial_ledger_row.dart';

/// Auditable financial breakdown card based on depot gas cash flow.
class FinancialBreakdownCard extends StatelessWidget {
  const FinancialBreakdownCard({
    super.key,
    required this.summary,
  });

  final ReportPeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final isProfit = summary.netProfit >= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Keuangan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space12),

          // 1. REVENUE (Total penjualan)
          FinancialLedgerRow(
            title: 'Total penjualan',
            amount: AppFormatters.currency(summary.rawOmset),
            isBold: true,
            amountColor: AppColors.brandPrimary,
          ),
          const SizedBox(height: AppDimensions.space8),
          FinancialIndicatorSubRow(
            title: 'Pemasukan diterima (lunas)',
            amount: AppFormatters.currency(summary.cashIn),
            dotColor: const Color(0xFF16A34A),
            amountColor: AppColors.textPrimary,
          ),

          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: AppDimensions.space12),

          // 2. MODAL & BEBAN
          FinancialLedgerRow(
            title: 'Modal beli tabung terjual',
            amount: '-${AppFormatters.currency(summary.hpp)}',
            isBold: true,
            amountColor: const Color(0xFFDC2626),
            subtitle: '${AppFormatters.number(summary.totalSoldQty)} tabung × ${AppFormatters.currency(summary.unitPurchasePrice)}',
          ),
          const SizedBox(height: AppDimensions.space8),
          FinancialIndicatorSubRow(
            title: summary.grossProfit >= 0 ? 'Laba kotor penjualan' : 'Defisit kotor penjualan',
            amount: AppFormatters.currency(summary.grossProfit),
            dotColor: summary.grossProfit >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            amountColor: summary.grossProfit >= 0 ? AppColors.textPrimary : const Color(0xFFDC2626),
          ),
          const SizedBox(height: AppDimensions.space8),
          FinancialIndicatorSubRow(
            title: 'Pengeluaran operasional',
            amount: '-${AppFormatters.currency(summary.operationalCost)}',
            dotColor: const Color(0xFFDC2626),
            amountColor: const Color(0xFFDC2626),
          ),

          const SizedBox(height: AppDimensions.space16),

          // 3. ANCHOR FOOTER: KEUNTUNGAN / RUGI BERSIH AKHIR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isProfit ? AppColors.brandPrimary : const Color(0xFF991B1B),
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isProfit ? 'Keuntungan bersih akhir' : 'Rugi bersih akhir',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: isProfit ? AppColors.brandAccent : const Color(0xFFFEE2E2),
                  ),
                ),
                Text(
                  AppFormatters.currency(summary.netProfit),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
