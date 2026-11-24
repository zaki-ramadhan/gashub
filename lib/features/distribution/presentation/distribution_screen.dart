import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/distribution_repository.dart';
import '../domain/distribution_model.dart';
import 'widgets/distribution_day_group_card.dart';
import 'widgets/distribution_filter_header.dart';
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
  final AppDebouncer _searchDebouncer = AppDebouncer(duration: const Duration(milliseconds: 300));
  String _activeFilter = 'Semua';
  String _searchQuery = '';
  final PagedListController<DistributionModel> _paginationController =
      PagedListController<DistributionModel>(pageSize: 8);
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
    _searchDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<DistributionModel> _getFilteredTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));

    return DistributionScreen.liveDistributions.where((tx) {
      if (_activeFilter == 'Hari Ini') {
        final d = tx.date;
        if (d.year != today.year || d.month != today.month || d.day != today.day) {
          return false;
        }
      } else if (_activeFilter == 'Minggu Ini') {
        if (tx.date.isBefore(startOfWeek)) return false;
      } else if (_activeFilter == 'Bulan Ini') {
        if (tx.date.year != now.year || tx.date.month != now.month) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = tx.customerName.toLowerCase();
        final items = tx.itemsLabel.toLowerCase();
        if (!title.contains(query) && !items.contains(query)) return false;
      }
      return true;
    }).toList();
  }

  void _syncFilteredData() {
    _paginationController.setSource(_getFilteredTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final todayTxs = DistributionScreen.liveDistributions.where((tx) {
      final d = tx.date;
      return d.year == DistributionScreen._today.year &&
          d.month == DistributionScreen._today.month &&
          d.day == DistributionScreen._today.day;
    }).toList();

    final todayTotalQty = todayTxs.fold<int>(0, (sum, tx) => sum + tx.qty);
    final todayTotalSales = todayTxs.fold<int>(0, (sum, tx) => sum + tx.amount);
    final todayTotalCost = todayTxs.fold<int>(0, (sum, tx) => sum + tx.totalCost);
    final todayNetMargin = todayTotalSales - todayTotalCost;

    final visibleTxs = (_isLoading && _paginationController.visibleItems.isEmpty)
        ? DistributionScreen._skeletonDistributions
        : _paginationController.visibleItems;
    final grouped = groupItemsByDate<DistributionModel>(visibleTxs, (tx) => tx.date);
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final topPadding = MediaQuery.paddingOf(context).top;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.brandPrimary,
      backgroundColor: Colors.white,
      edgeOffset: topPadding,
      child: Scaffold(
        appBar: AppBar(title: const Text('Penjualan Gas')),
        body: InfiniteScrollListener(
          onLoadMore: _paginationController.loadMore,
          isLoadingMore: _paginationController.isLoadingMore,
          hasMore: _paginationController.hasMore,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: DistributionSettlementCard(
                  totalQty: todayTotalQty,
                  totalSales: todayTotalSales,
                  totalCost: todayTotalCost,
                  netMargin: todayNetMargin,
                  isLoading: _isLoading,
                ),
              ),
              SliverToBoxAdapter(
                child: DistributionFilterHeader(
                  searchController: _searchController,
                  hasQuery: _searchQuery.isNotEmpty,
                  activeFilter: _activeFilter,
                  onSearchChanged: (val) {
                    _searchDebouncer.run(() {
                      if (mounted) {
                        setState(() {
                          _searchQuery = val.trim();
                          _syncFilteredData();
                        });
                      }
                    });
                  },
                  onSearchClear: () {
                    _searchDebouncer.cancel();
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _syncFilteredData();
                    });
                  },
                  onFilterSelected: (filter) {
                    setState(() {
                      _activeFilter = filter;
                      _syncFilteredData();
                    });
                  },
                ),
              ),
              if (_paginationController.totalCount == 0 && !_isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    message: _activeFilter == 'Semua' && _searchQuery.isEmpty
                        ? 'Belum ada penjualan'
                        : 'Penjualan tidak ditemukan',
                    actionLabel: _searchQuery.isNotEmpty ? 'Reset pencarian' : null,
                    onAction: _searchQuery.isNotEmpty
                        ? () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _syncFilteredData();
                          }
                        : null,
                  ),
                )
              else
                AppSkeletonizer.sliver(
                  isLoading: _isLoading,
                  child: SliverPadding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.space16,
                      right: AppDimensions.space16,
                      top: AppDimensions.space4,
                      bottom: 96,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == sortedDates.length) {
                            if (_isLoading) return const SizedBox.shrink();
                            return PaginationLoadingIndicator(
                              isLoadingMore: _paginationController.isLoadingMore,
                              hasMore: _paginationController.hasMore,
                              totalItems: _paginationController.totalCount,
                              loadingMessage: 'Memuat data penjualan lainnya...',
                            );
                          }
                          final dateKey = sortedDates[index];
                          final itemsForDay = grouped[dateKey]!;
                          return DistributionDayGroupCard(
                            dateKey: dateKey,
                            items: itemsForDay,
                            isFirst: index == 0,
                          );
                        },
                        childCount: sortedDates.length + 1,
                      ),
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
