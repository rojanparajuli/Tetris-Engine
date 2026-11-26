/// Rules for when a game ends besides topping out.
///
/// Use one of the built-in modes or define your own:
///
/// ```dart
/// final game = TetrisGame(mode: TetrisGameMode.sprint)..start();
///
/// // A 20-line sprint with a 3-minute cap.
/// const sprint20 = TetrisGameMode(
///   name: 'Sprint 20',
///   lineGoal: 20,
///   timeLimit: Duration(minutes: 3),
/// );
/// ```
class TetrisGameMode {
  /// Display name, also used as the key for per-mode records in
  /// `TetrisStatistics`.
  final String name;

  /// The game ends with [GameEndReason.goalReached] once this many lines are
  /// cleared. Null means no line goal.
  final int? lineGoal;

  /// The game ends with [GameEndReason.timeUp] after this much play time
  /// (pauses excluded). Null means no time limit.
  final Duration? timeLimit;

  const TetrisGameMode({required this.name, this.lineGoal, this.timeLimit})
    : assert(lineGoal == null || lineGoal > 0, 'lineGoal must be positive');

  /// Play until topping out. The default.
  static const endless = TetrisGameMode(name: 'Endless');

  /// Clear 150 lines (15 levels at the default 10 lines per level).
  static const marathon = TetrisGameMode(name: 'Marathon', lineGoal: 150);

  /// Clear 40 lines as fast as possible; the result is the play time.
  static const sprint = TetrisGameMode(name: 'Sprint', lineGoal: 40);

  /// Score as many points as possible in two minutes.
  static const ultra = TetrisGameMode(
    name: 'Ultra',
    timeLimit: Duration(minutes: 2),
  );

  /// The built-in modes, in menu order.
  static const List<TetrisGameMode> values = [endless, marathon, sprint, ultra];

  /// Whether the game ends after [timeLimit].
  bool get isTimed => timeLimit != null;

  /// Whether the game has an end besides topping out.
  bool get hasGoal => lineGoal != null || timeLimit != null;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (lineGoal != null) 'lineGoal': lineGoal,
    if (timeLimit != null) 'timeLimitMs': timeLimit!.inMilliseconds,
  };

  factory TetrisGameMode.fromJson(Map<String, dynamic> json) {
    final limitMs = json['timeLimitMs'] as int?;
    return TetrisGameMode(
      name: json['name'] as String,
      lineGoal: json['lineGoal'] as int?,
      timeLimit: limitMs == null ? null : Duration(milliseconds: limitMs),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TetrisGameMode &&
      other.name == name &&
      other.lineGoal == lineGoal &&
      other.timeLimit == timeLimit;

  @override
  int get hashCode => Object.hash(name, lineGoal, timeLimit);

  @override
  String toString() => 'TetrisGameMode($name)';
}

/// Why a game ended. See `GameState.endReason`.
enum GameEndReason {
  /// The stack reached the top: a new piece could not spawn.
  toppedOut,

  /// The mode's [TetrisGameMode.lineGoal] was reached.
  goalReached,

  /// The mode's [TetrisGameMode.timeLimit] ran out.
  timeUp,
}
