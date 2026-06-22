import 'package:flutter/widgets.dart';
import '../controllers/input_controller.dart';

/// Wraps a child widget with swipe + tap gesture controls.
///
/// - Swipe left/right → move
/// - Swipe down (fast) → hard drop
/// - Swipe down (slow) → soft drop
/// - Tap → rotate CW
/// - Long press → hold
class TetrisGestureHandler extends StatefulWidget {
  final Widget child;
  final InputController input;
  final double swipeThreshold;

  const TetrisGestureHandler({
    super.key,
    required this.child,
    required this.input,
    this.swipeThreshold = 20.0,
  });

  @override
  State<TetrisGestureHandler> createState() => _TetrisGestureHandlerState();
}

class _TetrisGestureHandlerState extends State<TetrisGestureHandler> {
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.input.dispatch('rotCW'),
      onLongPress: () => widget.input.dispatch('hold'),
      onPanStart: (d) => _dragStart = d.localPosition,
      onPanUpdate: (d) {
        final start = _dragStart;
        if (start == null) return;
        final dx = d.localPosition.dx - start.dx;
        final dy = d.localPosition.dy - start.dy;
        final t = widget.swipeThreshold;
        if (dx.abs() > dy.abs()) {
          if (dx > t) { widget.input.dispatch('moveRight'); _dragStart = d.localPosition; }
          else if (dx < -t) { widget.input.dispatch('moveLeft'); _dragStart = d.localPosition; }
        } else {
          if (dy > t) { widget.input.dispatch('softDrop'); _dragStart = d.localPosition; }
        }
      },
      onPanEnd: (d) {
        final velocity = d.velocity.pixelsPerSecond;
        if (velocity.dy > 800) widget.input.dispatch('hardDrop');
        _dragStart = null;
      },
      child: widget.child,
    );
  }
}
