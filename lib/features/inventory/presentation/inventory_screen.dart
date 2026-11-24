import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/inventory_repository.dart';
import '../domain/stock_models.dart';
import 'price_setting_sheet.dart';
import 'widgets/inventory_stock_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int get _stockFilled => InventoryRepository.instance.stockSummaryNotifier.value.filled;
  int get _stockEmpty => InventoryRepository.instance.stockSummaryNotifier.value.empty;
  int get _stockLoaned => InventoryRepository.instance.stockSummaryNotifier.value.loaned;
  int get _sellingPrice => InventoryRepository.instance.stockSummaryNotifier.value.sellingPrice;

  static final List<StockLogItem> _skeletonLogs =
      StockLogItem.skeleton();

  final PagedListController<StockLogItem> _paginationController =
      PagedListController<StockLogItem>(
    pageSize: 4,
    initialItems: InventoryRepository.instance.stockLogsNotifier.value,
  );
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    InventoryRepository.instance.stockSummaryNotifier.addListener(_onRepoUpdated);
    InventoryRepository.instance.stockLogsNotifier.addListener(_onRepoUpdated);
    _paginationController.addListener(_onPaginationUpdated);
    _loadInitialData();
  }

  void _onRepoUpdated() {
    if (mounted) {
      _paginationController.setSource(InventoryRepository.instance.stockLogsNotifier.value);
      setState(() {});
    }
  }

  Future<void> _loadInitialData() async {
    if (InventoryRepository.instance.stockLogsNotifier.value.isEmpty) {
      setState(() => _isLoading = true);
      await InventoryRepository.instance.fetchInventory();
      _paginationController.setSource(InventoryRepository.instance.stockLogsNotifier.value);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await InventoryRepository.instance.fetchInventory();
    _paginationController.setSource(InventoryRepository.instance.stockLogsNotifier.value);
    if (mounted) setState(() => _isLoading = false);
  }

  void _onPaginationUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    InventoryRepository.instance.stockSummaryNotifier.removeListener(_onRepoUpdated);
    InventoryRepository.instance.stockLogsNotifier.removeListener(_onRepoUpdated);
    _paginationController.removeListener(_onPaginationUpdated);
    _paginationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleLogs = (_isLoading && _paginationController.visibleItems.isEmpty)
        ? _skeletonLogs
        : _paginationController.visibleItems;
    final grouped = groupItemsByDate<StockLogItem>(
      visibleLogs,
      (tx) => tx.date,
    );
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final topPadding = MediaQuery.paddingOf(context).top;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.brandPrimary,
      backgroundColor: Colors.white,
      edgeOffset: topPadding,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stok Gas'),
        ),
      body: InfiniteScrollListener(
          onLoadMore: _paginationController.loadMore,
          isLoadingMore: _paginationController.isLoadingMore,
          hasMore: _paginationController.hasMore,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space16,
              AppDimensions.space8,
              AppDimensions.space16,
              96,
            ),
            child: AppSkeletonizer(
              isLoading: _isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Ringkasan Fisik Stok 3kg
                  InventoryStockCard(
                    stockFilled: _isLoading && _stockFilled == 0 ? 85 : _stockFilled,
                    stockEmpty: _isLoading && _stockEmpty == 0 ? 30 : _stockEmpty,
                    stockLoaned: _isLoading && _stockLoaned == 0 ? 45 : _stockLoaned,
                    sellingPrice: _isLoading && _sellingPrice == 0 ? 19000 : _sellingPrice,
                    onEditPrice: () => PriceSettingSheet.show(context),
                  ),
            const SizedBox(height: AppDimensions.space20),

            // 2. Riwayat Keluar Masuk Tabung Terkelompok Tanggal
            const Text(
              'Catatan Keluar Masuk Tabung',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.space4),
            if (sortedDates.isEmpty && !_isLoading)
              const AppEmptyState(message: 'Belum ada riwayat stok')
            else
              ...sortedDates.map((dateKey) {
              final itemsForDay = grouped[dateKey]!;
              final masuk = itemsForDay
                  .where((tx) => tx.isMasuk)
                  .fold<int>(0, (sum, tx) => sum + tx.qty);
              final keluar = itemsForDay
                  .where((tx) => !tx.isMasuk)
                  .fold<int>(0, (sum, tx) => sum + tx.qty);

              String summaryText;
              if (masuk > 0 && keluar > 0) {
                summaryText = 'Masuk $masuk | Keluar $keluar';
              } else if (masuk > 0) {
                summaryText = 'Masuk $masuk tabung';
              } else {
                summaryText = 'Keluar $keluar tabung';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateSectionHeader(
                    title: AppFormatters.relativeDateHeader(dateKey),
                    trailingText: summaryText,
                    topPadding: AppDimensions.space12,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: itemsForDay.asMap().entries.map((entry) {
                        final itemIndex = entry.key;
                        final item = entry.value;
                        final isMasuk = item.isMasuk;
                        final qty = item.qty;
                        final isLast = itemIndex == itemsForDay.length - 1;

                        return FlatTransactionRow(
                          title: item.title,
                          subtitle: item.time,
                          amount: isMasuk ? '+$qty tabung' : '-$qty tabung',
                          amountColor: isMasuk
                              ? AppColors.brandSuccess
                              : AppColors.dangerText,
                          statusLabel: isMasuk ? 'Masuk' : 'Keluar',
                          statusType: isMasuk
                              ? BadgeType.success
                              : BadgeType.danger,
                          showDivider: !isLast,
                          icon: isMasuk
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded,
                          iconColor: isMasuk
                              ? AppColors.brandSuccess
                              : AppColors.dangerText,
                          iconBg: AppColors.canvas,
                          iconSize: 18.0,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }),
            if (!_isLoading)
              PaginationLoadingIndicator(
                isLoadingMore: _paginationController.isLoadingMore,
                hasMore: _paginationController.hasMore,
                totalItems: _paginationController.totalCount,
                loadingMessage: 'Memuat catatan pasokan lainnya...',
              ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    ),
  ),
),
);
  }


}
