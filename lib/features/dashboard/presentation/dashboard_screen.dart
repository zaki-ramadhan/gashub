import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../data/dashboard_repository.dart';
import '../../customers/data/customers_repository.dart';
import '../../customers/presentation/widgets/top_customers_card.dart';
import '../../distribution/data/distribution_repository.dart';
import 'widgets/cashflow_history_sheet.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_recent_sales_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const double _headerGradientHeight = 180;

  bool _isLoading = false;
  late bool _hasLoadedOnce;

  int get _netCashflow => DashboardRepository.instance.cashflowSummaryNotifier.value.netCashflow;
  int get _cashIn => DashboardRepository.instance.cashflowSummaryNotifier.value.cashIn;
  int get _cashOut => DashboardRepository.instance.cashflowSummaryNotifier.value.cashOut;

  @override
  void initState() {
    super.initState();
    _hasLoadedOnce = CustomersRepository.instance.customersNotifier.value.isNotEmpty ||
        DistributionRepository.instance.distributionsNotifier.value.isNotEmpty;
    DashboardRepository.instance.cashflowSummaryNotifier.addListener(_onRepoUpdated);
    DistributionRepository.instance.distributionsNotifier.addListener(_onRepoUpdated);
    CustomersRepository.instance.customersNotifier.addListener(_onRepoUpdated);
    _loadInitialData();
  }

  void _onRepoUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInitialData() async {
    if (!_hasLoadedOnce) {
      setState(() => _isLoading = true);
    }
    try {
      await Future.wait([
        DashboardRepository.instance.fetchDashboardMetrics(),
        DashboardRepository.instance.fetchCashflowEntries(),
        DistributionRepository.instance.fetchDistributions(),
        CustomersRepository.instance.fetchCustomers(),
      ]).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Dashboard _loadInitialData error/timeout: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    try {
      await Future.wait([
        DashboardRepository.instance.fetchDashboardMetrics(),
        DashboardRepository.instance.fetchCashflowEntries(),
        DistributionRepository.instance.fetchDistributions(),
        CustomersRepository.instance.fetchCustomers(),
      ]).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Dashboard _handleRefresh error/timeout: $e');
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    DashboardRepository.instance.cashflowSummaryNotifier.removeListener(_onRepoUpdated);
    DistributionRepository.instance.distributionsNotifier.removeListener(_onRepoUpdated);
    CustomersRepository.instance.customersNotifier.removeListener(_onRepoUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final showSkeleton = _isLoading && !_hasLoadedOnce;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.brandPrimary,
      backgroundColor: Colors.white,
      edgeOffset: topPadding,
      child: Scaffold(
        appBar: const DashboardAppBar(),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Stack(
            children: [
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _headerGradientHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.brandPrimary, AppColors.canvas],
                      stops: [0.2, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonizer(
                      isLoading: showSkeleton,
                      child: MetricHeroCard(
                        netCashflow: _netCashflow,
                        cashIn: _cashIn,
                        cashOut: _cashOut,
                        onCheckStock: () => context.go('/stok'),
                        onReceivables: () => context.push('/piutang'),
                        onCustomers: () => context.push('/warung'),
                        onCashInTap: () => CashflowHistorySheet.show(context, initialFilter: 'Masuk'),
                        onCashOutTap: () => CashflowHistorySheet.show(context, initialFilter: 'Keluar'),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    TopCustomersCard(maxCount: 3, showSkeleton: showSkeleton),
                    const SizedBox(height: AppDimensions.space16),
                    DashboardRecentSalesSection(showSkeleton: showSkeleton),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
