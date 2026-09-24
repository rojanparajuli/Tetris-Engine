import '../models/level_state.dart';

/// Manages level progression.
class LevelSystem {
  /// Number of cleared lines required to advance one level.
  final int linesPerLevel;

  const LevelSystem({this.linesPerLevel = 10})
    : assert(linesPerLevel > 0, 'linesPerLevel must be positive');

  /// The level state a new game starts with.
  LevelState initialState({int startLevel = 1}) =>
      LevelState(level: startLevel, linesUntilNextLevel: linesPerLevel);

  /// Returns updated [LevelState] after clearing [linesCleared] lines.
  ///
  /// Lines beyond the level threshold carry over towards the next level, and
  /// clearing enough lines at once can advance more than one level.
  LevelState onLinesCleared(LevelState state, int linesCleared) {
    if (linesCleared == 0) return state;

    var level = state.level;
    var until = state.linesUntilNextLevel - linesCleared;
    while (until <= 0) {
      level++;
      until += linesPerLevel;
    }

    return LevelState(
      level: level,
      linesCleared: state.linesCleared + linesCleared,
      linesUntilNextLevel: until,
    );
  }
}
