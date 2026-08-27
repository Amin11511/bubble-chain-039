import 'dart:math' as math;
import 'dart:ui';

import '../theme/game_theme.dart';
import 'logic/chain_engine.dart';
import 'logic/score_manager.dart';
import 'models/bubble.dart';
import 'models/energy_wave.dart';
import 'models/particle.dart';

enum GamePhase { ready, chainReaction, completed }

/// Central state. The composer holds one instance and pumps it via
/// [update] each frame.
class GameState {
  Size viewport = Size.zero;
  Rect bounds = Rect.zero;
  bool ready = false;

  final List<Bubble> bubbles = [];
  final List<EnergyWave> waves = [];
  final List<Particle> particles = [];

  final ScoreManager score = ScoreManager();
  late final ChainEngine engine;

  GamePhase phase = GamePhase.ready;

  int highlightChain = 0;
  double impactShake = 0;
  int biggestChainThisRound = 0;
  int scoreThisRound = 0;

  final math.Random _rng = math.Random();
  int _nextId = 0;

  /// Callback for the composer to react to each pop (haptics, pulses).
  void Function(int chain, int delta, Bubble bubble)? onPop;

  GameState() {
    engine = ChainEngine(
      score: score,
      bubbles: bubbles,
      waves: waves,
      particles: particles,
      onPop: (chain, delta, b) => onPop?.call(chain, delta, b),
    );
  }

  void layout(Size size) {
    viewport = size;
    bounds = Rect.fromLTWH(14, 100, size.width - 28, size.height - 200);
    _spawnRound();
    ready = true;
  }

  void reset() {
    bubbles.clear();
    waves.clear();
    particles.clear();
    score.reset();
    highlightChain = 0;
    impactShake = 0;
    scoreThisRound = 0;
    biggestChainThisRound = 0;
    phase = GamePhase.ready;
    _spawnRound();
  }

  /// Fill the board with ~28-34 bubbles distributed with Poisson-ish
  /// spacing so clusters can form but big overlaps don't.
  void _spawnRound() {
    _nextId = 0;
    final count = 28 + _rng.nextInt(7);
    var attempts = 0;
    while (bubbles.length < count && attempts < 600) {
      attempts++;
      final r = 14.0 + _rng.nextDouble() * 16.0;
      final x = bounds.left + r + 4 + _rng.nextDouble() * (bounds.width - 2 * r - 8);
      final y = bounds.top + r + 4 + _rng.nextDouble() * (bounds.height - 2 * r - 8);
      final p = Offset(x, y);
      var ok = true;
      for (final o in bubbles) {
        final dx = o.position.dx - x;
        final dy = o.position.dy - y;
        if (dx * dx + dy * dy < (o.radius + r + 6) * (o.radius + r + 6)) {
          ok = false;
          break;
        }
      }
      if (!ok) continue;
      // Slow drift, random unit direction.
      final ang = _rng.nextDouble() * math.pi * 2;
      final speed = 12 + _rng.nextDouble() * 22;
      bubbles.add(Bubble(
        id: _nextId++,
        position: p,
        velocity: Offset(math.cos(ang), math.sin(ang)) * speed,
        radius: r,
        color: GameTheme
            .heroColors[_rng.nextInt(GameTheme.heroColors.length)],
        phase: _rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  /// Start a chain by detonating a picked bubble.
  void ignite(Bubble b) {
    phase = GamePhase.chainReaction;
    engine.detonate(b);
  }

  /// Frame update — bubble drift, engine, pop animation, particles,
  /// shake decay, round-end detection.
  void update(double dt) {
    if (!ready) return;
    _updateBubbles(dt);
    if (phase == GamePhase.chainReaction) {
      engine.update(dt);
    }
    _advancePops(dt);
    _updateParticles(dt);
    _decayShake(dt);
    _checkRoundEnd();
  }

  void _updateBubbles(double dt) {
    for (final b in bubbles) {
      if (b.state != BubbleState.idle) continue;
      // Ambient tiny sinusoid on top of velocity for that "float" feel.
      b.position = Offset(
        b.position.dx + b.velocity.dx * dt,
        b.position.dy + b.velocity.dy * dt,
      );
      // Bounce off bounds (soft) — reflect velocity if crossing.
      if (b.position.dx - b.radius < bounds.left) {
        b.position = Offset(bounds.left + b.radius, b.position.dy);
        b.velocity = Offset(b.velocity.dx.abs(), b.velocity.dy);
      } else if (b.position.dx + b.radius > bounds.right) {
        b.position = Offset(bounds.right - b.radius, b.position.dy);
        b.velocity = Offset(-b.velocity.dx.abs(), b.velocity.dy);
      }
      if (b.position.dy - b.radius < bounds.top) {
        b.position = Offset(b.position.dx, bounds.top + b.radius);
        b.velocity = Offset(b.velocity.dx, b.velocity.dy.abs());
      } else if (b.position.dy + b.radius > bounds.bottom) {
        b.position = Offset(b.position.dx, bounds.bottom - b.radius);
        b.velocity = Offset(b.velocity.dx, -b.velocity.dy.abs());
      }
    }
  }

  void _advancePops(double dt) {
    const popDuration = 0.32;
    for (final b in bubbles) {
      if (b.state != BubbleState.popping) continue;
      b.popProgress = math.min(1.0, b.popProgress + dt / popDuration);
      if (b.popProgress >= 1.0) {
        b.state = BubbleState.popped;
      }
    }
  }

  void _updateParticles(double dt) {
    for (final p in particles) {
      p.life -= dt;
      p.position += p.velocity * dt;
      p.velocity = p.velocity * math.exp(-1.5 * dt);
    }
    particles.removeWhere((p) => !p.alive);
  }

  void _decayShake(double dt) {
    if (impactShake > 0) {
      impactShake = math.max(0, impactShake - dt * 22);
    }
  }

  void _checkRoundEnd() {
    if (phase != GamePhase.chainReaction) return;
    if (waves.isNotEmpty) return;
    for (final b in bubbles) {
      if (b.state == BubbleState.popping) return;
    }
    // Round done.
    scoreThisRound = score.score;
    biggestChainThisRound = score.chain;
    phase = GamePhase.completed;
    score.endChain();
  }
}
