import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../domain/report_models.dart';
import 'report_metric_card.dart';

/// 2x2 grid of metric cards displaying business summary in reports screen.
class ReportBusinessSummaryGrid extends StatelessWidget {
  const ReportBusinessSummaryGrid({
    super.key,
    required this.summary,
  });

  final ReportPeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Usaha',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.space10),
        Row(
          children: [
            Expanded(
              child: ReportMetricCard(
                title: summary.netProfit >= 0 ? 'Untung Bersih' : 'Rugi Bersih',
                value: summary.shortNetProfit,
                valueColor: summary.netProfit >= 0 ? AppColors.brandPrimary : AppColors.dangerText,
                subWidget: Text(
                  summary.netProfit >= 0 ? 'Sisa uang di tangan' : 'Pengeluaran melebihi pemasukan',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: ReportMetricCard(
                title: 'Tabung Terjual',
                value: '${AppFormatters.number(summary.totalSoldQty)} tabung',
                subWidget: const Text(
                  'Terkirim ke pelanggan',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        Row(
          children: [
            Expanded(
              child: ReportMetricCard(
                title: 'Total Penjualan',
                value: summary.shortOmset,
                subWidget: Text(
                  summary.shortCashIn,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: Skeleton.ignore(
                child: InkWell(
                  onTap: () => context.push('/piutang'),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  child: ReportMetricCard(
                    title: 'Utang Pelanggan',
                    value: summary.shortReceivable,
                    subWidget: Text(
                      summary.receivable > 0 ? 'Belum dibayar pelanggan' : 'Semua tagihan lunas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: summary.receivable > 0 ? AppColors.warningText : AppColors.brandSuccess,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

