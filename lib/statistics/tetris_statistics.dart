import '../models/game_mode.dart';
import '../models/tetromino.dart';

/// Tracks aggregate stats across games.
class TetrisStatistics {
  int totalGames = 0;
  int highestScore = 0;
  int totalScore = 0;
  int totalLinesCleared = 0;
  int highestLevel = 0;
  int totalPlayTimeMs = 0;
  final Map<TetrominoType, int> pieceUsage = {
    for (final t in TetrominoType.values) t: 0,
  };

  /// Fastest time in milliseconds to reach each mode's line goal, keyed by
  /// [TetrisGameMode.name] (e.g. the best Sprint time).
  final Map<String, int> bestTimesMs = {};

  /// Highest score per mode, keyed by [TetrisGameMode.name].
  final Map<String, int> bestScores = {};

  /// Fastest goal time for [mode], or null if it was never completed.
  Duration? bestTime(TetrisGameMode mode) {
    final ms = bestTimesMs[mode.name];
    return ms == null ? null : Duration(milliseconds: ms);
  }

  /// Highest score in [mode], or null if it was never played.
  int? bestScore(TetrisGameMode mode) => bestScores[mode.name];

  double get averageScore => totalGames == 0 ? 0 : totalScore / totalGames;

  void recordGameOver({
    required int score,
    required int level,
    required int playTimeMs,
    TetrisGameMode? mode,
    GameEndReason? endReason,
  }) {
    totalGames++;
    totalScore += score;
    totalPlayTimeMs += playTimeMs;
    if (score > highestScore) highestScore = score;
    if (level > highestLevel) highestLevel = level;
    if (mode == null) return;
    if (score > (bestScores[mode.name] ?? -1)) bestScores[mode.name] = score;
    if (endReason == GameEndReason.goalReached &&
        playTimeMs < (bestTimesMs[mode.name] ?? playTimeMs + 1)) {
      bestTimesMs[mode.name] = playTimeMs;
    }
  }

  void recordLineClear(int lines) => totalLinesCleared += lines;

  void recordPieceLocked(TetrominoType type) =>
      pieceUsage[type] = (pieceUsage[type] ?? 0) + 1;

  void reset() {
    totalGames = 0;
    highestScore = 0;
    totalScore = 0;
    totalLinesCleared = 0;
    highestLevel = 0;
    totalPlayTimeMs = 0;
    bestTimesMs.clear();
    bestScores.clear();
    for (final t in TetrominoType.values) {
      pieceUsage[t] = 0;
    }
  }

  Map<String, dynamic> toJson() => {
    'totalGames': totalGames,
    'highestScore': highestScore,
    'totalScore': totalScore,
    'totalLinesCleared': totalLinesCleared,
    'highestLevel': highestLevel,
    'totalPlayTimeMs': totalPlayTimeMs,
    'pieceUsage': pieceUsage.map((k, v) => MapEntry(k.name, v)),
    'bestTimesMs': bestTimesMs,
    'bestScores': bestScores,
  };

  void loadFromJson(Map<String, dynamic> json) {
    totalGames = json['totalGames'] as int;
    highestScore = json['highestScore'] as int;
    totalScore = json['totalScore'] as int;
    totalLinesCleared = json['totalLinesCleared'] as int;
    highestLevel = json['highestLevel'] as int;
    totalPlayTimeMs = json['totalPlayTimeMs'] as int;
    final usage = json['pieceUsage'] as Map<String, dynamic>;
    for (final t in TetrominoType.values) {
      pieceUsage[t] = (usage[t.name] as int?) ?? 0;
    }
    bestTimesMs
      ..clear()
      ..addAll(_intMap(json['bestTimesMs']));
    bestScores
      ..clear()
      ..addAll(_intMap(json['bestScores']));
  }

  static Map<String, int> _intMap(Object? json) => json is Map<String, dynamic>
      ? json.map((k, v) => MapEntry(k, v as int))
      : const {};
}
