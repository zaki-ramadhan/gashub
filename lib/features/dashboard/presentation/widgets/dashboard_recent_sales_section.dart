import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../../distribution/data/distribution_repository.dart';
import '../../../distribution/domain/distribution_model.dart';
import '../../../distribution/presentation/widgets/sale_detail_sheet.dart';

/// Recent transactions list in Dashboard screen.
class DashboardRecentSalesSection extends StatelessWidget {
  const DashboardRecentSalesSection({
    super.key,
    required this.showSkeleton,
  });

  final bool showSkeleton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Penjualan Terkini',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            InkWell(
              onTap: () => context.go('/distribusi'),
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
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
        const SizedBox(height: AppDimensions.space10),
        if (!showSkeleton && DistributionRepository.instance.distributionsNotifier.value.isEmpty)
          const AppEmptyState(message: 'Belum ada penjualan')
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: ((showSkeleton && DistributionRepository.instance.distributionsNotifier.value.isEmpty)
                      ? DistributionModel.skeleton()
                      : DistributionRepository.instance.distributionsNotifier.value.take(4))
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final item = entry.value;
                final total = (showSkeleton && DistributionRepository.instance.distributionsNotifier.value.isEmpty)
                    ? DistributionModel.skeleton().length
                    : DistributionRepository.instance.distributionsNotifier.value.take(4).length;
                final isLast = index == total - 1;
                return AppSkeletonizer(
                  isLoading: showSkeleton,
                  child: FlatTransactionRow(
                    title: item.customerName,
                    subtitle: '${item.qty} tabung',
                    amount: AppFormatters.currency(item.amount),
                    statusLabel: item.statusLabel,
                    statusType: item.statusType,
                    time: item.time,
                    showDivider: !isLast,
                    onTap: () => SaleDetailSheet.show(context, item),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

