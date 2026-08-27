import 'package:flutter/material.dart';

import '../../theme/game_theme.dart';

/// "CHAIN COMPLETE" card — score + bubbles popped + best-chain — with
/// a tap-to-play-again pill.
class ResultOverlay extends StatelessWidget {
  final int score;
  final int bubblesPopped;
  final int bestChain;
  final bool newBest;

  const ResultOverlay({
    super.key,
    required this.score,
    required this.bubblesPopped,
    required this.bestChain,
    required this.newBest,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.42 * t),
          child: Center(
            child: Transform.scale(
              scale: 0.85 + 0.15 * t,
              child: Opacity(opacity: t, child: child),
            ),
          ),
        );
      },
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: GameTheme.purple.withValues(alpha: 0.32),
            blurRadius: 40,
            offset: const Offset(0, 22),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'CHAIN COMPLETE',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.4,
              color: GameTheme.textPrimary,
              shadows: [Shadow(color: Color(0x99B56BFF), blurRadius: 14)],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatBlock(label: 'SCORE', value: score, highlight: newBest),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _StatBlock(
                label: 'POPPED',
                value: bubblesPopped,
                highlight: false,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _StatBlock(
                label: 'CHAIN',
                value: bestChain,
                highlight: newBest,
              ),
            ],
          ),
          if (newBest) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: GameTheme.yellow.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'NEW BEST',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: GameTheme.yellow,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.replay_rounded,
                    size: 14, color: GameTheme.textPrimary),
                SizedBox(width: 8),
                Text(
                  'Tap to Play Again',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: GameTheme.textPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final int value;
  final bool highlight;
  const _StatBlock({
    required this.label,
    required this.value,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: GameTheme.textMuted,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: highlight ? GameTheme.yellow : GameTheme.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
