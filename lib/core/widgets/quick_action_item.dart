import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Reusable Quick Action item inspired by modern minimalist banking & POS interfaces.
/// Displays a touch-friendly circular icon button with a clean 12px label underneath.
class QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const QuickActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space8,
          vertical: AppDimensions.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Skeleton.replace(
              replacement: const Bone.circle(size: 48),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? AppColors.brandPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
