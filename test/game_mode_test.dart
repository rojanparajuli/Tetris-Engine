import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/tetris_engine.dart';

const oneLine = TetrisGameMode(name: 'One line', lineGoal: 1);
const twoSeconds = TetrisGameMode(
  name: 'Two seconds',
  timeLimit: Duration(seconds: 2),
);

/// A manually clocked game in [mode] where hard-dropping the active I piece
/// clears one line.
TetrisGame oneDropFromClear(TetrisGameMode mode) {
  final grid = List.generate(20, (_) => List.filled(10, const Cell.empty()));
  for (var c = 4; c < 10; c++) {
    grid[19][c] = const Cell(filled: true, type: TetrominoType.Z);
  }
  final game = TetrisGame(seed: 1, mode: mode)..useInternalClock = false;
  game.loadFromJson(
    GameState(
      board: BoardState(rows: 20, cols: 10, grid: grid),
      activePiece: Tetromino(
        type: TetrominoType.I,
        position: const Position(10, 0),
      ),
      nextQueue: const [TetrominoType.O, TetrominoType.I, TetrominoType.L],
      scoreState: const ScoreState(),
      levelState: const LevelState(),
      status: TetrisGameStatus.playing,
    ).toJson(),
  );
  game.resume();
  return game;
}

void main() {
  group('TetrisGameMode', () {
    test('built-in modes', () {
      expect(TetrisGameMode.sprint.lineGoal, 40);
      expect(TetrisGameMode.marathon.lineGoal, 150);
      expect(TetrisGameMode.ultra.timeLimit, const Duration(minutes: 2));
      expect(TetrisGameMode.endless.hasGoal, isFalse);
      expect(TetrisGameMode.values, hasLength(4));
    });

    test('JSON round trip and equality', () {
      for (final mode in [...TetrisGameMode.values, oneLine, twoSeconds]) {
        expect(TetrisGameMode.fromJson(mode.toJson()), mode);
      }
    });
  });

  group('line goal', () {
    test('reaching the goal ends the game as goalReached', () async {
      final game = oneDropFromClear(oneLine);
      expect(game.linesRemaining, 1);
      final events = <TetrisEvent>[];
      game.events.listen(events.add);

      game.hardDrop();
      await Future<void>.delayed(Duration.zero);

      expect(game.state.status, TetrisGameStatus.gameOver);
      expect(game.state.endReason, GameEndReason.goalReached);
      expect(game.linesRemaining, 0);
      expect(events.last.type, TetrisEventType.gameOver);
      expect(events.last.endReason, GameEndReason.goalReached);
      expect(game.statistics.bestTime(oneLine), isNotNull);
      expect(game.statistics.bestScore(oneLine), game.state.scoreState.score);
      game.dispose();
    });

    test('endless keeps playing after the same clear', () {
      final game = oneDropFromClear(TetrisGameMode.endless);
      expect(game.linesRemaining, isNull);
      game.hardDrop();
      expect(game.state.status, TetrisGameStatus.playing);
      expect(game.state.endReason, isNull);
      game.dispose();
    });
  });

  group('time limit', () {
    test('internal clock ends the game as timeUp', () {
      fakeAsync((async) {
        final game = TetrisGame(seed: 1, mode: twoSeconds)..start();
        expect(game.timeRemaining, isNotNull);
        async.elapse(const Duration(milliseconds: 1900));
        expect(game.state.status, TetrisGameStatus.playing);
        async.elapse(const Duration(milliseconds: 200));
        expect(game.state.status, TetrisGameStatus.gameOver);
        expect(game.state.endReason, GameEndReason.timeUp);
        game.dispose();
      });
    });

    test('pausing stops the time limit', () {
      fakeAsync((async) {
        final game = TetrisGame(seed: 1, mode: twoSeconds)..start();
        game.pause();
        async.elapse(const Duration(seconds: 10));
        expect(game.state.status, TetrisGameStatus.paused);
        game.resume();
        async.elapse(const Duration(seconds: 3));
        expect(game.state.endReason, GameEndReason.timeUp);
        game.dispose();
      });
    });

    test('expireTimeLimit is recorded and ignored for untimed modes', () {
      final recorder = ReplayRecorder();
      final endless = TetrisGame(seed: 1, recorder: recorder)
        ..useInternalClock = false
        ..start();
      endless.expireTimeLimit();
      expect(endless.state.status, TetrisGameStatus.playing);
      endless.dispose();

      final timed = TetrisGame(seed: 1, mode: twoSeconds, recorder: recorder)
        ..useInternalClock = false
        ..start();
      timed.expireTimeLimit();
      expect(timed.state.endReason, GameEndReason.timeUp);
      expect(recorder.frames.last.action, 'timeUp');
      timed.dispose();
    });

    test('start(mode:) switches modes and topping out is toppedOut', () {
      final game = TetrisGame(seed: 1)..useInternalClock = false;
      game.start(mode: TetrisGameMode.ultra);
      expect(game.mode, TetrisGameMode.ultra);
      while (game.state.status == TetrisGameStatus.playing) {
        game.hardDrop();
      }
      expect(game.state.endReason, GameEndReason.toppedOut);
      game.start();
      expect(game.mode, TetrisGameMode.ultra, reason: 'mode is kept');
      expect(game.state.endReason, isNull);
      game.dispose();
    });
  });

  test('save and load keeps mode and play time', () {
    final game = TetrisGame(seed: 1, mode: TetrisGameMode.ultra)
      ..useInternalClock = false
      ..start();
    final saved = {...game.toJson(), 'playTimeMs': 30000};

    final restored = TetrisGame()..useInternalClock = false;
    restored.loadFromJson(saved);
    expect(restored.mode, TetrisGameMode.ultra);
    expect(
      restored.playTime,
      greaterThanOrEqualTo(const Duration(seconds: 30)),
    );
    expect(
      restored.timeRemaining,
      lessThanOrEqualTo(const Duration(seconds: 90)),
    );
    game.dispose();
    restored.dispose();
  });

  test('per-mode records survive statistics JSON', () {
    final stats = TetrisStatistics()
      ..recordGameOver(
        score: 500,
        level: 2,
        playTimeMs: 60000,
        mode: TetrisGameMode.sprint,
        endReason: GameEndReason.goalReached,
      )
      ..recordGameOver(
        score: 300,
        level: 2,
        playTimeMs: 50000,
        mode: TetrisGameMode.sprint,
        endReason: GameEndReason.toppedOut,
      );
    expect(stats.bestTime(TetrisGameMode.sprint), const Duration(minutes: 1));
    expect(stats.bestScore(TetrisGameMode.sprint), 500);

    final copy = TetrisStatistics()..loadFromJson(stats.toJson());
    expect(copy.bestTimesMs, stats.bestTimesMs);
    expect(copy.bestScores, stats.bestScores);
  });

  testWidgets('game-over overlay shows the end reason and time', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: TetrisGameOverOverlay(
          score: 1200,
          onRestart: () {},
          endReason: GameEndReason.goalReached,
          time: const Duration(minutes: 1, seconds: 5, milliseconds: 430),
        ),
      ),
    );
    expect(find.text('COMPLETE'), findsOneWidget);
    expect(find.text('TIME: 1:05.43'), findsOneWidget);
  });

  testWidgets('GameModePanel shows time left and lines left', (tester) async {
    final game = TetrisGame(
      seed: 1,
      mode: const TetrisGameMode(
        name: 'Both',
        lineGoal: 20,
        timeLimit: Duration(minutes: 3),
      ),
    )..useInternalClock = false;
    game.start();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GameModePanel(game: game),
      ),
    );
    expect(find.text('TIME LEFT'), findsOneWidget);
    expect(find.text('LINES LEFT'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);

    game.expireTimeLimit();
    await tester.pump();
    expect(find.text('0:00.0'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    game.dispose();
  });
}
