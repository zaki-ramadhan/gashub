import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../data/customers_repository.dart';
import '../../domain/customer_model.dart';
import '../customer_detail_sheet.dart';

/// Analytics card highlighting the highest volume ordering customers.
class TopCustomersCard extends StatelessWidget {
  const TopCustomersCard({
    super.key,
    this.maxCount = 3,
    this.showSkeleton,
  });

  final int maxCount;
  final bool? showSkeleton;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CustomerModel>>(
      valueListenable: CustomersRepository.instance.customersNotifier,
      builder: (context, customers, _) {
        final isLoading = showSkeleton == true || (showSkeleton == null && customers.isEmpty);
        final listSource = isLoading ? CustomerModel.skeleton() : customers;

        // Sort by total cylinders ordered, then total spending
        final sorted = List<CustomerModel>.from(listSource)
          ..sort((a, b) {
            final cmp = b.totalCylinders.compareTo(a.totalCylinders);
            if (cmp != 0) return cmp;
            return b.totalSpending.compareTo(a.totalSpending);
          });

        final topList = sorted.take(maxCount).toList();

        return AppSkeletonizer(
          isLoading: isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pelanggan Terbanyak Order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                InkWell(
                  onTap: () => context.push('/warung?filter=Paling+Banyak+Order'),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusPill,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusPill,
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space8),
            if (!isLoading && customers.isEmpty)
              const AppEmptyState(message: 'Belum ada pelanggan')
            else
              Container(
                width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: topList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final customer = entry.value;
                  final isLast = index == topList.length - 1;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () => CustomerDetailSheet.show(context, customer),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              // Rank Badge
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _getRankColor(index),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: index == 0 ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space12),
                              // Customer Name & Subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.displayName,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      customer.totalCylinders > 0
                                          ? '${customer.totalCylinders} tabung'
                                          : 'Belum ada transaksi',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Contribution amount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    AppFormatters.currency(customer.totalSpending),
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brandPrimary,
                                    ),
                                  ),
                                  const Text(
                                    'Total belanja',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        const Divider(height: 1, thickness: 1, color: AppColors.border),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    },
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return AppColors.brandPrimary;
      case 1:
        return const Color(0xFFE2E8F0);
      case 2:
        return const Color(0xFFFEF3C7);
      default:
        return AppColors.surface;
    }
  }
}

