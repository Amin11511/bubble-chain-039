import 'package:flutter/material.dart';

import '../../theme/game_theme.dart';
import '../logic/score_manager.dart';

/// Top strip — big score in the middle, `CHAIN xN` chip on the left,
/// best chip on the right, plus a floating "INCREDIBLE!" tag when
/// chains cross the 20-mark.
class GameHud extends StatelessWidget {
  final int score;
  final int chain;
  final int bestScore;
  final int bestChain;
  final bool pulse;
  final bool incredible;

  const GameHud({
    super.key,
    required this.score,
    required this.chain,
    required this.bestScore,
    required this.bestChain,
    required this.pulse,
    required this.incredible,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Column(
        children: [
          Row(
            children: [
              _ChainChip(chain: chain),
              const Spacer(),
              _BestChip(bestScore: bestScore, bestChain: bestChain),
            ],
          ),
          const SizedBox(height: 4),
          _ScorePill(score: score, pulse: pulse),
          if (incredible)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: _IncredibleTag(),
            ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int score;
  final bool pulse;
  const _ScorePill({required this.score, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pulse ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutBack,
      child: Text(
        '$score',
        style: const TextStyle(
          fontSize: 46,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: GameTheme.textPrimary,
          shadows: [
            Shadow(color: Color(0x99B56BFF), blurRadius: 16),
          ],
        ),
      ),
    );
  }
}

class _ChainChip extends StatelessWidget {
  final int chain;
  const _ChainChip({required this.chain});

  @override
  Widget build(BuildContext context) {
    final active = chain > 0;
    final mult = ScoreManager.multiplierFor(chain);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? GameTheme.purple.withValues(alpha: 0.22)
            : GameTheme.chromeGlass,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? GameTheme.purple.withValues(alpha: 0.6)
              : GameTheme.chromeBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 12,
            color: active ? GameTheme.purple : GameTheme.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            'CHAIN x$chain',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: active ? GameTheme.purple : GameTheme.textPrimary,
              letterSpacing: 0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (mult > 1) ...[
            const SizedBox(width: 6),
            Text(
              '×$mult',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: GameTheme.yellow,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BestChip extends StatelessWidget {
  final int bestScore;
  final int bestChain;
  const _BestChip({required this.bestScore, required this.bestChain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: GameTheme.chromeGlass,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GameTheme.chromeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded,
              size: 12, color: GameTheme.textSecondary),
          const SizedBox(width: 5),
          Text(
            'BEST $bestScore · x$bestChain',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: GameTheme.textPrimary,
              letterSpacing: 0.4,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _IncredibleTag extends StatelessWidget {
  const _IncredibleTag();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(
        scale: 0.7 + 0.3 * t,
        // easeOutBack overshoots past 1.0 for the bounce — clamp so
        // Opacity's [0, 1] assertion stays happy.
        child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: GameTheme.yellow.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: GameTheme.yellow.withValues(alpha: 0.6)),
        ),
        child: const Text(
          'INCREDIBLE!',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: GameTheme.yellow,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class ReadyHint extends StatelessWidget {
  final bool visible;
  const ReadyHint({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 30),
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 320),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: GameTheme.chromeGlass,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: GameTheme.chromeBorder),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_rounded, size: 14, color: GameTheme.cyan),
              SizedBox(width: 8),
              Text(
                'Tap a bubble to start the chain',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: GameTheme.textPrimary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
