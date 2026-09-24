import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/tetris_engine.dart';

/// Builds a 20×10 board from the bottom rows up. `#` is filled, `.` empty.
BoardState boardFromRows(List<String> bottomRows) {
  final grid = List.generate(20, (_) => List.filled(10, const Cell.empty()));
  final top = 20 - bottomRows.length;
  for (var r = 0; r < bottomRows.length; r++) {
    for (var c = 0; c < 10; c++) {
      if (bottomRows[r][c] == '#') {
        grid[top + r][c] = const Cell(filled: true, type: TetrominoType.Z);
      }
    }
  }
  return BoardState(rows: 20, cols: 10, grid: grid);
}

/// A game positioned in [board] with [piece] active, driven manually.
TetrisGame gameWith(BoardState board, Tetromino piece) {
  final game = TetrisGame(seed: 1)..useInternalClock = false;
  game.loadFromJson(
    GameState(
      board: board,
      activePiece: piece,
      nextQueue: const [TetrominoType.O, TetrominoType.I, TetrominoType.L],
      scoreState: const ScoreState(),
      levelState: const LevelState(),
      status: TetrisGameStatus.playing,
    ).toJson(),
  );
  game.resume();
  return game;
}

int piecesLocked(TetrisGame game) =>
    game.statistics.pieceUsage.values.fold(0, (a, b) => a + b);

/// Soft-drops the active piece until it rests on the floor, without locking.
void dropToFloor(TetrisGame game) {
  while (game.state.activePiece!.position != game.state.ghostPiece!.position) {
    game.softDrop();
  }
}

void main() {
  group('TetrisGame', () {
    test('gravity does not award points', () {
      final game = TetrisGame(seed: 3)..useInternalClock = false;
      game.start();
      for (var i = 0; i < 5; i++) {
        game.applyGravity();
      }
      expect(game.state.activePiece!.position.row, 5);
      expect(game.state.scoreState.score, 0);
    });

    test('lock delay lets a grounded piece slide before locking', () {
      fakeAsync((async) {
        final game = TetrisGame(seed: 3);
        game.start();
        dropToFloor(game);
        async.elapse(const Duration(milliseconds: 400));
        expect(piecesLocked(game), 0);

        game.moveLeft(); // resets the lock timer
        async.elapse(const Duration(milliseconds: 400));
        expect(piecesLocked(game), 0);

        async.elapse(const Duration(milliseconds: 150));
        expect(piecesLocked(game), 1);
        game.dispose();
      });
    });

    test('lock resets are capped by maxLockResets', () {
      fakeAsync((async) {
        final game = TetrisGame(seed: 3, maxLockResets: 3);
        game.start();
        dropToFloor(game);
        for (var i = 0; i < 3; i++) {
          i.isEven ? game.moveLeft() : game.moveRight();
        }
        expect(piecesLocked(game), 0);
        game.moveLeft();
        expect(piecesLocked(game), 1);
        game.dispose();
      });
    });

    test('lockDelay zero locks on the next gravity step', () {
      final game = TetrisGame(seed: 3, lockDelay: Duration.zero)
        ..useInternalClock = false;
      game.start();
      dropToFloor(game);
      expect(piecesLocked(game), 0);
      game.applyGravity();
      expect(piecesLocked(game), 1);
    });

    test('pausing stops the lock timer', () {
      fakeAsync((async) {
        final game = TetrisGame(seed: 3);
        game.start();
        dropToFloor(game);
        game.pause();
        async.elapse(const Duration(seconds: 5));
        expect(piecesLocked(game), 0);
        game.resume();
        async.elapse(const Duration(milliseconds: 600));
        expect(piecesLocked(game), 1);
        game.dispose();
      });
    });

    test('holding the first piece advances the next queue', () {
      final game = TetrisGame(seed: 5)..useInternalClock = false;
      game.start();
      final active = game.state.activePiece!.type;
      final queue = game.state.nextQueue;
      game.holdPiece();
      expect(game.state.heldPiece!.type, active);
      expect(game.state.activePiece!.type, queue[0]);
      expect(game.state.nextQueue.first, queue[1]);
      expect(game.state.canHold, isFalse);

      game.holdPiece(); // not allowed twice in a row
      expect(game.state.activePiece!.type, queue[0]);
    });

    test('same seed gives the same pieces', () {
      final a = TetrisGame()..useInternalClock = false;
      final b = TetrisGame()..useInternalClock = false;
      a.start(seed: 1234);
      b.start(seed: 1234);
      for (var i = 0; i < 10; i++) {
        expect(b.state.activePiece, a.state.activePiece);
        expect(b.state.nextQueue, a.state.nextQueue);
        a.hardDrop();
        b.hardDrop();
      }
      expect(a.seed, 1234);
    });

    test('save and load restores board, queue and upcoming pieces', () {
      final a = TetrisGame(seed: 7)..useInternalClock = false;
      a.start();
      a.moveLeft();
      a.hardDrop();
      a.rotateCW();
      final saved = a.toJson();

      final b = TetrisGame(seed: 99)..useInternalClock = false;
      b.loadFromJson(saved);
      expect(b.state.status, TetrisGameStatus.paused);
      expect(b.state.board.toJson(), a.state.board.toJson());
      expect(b.state.nextQueue, a.state.nextQueue);
      expect(b.state.ghostPiece, isNotNull);

      b.resume();
      a.hardDrop();
      b.hardDrop();
      expect(b.state.activePiece, a.state.activePiece);
      expect(b.state.board.toJson(), a.state.board.toJson());
    });

    test('loading a save with a different board size throws', () {
      final small = TetrisGame(boardRows: 10, boardCols: 6, seed: 1);
      expect(
        () => TetrisGame().loadFromJson(small.toJson()),
        throwsArgumentError,
      );
    });

    test('custom board width spawns pieces inside the board', () {
      final game = TetrisGame(boardCols: 6, seed: 2)..useInternalClock = false;
      game.start();
      for (var i = 0; i < 7; i++) {
        expect(
          game.state.activePiece!.cells.every((c) => c.col >= 0 && c.col < 6),
          isTrue,
        );
        game.hardDrop();
      }
    });

    test('statistics can be shared across games', () {
      final stats = TetrisStatistics();
      final a = TetrisGame(seed: 1, statistics: stats)
        ..useInternalClock = false;
      a.start();
      a.hardDrop();
      final b = TetrisGame(seed: 2, statistics: stats)
        ..useInternalClock = false;
      b.start();
      b.hardDrop();
      expect(piecesLocked(a), 2);
      expect(identical(a.statistics, b.statistics), isTrue);
    });

    test('T-Spin Double scores and is reported', () async {
      final game = gameWith(
        boardFromRows(['...#......', '###...####', '####.#####']),
        Tetromino(
          type: TetrominoType.T,
          rotation: 3,
          position: const Position(17, 3),
        ),
      );
      final events = <TetrisEvent>[];
      game.events.listen(events.add);

      game.rotateCCW();
      game.hardDrop();
      await Future<void>.delayed(Duration.zero);

      expect(game.state.scoreState.score, 1200);
      final clear = events.firstWhere(
        (e) => e.type == TetrisEventType.linesCleared,
      );
      expect(clear.lines, 2);
      expect(clear.tSpin, TSpinType.full);
    });

    test('perfect clear is detected', () async {
      final game = gameWith(
        boardFromRows(['....######']),
        Tetromino(type: TetrominoType.I, position: const Position(18, 0)),
      );
      final events = <TetrisEvent>[];
      game.events.listen(events.add);
      game.hardDrop();
      await Future<void>.delayed(Duration.zero);

      expect(game.state.scoreState.score, 100 + 800);
      expect(
        events
            .singleWhere((e) => e.type == TetrisEventType.linesCleared)
            .perfectClear,
        isTrue,
      );
    });

    test('events report moves, locks and game over', () async {
      final game = TetrisGame(seed: 11)..useInternalClock = false;
      final types = <TetrisEventType>[];
      game.events.listen((e) => types.add(e.type));
      game.start();
      game.moveRight();
      game.rotateCW();
      while (game.state.status == TetrisGameStatus.playing) {
        game.hardDrop();
      }
      await Future<void>.delayed(Duration.zero);

      expect(types.first, TetrisEventType.started);
      expect(
        types,
        containsAll([
          TetrisEventType.moved,
          TetrisEventType.rotated,
          TetrisEventType.hardDropped,
          TetrisEventType.locked,
        ]),
      );
      expect(types.last, TetrisEventType.gameOver);
      expect(game.statistics.totalGames, 1);
    });

    test('actions are ignored unless playing', () {
      final game = TetrisGame(seed: 1)..useInternalClock = false;
      game.moveLeft();
      game.hardDrop();
      expect(game.state.status, TetrisGameStatus.idle);
      game.start();
      game.pause();
      final before = game.state.activePiece;
      game.moveLeft();
      game.hardDrop();
      expect(game.state.activePiece, before);
    });
  });

  group('Replay', () {
    test('a recorded game replays exactly', () {
      fakeAsync((async) {
        final recorder = ReplayRecorder();
        final original = TetrisGame(recorder: recorder);
        original.start();

        // Play with a mix of inputs, gravity and lock-delay expiry.
        final script = [
          original.moveLeft,
          original.rotateCW,
          original.moveRight,
          original.softDrop,
          original.holdPiece,
          original.rotateCCW,
          original.hardDrop,
        ];
        for (var i = 0; i < 30; i++) {
          script[i % script.length]();
          async.elapse(Duration(milliseconds: 150 + (i * 37) % 700));
        }
        // Let a piece rest on the stack until the lock delay expires.
        dropToFloor(original);
        async.elapse(const Duration(milliseconds: 600));
        original.moveLeft();

        expect(original.state.status, TetrisGameStatus.playing);
        recorder.stopRecording();
        original.pause();
        expect(piecesLocked(original), greaterThanOrEqualTo(4));

        final json = recorder.exportJson();
        final imported = ReplayRecorder()..importJson(json);
        expect(imported.seed, original.seed);
        expect(
          imported.frames.map((f) => f.action),
          containsAll(['gravity', 'lock']),
        );

        final replayed = TetrisGame(seed: 12345);
        var done = false;
        ReplayPlayer(InputController(replayed)).play(
          imported.frames,
          seed: imported.seed,
          onComplete: () => done = true,
        );
        async.flushTimers(flushPeriodicTimers: false);

        expect(done, isTrue);
        expect(replayed.state.board.toJson(), original.state.board.toJson());
        expect(
          replayed.state.scoreState.score,
          original.state.scoreState.score,
        );
        expect(replayed.state.activePiece, original.state.activePiece);
        expect(replayed.state.heldPiece, original.state.heldPiece);
        expect(replayed.state.status, TetrisGameStatus.paused);
        expect(replayed.useInternalClock, isTrue);
        original.dispose();
        replayed.dispose();
      });
    });
  });
}
