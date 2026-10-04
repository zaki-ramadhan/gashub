import 'package:flutter/foundation.dart';

/// Reusable controller managing pagination state, chunk slicing, and loading flags.
class PagedListController<T> extends ChangeNotifier {
  PagedListController({
    required this.pageSize,
    List<T>? initialItems,
    this.onFetchNext,
  }) {
    if (initialItems != null) {
      setSource(initialItems);
    }
  }

  final int pageSize;
  final Future<List<T>> Function(int offset, int limit)? onFetchNext;

  List<T> _allItems = [];
  int _visibleCount = 0;
  bool _isLoadingMore = false;
  bool _hasMoreRemote = true;
  bool _isDisposed = false;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore {
    if (onFetchNext != null) {
      return _hasMoreRemote;
    }
    return _visibleCount < _allItems.length;
  }

  List<T> get visibleItems => _allItems.take(_visibleCount).toList();
  int get totalCount => _allItems.length;
  int get visibleCount => _visibleCount;

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Updates source dataset (e.g., after filtering/searching) and recalculates chunk bounds.
  void setSource(List<T> items, {bool reset = true}) {
    _allItems = items;
    _isLoadingMore = false;
    _hasMoreRemote = true;
    if (reset) {
      _visibleCount = pageSize.clamp(0, _allItems.length);
    } else {
      _visibleCount = _visibleCount.clamp(0, _allItems.length);
    }
    _safeNotifyListeners();
  }

  /// Triggers loading next chunk.
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _isDisposed) return;

    _isLoadingMore = true;
    _safeNotifyListeners();

    if (onFetchNext != null) {
      try {
        final nextItems = await onFetchNext!(_allItems.length, pageSize);
        if (_isDisposed) return;
        if (nextItems.length < pageSize) {
          _hasMoreRemote = false;
        }
        _allItems.addAll(nextItems);
        _visibleCount = _allItems.length;
      } catch (_) {
        // preserve current state on error
      }
    } else {
      // Smooth latency simulation for in-memory / cached dataset
      await Future.delayed(const Duration(milliseconds: 350));
      if (_isDisposed) return;
      _visibleCount = (_visibleCount + pageSize).clamp(0, _allItems.length);
    }

    _isLoadingMore = false;
    _safeNotifyListeners();
  }

  /// Resets pagination back to initial chunk size.
  void reset() {
    _visibleCount = pageSize.clamp(0, _allItems.length);
    _isLoadingMore = false;
    _hasMoreRemote = true;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
