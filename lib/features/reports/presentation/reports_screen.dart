import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../data/reports_data.dart';
import '../domain/report_models.dart';

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
  bool _isLoading = false;

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) setState(() => _isLoading = false);
  }

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
        _isLoading = true;
        final options = ReportsData.getOptionsForTab(_selectedTabIndex);
        _activeSummary = options.first;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _isLoading = false);
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
      _isLoading = true;
      final options = ReportsData.getOptionsForTab(index);
      _activeSummary = options.first;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isLoading = false);
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
              setState(() {
                _activeSummary = summary;
                _isLoading = true;
              });
              Navigator.of(context, rootNavigator: true).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) setState(() => _isLoading = false);
              });
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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.brandPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              // Dynamic Report Content Wrapped in AppSkeletonizer
              AppSkeletonizer(
                isLoading: _isLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          child: Skeleton.ignore(
                            child: InkWell(
                              onTap: () => context.push('/piutang'),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // 6. Rincian Keuangan (Auditable Breakdown)
                    _buildFinancialBreakdownCard(context, current),
                  ],
                ),
              ),
              const SizedBox(height: 96),
            ],
          ),
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

  /// Simplified financial breakdown based on depot gas cash flow
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
          // Header: Plain Title (tanpa subteks)
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
            amount: AppFormatters.currency(current.rawOmset),
            isBold: true,
            amountColor: AppColors.brandPrimary,
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildIndicatorSubRow(
            title: 'Penerimaan tunai cair',
            amount: AppFormatters.currency(current.cashIn),
            dotColor: const Color(0xFF16A34A),
            amountColor: AppColors.textPrimary,
          ),
          const SizedBox(height: AppDimensions.space6),
          _buildIndicatorSubRow(
            title: 'Utang pelanggan belum dibayar',
            amount: AppFormatters.currency(current.receivable),
            dotColor: const Color(0xFFD97706),
            amountColor: AppColors.warningText,
          ),

          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: AppDimensions.space12),

          // 2. BEBAN POKOK (HPP KULAKAN SPPBE)
          _buildLedgerRow(
            title: 'Kulakan SPPBE (HPP)',
            amount: '-${AppFormatters.currency(current.hpp)}',
            isBold: true,
            amountColor: const Color(0xFFDC2626),
            subtitle: '${AppFormatters.number(current.totalSoldQty)} tabung × Rp 15.750',
          ),

          const SizedBox(height: AppDimensions.space16),

          // 3. ANCHOR FOOTER: UNTUNG BERSIH AKHIR (Tanpa subteks)
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
                  AppFormatters.currency(current.grossProfit),
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

  // ==========================================
  // SHARED HELPER ROWS
  // ==========================================
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

  Widget _buildIndicatorSubRow({
    required String title,
    required String amount,
    required Color dotColor,
    Color? amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
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
                fontSize: 13,
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
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: amountColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
