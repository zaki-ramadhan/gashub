import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Highlight card showing total outstanding receivables.
class ReceivablesHeroCard extends StatelessWidget {
  const ReceivablesHeroCard({
    super.key,
    required this.totalOutstanding,
    required this.activeCount,
    this.isLoading = false,
  });

  final int totalOutstanding;
  final int activeCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space16,
        AppDimensions.space4,
        AppDimensions.space16,
        AppDimensions.space12,
      ),
      child: AppSkeletonizer(
        isLoading: isLoading,
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
                'Dari $activeCount transaksi pelanggan aktif',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
