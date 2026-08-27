import 'dart:math' as math;
import 'dart:ui';

import '../models/bubble.dart';
import '../models/energy_wave.dart';

class CollisionDetector {
  CollisionDetector._();

  /// A wave *reaches* a bubble when the distance between centres is
  /// no more than the sum of their radii. Bubble radius counts — a
  /// bigger bubble is easier to hit.
  static bool waveHitsBubble(EnergyWave w, Bubble b) {
    if (b.state != BubbleState.idle) return false;
    final dx = w.centre.dx - b.position.dx;
    final dy = w.centre.dy - b.position.dy;
    final d = math.sqrt(dx * dx + dy * dy);
    return d <= w.radius + b.radius;
  }

  /// Tap-vs-bubble: pick the topmost idle bubble whose disc contains
  /// the tap point (with a small generous padding so tiny bubbles
  /// stay tappable).
  static Bubble? tapPickBubble(Offset tap, List<Bubble> bubbles) {
    Bubble? best;
    double bestDist = double.infinity;
    for (final b in bubbles) {
      if (b.state != BubbleState.idle) continue;
      final dx = tap.dx - b.position.dx;
      final dy = tap.dy - b.position.dy;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d <= b.radius + 8 && d < bestDist) {
        bestDist = d;
        best = b;
      }
    }
    return best;
  }
}
