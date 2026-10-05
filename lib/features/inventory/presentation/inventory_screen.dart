import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/inventory_repository.dart';
import '../domain/stock_models.dart';
import 'price_setting_sheet.dart';
import 'restock_form_sheet.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Gas'),
        actions: [
          IconButton(
            tooltip: 'Catat Pasokan',
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () => RestockFormSheet.show(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.brandPrimary,
        child: InfiniteScrollListener(
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
                    stockFilled: _stockFilled,
                    stockEmpty: _stockEmpty,
                    stockLoaned: _stockLoaned,
                    sellingPrice: _sellingPrice,
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
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: const Text(
                  'Belum ada catatan mutasi tabung',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              )
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
                  ...itemsForDay.map((item) {
                    final isMasuk = item.isMasuk;
                    final qty = item.qty;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                      child: FlatTransactionRow(
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
                        icon: isMasuk ? Icons.south_west : Icons.north_east,
                        iconColor: AppColors.brandPrimary,
                        iconBg: AppColors.canvas,
                      ),
                    );
                  }),
                ],
              );
            }),
            if (!_isLoading)
              PaginationLoadingIndicator(
                isLoadingMore: _paginationController.isLoadingMore,
                hasMore: _paginationController.hasMore,
                totalItems: _paginationController.totalCount,
                loadingMessage: 'Memuat catatan pasokan lainnya...',
                endMessage: 'Semua catatan pasokan telah ditampilkan',
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
