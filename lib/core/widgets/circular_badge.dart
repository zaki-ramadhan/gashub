import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../constants/app_colors.dart';

/// Circular pastel badge icon for product categories and status markers.
class CircularBadge extends StatelessWidget {
  const CircularBadge({
    super.key,
    required this.icon,
    this.backgroundColor = AppColors.brandAccent,
    this.iconColor = AppColors.brandPrimary,
    this.size = 38.0,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Skeleton.replace(
      replacement: Bone.circle(size: size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: size * 0.58,
          color: iconColor,
        ),
      ),
    );
  }
}
