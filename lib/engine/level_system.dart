import '../models/level_state.dart';

/// Manages level progression.
class LevelSystem {
  const LevelSystem();

  /// Returns updated [LevelState] after clearing [linesCleared] lines.
  LevelState onLinesCleared(LevelState state, int linesCleared) {
    if (linesCleared == 0) return state;

    final newTotal = state.linesCleared + linesCleared;
    final newUntil = state.linesUntilNextLevel - linesCleared;

    if (newUntil <= 0) {
      return LevelState(
        level: state.level + 1,
        linesCleared: newTotal,
        linesUntilNextLevel: 10 + newUntil.abs(),
      );
    }

    return state.copyWith(
      linesCleared: newTotal,
      linesUntilNextLevel: newUntil,
    );
  }
}
