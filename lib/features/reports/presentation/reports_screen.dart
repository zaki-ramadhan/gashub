import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/reports_data.dart';
import '../domain/report_models.dart';
import 'expense_form_sheet.dart';
import 'reports_chart.dart';

/// Reports & Analytics Screen designed for an individual gas depot owner.
/// - Clean, balanced contrast with uniform white card surfaces.
/// - High data density without unnecessary decorative icon spam.
/// - Zero icons on the top-right of the 4 summary cards.
/// - Fully functional interactive period tabs, dropdown picker, metric toggle, and real datasets.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // 0: Minggu, 1: Bulan, 2: Tahun (Default), 3: Semua
  int _selectedTabIndex = 2;

  // Active period summary data
  ReportPeriodSummary _activeSummary = ReportsData.year2026;

  @override
  void initState() {
    super.initState();
  }

  void _onTabChanged(int index) {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
      final options = ReportsData.getOptionsForTab(index);
      _activeSummary = options.first;
    });
  }

  void _showPeriodPickerSheet(BuildContext context) {
    final options = ReportsData.getOptionsForTab(_selectedTabIndex);

    AppBottomSheet.show(
      context: context,
      title: 'Pilih Periode Laporan',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((summary) {
          final isSelected = summary.id == _activeSummary.id;

          return InkWell(
            onTap: () {
              setState(() => _activeSummary = summary);
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space12,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.05) : Colors.transparent,
                border: const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${summary.dateRangeLabel} • ${summary.comparisonText}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppColors.brandPrimary,
                    )
                  else
                    const Icon(
                      Icons.radio_button_unchecked,
                      size: 20,
                      color: AppColors.border,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _shareReport() {
    AppToast.success(
      title: 'Laporan berhasil diekspor',
      description: 'Data ${_activeSummary.title} siap dibagikan',
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _activeSummary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan & Statistik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            tooltip: 'Bagikan Laporan',
            onPressed: _shareReport,
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.space16,
          AppDimensions.space8,
          AppDimensions.space16,
          96,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Segmented Period Tabs (Minggu | Bulan | Tahun | Semua)
            Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Row(
                children: [
                  _buildSegmentTab('Minggu', 0),
                  _buildSegmentTab('Bulan', 1),
                  _buildSegmentTab('Tahun', 2),
                  _buildSegmentTab('Semua', 3),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 2. Interactive Period Sub-header (Clickable dropdown + BAGIKAN button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Clickable Period Title & Dropdown trigger
                InkWell(
                  onTap: () => _showPeriodPickerSheet(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              current.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border, width: 0.8),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${current.dateRangeLabel} • ${current.comparisonText}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BAGIKAN Button
                InkWell(
                  onTap: _shareReport,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    child: const Text(
                      'Bagikan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // 3. Single Focused Bar Chart with Metric Toggle (Omset vs Tabung)
            ReportsChartCard(
              dataPoints: current.dataPoints,
              periodTitle: current.title,
            ),
            const SizedBox(height: AppDimensions.space20),

            // 4. Section Title: Ringkasan Performa
            const Text(
              'Ringkasan Performa',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.space10),

            // 5. 2x2 Clean Summary Cards (NO ICONS ON TOP RIGHT, Uniform White Background)
            Row(
              children: [
                // Card 1: Laba Bersih
                Expanded(
                  child: _buildMetricCard(
                    title: 'Laba Bersih',
                    value: current.shortNetProfit,
                    valueColor: AppColors.brandPrimary,
                    subWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: current.profitGrowthPct >= 0
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${current.profitGrowthPct >= 0 ? '+' : ''}${current.profitGrowthPct}% vs lalu',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: current.profitGrowthPct >= 0
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),

                // Card 2: Tabung Terjual
                Expanded(
                  child: _buildMetricCard(
                    title: 'Tabung Terjual',
                    value: '${AppFormatters.number(current.totalSoldQty)} tabung',
                    subWidget: Text(
                      'Target ${AppFormatters.number(current.targetSoldQty)} (${((current.totalSoldQty / current.targetSoldQty) * 100).toInt()}%)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),

            Row(
              children: [
                // Card 3: Total Omset Penjualan
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Omset',
                    value: current.shortOmset,
                    subWidget: Text(
                      current.shortCashIn,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),

                // Card 4: Sisa Piutang Warung
                Expanded(
                  child: _buildMetricCard(
                    title: 'Piutang Warung',
                    value: current.shortReceivable,
                    subWidget: const Text(
                      'Tertahan di warung',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warningText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space20),

            // 6. Rincian Arus Kas & Biaya Operasional (Auditable Breakdown)
            _buildFinancialBreakdownCard(context, current),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }

  /// Segmented Tab pill for period selection
  Widget _buildSegmentTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  /// Metric summary card with NO top-right icons and harmonious white surface.
  Widget _buildMetricCard({
    required String title,
    required String value,
    required Widget subWidget,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clean title row (NO decorative icons)
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          subWidget,
        ],
      ),
    );
  }

  /// Transparent financial breakdown reflecting real mathematically cohesive values.
  Widget _buildFinancialBreakdownCard(BuildContext context, ReportPeriodSummary current) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rincian Keuangan & Biaya',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => ExpenseFormSheet.show(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    '+ Catat Biaya',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space12),

          _buildAuditRow('Total Omset Penjualan', current.rawOmset, isBold: true),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
            child: Column(
              children: [
                _buildSubAuditRow('Uang tunai diterima', current.cashIn),
                _buildSubAuditRow('Piutang tempo warung', current.receivable),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _buildAuditRow('Beban Pokok Kulakan SPPBE (HPP)', -current.hpp),
          const SizedBox(height: 6),
          _buildAuditRow(
            'Laba Kotor Penjualan',
            current.grossProfit,
            textColor: AppColors.brandPrimary,
          ),
          const SizedBox(height: 6),
          _buildAuditRow('Total Biaya Operasional Depo', -current.operationalCost),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
            child: Column(
              children: [
                _buildSubAuditRow('Bensin & Angkut Tabung', current.transportCost),
                _buildSubAuditRow('Upah Tenaga Bongkar Muat', current.laborCost),
                _buildSubAuditRow('Listrik & Operasional Lainnya', current.utilityCost),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _buildAuditRow(
            'Keuntungan Bersih (Laba Bersih)',
            current.netProfit,
            isBold: true,
            textColor: const Color(0xFF166534),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditRow(String title, int amount, {bool isBold = false, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isBold ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        Text(
          AppFormatters.currency(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubAuditRow(String title, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '• $title',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          Text(
            AppFormatters.currency(amount),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
