import 'package:flutter/material.dart';
import '../engine/tetris_game.dart';
import '../themes/level_themes.dart';
import '../themes/tetris_theme.dart';

/// Rebuilds [builder] with the theme for [game]'s current level.
///
/// Only rebuilds when the level's theme changes, so it is cheap to wrap a
/// whole game layout. Pass widgets that do not depend on the theme as [child].
class LevelThemeBuilder extends StatefulWidget {
  final TetrisGame game;
  final LevelThemes levelThemes;
  final Widget Function(BuildContext context, TetrisTheme theme, Widget? child)
  builder;
  final Widget? child;

  const LevelThemeBuilder({
    super.key,
    required this.game,
    required this.levelThemes,
    required this.builder,
    this.child,
  });

  @override
  State<LevelThemeBuilder> createState() => _LevelThemeBuilderState();
}

class _LevelThemeBuilderState extends State<LevelThemeBuilder> {
  late TetrisTheme _theme;

  TetrisTheme get _current =>
      widget.levelThemes.forLevel(widget.game.state.levelState.level);

  @override
  void initState() {
    super.initState();
    _theme = _current;
    widget.game.addListener(_onGameChanged);
  }

  @override
  void didUpdateWidget(LevelThemeBuilder old) {
    super.didUpdateWidget(old);
    if (old.game != widget.game) {
      old.game.removeListener(_onGameChanged);
      widget.game.addListener(_onGameChanged);
    }
    _theme = _current;
  }

  void _onGameChanged() {
    final next = _current;
    if (!identical(next, _theme)) setState(() => _theme = next);
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _theme, widget.child);
}
