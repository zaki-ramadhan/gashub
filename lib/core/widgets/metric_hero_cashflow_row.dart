import 'package:flutter/material.dart';
import 'package:flutter_solar_icons/linear.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../formatters/app_formatters.dart';

/// Bottom row of MetricHeroCard showing split Inflow & Outflow.
class MetricHeroCashflowRow extends StatelessWidget {
  const MetricHeroCashflowRow({
    super.key,
    required this.cashIn,
    required this.cashOut,
    required this.isVisible,
    required this.isSkeleton,
    this.onCashInTap,
    this.onCashOutTap,
  });

  final int cashIn;
  final int cashOut;
  final bool isVisible;
  final bool isSkeleton;
  final VoidCallback? onCashInTap;
  final VoidCallback? onCashOutTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: AppDimensions.space16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Inflow
          Expanded(
            child: InkWell(
              onTap: onCashInTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Skeleton.keep(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.brandAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const ArrowDownLinearIcon(
                              size: 11,
                              color: AppColors.brandPrimary,
                              strokeWidth: 2.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Kas Masuk',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isSkeleton
                            ? 'Rp 3.500.000'
                            : (isVisible ? AppFormatters.currency(cashIn) : 'Rp ******'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Vertical Divider
          Container(
            height: 36,
            width: 1,
            color: AppColors.border,
          ),

          // Outflow
          Expanded(
            child: InkWell(
              onTap: onCashOutTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Skeleton.keep(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const ArrowUpLinearIcon(
                              size: 11,
                              color: AppColors.dangerText,
                              strokeWidth: 2.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Kas Keluar',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isSkeleton
                            ? 'Rp 1.050.000'
                            : (isVisible ? AppFormatters.currency(cashOut) : 'Rp ******'),
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

