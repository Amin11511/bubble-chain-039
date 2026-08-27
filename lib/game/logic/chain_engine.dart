import 'dart:math' as math;
import 'dart:ui';

import '../models/bubble.dart';
import '../models/energy_wave.dart';
import '../models/particle.dart';
import 'collision_detector.dart';
import 'score_manager.dart';

/// Reactive core: given the current bubbles + waves, expands waves,
/// pops anything they touch, and emits the follow-on wave / particle
/// events. Pure logic — the composer wires it to state + haptics.
class ChainEngine {
  final ScoreManager score;
  final List<Bubble> bubbles;
  final List<EnergyWave> waves;
  final List<Particle> particles;
  final math.Random _rng = math.Random();

  /// Fired every time a bubble ignites in the chain. Lets the
  /// composer light up score-pulses, screen shake, haptics.
  final void Function(int chain, int deltaScore, Bubble bubble)? onPop;

  ChainEngine({
    required this.score,
    required this.bubbles,
    required this.waves,
    required this.particles,
    this.onPop,
  });

  /// Detonate a bubble. Immediately transitions to popping, emits
  /// particles, spawns a wave, and registers the pop for scoring.
  void detonate(Bubble b, {double waveMaxRadius = 180}) {
    if (b.state != BubbleState.idle) return;
    b.state = BubbleState.popping;
    b.popProgress = 0;
    final delta = score.registerPop();
    _emitParticles(b);
    waves.add(EnergyWave(
      centre: b.position,
      color: b.color,
      // Bigger bubbles fling a bigger wave.
      maxRadius: waveMaxRadius + b.radius * 1.6,
      expansionRate: 360,
    ));
    onPop?.call(score.chain, delta, b);
  }

  /// Frame update — expand waves, decay them, and detonate any idle
  /// bubble whose disc a wave has just entered.
  void update(double dt) {
    // Expand + decay waves.
    for (final w in waves) {
      w.radius = math.min(w.maxRadius, w.radius + w.expansionRate * dt);
      w.life -= dt;
    }
    // Real chain reaction — every idle bubble is tested against every
    // active wave. `detonate` appends a new wave, so we iterate a
    // *snapshot* of the current list to avoid concurrent modification;
    // any new waves are collected this frame and evaluated next frame.
    final activeWaves = List<EnergyWave>.of(waves);
    for (final w in activeWaves) {
      if (!w.alive) continue;
      for (final b in bubbles) {
        if (CollisionDetector.waveHitsBubble(w, b)) {
          detonate(b);
        }
      }
    }
    // Retire dead waves.
    waves.removeWhere((w) => !w.alive);
  }

  void _emitParticles(Bubble b) {
    final n = 10 + _rng.nextInt(8);
    for (int i = 0; i < n; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 60 + _rng.nextDouble() * 160;
      particles.add(Particle(
        position: b.position,
        velocity: Offset(math.cos(angle), math.sin(angle)) * speed,
        maxLife: 0.55 + _rng.nextDouble() * 0.15,
        size: 2 + _rng.nextDouble() * 3,
        color: b.color,
      ));
    }
  }
}
