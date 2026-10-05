import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/distribution_repository.dart';
import '../domain/distribution_model.dart';
import 'distribution_form_sheet.dart';
import 'widgets/distribution_settlement_card.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  static final DateTime _now = DateTime.now();
  static final DateTime _today = DateTime(_now.year, _now.month, _now.day);

  static List<DistributionModel> get liveDistributions =>
      DistributionRepository.instance.distributionsNotifier.value;

  static final List<DistributionModel> _skeletonDistributions =
      DistributionModel.skeleton();

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'Semua';
  String _searchQuery = '';
  final PagedListController<DistributionModel> _paginationController =
      PagedListController<DistributionModel>(
    pageSize: 4,
  );
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    DistributionRepository.instance.distributionsNotifier.addListener(_onRepoUpdated);
    _paginationController.addListener(_onPaginationUpdated);
    _loadInitialData();
  }

  void _onRepoUpdated() {
    if (mounted) {
      _syncFilteredData();
      setState(() {});
    }
  }

  Future<void> _loadInitialData() async {
    if (DistributionRepository.instance.distributionsNotifier.value.isEmpty) {
      setState(() => _isLoading = true);
      await DistributionRepository.instance.fetchDistributions();
      _syncFilteredData();
      if (mounted) setState(() => _isLoading = false);
    } else {
      _syncFilteredData();
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await DistributionRepository.instance.fetchDistributions();
    _syncFilteredData();
    if (mounted) setState(() => _isLoading = false);
  }

  void _onPaginationUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DistributionRepository.instance.distributionsNotifier.removeListener(_onRepoUpdated);
    _paginationController.removeListener(_onPaginationUpdated);
    _paginationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<DistributionModel> _getFilteredTransactions() {
    return DistributionScreen.liveDistributions.where((tx) {
      if (_activeFilter == 'Lunas' && !tx.isPaid) {
        return false;
      }
      if (_activeFilter == 'Belum Bayar' && tx.isPaid) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = tx.customerName.toLowerCase();
        final items = tx.itemsLabel.toLowerCase();
        if (!title.contains(query) && !items.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _syncFilteredData() {
    final filtered = _getFilteredTransactions();
    _paginationController.setSource(filtered);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Settlement metrics for today (purely from live Supabase records)
    final rawTodayTxs = DistributionScreen.liveDistributions.where((tx) {
      final d = tx.date;
      return d.year == DistributionScreen._today.year &&
          d.month == DistributionScreen._today.month &&
          d.day == DistributionScreen._today.day;
    }).toList();
    final todayTxs = rawTodayTxs;

    final todayTotalQty = todayTxs.fold<int>(0, (sum, tx) => sum + tx.qty);
    final todayPaid = todayTxs
        .where((tx) => tx.isPaid)
        .fold<int>(0, (sum, tx) => sum + tx.amount);
    final todayDebt = todayTxs
        .where((tx) => !tx.isPaid)
        .fold<int>(0, (sum, tx) => sum + tx.amount);
    final todayMargin = todayTotalQty * 3000;

    // 3. Group visible items by date for pagination chunking
    final visibleTxs = (_isLoading && _paginationController.visibleItems.isEmpty)
        ? DistributionScreen._skeletonDistributions
        : _paginationController.visibleItems;
    final grouped = groupItemsByDate<DistributionModel>(
      visibleTxs,
      (tx) => tx.date,
    );
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribusi Gas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space16),
            child: ElevatedButton.icon(
              onPressed: () => DistributionFormSheet.show(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Catat Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.brandPrimary,
        child: Column(
          children: [
          // 1. Rekapitulasi Distribusi Hari Ini
          DistributionSettlementCard(
            totalQty: todayTotalQty,
            paidAmount: todayPaid,
            debtAmount: todayDebt,
            marginAmount: todayMargin,
            isLoading: _isLoading,
          ),

          // 2. Filter Bar & Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                      _syncFilteredData();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama pelanggan...',
                    hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _syncFilteredData();
                              });
                            },
                          )
                        : null,
                    isDense: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.space10),
                AppFilterChips<String>(
                  options: const ['Semua', 'Lunas', 'Belum Bayar'],
                  selected: _activeFilter,
                  onSelected: (filter) {
                    setState(() {
                      _activeFilter = filter;
                      _syncFilteredData();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space8),

          // Daftar Transaksi Terkelompok Berdasarkan Tanggal (Chunk Paginated)
          Expanded(
            child: _paginationController.totalCount == 0 && !_isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppDimensions.space24),
                    child: Center(
                      child: Text(
                        'Tidak ada data distribusi yang cocok dengan pencarian / filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ),
                  )
                : AppSkeletonizer(
                    isLoading: _isLoading,
                    child: InfiniteScrollListener(
                      onLoadMore: _paginationController.loadMore,
                      isLoadingMore: _paginationController.isLoadingMore,
                      hasMore: _paginationController.hasMore,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: AppDimensions.space16,
                          right: AppDimensions.space16,
                          top: AppDimensions.space4,
                          bottom: 96,
                        ),
                        itemCount: sortedDates.length + 1,
                        itemBuilder: (context, index) {
                          if (index == sortedDates.length) {
                            if (_isLoading) return const SizedBox.shrink();
                            return PaginationLoadingIndicator(
                              isLoadingMore: _paginationController.isLoadingMore,
                              hasMore: _paginationController.hasMore,
                              totalItems: _paginationController.totalCount,
                              loadingMessage: 'Memuat data distribusi lainnya...',
                              endMessage: 'Semua data distribusi telah ditampilkan',
                            );
                          }
                          final dateKey = sortedDates[index];
                          final itemsForDay = grouped[dateKey]!;
                          final dayQty = itemsForDay.fold<int>(
                              0, (sum, tx) => sum + tx.qty);
                          final dayAmount = itemsForDay.fold<int>(
                              0, (sum, tx) => sum + tx.amount);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DateSectionHeader(
                                title: AppFormatters.relativeDateHeader(dateKey),
                                trailingText: '$dayQty tabung | ${AppFormatters.currency(dayAmount)}',
                                topPadding: index == 0
                                    ? AppDimensions.space4
                                    : AppDimensions.space16,
                              ),
                              ...itemsForDay.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppDimensions.space8),
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
                            ],
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
  }


}
