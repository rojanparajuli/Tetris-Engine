/// Holds references to Flutter AnimationControllers used for Tetris effects.
/// Pass an instance to [TetrisBoard] to hook into piece lock, line clear, etc.
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
