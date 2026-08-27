import 'dart:ui';

/// Cheap screen-space particle. No pooling — round budgets stay low.
class Particle {
  Offset position;
  Offset velocity;
  double life;
  final double maxLife;
  final double size;
  final Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.maxLife,
    required this.size,
    required this.color,
  }) : life = maxLife;

  double get t => (life / maxLife).clamp(0.0, 1.0);
  bool get alive => life > 0;
}
