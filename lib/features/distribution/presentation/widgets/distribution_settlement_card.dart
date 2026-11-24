import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Summary card displaying today's sales, modal, and net margin (sisa).
class DistributionSettlementCard extends StatelessWidget {
  const DistributionSettlementCard({
    super.key,
    required this.totalQty,
    required this.totalSales,
    required this.totalCost,
    required this.netMargin,
    this.isLoading = false,
  });

  final int totalQty;
  final int totalSales;
  final int totalCost;
  final int netMargin;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final displayQty = isLoading && totalQty == 0 ? 15 : totalQty;
    final displaySales = isLoading && totalSales == 0 ? 285000 : totalSales;
    final displayCost = isLoading && totalCost == 0 ? 240000 : totalCost;
    final displayMargin = isLoading && netMargin == 0 ? 45000 : netMargin;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space16,
        AppDimensions.space4,
        AppDimensions.space16,
        AppDimensions.space10,
      ),
      child: AppSkeletonizer(
        isLoading: isLoading,
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
                    'Rekap Penjualan Hari Ini',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$displayQty tabung terjual',
                    style: const TextStyle(
                      fontSize: 14,
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
                          'Total Penjualan',
                          style: TextStyle(
                            fontSize: 14,
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
                            AppFormatters.currency(displaySales),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
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
                          'Total Modal',
                          style: TextStyle(
                            fontSize: 14,
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
                            AppFormatters.currency(displayCost),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
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
                          'Sisa Margin',
                          style: TextStyle(
                            fontSize: 14,
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
                            AppFormatters.signedCurrency(displayMargin),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF16A34A),
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
    );
  }
}
