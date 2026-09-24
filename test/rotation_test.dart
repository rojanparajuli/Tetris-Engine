import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/engine/collision_system.dart';
import 'package:tetris_engine/engine/rotation_system.dart';
import 'package:tetris_engine/models/board_state.dart';
import 'package:tetris_engine/models/position.dart';
import 'package:tetris_engine/models/tetromino.dart';

void main() {
  final collision = const CollisionSystem();
  final rotation = RotationSystem(collision);
  final board = BoardState(rows: 20, cols: 10);

  group('RotationSystem', () {
    test('T piece rotates CW on empty board', () {
      final piece = Tetromino.spawn(TetrominoType.T);
      final rotated = rotation.rotateCW(piece, board);
      expect(rotated, isNotNull);
      expect(rotated!.rotation, 1);
    });

    test('O piece rotation is identity', () {
      final piece = Tetromino.spawn(TetrominoType.O);
      final rotated = rotation.rotateCW(piece, board);
      expect(rotated, isNotNull);
      // O piece cells don't change
      expect(rotated!.cells, unorderedEquals(piece.cells));
    });

    test('I piece CW → CCW returns to original rotation', () {
      final piece = Tetromino.spawn(TetrominoType.I);
      final cw = rotation.rotateCW(piece, board);
      expect(cw, isNotNull);
      final back = rotation.rotateCCW(cw!, board);
      expect(back, isNotNull);
      expect(back!.rotation, piece.rotation);
    });

    test('full 360 CW rotation returns to rotation 0', () {
      var piece = Tetromino.spawn(TetrominoType.T);
      for (int i = 0; i < 4; i++) {
        piece = rotation.rotateCW(piece, board)!;
      }
      expect(piece.rotation, 0);
    });

    test('wall kick moves I piece away from the right wall', () {
      // Vertical I in the rightmost column, rotation 1 (cells in col 9).
      final piece = Tetromino(
        type: TetrominoType.I,
        rotation: 1,
        position: const Position(5, 7),
      );
      final result = rotation.tryRotate(piece, board, clockwise: true);
      expect(result, isNotNull);
      expect(result!.kickIndex, greaterThan(0));
      expect(result.piece.cells.every((c) => c.col < 10), isTrue);
    });

    test('rotation fails when completely boxed in', () {
      final full = BoardState.fromJson({
        'rows': 20,
        'cols': 10,
        'grid': List.generate(
          20,
          (r) => List.generate(
            10,
            (c) => {'filled': r > 1, 'type': r > 1 ? 0 : null},
          ),
        ),
      });
      final piece = Tetromino(
        type: TetrominoType.I,
        position: const Position(0, 3),
      );
      expect(rotation.rotateCW(piece, full), isNull);
    });
  });

  group('T-Spin detection', () {
    // Bottom rows of a T-Spin Double slot, with an overhang at (17, 3).
    BoardState tSlot() {
      final b = BoardState(rows: 20, cols: 10);
      final grid = b.grid.map((r) => [...r]).toList();
      for (var c = 0; c < 10; c++) {
        if (c != 4) grid[19][c] = grid[19][c].copyWith(filled: true);
        if (c < 3 || c > 5) grid[18][c] = grid[18][c].copyWith(filled: true);
      }
      grid[17][3] = grid[17][3].copyWith(filled: true);
      return BoardState(rows: 20, cols: 10, grid: grid);
    }

    test('T pointing into the slot with 3 corners is a full T-Spin', () {
      final piece = Tetromino(
        type: TetrominoType.T,
        rotation: 2,
        position: const Position(17, 3),
      );
      expect(rotation.detectTSpin(piece, tSlot()), TSpinType.full);
    });

    test('only one front corner is a mini', () {
      final piece = Tetromino(
        type: TetrominoType.T,
        rotation: 1,
        position: const Position(17, 3),
      );
      expect(rotation.detectTSpin(piece, tSlot()), TSpinType.mini);
      expect(
        rotation.detectTSpin(piece, tSlot(), kickIndex: 4),
        TSpinType.full,
      );
    });

    test('open space is not a T-Spin', () {
      final piece = Tetromino.spawn(TetrominoType.T);
      expect(rotation.detectTSpin(piece, board), TSpinType.none);
    });

    test('non-T pieces never T-Spin', () {
      final piece = Tetromino(
        type: TetrominoType.S,
        position: const Position(17, 3),
      );
      expect(rotation.detectTSpin(piece, tSlot()), TSpinType.none);
    });
  });
}
