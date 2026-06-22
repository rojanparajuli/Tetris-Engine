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

  double get averageScore => totalGames == 0 ? 0 : totalScore / totalGames;

  void recordGameOver({required int score, required int level, required int playTimeMs}) {
    totalGames++;
    totalScore += score;
    totalPlayTimeMs += playTimeMs;
    if (score > highestScore) highestScore = score;
    if (level > highestLevel) highestLevel = level;
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
  }
}
