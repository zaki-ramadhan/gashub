import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Centralized GasHub skeleton loading wrapper.
/// Preserves parent white card containers, borders, and layouts while shimmering internal leaf elements.
class AppSkeletonizer extends StatelessWidget {
  const AppSkeletonizer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.ignoreContainers = false,
    this.enableSwitchAnimation = true,
    this.containersColor,
    this.baseColor,
    this.highlightColor,
  }) : _isSliver = false;

  const AppSkeletonizer.sliver({
    super.key,
    required this.child,
    this.isLoading = true,
    this.ignoreContainers = false,
    this.enableSwitchAnimation = true,
    this.containersColor,
    this.baseColor,
    this.highlightColor,
  }) : _isSliver = true;

  final Widget child;
  final bool isLoading;
  final bool ignoreContainers;
  final bool enableSwitchAnimation;
  final Color? containersColor;
  final Color? baseColor;
  final Color? highlightColor;
  final bool _isSliver;

  @override
  Widget build(BuildContext context) {
    if (_isSliver) {
      return Skeletonizer.sliver(
        enabled: isLoading,
        ignoreContainers: ignoreContainers,
        ignorePointers: false,
        effect: ShimmerEffect(
          baseColor: baseColor ?? const Color(0xFFE2E8F0),
          highlightColor: highlightColor ?? const Color(0xFFF8FAFC),
          duration: const Duration(milliseconds: 1400),
        ),
        containersColor: containersColor,
        child: child,
      );
    }
    return Skeletonizer(
      enabled: isLoading,
      enableSwitchAnimation: enableSwitchAnimation,
      ignoreContainers: ignoreContainers,
      ignorePointers: false,
      effect: ShimmerEffect(
        baseColor: baseColor ?? const Color(0xFFE2E8F0),
        highlightColor: highlightColor ?? const Color(0xFFF8FAFC),
        duration: const Duration(milliseconds: 1400),
      ),
      containersColor: containersColor,
      child: child,
    );
  }
}
