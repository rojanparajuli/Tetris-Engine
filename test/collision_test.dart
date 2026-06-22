import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/engine/collision_system.dart';
import 'package:tetris_engine/models/board_state.dart';
import 'package:tetris_engine/models/position.dart';
import 'package:tetris_engine/models/tetromino.dart';

void main() {
  final collision = const CollisionSystem();

  BoardState emptyBoard({int rows = 20, int cols = 10}) =>
      BoardState(rows: rows, cols: cols);

  group('CollisionSystem', () {
    test('no collision on empty board at spawn', () {
      final board = emptyBoard();
      final piece = Tetromino.spawn(TetrominoType.T);
      expect(collision.hasCollision(piece, board), isFalse);
    });

    test('out-of-bounds left', () {
      final board = emptyBoard();
      final piece = Tetromino(type: TetrominoType.I, position: const Position(5, -2));
      expect(collision.hasCollision(piece, board), isTrue);
    });

    test('out-of-bounds right', () {
      final board = emptyBoard();
      final piece = Tetromino(type: TetrominoType.I, position: const Position(5, 9));
      expect(collision.hasCollision(piece, board), isTrue);
    });

    test('out-of-bounds bottom', () {
      final board = emptyBoard();
      final piece = Tetromino(type: TetrominoType.O, position: const Position(20, 4));
      expect(collision.hasCollision(piece, board), isTrue);
    });

    test('collision with locked cell', () {
      var board = emptyBoard();
      final locked = Tetromino(type: TetrominoType.O, position: const Position(18, 4));
      board = board.withPieceLocked(locked);
      final piece = Tetromino(type: TetrominoType.O, position: const Position(18, 4));
      expect(collision.hasCollision(piece, board), isTrue);
    });

    test('ghost piece lands at bottom on empty board', () {
      final board = emptyBoard();
      final piece = Tetromino.spawn(TetrominoType.O);
      final ghost = collision.ghostPiece(piece, board);
      expect(ghost.position.row, greaterThan(piece.position.row));
    });

    test('canMove returns false when blocked below', () {
      var board = emptyBoard();
      final bottom = Tetromino(type: TetrominoType.I, rotation: 0, position: const Position(18, 0));
      board = board.withPieceLocked(bottom);
      final piece = Tetromino(type: TetrominoType.I, rotation: 0, position: const Position(17, 0));
      expect(collision.canMove(piece, board, 1, 0), isFalse);
    });
  });
}
