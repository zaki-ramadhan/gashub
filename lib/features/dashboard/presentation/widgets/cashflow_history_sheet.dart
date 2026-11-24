import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/cashflow_entry_model.dart';
import 'cashflow_entry_row.dart';

/// Modal bottom sheet displaying detailed cashflow history (Kas Masuk & Kas Keluar).
class CashflowHistorySheet extends StatefulWidget {
  const CashflowHistorySheet({
    super.key,
    this.initialFilter = 'Semua', // 'Semua', 'Masuk', 'Keluar'
  });

  final String initialFilter;

  static void show(BuildContext context, {String initialFilter = 'Semua'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CashflowHistorySheet(initialFilter: initialFilter),
    );
  }

  @override
  State<CashflowHistorySheet> createState() => _CashflowHistorySheetState();
}

class _CashflowHistorySheetState extends State<CashflowHistorySheet> {
  late String _activeFilter;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialFilter;
    if (DashboardRepository.instance.cashflowEntriesNotifier.value.isEmpty) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await DashboardRepository.instance.fetchCashflowEntries();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Drag handle & Header
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space20,
              vertical: AppDimensions.space8,
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Arus Kas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),

          // 2. Filter Pills (Semua, Masuk, Keluar)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                const SizedBox(width: AppDimensions.space8),
                _buildFilterChip('Masuk'),
                const SizedBox(width: AppDimensions.space8),
                _buildFilterChip('Keluar'),
              ],
            ),
          ),

          // 3. Content List
          Expanded(
            child: ValueListenableBuilder<List<CashflowEntryModel>>(
              valueListenable: DashboardRepository.instance.cashflowEntriesNotifier,
              builder: (context, entries, _) {
                if (_isLoading) {
                  return AppSkeletonizer(
                    isLoading: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space16,
                      ),
                      itemCount: 5,
                      itemBuilder: (_, i) => CashflowEntryRow(
                        entry: CashflowEntryModel.skeleton()[i],
                      ),
                    ),
                  );
                }

                // Filter logic
                final filtered = entries.where((e) {
                  if (_activeFilter == 'Masuk') return e.isInflow;
                  if (_activeFilter == 'Keluar') return !e.isInflow;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return AppEmptyState(
                    message: _activeFilter == 'Semua'
                        ? 'Belum ada transaksi kas'
                        : 'Transaksi kas $_activeFilter tidak ditemukan',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.space16,
                    0,
                    AppDimensions.space16,
                    AppDimensions.space24,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => CashflowEntryRow(entry: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _activeFilter = label),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lime : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            border: Border.all(
              color: isSelected
                  ? AppColors.forestGreen.withValues(alpha: 0.5)
                  : AppColors.border,
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

