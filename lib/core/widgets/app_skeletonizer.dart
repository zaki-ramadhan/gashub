import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Centralized GasHub skeleton loading wrapper.
/// Adheres strictly to GasHub Design DNA using subtle Slate tones (#E2E8F0 & #F8FAFC).
class AppSkeletonizer extends StatelessWidget {
  const AppSkeletonizer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.ignoreContainers = false,
  });

  final Widget child;
  final bool isLoading;
  final bool ignoreContainers;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      ignoreContainers: ignoreContainers,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFE2E8F0),
        highlightColor: Color(0xFFF8FAFC),
        duration: Duration(milliseconds: 1400),
      ),
      containersColor: const Color(0xFFE2E8F0),
      child: child,
    );
  }
}
