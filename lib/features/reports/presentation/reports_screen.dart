import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../data/reports_repository.dart';
import '../domain/report_models.dart';
import 'widgets/financial_breakdown_card.dart';
import 'widgets/period_picker_sheet.dart';
import 'widgets/report_metric_card.dart';

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
    await ReportsRepository.instance.fetchLiveReport();
    if (mounted) {
      final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
      setState(() {
        if (options.isNotEmpty) {
          _activeSummary = options.first;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex ?? ReportsScreen.activeTabNotifier.value;
    ReportsScreen.activeTabNotifier.addListener(_onNotifierTabChanged);
    ReportsRepository.instance.liveSummaryNotifier.addListener(_onLiveReportUpdated);
    final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
    if (options.isNotEmpty) {
      _activeSummary = options.first;
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (ReportsRepository.instance.liveSummaryNotifier.value == null) {
      setState(() => _isLoading = true);
      await ReportsRepository.instance.fetchLiveReport();
      if (mounted) {
        final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
        setState(() {
          if (options.isNotEmpty) {
            _activeSummary = options.first;
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    ReportsScreen.activeTabNotifier.removeListener(_onNotifierTabChanged);
    ReportsRepository.instance.liveSummaryNotifier.removeListener(_onLiveReportUpdated);
    super.dispose();
  }

  void _onLiveReportUpdated() {
    if (mounted) {
      final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
      if (options.isNotEmpty) {
        setState(() {
          _activeSummary = options.first;
        });
      }
    }
  }

  void _onNotifierTabChanged() {
    final newTab = ReportsScreen.activeTabNotifier.value;
    if (_selectedTabIndex != newTab && mounted) {
      setState(() {
        _selectedTabIndex = newTab;
        final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
        if (options.isNotEmpty) {
          _activeSummary = options.first;
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != null && widget.initialTabIndex != _selectedTabIndex) {
      setState(() {
        _selectedTabIndex = widget.initialTabIndex!;
        final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
        if (options.isNotEmpty) {
          _activeSummary = options.first;
        }
      });
    }
  }

  void _onTabChanged(int index) {
    if (_selectedTabIndex == index) return;
    ReportsScreen.activeTabNotifier.value = index;
    setState(() {
      _selectedTabIndex = index;
      final options = ReportsRepository.instance.getOptionsForTab(index);
      if (options.isNotEmpty) {
        _activeSummary = options.first;
      }
    });
  }

  void _showPeriodPickerSheet(BuildContext context) {
    final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
    PeriodPickerSheet.show(
      context: context,
      options: options,
      activeSummary: _activeSummary,
      onSelected: (summary) {
        setState(() {
          _activeSummary = summary;
        });
      },
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
                          child: ReportMetricCard(
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
                          child: ReportMetricCard(
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
                          child: ReportMetricCard(
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
                              child: ReportMetricCard(
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
                    FinancialBreakdownCard(summary: current),
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


}
