import 'package:shared_preferences/shared_preferences.dart';

class BestScores {
  final int score;
  final int chain;
  const BestScores({required this.score, required this.chain});
}

class ScoreService {
  static const _scoreKey = 'bubble_chain_best_score';
  static const _chainKey = 'bubble_chain_best_chain';

  Future<BestScores> load() async {
    final p = await SharedPreferences.getInstance();
    return BestScores(
      score: p.getInt(_scoreKey) ?? 0,
      chain: p.getInt(_chainKey) ?? 0,
    );
  }

  Future<void> save(BestScores b) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_scoreKey, b.score);
    await p.setInt(_chainKey, b.chain);
  }
}
