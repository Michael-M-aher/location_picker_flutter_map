import 'dart:async';

import 'package:flutter/foundation.dart';

class Debounce {
  final int milliseconds;
  final int seconds;
  Timer? _timer;

  Debounce({this.milliseconds = 0, this.seconds = 0});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer =
        Timer(Duration(milliseconds: milliseconds, seconds: seconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}
