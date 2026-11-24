import 'package:flutter/material.dart';
import 'package:flutter_solar_icons/linear.dart';
import '../../../../core/core.dart';
import '../../domain/report_models.dart';

/// Interactive period sub-header dropdown button for ReportsScreen.
class ReportPeriodHeaderBar extends StatelessWidget {
  const ReportPeriodHeaderBar({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final ReportPeriodSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          children: [
            const CalendarLinearIcon(
              size: 16,
              color: AppColors.brandPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              summary.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '|',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.border,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                summary.dateRangeLabel,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const AltArrowDownLinearIcon(
              size: 18,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

