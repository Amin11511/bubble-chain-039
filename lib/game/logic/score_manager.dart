/// Chain-aware scorer. Bubble #N in the chain (1-indexed) yields
/// N points; every 5-bubble milestone multiplies the incoming award
/// by an additional +1, so late pops in a huge chain feel weighty.
class ScoreManager {
  int score = 0;
  int chain = 0;
  int roundBubblesPopped = 0;
  int bestChain = 0;

  void reset() {
    score = 0;
    chain = 0;
    roundBubblesPopped = 0;
  }

  /// Called once per bubble popped in the active chain. Returns the
  /// number of points *added* to [score] by this pop.
  int registerPop() {
    chain += 1;
    roundBubblesPopped += 1;
    final multiplier = _multiplier(chain);
    final delta = chain * multiplier;
    score += delta;
    if (chain > bestChain) bestChain = chain;
    return delta;
  }

  /// Reset chain to 0 when a round ends.
  void endChain() {
    chain = 0;
  }

  static int _multiplier(int chain) {
    if (chain >= 20) return 4;
    if (chain >= 15) return 3;
    if (chain >= 10) return 2;
    return 1;
  }

  static int multiplierFor(int chain) => _multiplier(chain);
}
