import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/report_models.dart';

/// Modal bottom sheet for switching active report period.
class PeriodPickerSheet extends StatelessWidget {
  const PeriodPickerSheet({
    super.key,
    required this.options,
    required this.activeSummary,
    required this.onSelected,
  });

  final List<ReportPeriodSummary> options;
  final ReportPeriodSummary activeSummary;
  final ValueChanged<ReportPeriodSummary> onSelected;

  static void show({
    required BuildContext context,
    required List<ReportPeriodSummary> options,
    required ReportPeriodSummary activeSummary,
    required ValueChanged<ReportPeriodSummary> onSelected,
  }) {
    AppBottomSheet.show(
      context: context,
      title: 'Pilih Periode',
      child: PeriodPickerSheet(
        options: options,
        activeSummary: activeSummary,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: options.map((summary) {
        final isSelected = summary.id == activeSummary.id;

        return InkWell(
          onTap: () {
            onSelected(summary);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.05) : Colors.transparent,
              border: const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary.dateRangeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.brandPrimary,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
