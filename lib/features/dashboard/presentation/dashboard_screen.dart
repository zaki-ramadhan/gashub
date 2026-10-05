import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../data/dashboard_repository.dart';
import '../../distribution/data/distribution_repository.dart';
import '../../distribution/domain/distribution_model.dart';
import '../../distribution/presentation/distribution_form_sheet.dart';
import '../../inventory/presentation/price_setting_sheet.dart';
import '../../inventory/presentation/restock_form_sheet.dart';
import '../../reports/presentation/expense_form_sheet.dart';
import 'widgets/dashboard_quick_tools.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Gradient ends roughly at the vertical middle of MetricHeroCard.
  static const double _headerGradientHeight = 180;

  bool _isLoading = false;

  int get _netCashflow => DashboardRepository.instance.cashflowSummaryNotifier.value.netCashflow;
  int get _cashIn => DashboardRepository.instance.cashflowSummaryNotifier.value.cashIn;
  int get _cashOut => DashboardRepository.instance.cashflowSummaryNotifier.value.cashOut;

  @override
  void initState() {
    super.initState();
    DashboardRepository.instance.cashflowSummaryNotifier.addListener(_onRepoUpdated);
    DistributionRepository.instance.distributionsNotifier.addListener(_onRepoUpdated);
    _loadInitialData();
  }

  void _onRepoUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      DashboardRepository.instance.fetchDashboardMetrics(),
      DistributionRepository.instance.fetchDistributions(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.wait([
      DashboardRepository.instance.fetchDashboardMetrics(),
      DistributionRepository.instance.fetchDistributions(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    DashboardRepository.instance.cashflowSummaryNotifier.removeListener(_onRepoUpdated);
    DistributionRepository.instance.distributionsNotifier.removeListener(_onRepoUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: AppColors.brandPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        titleSpacing: AppDimensions.space16,
        title: Builder(
          builder: (context) {
            final now = DateTime.now();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppFormatters.dayOfWeek(now),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.fullDate(now),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.15,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space16),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.notifications_none,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  AppToast.info(title: 'Tidak ada notifikasi baru');
                },
                tooltip: 'Notifikasi',
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.brandPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Stack(
            children: [
              Positioned(
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
                child: AppSkeletonizer(
                  isLoading: _isLoading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Focal Hero Balance Card
                      MetricHeroCard(
                        netCashflow: _netCashflow,
                        cashIn: _cashIn,
                        cashOut: _cashOut,
                        onDistribute: () => DistributionFormSheet.show(context),
                        onRestock: () => RestockFormSheet.show(context),
                        onExpense: () => ExpenseFormSheet.show(context),
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      // 2. Secondary Quick Tools Card (4 Menu Pendukung Utama)
                      DashboardQuickTools(
                        onCatatUtang: () => context.push('/piutang'),
                        onStokGas: () => context.go('/stok'),
                        onPelanggan: () => context.push('/warung'),
                        onAturHarga: () => PriceSettingSheet.show(context),
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // 3. Recent Transaction Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Distribusi Terkini',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Skeleton.ignore(
                            child: InkWell(
                              onTap: () => context.go('/distribusi'),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusPill,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusPill,
                                  ),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Text(
                                  'Lihat semua',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.brandPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space10),

                      // 4. Standalone Pill-Shaped Transaction Cards
                      if (!_isLoading && DistributionRepository.instance.distributionsNotifier.value.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          alignment: Alignment.center,
                          child: const Text(
                            'Belum ada transaksi distribusi tercatat',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        )
                      else
                        ...((_isLoading && DistributionRepository.instance.distributionsNotifier.value.isEmpty)
                                ? DistributionModel.skeleton()
                                : DistributionRepository.instance.distributionsNotifier.value.take(3))
                            .map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                            child: FlatTransactionRow(
                              title: item.customerName,
                              subtitle: item.itemsLabel,
                              amount: AppFormatters.currency(item.amount),
                              statusLabel: item.statusLabel,
                              statusType: item.statusType,
                              time: item.time,
                              icon: Icons.person_outline,
                              iconColor: AppColors.brandPrimary,
                              iconBg: AppColors.canvas,
                            ),
                          );
                        }),
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
