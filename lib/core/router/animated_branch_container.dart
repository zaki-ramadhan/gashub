import 'package:flutter/material.dart';

/// Container cabang navigator yang menganimasikan perpindahan tab secara horizontal (slide kanan/kiri)
/// dengan sistem Lazy Loading: tab hanya dimuat dan mengambil data saat pertama kali dikunjungi.
class AnimatedBranchContainer extends StatefulWidget {
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
  State<AnimatedBranchContainer> createState() => _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer> {
  final Set<int> _activatedIndices = <int>{};

  @override
  void initState() {
    super.initState();
    _activatedIndices.add(widget.currentIndex);
  }

  @override
  void didUpdateWidget(covariant AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _activatedIndices.add(widget.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List<Widget>.generate(widget.children.length, (int index) {
        final bool isCurrent = index == widget.currentIndex;
        final bool isActivated = _activatedIndices.contains(index);

        if (!isActivated) {
          return const SizedBox.shrink();
        }

        final double targetX = isCurrent
            ? 0.0
            : (index < widget.currentIndex ? -1.0 : 1.0);

        return AnimatedSlide(
          offset: Offset(targetX, 0.0),
          duration: widget.duration,
          curve: widget.curve,
          child: AnimatedOpacity(
            opacity: isCurrent ? 1.0 : 0.0,
            duration: widget.duration,
            curve: widget.curve,
            child: IgnorePointer(
              ignoring: !isCurrent,
              child: widget.children[index],
            ),
          ),
        );
      }),
    );
  }
}
