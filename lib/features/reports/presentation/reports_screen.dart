import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../data/reports_data.dart';
import '../domain/report_models.dart';
import 'expense_form_sheet.dart';

/// Reports & Analytics Screen designed for an individual gas depot owner.
/// - Clean, balanced contrast with uniform white card surfaces.
/// - High data density without unnecessary decorative icon spam.
/// - Zero icons on the top-right of the 4 summary cards.
/// - Fully functional interactive period tabs, dropdown picker, metric toggle, and real datasets.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.initialTabIndex});

  final int? initialTabIndex;

  /// Global notifier for external tab switching (e.g. from Dashboard quick tools)
  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(2);

  /// Synchronously switches active report tab and navigates to /laporan
  static void switchToTab(BuildContext context, int tabIndex) {
    activeTabNotifier.value = tabIndex;
    context.go('/laporan');
  }

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // 0: Minggu, 1: Bulan, 2: Tahun (Default), 3: Semua
  late int _selectedTabIndex;

  // Active period summary data
  late ReportPeriodSummary _activeSummary;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex ?? ReportsScreen.activeTabNotifier.value;
    ReportsScreen.activeTabNotifier.addListener(_onNotifierTabChanged);
    final options = ReportsData.getOptionsForTab(_selectedTabIndex);
    _activeSummary = options.first;
  }

  @override
  void dispose() {
    ReportsScreen.activeTabNotifier.removeListener(_onNotifierTabChanged);
    super.dispose();
  }

  void _onNotifierTabChanged() {
    final newTab = ReportsScreen.activeTabNotifier.value;
    if (_selectedTabIndex != newTab && mounted) {
      setState(() {
        _selectedTabIndex = newTab;
        final options = ReportsData.getOptionsForTab(_selectedTabIndex);
        _activeSummary = options.first;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != null && widget.initialTabIndex != _selectedTabIndex) {
      setState(() {
        _selectedTabIndex = widget.initialTabIndex!;
        final options = ReportsData.getOptionsForTab(_selectedTabIndex);
        _activeSummary = options.first;
      });
    }
  }

  void _onTabChanged(int index) {
    if (_selectedTabIndex == index) return;
    ReportsScreen.activeTabNotifier.value = index;
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
      title: 'Pilih Periode',
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
                            fontSize: 14.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                          ),
                        ),
                        if (_selectedTabIndex == 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            summary.dateRangeLabel,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    final current = _activeSummary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan & Statistik'),
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
            // 1. Top Segmented Period Tabs (Mingguan | Bulanan | Tahunan | Semua)
            Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Row(
                children: [
                  _buildSegmentTab('Mingguan', 0),
                  _buildSegmentTab('Bulanan', 1),
                  _buildSegmentTab('Tahunan', 2),
                  _buildSegmentTab('Semua', 3),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 2. Interactive Period Sub-header (only for Mingguan, Bulanan, Tahunan)
            if (_selectedTabIndex != 3) ...[
              InkWell(
                onTap: () => _showPeriodPickerSheet(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                    border: Border.all(color: AppColors.border, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.brandPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        current.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '|',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.border,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          current.dateRangeLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
            ],

            // Ringkasan Usaha (4 Kartu Praktis Tanpa Rumit)
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
                // Card 1: Untung Bersih
                Expanded(
                  child: _buildMetricCard(
                    title: 'Untung Bersih',
                    value: current.shortNetProfit,
                    valueColor: AppColors.brandPrimary,
                    subWidget: const Text(
                      'Sisa uang di tangan',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),

                // Card 2: Tabung Terjual
                Expanded(
                  child: _buildMetricCard(
                    title: 'Tabung Terjual',
                    value: '${AppFormatters.number(current.totalSoldQty)} tabung',
                    subWidget: const Text(
                      'Terkirim ke pelanggan',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
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
                // Card 3: Total Penjualan
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Penjualan',
                    value: current.shortOmset,
                    subWidget: Text(
                      current.shortCashIn,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),

                // Card 4: Sisa Piutang Warung
                Expanded(
                  child: _buildMetricCard(
                    title: 'Utang Pelanggan',
                    value: current.shortReceivable,
                    subWidget: const Text(
                      'Belum dibayar pelanggan',
                      style: TextStyle(
                        fontSize: 12,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
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
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 5),
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
          const SizedBox(height: 5),
          subWidget,
        ],
      ),
    );
  }

  /// Structured, auditable financial breakdown (anti-flat presentation)
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
          // Header with Title & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Keuangan & Biaya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rekapitulasi kalkulasi periode ${current.title}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => ExpenseFormSheet.show(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                    border: Border.all(color: AppColors.border, width: 1.0),
                  ),
                  child: const Text(
                    '+ Pengeluaran',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space12),

          // 1. REVENUE (Pendapatan Kotor)
          _buildLedgerRow(
            title: 'Total omset penjualan',
            amount: AppFormatters.currency(current.rawOmset),
            isBold: true,
            amountColor: AppColors.brandPrimary,
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildLedgerSubRow(
            title: 'Penerimaan tunai cair',
            amount: AppFormatters.currency(current.cashIn),
            amountColor: AppColors.textPrimary,
          ),
          const SizedBox(height: AppDimensions.space6),
          _buildLedgerSubRow(
            title: 'Utang pelanggan belum dibayar',
            amount: AppFormatters.currency(current.receivable),
            amountColor: AppColors.warningText,
          ),

          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E8F0)),
          const SizedBox(height: AppDimensions.space12),

          // 2. BEBAN POKOK (HPP KULAKAN SPPBE)
          _buildLedgerRow(
            title: 'Kulakan SPPBE (HPP)',
            amount: '-${AppFormatters.currency(current.hpp)}',
            isBold: true,
            amountColor: const Color(0xFFDC2626),
            subtitle: '${AppFormatters.number(current.totalSoldQty)} tabung × Rp 15.750',
          ),

          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: AppDimensions.space10),

          // 3. SUBTOTAL: LABA KOTOR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Text(
                  'Laba kotor penjualan',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                  ),
                ),
                const Spacer(),
                Text(
                  AppFormatters.currency(current.grossProfit),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space10),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: AppDimensions.space12),

          // 4. BIAYA OPERASIONAL
          _buildLedgerRow(
            title: 'Biaya operasional',
            amount: '-${AppFormatters.currency(current.operationalCost)}',
            isBold: true,
            amountColor: const Color(0xFFDC2626),
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildLedgerSubRow(
            title: 'Bensin motor & tossa antar',
            amount: AppFormatters.currency(current.transportCost),
          ),
          const SizedBox(height: AppDimensions.space6),
          _buildLedgerSubRow(
            title: 'Upah & uang makan pekerja',
            amount: AppFormatters.currency(current.laborCost),
          ),
          const SizedBox(height: AppDimensions.space6),
          _buildLedgerSubRow(
            title: 'Lain-lain / operasional depo',
            amount: AppFormatters.currency(current.utilityCost),
          ),

          const SizedBox(height: AppDimensions.space16),
          const Divider(height: 1, thickness: 1.5, color: Color(0xFFCBD5E1)),
          const SizedBox(height: AppDimensions.space12),

          // 5. LABA BERSIH AKHIR (BOTTOM LINE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Untung bersih akhir',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF14432A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Uang bersih setelah kulakan & beban biaya',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+${AppFormatters.currency(current.netProfit)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: Color(0xFF14432A),
                ),
              ),
            ],
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
      crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isBold ? 14.5 : 14,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 15.5 : 14.5,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: amountColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerSubRow({
    required String title,
    required String amount,
    Color? amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          const Text(
            '–',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: amountColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
