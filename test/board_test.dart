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
      // Build a 4×4 board with row 3 fully filled using the I-piece
      var board = BoardState(rows: 4, cols: 4);
      final piece = Tetromino(
        type: TetrominoType.I,
        rotation: 0,
        position: const Position(3, 0),
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
          position: Position(row, 0),
        );
        board = board.withPieceLocked(piece);
      }
      final (_, count) = board.clearLines();
      expect(count, 2);
    });
  });
}
