import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/game_theme.dart';
import '../game_state.dart';
import '../models/bubble.dart';
import '../models/energy_wave.dart';
import '../models/particle.dart';

/// Single-pass painter. Layers (back → front):
///   1. Gradient bg + aurora blooms + ambient dust.
///   2. Board rounded rect (very subtle — mostly a shape hint).
///   3. Bubbles (glossy body + rim + highlight).
///   4. Pop animations (expanding rings + fading tint).
///   5. Live energy waves.
///   6. Particles.
class GamePainter extends CustomPainter {
  final GameState state;
  final double time;
  final Offset shake;

  GamePainter({
    required this.state,
    required this.time,
    required this.shake,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(shake.dx, shake.dy);

    _paintBackground(canvas, size);
    _paintBoard(canvas);
    _paintBubbles(canvas);
    _paintPopEffects(canvas);
    _paintWaves(canvas);
    _paintParticles(canvas);

    canvas.restore();
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameTheme.bgTop, GameTheme.bg],
        ).createShader(rect),
    );
    // Two soft, colour-drift aurora blobs — parallax-like motion tied
    // to `time` so the backdrop is never fully still.
    for (int i = 0; i < 2; i++) {
      final phase = time * (0.25 + i * 0.15);
      final cx = size.width * (0.3 + 0.4 * i) +
          math.sin(phase) * size.width * 0.08;
      final cy = size.height * (0.3 + 0.4 * i) +
          math.cos(phase * 0.9) * size.height * 0.06;
      final c = i.isEven ? GameTheme.blue : GameTheme.purple;
      canvas.drawCircle(
        Offset(cx, cy),
        size.width * 0.6,
        Paint()
          ..color = c.withValues(alpha: 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
      );
    }
    // Ambient dust — deterministic scatter with a slow drift.
    final rng = math.Random(11);
    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height * 1.1;
      final speed = 4 + rng.nextDouble() * 12;
      final y = (baseY + time * speed) % (size.height + 40) - 20;
      canvas.drawCircle(
        Offset(x, y),
        0.5 + rng.nextDouble() * 1.4,
        Paint()..color = Colors.white.withValues(alpha: 0.08 + rng.nextDouble() * 0.08),
      );
    }
  }

  void _paintBoard(Canvas canvas) {
    // Very faint outer border on the play area — just enough to
    // define the space without stealing focus from the bubbles.
    final rr = RRect.fromRectAndRadius(
      state.bounds,
      const Radius.circular(24),
    );
    canvas.drawRRect(
      rr.inflate(2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _paintBubbles(Canvas canvas) {
    for (final Bubble b in state.bubbles) {
      if (b.state == BubbleState.popped) continue;
      // Popping bubbles are drawn scaled + faded so they still show
      // during the ~0.32s pop animation.
      double scale = 1.0;
      double opacity = 1.0;
      if (b.state == BubbleState.popping) {
        final t = b.popProgress;
        // scale 1 → 1.15 → 0.85 → burst.
        if (t < 0.35) {
          scale = 1.0 + (0.15) * (t / 0.35);
        } else if (t < 0.65) {
          scale = 1.15 - (0.30) * ((t - 0.35) / 0.30);
        } else {
          scale = 0.85 * (1 - (t - 0.65) / 0.35);
        }
        opacity = 1 - t;
      }
      _paintBubble(canvas, b, scale: scale, opacity: opacity);
    }
  }

  void _paintBubble(Canvas canvas, Bubble b,
      {double scale = 1, double opacity = 1}) {
    // Gentle idle bob so the board never looks static.
    final float = math.sin(time * 1.4 + b.phase) * b.radius * 0.04;
    final centre = Offset(b.position.dx, b.position.dy + float);
    final r = b.radius * scale;
    final base = b.color.withValues(alpha: opacity);

    // Wide glow.
    canvas.drawCircle(
      centre,
      r * 1.9,
      Paint()
        ..color = base.withValues(alpha: 0.30 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    // Glossy translucent body — radial gradient soft to bright edge.
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: [
            Colors.white.withValues(alpha: 0.35 * opacity),
            base.withValues(alpha: 0.55 * opacity),
            base.withValues(alpha: 0.18 * opacity),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: centre, radius: r)),
    );
    // Bright edge rim.
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..color = base.withValues(alpha: 0.85 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Thin inner rim for the "double-shell" glossy read.
    canvas.drawCircle(
      centre,
      r - 3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Specular highlight bead.
    canvas.drawCircle(
      Offset(centre.dx - r * 0.34, centre.dy - r * 0.38),
      r * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.7 * opacity),
    );
    // Second smaller sparkle.
    canvas.drawCircle(
      Offset(centre.dx - r * 0.05, centre.dy - r * 0.55),
      r * 0.08,
      Paint()..color = Colors.white.withValues(alpha: 0.55 * opacity),
    );
  }

  void _paintPopEffects(Canvas canvas) {
    for (final Bubble b in state.bubbles) {
      if (b.state != BubbleState.popping) continue;
      final t = b.popProgress;
      // Bright expanding ring layered under the bubble's fading body.
      final ringR = b.radius * (1 + t * 2.4);
      canvas.drawCircle(
        b.position,
        ringR,
        Paint()
          ..color = b.color.withValues(alpha: 0.35 * (1 - t))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 + 6 * (1 - t)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _paintWaves(Canvas canvas) {
    for (final EnergyWave w in state.waves) {
      final alpha = 0.55 * (1 - w.progress);
      // Wide soft outer glow.
      canvas.drawCircle(
        w.centre,
        w.radius,
        Paint()
          ..color = w.color.withValues(alpha: alpha * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Sharper body ring.
      canvas.drawCircle(
        w.centre,
        w.radius,
        Paint()
          ..color = w.color.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      // Bright inner line.
      canvas.drawCircle(
        w.centre,
        w.radius,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _paintParticles(Canvas canvas) {
    for (final Particle p in state.particles) {
      canvas.drawCircle(
        p.position,
        p.size * (0.4 + 0.6 * p.t),
        Paint()
          ..color = p.color.withValues(alpha: 0.9 * p.t)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter old) => true;
}
