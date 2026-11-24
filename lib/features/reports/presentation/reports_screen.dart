import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../data/reports_repository.dart';
import '../domain/report_models.dart';
import 'widgets/financial_breakdown_card.dart';
import 'widgets/period_picker_sheet.dart';
import 'widgets/report_business_summary_grid.dart';
import 'widgets/report_period_header_bar.dart';
import 'widgets/report_segmented_tabs.dart';

/// Reports & Analytics Screen designed for an individual gas depot owner.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.initialTabIndex});

  final int? initialTabIndex;

  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(2);

  static void switchToTab(BuildContext context, int tabIndex) {
    activeTabNotifier.value = tabIndex;
    context.go('/laporan');
  }

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late int _selectedTabIndex;
  late ReportPeriodSummary _activeSummary;
  bool _isLoading = false;

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await ReportsRepository.instance.fetchLiveReport();
    if (mounted) {
      final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
      setState(() {
        if (options.isNotEmpty) _activeSummary = options.first;
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
          if (options.isNotEmpty) _activeSummary = options.first;
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
        setState(() => _activeSummary = options.first);
      }
    }
  }

  void _onNotifierTabChanged() {
    final newTab = ReportsScreen.activeTabNotifier.value;
    if (_selectedTabIndex != newTab && mounted) {
      setState(() {
        _selectedTabIndex = newTab;
        final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
        if (options.isNotEmpty) _activeSummary = options.first;
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
        if (options.isNotEmpty) _activeSummary = options.first;
      });
    }
  }

  void _onTabChanged(int index) {
    if (_selectedTabIndex == index) return;
    ReportsScreen.activeTabNotifier.value = index;
    setState(() {
      _selectedTabIndex = index;
      final options = ReportsRepository.instance.getOptionsForTab(index);
      if (options.isNotEmpty) _activeSummary = options.first;
    });
  }

  void _showPeriodPickerSheet(BuildContext context) {
    final options = ReportsRepository.instance.getOptionsForTab(_selectedTabIndex);
    PeriodPickerSheet.show(
      context: context,
      options: options,
      activeSummary: _activeSummary,
      onSelected: (summary) => setState(() => _activeSummary = summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _activeSummary;
    final topPadding = MediaQuery.paddingOf(context).top;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.brandPrimary,
      backgroundColor: Colors.white,
      edgeOffset: topPadding,
      child: Scaffold(
        appBar: AppBar(title: const Text('Laporan & Statistik')),
        body: SingleChildScrollView(
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
              ReportSegmentedTabs(
                selectedIndex: _selectedTabIndex,
                onTabChanged: _onTabChanged,
              ),
              const SizedBox(height: AppDimensions.space16),
              if (_selectedTabIndex != 3) ...[
                ReportPeriodHeaderBar(
                  summary: current,
                  onTap: () => _showPeriodPickerSheet(context),
                ),
                const SizedBox(height: AppDimensions.space16),
              ],
              AppSkeletonizer(
                isLoading: _isLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReportBusinessSummaryGrid(summary: current),
                    const SizedBox(height: AppDimensions.space20),
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
}
