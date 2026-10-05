import 'package:flutter/material.dart';

/// Container cabang navigator yang menganimasikan perpindahan tab secara horizontal (slide kanan/kiri)
/// sekaligus menjaga state (scroll, input form) di setiap tab tetap utuh.
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeInOutCubic,
  });

  final int currentIndex;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List<Widget>.generate(children.length, (int index) {
        final bool isCurrent = index == currentIndex;
        final double targetX = isCurrent
            ? 0.0
            : (index < currentIndex ? -1.0 : 1.0);

        return AnimatedSlide(
          offset: Offset(targetX, 0.0),
          duration: duration,
          curve: curve,
          child: AnimatedOpacity(
            opacity: isCurrent ? 1.0 : 0.0,
            duration: duration,
            curve: curve,
            child: IgnorePointer(
              ignoring: !isCurrent,
              child: TickerMode(
                enabled: isCurrent,
                child: children[index],
              ),
            ),
          ),
        );
      }),
    );
  }
}
