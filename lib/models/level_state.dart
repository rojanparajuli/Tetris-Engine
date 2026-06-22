/// Tracks the current level and line-count state.
class LevelState {
  final int level;
  final int linesCleared;
  final int linesUntilNextLevel;

  const LevelState({
    this.level = 1,
    this.linesCleared = 0,
    this.linesUntilNextLevel = 10,
  });

  LevelState copyWith({int? level, int? linesCleared, int? linesUntilNextLevel}) =>
      LevelState(
        level: level ?? this.level,
        linesCleared: linesCleared ?? this.linesCleared,
        linesUntilNextLevel: linesUntilNextLevel ?? this.linesUntilNextLevel,
      );

  /// Gravity delay in milliseconds for the current level.
  int get gravityMs {
    // Guideline formula approximation: 1000ms at level 1, faster each level.
    const base = 1000;
    final reduction = (level - 1) * 80;
    return (base - reduction).clamp(50, base);
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'linesCleared': linesCleared,
    'linesUntilNextLevel': linesUntilNextLevel,
  };

  factory LevelState.fromJson(Map<String, dynamic> json) => LevelState(
    level: json['level'] as int,
    linesCleared: json['linesCleared'] as int,
    linesUntilNextLevel: json['linesUntilNextLevel'] as int,
  );
}
