import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/receivables_repository.dart';
import '../domain/receivable_model.dart';
import 'receivable_payment_sheet.dart';
import 'widgets/receivables_hero_card.dart';

class ReceivablesScreen extends StatefulWidget {
  const ReceivablesScreen({super.key});

  @override
  State<ReceivablesScreen> createState() => _ReceivablesScreenState();
}

class _ReceivablesScreenState extends State<ReceivablesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'Semua';
  final PagedListController<ReceivableModel> _paginationController =
      PagedListController<ReceivableModel>(
    pageSize: 4,
  );
  bool _isLoading = false;

  static final List<ReceivableModel> _skeletonReceivables =
      ReceivableModel.skeleton();

  @override
  void initState() {
    super.initState();
    ReceivablesRepository.instance.receivablesNotifier.addListener(_onRepoUpdated);
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
    if (ReceivablesRepository.instance.receivablesNotifier.value.isEmpty) {
      setState(() => _isLoading = true);
      await ReceivablesRepository.instance.fetchReceivables();
      _syncFilteredData();
      if (mounted) setState(() => _isLoading = false);
    } else {
      _syncFilteredData();
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await ReceivablesRepository.instance.fetchReceivables();
    _syncFilteredData();
    if (mounted) setState(() => _isLoading = false);
  }

  void _onPaginationUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ReceivablesRepository.instance.receivablesNotifier.removeListener(_onRepoUpdated);
    _paginationController.removeListener(_onPaginationUpdated);
    _paginationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ReceivableModel> _getFilteredData() {
    return _receivablesData.where((item) {
      if (_activeFilter == 'Belum Bayar' && item.statusLabel != 'Belum Bayar') {
        return false;
      }
      if (_activeFilter == 'Cicilan Sebagian' && item.statusLabel != 'Cicilan Sebagian') {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = item.customerName.toLowerCase();
        final inv = item.invoiceNumber.toLowerCase();
        if (!name.contains(query) && !inv.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _syncFilteredData() {
    final filtered = _getFilteredData();
    _paginationController.setSource(filtered);
  }

  static List<ReceivableModel> get _receivablesData =>
      ReceivablesRepository.instance.receivablesNotifier.value;

  @override
  Widget build(BuildContext context) {
    final filtered = _receivablesData.where((item) {
      if (_activeFilter == 'Belum Bayar' && item.statusLabel != 'Belum Bayar') {
        return false;
      }
      if (_activeFilter == 'Cicilan Sebagian' && item.statusLabel != 'Cicilan Sebagian') {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = item.customerName.toLowerCase();
        final inv = item.invoiceNumber.toLowerCase();
        if (!name.contains(query) && !inv.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    final totalOutstanding = filtered.fold<int>(0, (sum, i) => sum + i.remainingAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Utang'),
        titleSpacing: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.brandPrimary,
        child: InfiniteScrollListener(
          onLoadMore: _paginationController.loadMore,
          isLoadingMore: _paginationController.isLoadingMore,
          hasMore: _paginationController.hasMore,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Total Piutang Highlight Card
              SliverToBoxAdapter(
                child: ReceivablesHeroCard(
                  totalOutstanding: totalOutstanding,
                  activeCount: filtered.length,
                  isLoading: _isLoading,
                ),
              ),

              // 2. Search & Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 14),
                        inputFormatters: [AppInputFormatters.cleanText],
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                            _syncFilteredData();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari nama pelanggan...',
                          hintStyle: const TextStyle(
                              fontSize: 14, color: AppColors.textMuted),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 12, right: 8),
                            child: Icon(Icons.search,
                                size: 20, color: AppColors.textMuted),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 40, minHeight: 40),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      size: 18, color: AppColors.textMuted),
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
                        options: const [
                          'Semua',
                          'Belum Bayar',
                          'Cicilan Sebagian'
                        ],
                        selected: _activeFilter,
                        onSelected: (filter) {
                          setState(() {
                            _activeFilter = filter;
                            _syncFilteredData();
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.space8),
                    ],
                  ),
                ),
              ),

              // 3. Daftar Pelanggan Berhutang (Chunk Paginated)
              if (_paginationController.totalCount == 0 && !_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Tidak ada data piutang yang cocok.',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                AppSkeletonizer.sliver(
                  isLoading: _isLoading,
                  child: Builder(
                    builder: (context) {
                      final displayItems = (_isLoading &&
                              _paginationController.visibleItems.isEmpty)
                          ? _skeletonReceivables
                          : _paginationController.visibleItems;

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.space16,
                          0,
                          AppDimensions.space16,
                          96,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == displayItems.length) {
                                if (_isLoading) return const SizedBox.shrink();
                                return PaginationLoadingIndicator(
                                  isLoadingMore:
                                      _paginationController.isLoadingMore,
                                  hasMore: _paginationController.hasMore,
                                  totalItems: _paginationController.totalCount,
                                  loadingMessage:
                                      'Memuat data utang lainnya...',
                                  endMessage:
                                      'Semua data utang telah ditampilkan',
                                );
                              }
                              final item = displayItems[index];

                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppDimensions.space8),
                                child: FlatTransactionRow(
                                  title: item.customerName,
                                  subtitle: AppFormatters.date(item.date),
                                  subtitleColor: AppColors.textMuted,
                                  amount: AppFormatters.currency(
                                      item.remainingAmount),
                                  amountColor: AppColors.dangerText,
                                  statusLabel: item.statusLabel,
                                  statusType: item.statusType,
                                  icon: Icons.person_outline,
                                  iconColor: AppColors.brandPrimary,
                                  iconBg: AppColors.canvas,
                                  trailingAction: Skeleton.ignore(
                                    child: InkWell(
                                      onTap: _isLoading
                                          ? null
                                          : () => ReceivablePaymentSheet.show(
                                              context: context, item: item),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        child: Text(
                                          'Bayar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.brandPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: displayItems.length + 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
  );
  }


}
