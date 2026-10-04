import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Callback triggered when scroll approaches the bottom threshold.
typedef LoadMoreCallback = Future<void> Function();

/// Reusable scroll listener widget that monitors scroll events and triggers
/// [onLoadMore] when the user scrolls near the bottom extent.
class InfiniteScrollListener extends StatefulWidget {
  const InfiniteScrollListener({
    super.key,
    required this.child,
    required this.onLoadMore,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.threshold = 180.0,
  });

  final Widget child;
  final LoadMoreCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final double threshold;

  @override
  State<InfiniteScrollListener> createState() => _InfiniteScrollListenerState();
}

class _InfiniteScrollListenerState extends State<InfiniteScrollListener> {
  bool _isTriggering = false;

  void _checkAndTrigger(ScrollMetrics metrics) {
    if (!widget.hasMore || widget.isLoadingMore || _isTriggering) return;

    final distanceRemaining = metrics.maxScrollExtent - metrics.pixels;
    if (distanceRemaining <= widget.threshold) {
      _isTriggering = true;
      widget.onLoadMore().whenComplete(() {
        if (mounted) {
          setState(() {
            _isTriggering = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          _checkAndTrigger(notification.metrics);
        }
        return false;
      },
      child: widget.child,
    );
  }
}

/// Standardized loading and end-of-list footer indicator for GasHub infinite lists.
class PaginationLoadingIndicator extends StatelessWidget {
  const PaginationLoadingIndicator({
    super.key,
    required this.isLoadingMore,
    this.hasMore = true,
    this.totalItems = 0,
    this.loadingMessage = 'Memuat data berikutnya...',
    this.endMessage = 'Semua data telah ditampilkan',
    this.padding = const EdgeInsets.symmetric(vertical: 14),
  });

  final bool isLoadingMore;
  final bool hasMore;
  final int totalItems;
  final String loadingMessage;
  final String endMessage;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return Padding(
        padding: padding,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                loadingMessage,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasMore && totalItems > 0) {
      return Padding(
        padding: padding,
        child: Center(
          child: Text(
            endMessage,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
