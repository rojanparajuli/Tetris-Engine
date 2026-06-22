
import 'package:tetris_engine/models/game_state.dart';

import '../engine/tetris_game.dart';

/// Maps high-level action strings to game engine calls.
class InputController {
  final TetrisGame game;

  InputController(this.game);

  void dispatch(String action) {
    switch (action) {
      case 'moveLeft':   game.moveLeft(); break;
      case 'moveRight':  game.moveRight(); break;
      case 'softDrop':   game.softDrop(); break;
      case 'hardDrop':   game.hardDrop(); break;
      case 'rotCW':      game.rotateCW(); break;
      case 'rotCCW':     game.rotateCCW(); break;
      case 'hold':       game.holdPiece(); break;
      case 'pause':
        if (game.state.status == TetrisGameStatus.playing) {
          game.pause();
        } else if (game.state.status == TetrisGameStatus.paused) {
          game.resume();
        }
        break;
    }
  }
}
