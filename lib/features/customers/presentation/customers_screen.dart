import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/customers_repository.dart';
import '../domain/customer_model.dart';
import 'customer_detail_sheet.dart';

/// Screen listing partner stores & customers with search, debt status, and detailed history.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({
    super.key,
    this.initialFilter,
  });

  final String? initialFilter;

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  final _searchDebouncer = AppDebouncer(duration: const Duration(milliseconds: 300));
  String _searchQuery = '';
  late String _activeFilter;
  bool _isLoading = false;

  static final List<CustomerModel> _placeholderCustomers = List.generate(
    6,
    (i) => CustomerModel(
      id: 'placeholder_$i',
      name: i == 0
          ? 'Pangkalan Barokah H. Slamet'
          : (i == 1 ? 'Warung Madura Pak Joko' : 'Toko Kelontong Berkah Ibu Ani'),
      owner: i.isEven ? 'H. Slamet' : 'Pak Joko',
      phone: '0812-3456-7890',
      address: 'Jl. Raya Kp. Melayu No. 45',
      activeDebt: i.isEven ? 475000 : 0,
      totalCylinders: (i + 1) * 15,
      lastOrderDate: DateTime.now(),
      transactions: const [],
    ),
  );

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialFilter ?? 'Semua';
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (CustomersRepository.instance.customersNotifier.value.isEmpty) {
      setState(() => _isLoading = true);
      await CustomersRepository.instance.fetchCustomers();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await CustomersRepository.instance.fetchCustomers();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.brandPrimary,
      backgroundColor: Colors.white,
      edgeOffset: topPadding,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Pelanggan'),
        ),
      body: ValueListenableBuilder<List<CustomerModel>>(
          valueListenable: CustomersRepository.instance.customersNotifier,
          builder: (context, allCustomers, _) {
            final filtered = CustomersRepository.instance.searchCustomers(
              query: _searchQuery,
              filter: _activeFilter,
            );

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Search Bar & Status Counter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSearchBar(
                          controller: _searchController,
                          hintText: 'Cari nama pelanggan...',
                          hasQuery: _searchQuery.isNotEmpty,
                          onChanged: (val) {
                            _searchDebouncer.run(() {
                              if (mounted) {
                                setState(() => _searchQuery = val.trim());
                              }
                            });
                          },
                          onClear: () {
                            _searchDebouncer.cancel();
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                        const SizedBox(height: AppDimensions.space10),

                        // Filter Chips
                        AppFilterChips<String>(
                          options: const ['Semua', 'Ada Utang', 'Paling Banyak Order'],
                          selected: _activeFilter,
                          onSelected: (filter) =>
                              setState(() => _activeFilter = filter),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                      ],
                    ),
                  ),
                ),

                // 2. Daftar Warung / Pelanggan / Empty State
                if (filtered.isEmpty && !_isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      message: _searchQuery.isEmpty
                          ? 'Belum ada pelanggan'
                          : 'Pelanggan tidak ditemukan',
                      actionLabel: _searchQuery.isNotEmpty ? 'Reset pencarian' : null,
                      onAction: _searchQuery.isNotEmpty
                          ? () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            }
                          : null,
                    ),
                  )
                else
                  AppSkeletonizer.sliver(
                    isLoading: _isLoading,
                    child: Builder(
                      builder: (context) {
                        final displayList = (_isLoading && filtered.isEmpty)
                            ? _placeholderCustomers
                            : filtered;

                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.space16,
                            AppDimensions.space8,
                            AppDimensions.space16,
                            96,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusCard),
                                border: Border.all(
                                    color: AppColors.border, width: 1.0),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: displayList.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final customer = entry.value;
                                  final isRankMode =
                                      _activeFilter == 'Paling Banyak Order';
                                  final isDebtMode =
                                      _activeFilter == 'Ada Utang';
                                  final showDebt = customer.hasDebt;
                                  final isLast = index == displayList.length - 1;

                                  final subtitle = isDebtMode
                                      ? '${customer.unpaidTransactionsCount} nota belum lunas'
                                      : (customer.totalCylinders > 0
                                          ? '${customer.totalCylinders} tabung'
                                          : (customer.lastOrderDate != null
                                              ? 'Order: ${AppFormatters.date(customer.lastOrderDate!)}'
                                              : 'Belum ada riwayat order'));

                                  return FlatTransactionRow(
                                    leadingWidget:
                                        isRankMode ? _buildRankBadge(index) : null,
                                    title: customer.displayName,
                                    subtitle: subtitle,
                                    amount: showDebt
                                        ? AppFormatters.currency(
                                            customer.activeDebt)
                                        : (customer.totalSpending > 0
                                            ? AppFormatters.currency(
                                                customer.totalSpending)
                                            : ''),
                                    amountColor: showDebt
                                        ? AppColors.dangerText
                                        : AppColors.brandPrimary,
                                    statusLabel: showDebt ? 'Ada Utang' : null,
                                    statusType: showDebt ? BadgeType.danger : null,
                                    showDivider: !isLast,
                                    onTap: _isLoading
                                        ? null
                                        : () => CustomerDetailSheet.show(
                                            context, customer),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankBadge(int index) {
    Color bg;
    Color textColor;
    Border? border;

    switch (index) {
      case 0:
        bg = AppColors.brandPrimary;
        textColor = Colors.white;
        break;
      case 1:
        bg = const Color(0xFFE2E8F0);
        textColor = AppColors.textPrimary;
        break;
      case 2:
        bg = const Color(0xFFFEF3C7);
        textColor = AppColors.textPrimary;
        break;
      default:
        bg = AppColors.canvas;
        textColor = AppColors.textMuted;
        border = Border.all(color: AppColors.border, width: 1.0);
    }

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Text(
        '${index + 1}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
