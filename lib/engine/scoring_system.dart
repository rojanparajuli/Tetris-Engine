import '../models/score_state.dart';
import '../models/tetromino.dart';

/// Tetris Guideline scoring.
class ScoringSystem {
  const ScoringSystem();

  /// Returns a new [ScoreState] after a piece locks and clears [linesCleared]
  /// lines. [level] is used for point multipliers.
  ///
  /// [tSpin] awards T-Spin points, and [perfectClear] adds the perfect clear
  /// bonus when the board is left empty.
  ///
  /// Back-to-back is kept alive by consecutive "difficult" clears (Tetrises
  /// and T-Spin line clears) and is only broken by an ordinary line clear;
  /// placing a piece that clears nothing does not break it.
  ScoreState onLinesCleared(
    ScoreState state,
    int linesCleared,
    int level, {
    TSpinType tSpin = TSpinType.none,
    bool perfectClear = false,
  }) {
    if (linesCleared == 0) {
      // A T-Spin with no lines still scores, but ends any combo.
      return state.copyWith(
        score: state.score + _tSpinPoints(tSpin, 0) * level,
        combo: 0,
      );
    }

    final difficult = linesCleared == 4 || tSpin != TSpinType.none;
    final b2b = difficult && state.backToBack;

    var base =
        (tSpin == TSpinType.none
            ? _basePoints(linesCleared)
            : _tSpinPoints(tSpin, linesCleared)) *
        level;
    if (b2b) base = (base * 1.5).toInt();

    var comboBonus = 0;
    if (state.combo > 0) comboBonus = 50 * state.combo * level;

    var pcBonus = 0;
    if (perfectClear) {
      pcBonus =
          (linesCleared == 4 && b2b
              ? 3200
              : _perfectClearPoints(linesCleared)) *
          level;
    }

    return state.copyWith(
      score: state.score + base + comboBonus + pcBonus,
      combo: state.combo + 1,
      backToBack: difficult,
    );
  }

  /// Points for soft drop (1 per cell) and hard drop (2 per cell).
  ScoreState onSoftDrop(ScoreState state, int cells) =>
      state.copyWith(score: state.score + cells);

  ScoreState onHardDrop(ScoreState state, int cells) =>
      state.copyWith(score: state.score + cells * 2);

  int _basePoints(int lines) => switch (lines) {
    1 => 100,
    2 => 300,
    3 => 500,
    4 => 800,
    _ => 0,
  };

  int _tSpinPoints(TSpinType tSpin, int lines) => switch (tSpin) {
    TSpinType.none => 0,
    TSpinType.mini => switch (lines) {
      0 => 100,
      1 => 200,
      _ => 400,
    },
    TSpinType.full => switch (lines) {
      0 => 400,
      1 => 800,
      2 => 1200,
      _ => 1600,
    },
  };

  int _perfectClearPoints(int lines) => switch (lines) {
    1 => 800,
    2 => 1200,
    3 => 1800,
    4 => 2000,
    _ => 0,
  };
}
