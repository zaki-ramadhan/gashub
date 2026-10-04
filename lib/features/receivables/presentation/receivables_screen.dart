import 'package:flutter/material.dart';
import '../../../core/core.dart';

class ReceivablesScreen extends StatefulWidget {
  const ReceivablesScreen({super.key});

  @override
  State<ReceivablesScreen> createState() => _ReceivablesScreenState();
}

class _ReceivablesScreenState extends State<ReceivablesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'Semua';
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

  List<Map<String, dynamic>> _getFilteredData() {
    return _receivablesData.where((item) {
      if (_activeFilter == 'Belum Bayar' && item['statusLabel'] != 'Belum Bayar') {
        return false;
      }
      if (_activeFilter == 'Cicilan Sebagian' && item['statusLabel'] != 'Cicilan Sebagian') {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (item['customer'] as String).toLowerCase();
        final inv = (item['invoice'] as String).toLowerCase();
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

  static final List<Map<String, dynamic>> _receivablesData = [
    {
      'customer': 'Warung Barokah (Pak Slamet)',
      'phone': '0812-3456-7890',
      'remaining': 1250000,
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'invoice': '#DST-202610-001',
      'statusLabel': 'Belum Bayar',
      'statusType': BadgeType.danger,
    },
    {
      'customer': 'Toko Berkah Ibu',
      'phone': '0813-9876-5432',
      'remaining': 380000,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'invoice': '#DST-202610-002',
      'statusLabel': 'Cicilan Sebagian',
      'statusType': BadgeType.warning,
    },
    {
      'customer': 'Warung Kelontong Bu Siti',
      'phone': '0857-1122-3344',
      'remaining': 190000,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'invoice': '#DST-202610-004',
      'statusLabel': 'Belum Bayar',
      'statusType': BadgeType.danger,
    },
    {
      'customer': 'RM Padang Sederhana',
      'phone': '0821-4455-6677',
      'remaining': 860000,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'invoice': '#DST-202610-005',
      'statusLabel': 'Belum Bayar',
      'statusType': BadgeType.danger,
    },
    {
      'customer': 'Kios Gas Bu Nurul',
      'phone': '0812-8877-6655',
      'remaining': 285000,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'invoice': '#DST-202610-008',
      'statusLabel': 'Belum Bayar',
      'statusType': BadgeType.danger,
    },
    {
      'customer': 'Toko Klontong Pak De',
      'phone': '0852-3344-5566',
      'remaining': 342000,
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'invoice': '#DST-202610-009',
      'statusLabel': 'Belum Bayar',
      'statusType': BadgeType.danger,
    },
    {
      'customer': 'Kantin Bu Lestari',
      'phone': '0878-9900-1122',
      'remaining': 152000,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'invoice': '#DST-202610-011',
      'statusLabel': 'Cicilan Sebagian',
      'statusType': BadgeType.warning,
    },
    {
      'customer': 'Kedai Kopi Mas Yono',
      'phone': '0819-2233-4455',
      'remaining': 266000,
      'date': DateTime.now().subtract(const Duration(days: 8)),
      'invoice': '#DST-202610-012',
      'statusLabel': 'Belum Bayar',
      'statusType': BadgeType.danger,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _receivablesData.where((item) {
      if (_activeFilter == 'Belum Bayar' && item['statusLabel'] != 'Belum Bayar') {
        return false;
      }
      if (_activeFilter == 'Cicilan Sebagian' && item['statusLabel'] != 'Cicilan Sebagian') {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (item['customer'] as String).toLowerCase();
        final inv = (item['invoice'] as String).toLowerCase();
        if (!name.contains(query) && !inv.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    final totalOutstanding = filtered.fold<int>(0, (sum, i) => sum + (i['remaining'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Utang'),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // 1. Total Piutang Highlight Card (Clean surface, no harsh green block)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space16,
              AppDimensions.space4,
              AppDimensions.space16,
              AppDimensions.space12,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total utang belum lunas',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                      StatusBadge(label: 'Perlu Ditagih', type: BadgeType.warning),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    AppFormatters.currency(totalOutstanding),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dangerText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dari ${filtered.length} transaksi pelanggan aktif',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),

          // 2. Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
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
                      _buildFilterChip('Belum Bayar'),
                      const SizedBox(width: AppDimensions.space8),
                      _buildFilterChip('Cicilan Sebagian'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space8),

          // 3. Daftar Pelanggan Berhutang (Chunk Paginated)
          Expanded(
            child: _paginationController.totalCount == 0
                ? const Center(
                    child: Text(
                      'Tidak ada data piutang yang cocok.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  )
                : InfiniteScrollListener(
                    onLoadMore: _paginationController.loadMore,
                    isLoadingMore: _paginationController.isLoadingMore,
                    hasMore: _paginationController.hasMore,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.space16,
                        0,
                        AppDimensions.space16,
                        96,
                      ),
                      itemCount: _paginationController.visibleItems.length + 1,
                      separatorBuilder: (context, index) =>
                          index < _paginationController.visibleItems.length - 1
                              ? const SizedBox(height: AppDimensions.space8)
                              : const SizedBox.shrink(),
                      itemBuilder: (context, index) {
                        if (index == _paginationController.visibleItems.length) {
                          return PaginationLoadingIndicator(
                            isLoadingMore: _paginationController.isLoadingMore,
                            hasMore: _paginationController.hasMore,
                            totalItems: _paginationController.totalCount,
                            loadingMessage: 'Memuat data utang lainnya...',
                            endMessage: 'Semua data utang telah ditampilkan',
                          );
                        }
                        final item = _paginationController.visibleItems[index];
                        final date = item['date'] as DateTime;

                        return FlatTransactionRow(
                          title: item['customer'] as String,
                          subtitle: AppFormatters.date(date),
                          subtitleColor: AppColors.textMuted,
                          amount: AppFormatters.currency(item['remaining'] as int),
                          amountColor: AppColors.dangerText,
                          statusLabel: item['statusLabel'] as String,
                          statusType: item['statusType'] as BadgeType,
                          trailingAction: InkWell(
                            onTap: () => _showPaymentSheet(context, item),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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

  void _showPaymentSheet(BuildContext context, Map<String, dynamic> item) {
    final payController = TextEditingController(text: '');
    final int totalDebt = item['remaining'] as int;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final enteredAmount = AppInputFormatters.parseNumber(payController.text);
            final remainingAfter = totalDebt - enteredAmount;
            final bool isOverpaid = enteredAmount > totalDebt;

            return AppBottomSheet(
              title: 'Catat Bayar Utang',
              bottomAction: AppButton(
                text: 'Simpan Pembayaran',
                isLoading: isSaving,
                onPressed: () async {
                  if (enteredAmount <= 0) {
                    AppToast.warning(title: 'Masukkan nominal pembayaran');
                    return;
                  }
                  if (isOverpaid) {
                    AppToast.warning(title: 'Nominal melebihi sisa utang');
                    return;
                  }

                  setSheetState(() => isSaving = true);
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (!ctx.mounted) return;

                    setState(() {
                      final newRemaining = totalDebt - enteredAmount;
                      item['remaining'] = newRemaining;
                      if (newRemaining == 0) {
                        item['statusLabel'] = 'Lunas';
                        item['statusType'] = BadgeType.success;
                      } else {
                        item['statusLabel'] = 'Cicilan Sebagian';
                        item['statusType'] = BadgeType.warning;
                      }
                      _syncFilteredData();
                    });

                  Navigator.of(ctx, rootNavigator: true).pop();
                  AppToast.success(
                    title: enteredAmount == totalDebt
                        ? 'Utang berhasil dilunasi'
                        : 'Cicilan berhasil disimpan',
                  );
                },
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Info Pelanggan & Utang (Teks biasa tanpa banner / card)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['customer'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item['invoice']} • ${AppFormatters.date(item['date'] as DateTime)}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Sisa utang saat ini',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppFormatters.currency(totalDebt),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dangerText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space12),
                  const Divider(height: 1, thickness: 1, color: AppColors.border),
                  const SizedBox(height: AppDimensions.space16),

                  // 2. Nominal Pembayaran Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nominal yang dibayar (Rp)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          payController.text = AppFormatters.number(totalDebt);
                          setSheetState(() {});
                        },
                        child: const Text(
                          'Lunasi Penuh',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: payController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [AppInputFormatters.thousands],
                    onChanged: (_) => setSheetState(() {}),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. Status Kalkulasi Pembayaran / Cicilan Live
                  if (enteredAmount == 0)
                    const Text(
                      'Ketik nominal yang dibayar pelanggan (bisa cicilan atau lunas).',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    )
                  else if (isOverpaid)
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.dangerText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Nominal melebihi sisa utang (${AppFormatters.currency(totalDebt)})',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dangerText,
                          ),
                        ),
                      ],
                    )
                  else if (enteredAmount == totalDebt)
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Pelunasan penuh • Sisa utang: Rp 0 (Lunas)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD97706),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Cicilan sebagian • Sisa utang nanti: ${AppFormatters.currency(remainingAfter)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.warningText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
