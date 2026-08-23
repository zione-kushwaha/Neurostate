import 'dart:math';

/// Analyzes viewport scrolling velocity ($v = \Delta y / \Delta t$) and lookahead trajectory
class ViewportVelocityTracker {
  double _lastOffset = 0.0;
  DateTime _lastTime = DateTime.now();
  double _currentVelocity = 0.0; // pixels per second

  double get velocity => _currentVelocity;
  bool get isScrollingDown => _currentVelocity > 50.0;
  bool get isScrollingUp => _currentVelocity < -50.0;

  void updateScroll(double currentOffset) {
    final now = DateTime.now();
    final dt = now.difference(_lastTime).inMicroseconds / 1000000.0;
    if (dt > 0.005) {
      final dy = currentOffset - _lastOffset;
      _currentVelocity = dy / dt;
      _lastOffset = currentOffset;
      _lastTime = now;
    }
  }

  /// Calculates dynamic prefetch window lookahead count based on scroll speed
  int computeLookaheadCount({int baseLookahead = 4, int maxLookahead = 12}) {
    final speed = _currentVelocity.abs();
    if (speed < 100) return baseLookahead;
    if (speed < 600) return min(baseLookahead + 3, maxLookahead);
    return maxLookahead;
  }
}
