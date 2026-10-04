import 'package:flutter/material.dart';
import '../../../core/core.dart';
import 'distribution_form_sheet.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  static final DateTime _now = DateTime.now();
  static final DateTime _today = DateTime(_now.year, _now.month, _now.day);
  static final DateTime _yesterday = _today.subtract(const Duration(days: 1));
  static final DateTime _twoDaysAgo = _today.subtract(const Duration(days: 2));
  static final DateTime _threeDaysAgo = _today.subtract(const Duration(days: 3));
  static final DateTime _fourDaysAgo = _today.subtract(const Duration(days: 4));

  static List<Map<String, dynamic>> get sampleTransactions => [
    // Hari Ini
    {
      'title': 'Warung Madura Pak Joko',
      'qty': 15,
      'items': '15 tabung',
      'date': _today,
      'time': '14:30 WIB',
      'amount': 285000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    {
      'title': 'Toko Berkah Ibu',
      'qty': 20,
      'items': '20 tabung',
      'date': _today,
      'time': '13:15 WIB',
      'amount': 380000,
      'statusType': BadgeType.warning,
      'statusLabel': 'Belum Bayar',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    {
      'title': 'Pangkalan Barokah H. Slamet',
      'qty': 30,
      'items': '30 tabung',
      'date': _today,
      'time': '11:00 WIB',
      'amount': 570000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    // Kemarin
    {
      'title': 'Warung Kelontong Bu Siti',
      'qty': 10,
      'items': '10 tabung',
      'date': _yesterday,
      'time': '15:20 WIB',
      'amount': 190000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    {
      'title': 'RM Padang Sederhana',
      'qty': 25,
      'items': '25 tabung',
      'date': _yesterday,
      'time': '11:10 WIB',
      'amount': 475000,
      'statusType': BadgeType.warning,
      'statusLabel': 'Belum Bayar',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    {
      'title': 'Toko Sembako Berkah Jaya',
      'qty': 35,
      'items': '35 tabung',
      'date': _yesterday,
      'time': '09:00 WIB',
      'amount': 665000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    // 2 Hari Lalu
    {
      'title': 'Warung Makan Sumber Rejeki',
      'qty': 20,
      'items': '20 tabung',
      'date': _twoDaysAgo,
      'time': '14:00 WIB',
      'amount': 380000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    {
      'title': 'Kios Gas Bu Nurul',
      'qty': 15,
      'items': '15 tabung',
      'date': _twoDaysAgo,
      'time': '10:30 WIB',
      'amount': 285000,
      'statusType': BadgeType.warning,
      'statusLabel': 'Belum Bayar',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    // 3 Hari Lalu
    {
      'title': 'Warung Barokah Bu Ani',
      'qty': 12,
      'items': '12 tabung',
      'date': _threeDaysAgo,
      'time': '16:00 WIB',
      'amount': 228000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    {
      'title': 'Toko Klontong Pak De',
      'qty': 18,
      'items': '18 tabung',
      'date': _threeDaysAgo,
      'time': '11:45 WIB',
      'amount': 342000,
      'statusType': BadgeType.warning,
      'statusLabel': 'Belum Bayar',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    // 4 Hari Lalu
    {
      'title': 'Kantin Bu Lestari',
      'qty': 8,
      'items': '8 tabung',
      'date': _fourDaysAgo,
      'time': '13:20 WIB',
      'amount': 152000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
    {
      'title': 'Kedai Kopi Mas Yono',
      'qty': 14,
      'items': '14 tabung',
      'date': _fourDaysAgo,
      'time': '09:10 WIB',
      'amount': 266000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.person_outline,
      'iconColor': AppColors.brandPrimary,
      'iconBg': AppColors.canvas,
    },
  ];

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'Semua';
  String _searchQuery = '';
  late final PagedListController<Map<String, dynamic>> _paginationController;

  @override
  void initState() {
    super.initState();
    _paginationController = PagedListController<Map<String, dynamic>>(
      pageSize: 4,
    );
    _paginationController.addListener(_onPaginationUpdated);
    _syncFilteredData();
  }

  void _onPaginationUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _paginationController.removeListener(_onPaginationUpdated);
    _paginationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    return DistributionScreen.sampleTransactions.where((tx) {
      if (_activeFilter == 'Lunas' && tx['statusLabel'] != 'Lunas') {
        return false;
      }
      if (_activeFilter == 'Belum Bayar' && tx['statusLabel'] != 'Belum Bayar') {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = (tx['title'] as String).toLowerCase();
        final items = (tx['items'] as String).toLowerCase();
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

  String _formatDateHeader(DateTime date) {
    if (date.year == DistributionScreen._today.year &&
        date.month == DistributionScreen._today.month &&
        date.day == DistributionScreen._today.day) {
      return 'Hari Ini, ${AppFormatters.date(date)}';
    } else if (date.year == DistributionScreen._yesterday.year &&
        date.month == DistributionScreen._yesterday.month &&
        date.day == DistributionScreen._yesterday.day) {
      return 'Kemarin, ${AppFormatters.date(date)}';
    } else {
      return '${AppFormatters.dayOfWeek(date)}, ${AppFormatters.date(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Settlement metrics for today
    final todayTxs = DistributionScreen.sampleTransactions.where((tx) {
      final d = tx['date'] as DateTime;
      return d.year == DistributionScreen._today.year &&
          d.month == DistributionScreen._today.month &&
          d.day == DistributionScreen._today.day;
    }).toList();

    final todayTotalQty = todayTxs.fold<int>(0, (sum, tx) => sum + (tx['qty'] as int? ?? 0));
    final todayPaid = todayTxs
        .where((tx) => tx['statusLabel'] == 'Lunas')
        .fold<int>(0, (sum, tx) => sum + (tx['amount'] as int? ?? 0));
    final todayDebt = todayTxs
        .where((tx) => tx['statusLabel'] != 'Lunas')
        .fold<int>(0, (sum, tx) => sum + (tx['amount'] as int? ?? 0));
    final todayMargin = todayTotalQty * 3000;

    // 3. Group visible items by date for pagination chunking
    final visibleTxs = _paginationController.visibleItems;
    final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
    for (final tx in visibleTxs) {
      final date = tx['date'] as DateTime;
      final dateKey = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
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
      body: Column(
        children: [
          // 1. Rekapitulasi Distribusi Hari Ini
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space16,
              AppDimensions.space4,
              AppDimensions.space16,
              AppDimensions.space10,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rekap Distribusi Hari Ini',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$todayTotalQty tabung terdistribusi',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sudah Diterima',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppFormatters.currency(todayPaid),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.brandPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 28, color: AppColors.border),
                      const SizedBox(width: AppDimensions.space10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Belum Dibayar',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppFormatters.currency(todayDebt),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.dangerText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 28, color: AppColors.border),
                      const SizedBox(width: AppDimensions.space10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Keuntungan',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppFormatters.currency(todayMargin),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua'),
                      const SizedBox(width: AppDimensions.space8),
                      _buildFilterChip('Lunas'),
                      const SizedBox(width: AppDimensions.space8),
                      _buildFilterChip('Belum Bayar'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space8),

          // Daftar Transaksi Terkelompok Berdasarkan Tanggal (Chunk Paginated)
          Expanded(
            child: _paginationController.totalCount == 0
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
                : InfiniteScrollListener(
                    onLoadMore: _paginationController.loadMore,
                    isLoadingMore: _paginationController.isLoadingMore,
                    hasMore: _paginationController.hasMore,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.space16,
                        right: AppDimensions.space16,
                        top: AppDimensions.space4,
                        bottom: 96,
                      ),
                      itemCount: sortedDates.length + 1,
                      itemBuilder: (context, index) {
                        if (index == sortedDates.length) {
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
                            0, (sum, tx) => sum + (tx['qty'] as int? ?? 0));
                        final dayAmount = itemsForDay.fold<int>(
                            0, (sum, tx) => sum + (tx['amount'] as int? ?? 0));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: index == 0
                                  ? AppDimensions.space4
                                  : AppDimensions.space16,
                              bottom: AppDimensions.space8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDateHeader(dateKey),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '$dayQty tabung | ${AppFormatters.currency(dayAmount)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...itemsForDay.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.space8),
                              child: FlatTransactionRow(
                                title: item['title'] as String,
                                subtitle: item['items'] as String,
                                amount: AppFormatters.currency(
                                    item['amount'] as int),
                                statusLabel: item['statusLabel'] as String,
                                statusType: item['statusType'] as BadgeType,
                                time: item['time'] as String?,
                                icon: Icons.person_outline,
                                iconColor: item['iconColor'] as Color?,
                                iconBg: item['iconBg'] as Color?,
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = label;
          _syncFilteredData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
