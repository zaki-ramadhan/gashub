import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/customers_repository.dart';
import '../domain/customer_model.dart';
import 'customer_detail_sheet.dart';
import 'customer_form_sheet.dart';

/// Screen listing partner stores & customers with search, debt status, and detailed history.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pelanggan'),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space16),
            child: Center(
              child: InkWell(
                onTap: () => CustomerFormSheet.show(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '+ Tambah',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<CustomerModel>>(
        valueListenable: CustomersRepository.instance.customersNotifier,
        builder: (context, allCustomers, _) {
          final filtered = CustomersRepository.instance.searchCustomers(
            query: _searchQuery,
            filter: _activeFilter,
          );

          final totalDebtors = allCustomers.where((c) => c.hasDebt).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar & Status Counter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
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
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        isDense: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space10),

                    // Filter Chips & Counter
                    Row(
                      children: [
                        _buildFilterChip('Semua'),
                        const SizedBox(width: AppDimensions.space8),
                        _buildFilterChip('Ada Utang'),
                        const SizedBox(width: AppDimensions.space8),
                        _buildFilterChip('Lunas'),
                        const Spacer(),
                        Text(
                          '$totalDebtors ada utang',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space8),

              // 2. Daftar Warung
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tidak ada pelanggan yang sesuai',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: const Text('Reset pencarian'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppDimensions.space8),
                        itemBuilder: (context, index) {
                          final customer = filtered[index];

                          return FlatTransactionRow(
                            title: customer.name,
                            subtitle: customer.lastOrderDate != null
                                ? 'Kirim terakhir: ${AppFormatters.date(customer.lastOrderDate!)}'
                                : 'Belum ada riwayat kirim',
                            amount: customer.hasDebt
                                ? AppFormatters.currency(customer.activeDebt)
                                : '',
                            amountColor: AppColors.dangerText,
                            statusLabel: customer.hasDebt ? 'Ada Utang' : null,
                            statusType: customer.hasDebt ? BadgeType.danger : null,
                            icon: Icons.person_outline,
                            iconColor: AppColors.brandPrimary,
                            iconBg: AppColors.canvas,
                            onTap: () => CustomerDetailSheet.show(context, customer),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
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
