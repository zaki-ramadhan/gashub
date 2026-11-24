import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Live margin and profit calculator indicator card in PriceSettingSheet.
class PriceMarginCard extends StatelessWidget {
  const PriceMarginCard({
    super.key,
    required this.margin,
    required this.sellingPrice,
  });

  final int margin;
  final int sellingPrice;

  @override
  Widget build(BuildContext context) {
    final marginPercent = sellingPrice > 0
        ? ((margin / sellingPrice) * 100).toStringAsFixed(1)
        : '0.0';
    final isProfitable = margin >= 0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: isProfitable ? AppColors.brandAccent : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(
          color: isProfitable
              ? AppColors.brandSuccess.withValues(alpha: 0.3)
              : AppColors.dangerText.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isProfitable ? Icons.trending_up : Icons.trending_down,
            color: isProfitable ? AppColors.brandSuccess : AppColors.dangerText,
            size: 24,
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProfitable ? 'Keuntungan per Tabung' : 'Rugi per Tabung',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isProfitable ? AppColors.brandPrimary : AppColors.dangerText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppFormatters.currency(margin)} ($marginPercent%)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isProfitable ? AppColors.brandPrimary : AppColors.dangerText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

