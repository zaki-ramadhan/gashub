import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/customers_repository.dart';
import '../domain/customer_model.dart';
import 'widgets/customer_detail_contact_info.dart';
import 'widgets/customer_detail_summary_row.dart';
import 'widgets/customer_order_item_row.dart';

/// Modal bottom sheet showing customer profile, active debt, and order history.
class CustomerDetailSheet extends StatefulWidget {
  const CustomerDetailSheet({super.key, required this.customer});

  final CustomerModel customer;

  static Future<void> show(BuildContext context, CustomerModel customer) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomerDetailSheet(customer: customer),
    );
  }

  @override
  State<CustomerDetailSheet> createState() => _CustomerDetailSheetState();
}

class _CustomerDetailSheetState extends State<CustomerDetailSheet> {
  late CustomerModel _customer;
  late final PagedListController<CustomerTransaction> _paginationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
    _paginationController = PagedListController<CustomerTransaction>(
      pageSize: 5,
      initialItems: _customer.transactions,
    );
    _paginationController.addListener(_onPaginationUpdated);
  }

  void _onPaginationUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _paginationController.removeListener(_onPaginationUpdated);
    _paginationController.dispose();
    super.dispose();
  }

  Future<void> _handlePayDebt() async {
    final debt = _customer.activeDebt;
    if (debt <= 0) return;

    setState(() => _isLoading = true);
    try {
      await CustomersRepository.instance.payDebt(_customer.id, debt);
      if (mounted) {
        // Mark all transactions as paid locally so UI updates synchronously
        final updatedTxs = _customer.transactions.map((tx) {
          if (tx.isUnpaid) {
            return tx.copyWith(
              paidAmount: tx.totalAmount,
              statusLabel: 'Lunas',
              statusType: BadgeType.success,
            );
          }
          return tx;
        }).toList();

        setState(() {
          _customer = _customer.copyWith(
            activeDebt: 0,
            transactions: updatedTxs,
          );
          _paginationController.setSource(updatedTxs);
          _isLoading = false;
        });

        AppToast.success(
          title: 'Pelunasan berhasil dicatat',
          description: 'Seluruh utang ${_customer.name} kini telah lunas',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(title: 'Gagal mencatat pelunasan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollListener(
      onLoadMore: _paginationController.loadMore,
      isLoadingMore: _paginationController.isLoadingMore,
      hasMore: _paginationController.hasMore,
      child: AppBottomSheet(
        title: _customer.name,
        child: AppSkeletonizer(
          isLoading: _isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Raw-text Contact & Address Details
              CustomerDetailContactInfo(customer: _customer),
              const SizedBox(height: AppDimensions.space12),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              const SizedBox(height: AppDimensions.space12),

              // 2. Clean Flat Summary Row (Sisa Utang & Total Tabung)
              CustomerDetailSummaryRow(
                customer: _customer,
                onPayDebt: _handlePayDebt,
              ),
              const SizedBox(height: AppDimensions.space12),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              const SizedBox(height: AppDimensions.space16),

              // 3. Riwayat Nota
              const Text(
                'Riwayat Nota',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),

              if (_paginationController.totalCount == 0)
                const AppEmptyState(message: 'Belum ada riwayat belanja')
              else ...[
                ..._paginationController.visibleItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final tx = entry.value;
                  final isLast = idx == _paginationController.visibleItems.length - 1;
                  return CustomerOrderItemRow(
                    transaction: tx,
                    showDivider: !isLast,
                  );
                }),
                if (!_isLoading)
                  PaginationLoadingIndicator(
                    isLoadingMore: _paginationController.isLoadingMore,
                    hasMore: _paginationController.hasMore,
                    totalItems: _paginationController.totalCount,
                    loadingMessage: 'Memuat riwayat nota...',
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
