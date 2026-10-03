import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum BadgeType { success, warning, danger, info }

/// Semantic status pill.
/// Strictly 999px radius, padding 4x10, font 12px weight 500.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  final String label;
  final BadgeType type;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      BadgeType.success => (AppColors.successBg, AppColors.successText),
      BadgeType.warning => (AppColors.warningBg, AppColors.warningText),
      BadgeType.danger => (AppColors.dangerBg, AppColors.dangerText),
      BadgeType.info => (AppColors.infoBg, AppColors.infoText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
