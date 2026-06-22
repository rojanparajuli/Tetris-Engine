import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/engine/collision_system.dart';
import 'package:tetris_engine/engine/rotation_system.dart';
import 'package:tetris_engine/models/board_state.dart';
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
  });
}
