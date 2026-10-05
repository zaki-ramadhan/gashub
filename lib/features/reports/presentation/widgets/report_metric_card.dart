import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Clean metric summary card with no decorative icons and harmonious white surface.
class ReportMetricCard extends StatelessWidget {
  const ReportMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subWidget,
    this.valueColor,
  });

  final String title;
  final String value;
  final Widget subWidget;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          subWidget,
        ],
      ),
    );
  }
}
