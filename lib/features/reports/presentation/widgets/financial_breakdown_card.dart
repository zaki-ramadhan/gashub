import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/report_models.dart';

/// Auditable financial breakdown card based on depot gas cash flow.
class FinancialBreakdownCard extends StatelessWidget {
  const FinancialBreakdownCard({
    super.key,
    required this.summary,
  });

  final ReportPeriodSummary summary;

  @override
  Widget build(BuildContext context) {
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

          // 1. REVENUE (Total omset penjualan)
          _buildLedgerRow(
            title: 'Total omset penjualan',
            amount: AppFormatters.currency(summary.rawOmset),
            isBold: true,
            amountColor: AppColors.brandPrimary,
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildIndicatorSubRow(
            title: 'Penerimaan tunai cair',
            amount: AppFormatters.currency(summary.cashIn),
            dotColor: const Color(0xFF16A34A),
            amountColor: AppColors.textPrimary,
          ),
          const SizedBox(height: AppDimensions.space6),
          _buildIndicatorSubRow(
            title: 'Utang pelanggan belum dibayar',
            amount: AppFormatters.currency(summary.receivable),
            dotColor: const Color(0xFFD97706),
            amountColor: AppColors.warningText,
          ),

          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: AppDimensions.space12),

          // 2. BEBAN POKOK (HPP KULAKAN SPPBE)
          _buildLedgerRow(
            title: 'Kulakan SPPBE (HPP)',
            amount: '-${AppFormatters.currency(summary.hpp)}',
            isBold: true,
            amountColor: const Color(0xFFDC2626),
            subtitle: '${AppFormatters.number(summary.totalSoldQty)} tabung × Rp 15.750',
          ),

          const SizedBox(height: AppDimensions.space16),

          // 3. ANCHOR FOOTER: UNTUNG BERSIH AKHIR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF14432A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Untung bersih akhir',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDCFCE7),
                  ),
                ),
                Text(
                  AppFormatters.currency(summary.grossProfit),
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

  Widget _buildLedgerRow({
    required String title,
    required String amount,
    bool isBold = false,
    Color? amountColor,
    String? subtitle,
  }) {
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
                  fontSize: 13.5,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
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
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: amountColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorSubRow({
    required String title,
    required String amount,
    required Color dotColor,
    required Color amountColor,
  }) {
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
              fontSize: 12.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
