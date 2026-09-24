import '../engine/tetris_game.dart';

/// Maps high-level action strings to game engine calls.
///
/// Supported actions: `moveLeft`, `moveRight`, `softDrop`, `hardDrop`,
/// `rotCW`, `rotCCW`, `hold`, `pause` (toggles pause/resume), `resume`,
/// and the clock actions `gravity` and `lock` used by replays.
class InputController {
  final TetrisGame game;

  InputController(this.game);

  void dispatch(String action) {
    switch (action) {
      case 'moveLeft':
        game.moveLeft();
        break;
      case 'moveRight':
        game.moveRight();
        break;
      case 'softDrop':
        game.softDrop();
        break;
      case 'hardDrop':
        game.hardDrop();
        break;
      case 'rotCW':
        game.rotateCW();
        break;
      case 'rotCCW':
        game.rotateCCW();
        break;
      case 'hold':
        game.holdPiece();
        break;
      case 'pause':
        game.togglePause();
        break;
      case 'resume':
        game.resume();
        break;
      case 'gravity':
        game.applyGravity();
        break;
      case 'lock':
        game.lockActivePiece();
        break;
    }
  }
}
