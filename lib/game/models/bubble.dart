import 'dart:ui';

enum BubbleState { idle, popping, popped }

/// A single floating bubble. `state` gates whether waves can trigger
/// it — a popped or already-popping bubble is inert.
class Bubble {
  final int id;
  Offset position;
  Offset velocity;
  double radius;
  final Color color;

  BubbleState state = BubbleState.idle;

  /// Ambient float animation phase.
  final double phase;

  /// 0..1 progress through the pop animation. Painter maps this to
  /// scale/opacity; game loop retires the bubble once it hits 1.
  double popProgress = 0;

  Bubble({
    required this.id,
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
    required this.phase,
  });
}
