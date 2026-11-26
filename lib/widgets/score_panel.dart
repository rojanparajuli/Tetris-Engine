import 'dart:async';
import 'package:flutter/widgets.dart';
import '../models/game_state.dart';
import '../engine/tetris_game.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';

/// Shows the current score. Rebuilds automatically as [game] changes.
class ScorePanel extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme? theme;

  const ScorePanel({super.key, required this.game, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return ListenableBuilder(
      listenable: game,
      builder: (_, _) => _Panel(
        label: 'SCORE',
        value: game.state.scoreState.score.toString(),
        theme: t,
      ),
    );
  }
}

/// Shows the current level. Rebuilds automatically as [game] changes.
class LevelPanel extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme? theme;

  const LevelPanel({super.key, required this.game, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return ListenableBuilder(
      listenable: game,
      builder: (_, _) => _Panel(
        label: 'LEVEL',
        value: game.state.levelState.level.toString(),
        theme: t,
      ),
    );
  }
}

/// Shows the total number of lines cleared in the current game.
class LinesClearedPanel extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme? theme;

  const LinesClearedPanel({super.key, required this.game, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return ListenableBuilder(
      listenable: game,
      builder: (_, _) => _Panel(
        label: 'LINES',
        value: game.state.levelState.linesCleared.toString(),
        theme: t,
      ),
    );
  }
}

/// Shows the clock and goal progress for the game's [TetrisGame.mode].
///
/// Timed modes (Ultra) count down as TIME LEFT; other modes count up as
/// TIME. Modes with a line goal (Sprint, Marathon) add LINES LEFT.
class GameModePanel extends StatefulWidget {
  final TetrisGame game;
  final TetrisTheme? theme;

  /// How often the clock redraws.
  final Duration refreshInterval;

  const GameModePanel({
    super.key,
    required this.game,
    this.theme,
    this.refreshInterval = const Duration(milliseconds: 100),
  });

  /// Formats [d] as `m:ss.c`.
  static String formatTime(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final ds = (d.inMilliseconds % 1000) ~/ 100;
    return '$m:$s.$ds';
  }

  @override
  State<GameModePanel> createState() => _GameModePanelState();
}

class _GameModePanelState extends State<GameModePanel> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    widget.game.addListener(_syncTicker);
    _syncTicker();
  }

  @override
  void didUpdateWidget(GameModePanel old) {
    super.didUpdateWidget(old);
    if (old.game != widget.game) {
      old.game.removeListener(_syncTicker);
      widget.game.addListener(_syncTicker);
    }
    _tick?.cancel();
    _tick = null;
    _syncTicker();
  }

  /// Runs the redraw timer only while the game is playing.
  void _syncTicker() {
    final playing = widget.game.state.status == TetrisGameStatus.playing;
    if (playing && _tick == null) {
      _tick = Timer.periodic(widget.refreshInterval, (_) {
        if (mounted) setState(() {});
      });
    } else if (!playing && _tick != null) {
      _tick!.cancel();
      _tick = null;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tick?.cancel();
    widget.game.removeListener(_syncTicker);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme ?? defaultTetrisTheme;
    final game = widget.game;
    final timeLeft = game.timeRemaining;
    final linesLeft = game.linesRemaining;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Panel(
          label: timeLeft != null ? 'TIME LEFT' : 'TIME',
          value: GameModePanel.formatTime(timeLeft ?? game.playTime),
          theme: t,
        ),
        if (linesLeft != null) ...[
          const SizedBox(height: 8),
          _Panel(label: 'LINES LEFT', value: '$linesLeft', theme: t),
        ],
      ],
    );
  }
}

/// Internal reusable label+value panel.
class _Panel extends StatelessWidget {
  final String label;
  final String value;
  final TetrisTheme theme;

  const _Panel({required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.panelBackground,
        border: Border.all(color: theme.boardBorderColor.withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.labelStyle),
          const SizedBox(height: 2),
          Text(value, style: theme.valueStyle),
        ],
      ),
    );
  }
}
