/// Callbacks for Tetris effects.
///
/// This class was never wired into the engine. Use `TetrisGame.events`,
/// which reports piece locks, line clears, level ups and more.
@Deprecated(
  'Not connected to the engine. Listen to TetrisGame.events instead. '
  'Will be removed in 2.0.0.',
)
class TetrisAnimationController {
  final void Function()? onPieceLock;
  final void Function(int lines)? onLineClear;
  final void Function()? onGameOver;
  final void Function(int level)? onLevelUp;
  final void Function()? onHardDrop;

  const TetrisAnimationController({
    this.onPieceLock,
    this.onLineClear,
    this.onGameOver,
    this.onLevelUp,
    this.onHardDrop,
  });
}
