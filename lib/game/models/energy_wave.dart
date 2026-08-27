import 'dart:ui';

/// Expanding ring emitted by a popped bubble. Every frame the game
/// loop grows [radius] and drops [life]. The chain engine reads the
/// current radius for real distance-based collision.
class EnergyWave {
  Offset centre;
  double radius;
  final double maxRadius;
  final double expansionRate;
  final Color color;
  double life;
  final double totalLife;

  EnergyWave({
    required this.centre,
    required this.color,
    required this.maxRadius,
    required this.expansionRate,
  })  : radius = 0,
        totalLife = maxRadius / expansionRate,
        life = maxRadius / expansionRate;

  double get progress => 1 - (life / totalLife).clamp(0.0, 1.0);
  bool get alive => life > 0;
}
