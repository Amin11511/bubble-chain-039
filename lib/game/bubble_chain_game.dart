import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../theme/game_theme.dart';
import 'game_state.dart';
import 'logic/collision_detector.dart';
import 'painters/game_painter.dart';
import 'services/score_service.dart';
import 'widgets/game_hud.dart';
import 'widgets/result_overlay.dart';

class BubbleChainGame extends StatefulWidget {
  const BubbleChainGame({super.key});

  @override
  State<BubbleChainGame> createState() => _BubbleChainGameState();
}

class _BubbleChainGameState extends State<BubbleChainGame>
    with SingleTickerProviderStateMixin {
  final GameState _state = GameState();
  final ScoreService _scoreService = ScoreService();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _clock = 0;

  Size? _lastSize;
  Offset _shake = Offset.zero;
  bool _scorePulse = false;
  bool _incredible = false;

  int _bestScore = 0;
  int _bestChain = 0;

  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _state.onPop = _handlePop;
    _ticker = createTicker(_onTick)..start();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final b = await _scoreService.load();
    if (mounted) {
      setState(() {
        _bestScore = b.score;
        _bestChain = b.chain;
        _state.score.bestChain = b.chain;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!_state.ready) return;
    final dt = _last == Duration.zero
        ? 1 / 60
        : (elapsed - _last).inMicroseconds / 1000000.0;
    _last = elapsed;
    final clamped = dt.clamp(1 / 240, 1 / 20).toDouble();
    _clock += clamped;

    _state.update(clamped);
    _updateShake(clamped);

    if (_state.phase == GamePhase.completed && _shake == Offset.zero) {
      // Persist best on round end.
      final newScore = math.max(_bestScore, _state.scoreThisRound);
      final newChain = math.max(_bestChain, _state.biggestChainThisRound);
      if (newScore != _bestScore || newChain != _bestChain) {
        _bestScore = newScore;
        _bestChain = newChain;
        _scoreService.save(BestScores(score: newScore, chain: newChain));
      }
    }

    if (mounted) setState(() {});
  }

  void _updateShake(double dt) {
    if (_state.impactShake <= 0) {
      _shake = Offset.zero;
      return;
    }
    final s = _state.impactShake;
    _shake = Offset(
      (_rng.nextDouble() - 0.5) * s,
      (_rng.nextDouble() - 0.5) * s,
    );
  }

  void _handlePop(int chain, int delta, _) {
    _scorePulse = true;
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _scorePulse = false);
    });
    // Haptic thresholds — never one-per-pop.
    if (chain == 1) {
      HapticFeedback.lightImpact();
    } else if (chain == 10 || chain == 20 || chain == 30) {
      HapticFeedback.mediumImpact();
    }
    if (chain >= 20 && !_incredible) {
      setState(() => _incredible = true);
      _state.impactShake = 10;
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) setState(() => _incredible = false);
      });
    }
  }

  // ---------- Input ----------
  void _onTapDown(TapDownDetails d) {
    if (_state.phase == GamePhase.completed) {
      setState(() {
        _incredible = false;
        _state.reset();
      });
      return;
    }
    if (_state.phase != GamePhase.ready) return; // one tap per round
    final b = CollisionDetector.tapPickBubble(d.localPosition, _state.bubbles);
    if (b == null) return;
    _state.ignite(b);
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final newBest = _state.scoreThisRound > 0 &&
        _state.scoreThisRound >= _bestScore &&
        _state.phase == GamePhase.completed;
    return Scaffold(
      backgroundColor: GameTheme.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          if (_lastSize != size) {
            _lastSize = size;
            _state.layout(size);
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _onTapDown,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: GamePainter(
                      state: _state,
                      time: _clock,
                      shake: _shake,
                    ),
                  ),
                ),
                GameHud(
                  score: _state.score.score,
                  chain: _state.score.chain,
                  bestScore: _bestScore,
                  bestChain: _bestChain,
                  pulse: _scorePulse,
                  incredible: _incredible,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ReadyHint(visible: _state.phase == GamePhase.ready),
                ),
                if (_state.phase == GamePhase.completed)
                  ResultOverlay(
                    score: _state.scoreThisRound,
                    bubblesPopped: _state.biggestChainThisRound,
                    bestChain: _state.score.bestChain,
                    newBest: newBest,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
