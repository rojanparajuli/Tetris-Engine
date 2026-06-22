import 'package:flutter/services.dart';
import '../controllers/input_controller.dart';

/// Maps keyboard [LogicalKeyboardKey]s to game actions.
/// Wire this to a [Focus] or [RawKeyboardListener] widget.
class TetrisKeyboardHandler {
  final InputController input;

  /// Customizable key mapping.
  final Map<LogicalKeyboardKey, String> keyMap;

  TetrisKeyboardHandler(this.input, {Map<LogicalKeyboardKey, String>? keyMap})
      : keyMap = keyMap ?? _defaultKeyMap;

  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    final action = keyMap[event.logicalKey];
    if (action == null) return false;
    input.dispatch(action);
    return true;
  }

  static final Map<LogicalKeyboardKey, String> _defaultKeyMap = {
    LogicalKeyboardKey.arrowLeft:  'moveLeft',
    LogicalKeyboardKey.arrowRight: 'moveRight',
    LogicalKeyboardKey.arrowDown:  'softDrop',
    LogicalKeyboardKey.arrowUp:    'rotCW',
    LogicalKeyboardKey.keyA:       'moveLeft',
    LogicalKeyboardKey.keyD:       'moveRight',
    LogicalKeyboardKey.keyS:       'softDrop',
    LogicalKeyboardKey.keyW:       'rotCW',
    LogicalKeyboardKey.keyZ:       'rotCCW',
    LogicalKeyboardKey.space:      'hardDrop',
    LogicalKeyboardKey.keyC:       'hold',
    LogicalKeyboardKey.keyP:       'pause',
    LogicalKeyboardKey.escape:     'pause',
  };
}
