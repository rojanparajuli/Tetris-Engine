import '../models/score_state.dart';

/// Tetris Guideline scoring.
class ScoringSystem {
  const ScoringSystem();

  /// Returns a new [ScoreState] after clearing [linesCleared] lines.
  /// [level] is used for point multipliers.
  ScoreState onLinesCleared(ScoreState state, int linesCleared, int level) {
    if (linesCleared == 0) {
      return state.copyWith(combo: 0, backToBack: false);
    }

    final bool isTetris = linesCleared == 4;
    final bool b2b = isTetris && state.backToBack;

    int base = _basePoints(linesCleared) * level;
    if (b2b) base = (base * 1.5).toInt();

    int comboBonus = 0;
    if (state.combo > 0) comboBonus = 50 * state.combo * level;

    return state.copyWith(
      score: state.score + base + comboBonus,
      combo: state.combo + 1,
      backToBack: isTetris,
    );
  }

  /// Points for soft drop (1 per cell) and hard drop (2 per cell).
  ScoreState onSoftDrop(ScoreState state, int cells) =>
      state.copyWith(score: state.score + cells);

  ScoreState onHardDrop(ScoreState state, int cells) =>
      state.copyWith(score: state.score + cells * 2);

  int _basePoints(int lines) {
    switch (lines) {
      case 1: return 100;
      case 2: return 300;
      case 3: return 500;
      case 4: return 800;
      default: return 0;
    }
  }
}
