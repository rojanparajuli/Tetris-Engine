import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/tetris_game.dart';
import '../models/game_state.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';

/// On-screen buttons for touch devices.
///
/// Move and soft-drop buttons auto-repeat while held: the first repeat comes
/// after [repeatDelay], then every [repeatInterval] (the "DAS" and "ARR"
/// settings in competitive Tetris).
///
/// ```dart
/// Column(children: [
///   Expanded(child: TetrisBoard(game: game)),
///   TetrisControlPad(game: game, theme: darkTetrisTheme),
/// ])
/// ```
class TetrisControlPad extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme? theme;
  final double buttonSize;
  final double spacing;
  final Duration repeatDelay;
  final Duration repeatInterval;
  final bool showPauseButton;

  /// Play a light haptic tick on each button press.
  final bool hapticFeedback;

  const TetrisControlPad({
    super.key,
    required this.game,
    this.theme,
    this.buttonSize = 44,
    this.spacing = 8,
    this.repeatDelay = const Duration(milliseconds: 170),
    this.repeatInterval = const Duration(milliseconds: 50),
    this.showPauseButton = true,
    this.hapticFeedback = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    final fg = t.valueStyle.color ?? Colors.white;

    Widget button(
      IconData icon,
      String tooltip,
      VoidCallback action, {
      bool repeat = false,
    }) => TetrisPadButton(
      icon: icon,
      tooltip: tooltip,
      onPressed: action,
      size: buttonSize,
      color: fg,
      repeatDelay: repeat ? repeatDelay : null,
      repeatInterval: repeatInterval,
      hapticFeedback: hapticFeedback,
    );

    final gap = SizedBox(width: spacing);
    return Container(
      color: t.panelBackground,
      padding: EdgeInsets.all(spacing),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: spacing * 2,
        runSpacing: spacing,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              button(
                Icons.chevron_left,
                'Move left',
                game.moveLeft,
                repeat: true,
              ),
              gap,
              button(
                Icons.chevron_right,
                'Move right',
                game.moveRight,
                repeat: true,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              button(
                Icons.rotate_left,
                'Rotate counter-clockwise',
                game.rotateCCW,
              ),
              gap,
              button(Icons.rotate_right, 'Rotate clockwise', game.rotateCW),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              button(Icons.swap_vert, 'Hold', game.holdPiece),
              gap,
              button(
                Icons.keyboard_arrow_down,
                'Soft drop',
                game.softDrop,
                repeat: true,
              ),
              gap,
              button(Icons.vertical_align_bottom, 'Hard drop', game.hardDrop),
            ],
          ),
          if (showPauseButton)
            ListenableBuilder(
              listenable: game,
              builder: (_, _) {
                final playing = game.state.status == TetrisGameStatus.playing;
                return button(
                  playing ? Icons.pause : Icons.play_arrow,
                  playing ? 'Pause' : 'Resume',
                  game.togglePause,
                );
              },
            ),
        ],
      ),
    );
  }
}

/// A single square control button that can auto-repeat while held.
///
/// Used by [TetrisControlPad]; exposed so you can build custom layouts.
class TetrisPadButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;
  final Color color;

  /// Delay before auto-repeat starts. Null disables auto-repeat.
  final Duration? repeatDelay;
  final Duration repeatInterval;
  final bool hapticFeedback;

  const TetrisPadButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
    this.color = Colors.white,
    this.repeatDelay,
    this.repeatInterval = const Duration(milliseconds: 50),
    this.hapticFeedback = false,
  });

  @override
  State<TetrisPadButton> createState() => _TetrisPadButtonState();
}

class _TetrisPadButtonState extends State<TetrisPadButton> {
  Timer? _repeat;
  bool _pressed = false;

  void _down() {
    setState(() => _pressed = true);
    _fire();
    final delay = widget.repeatDelay;
    if (delay == null) return;
    _repeat = Timer(delay, () {
      _repeat = Timer.periodic(widget.repeatInterval, (_) => _fire());
    });
  }

  void _up() {
    _repeat?.cancel();
    _repeat = null;
    if (mounted) setState(() => _pressed = false);
  }

  void _fire() {
    if (widget.hapticFeedback) HapticFeedback.selectionClick();
    widget.onPressed();
  }

  @override
  void dispose() {
    _repeat?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    return Semantics(
      button: true,
      label: widget.tooltip,
      onTap: widget.onPressed,
      child: Listener(
        onPointerDown: (_) => _down(),
        onPointerUp: (_) => _up(),
        onPointerCancel: (_) => _up(),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: c.withAlpha(_pressed ? 40 : 12),
            border: Border.all(color: c.withAlpha(40)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            widget.icon,
            color: c.withAlpha(200),
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}
