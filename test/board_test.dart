import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/models/board_state.dart';
import 'package:tetris_engine/models/position.dart';
import 'package:tetris_engine/models/tetromino.dart';

void main() {
  group('BoardState.clearLines', () {
    test('no lines cleared on empty board', () {
      final board = BoardState(rows: 4, cols: 4);
      final (newBoard, count) = board.clearLines();
      expect(count, 0);
      expect(newBoard.rows, 4);
    });

    test('full row is cleared', () {
      // Build a 4×4 board with row 3 fully filled using the I-piece.
      // A flat I piece occupies the row below its anchor.
      var board = BoardState(rows: 4, cols: 4);
      final piece = Tetromino(
        type: TetrominoType.I,
        rotation: 0,
        position: const Position(2, 0),
      );
      board = board.withPieceLocked(piece);

      final (cleared, count) = board.clearLines();
      expect(count, 1);
      // Top row should now be empty
      expect(cleared.cellAt(0, 0).filled, isFalse);
    });

    test('multiple rows cleared simultaneously', () {
      var board = BoardState(rows: 5, cols: 4);
      // Fill rows 3 and 4 completely with I pieces (horizontal)
      for (final row in [3, 4]) {
        final piece = Tetromino(
          type: TetrominoType.I,
          rotation: 0,
          position: Position(row - 1, 0),
        );
        board = board.withPieceLocked(piece);
      }
      final (cleared, count) = board.clearLines();
      expect(count, 2);
      expect(cleared.isEmpty, isTrue);
    });

    test('rows above a cleared row shift down', () {
      var board = BoardState(rows: 4, cols: 4);
      board = board.withPieceLocked(
        Tetromino(type: TetrominoType.O, position: const Position(1, 0)),
      );
      board = board.withPieceLocked(
        Tetromino(type: TetrominoType.O, position: const Position(2, 2)),
      );
      // Row 2 is now full (cols 0-1 from the first O, 2-3 from the second).
      final (cleared, count) = board.clearLines();
      expect(count, 1);
      expect(cleared.cellAt(2, 0).filled, isTrue);
      expect(cleared.cellAt(3, 2).filled, isTrue);
      expect(cleared.cellAt(1, 0).filled, isFalse);
    });
  });

  test('JSON round trip preserves the grid', () {
    final board = BoardState(rows: 4, cols: 4).withPieceLocked(
      Tetromino(type: TetrominoType.T, position: const Position(1, 0)),
    );
    final restored = BoardState.fromJson(board.toJson());
    expect(restored.toJson(), board.toJson());
  });
}
