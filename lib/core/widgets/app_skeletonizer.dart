import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Centralized GasHub skeleton loading wrapper.
/// Implements a 3-tier pure neutral monochromatic gray hierarchy (100% neutral, zero blue cast, identical to YouTube/Google skeleton):
/// - Tier 1: Pure soft light gray (#F0F0F0) for parent cards and structural containers
/// - Tier 2: Pure neutral transition (#E2E2E2) for animated shimmer sweep
/// - Tier 3: Pure solid medium gray (#CCCCCC) for child elements (avatars, buttons, text bars, badges)
class AppSkeletonizer extends StatelessWidget {
  const AppSkeletonizer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.ignoreContainers = false,
    this.containersColor,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final bool isLoading;
  final bool ignoreContainers;
  final Color? containersColor;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      ignoreContainers: ignoreContainers,
      effect: ShimmerEffect(
        baseColor: baseColor ?? const Color(0xFFCCCCCC),
        highlightColor: highlightColor ?? const Color(0xFFE2E2E2),
        duration: const Duration(milliseconds: 1400),
      ),
      containersColor: containersColor ?? const Color(0xFFF0F0F0),
      child: child,
    );
  }
}
