import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Reusable grouped date section header.
/// Shows calendar date on the left and optional metric summary on the right.
class DateSectionHeader extends StatelessWidget {
  const DateSectionHeader({
    super.key,
    required this.title,
    this.summary,
    String? trailingText,
    this.topPadding = AppDimensions.space16,
  }) : _trailingText = trailingText;

  final String title;
  final String? summary;
  final String? _trailingText;
  final double topPadding;

  String? get effectiveSummary => summary ?? _trailingText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: AppDimensions.space8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (effectiveSummary != null)
            Text(
              effectiveSummary!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
