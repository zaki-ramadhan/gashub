import 'dart:async';
import 'package:flutter/foundation.dart';

/// Lightweight debouncer utility for search inputs and rapid user interactions.
/// Ensures expensive filtering, querying, and UI rebuilding are only executed
/// after the user pauses typing for the specified [duration] (default 300ms).
class AppDebouncer {
  AppDebouncer({this.duration = const Duration(milliseconds: 300)});

  final Duration duration;
  Timer? _timer;

  /// Runs the given [action] after [duration]. Cancels any previously active timer.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancels the current timer without running the action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes active timers when a State/Widget is destroyed.
  void dispose() {
    cancel();
  }
}

