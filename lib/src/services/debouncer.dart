import 'dart:async';

/// Utility class for debouncing function calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Executes the action after the specified delay
  /// Cancels any previous pending execution
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending execution
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer and cancels any pending execution
  void dispose() {
    _timer?.cancel();
  }
}
