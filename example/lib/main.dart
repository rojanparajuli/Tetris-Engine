import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris_engine/tetris_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const TetrisExampleApp());
}


class TetrisExampleApp extends StatefulWidget {
  const TetrisExampleApp({super.key});

  @override
  State<TetrisExampleApp> createState() => _TetrisExampleAppState();
}

class _TetrisExampleAppState extends State<TetrisExampleApp> {
  TetrisTheme _theme = darkTetrisTheme;
  final _themeNotifier = ValueNotifier<TetrisTheme>(darkTetrisTheme);

  void _cycleTheme() {
    TetrisTheme next;
    if (_theme == darkTetrisTheme) {
      next = defaultTetrisTheme;
    } else if (_theme == defaultTetrisTheme) {
      next = colorblindTetrisTheme;
    } else {
      next = darkTetrisTheme;
    }
    setState(() => _theme = next);
    _themeNotifier.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _theme == darkTetrisTheme || _theme == colorblindTetrisTheme;
    return MaterialApp(
      title: 'Flutter Tetris',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: isDark
            ? const ColorScheme.dark(primary: Colors.white)
            : const ColorScheme.light(primary: Colors.black),
        useMaterial3: true,
      ),
      home: TetrisHome(
        activeTheme: _theme,
        themeNotifier: _themeNotifier,
        onCycleTheme: _cycleTheme,
      ),
    );
  }
}


class TetrisHome extends StatefulWidget {
  final TetrisTheme activeTheme;
  final ValueNotifier<TetrisTheme> themeNotifier;
  final VoidCallback onCycleTheme;

  const TetrisHome({
    super.key,
    required this.activeTheme,
    required this.themeNotifier,
    required this.onCycleTheme,
  });

  @override
  State<TetrisHome> createState() => _TetrisHomeState();
}

class _TetrisHomeState extends State<TetrisHome> {
  _Screen _screen = _Screen.menu;
  late TetrisGame _game;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _game = _buildGame();
  }

  TetrisGame _buildGame() => TetrisGame(
        onScoreChanged: (s) {
          if (s > _highScore) setState(() => _highScore = s);
        },
        onLevelUp: (level) => _showBanner('Level $level!'),
        onLinesCleared: (lines) {
          if (lines == 4) _showBanner('TETRIS!');
        },
        onGameOver: () => setState(() => _screen = _Screen.gameOver),
      );

  void _showBanner(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 40, right: 40),
          shape: const RoundedRectangleBorder(),
        ),
      );
  }

  void _startGame() {
    _game.dispose();
    _game = _buildGame();
    _game.start();
    setState(() => _screen = _Screen.game);
  }

  void _restartGame() {
    _game.restart();
    setState(() => _screen = _Screen.game);
  }

  void _goToMenu() {
    _game.pause();
    setState(() => _screen = _Screen.menu);
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TetrisTheme>(
      valueListenable: widget.themeNotifier,
      builder: (context, theme, _) {
        final bg = theme.boardBackground;
        return Scaffold(
          backgroundColor: bg,
          body: switch (_screen) {
            _Screen.menu => _MenuScreen(
                theme: theme,
                highScore: _highScore,
                onStart: _startGame,
                onStats: () => setState(() => _screen = _Screen.stats),
                onCycleTheme: widget.onCycleTheme,
                activeTheme: widget.activeTheme,
              ),
            _Screen.game => _GameScreen(
                game: _game,
                theme: theme,
                onMenu: _goToMenu,
                onRestart: _restartGame,
              ),
            _Screen.gameOver => _GameOverScreen(
                theme: theme,
                score: _game.state.scoreState.score,
                level: _game.state.levelState.level,
                lines: _game.state.levelState.linesCleared,
                highScore: _highScore,
                onRestart: _restartGame,
                onMenu: () => setState(() => _screen = _Screen.menu),
              ),
            _Screen.stats => _StatsScreen(
                theme: theme,
                statistics: _game.statistics,
                onBack: () => setState(() => _screen = _Screen.menu),
              ),
          },
        );
      },
    );
  }
}

enum _Screen { menu, game, gameOver, stats }

// ─── Menu screen ─────────────────────────────────────────────────────────────

class _MenuScreen extends StatelessWidget {
  final TetrisTheme theme;
  final int highScore;
  final VoidCallback onStart;
  final VoidCallback onStats;
  final VoidCallback onCycleTheme;
  final TetrisTheme activeTheme;

  const _MenuScreen({
    required this.theme,
    required this.highScore,
    required this.onStart,
    required this.onStats,
    required this.onCycleTheme,
    required this.activeTheme,
  });

  String get _themeName {
    if (activeTheme == darkTetrisTheme) return 'DARK';
    if (activeTheme == defaultTetrisTheme) return 'LIGHT';
    return 'COLOR-BLIND';
  }

  @override
  Widget build(BuildContext context) {
    final fg = theme == defaultTetrisTheme ? Colors.black : Colors.white;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(
              'TETRIS',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: fg,
                letterSpacing: 8,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'flutter_tetris',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: fg.withAlpha(100),
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 48),
            if (highScore > 0) ...[
              Text('BEST', style: theme.labelStyle),
              const SizedBox(height: 2),
              Text(
                highScore.toString(),
                style: theme.valueStyle.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 40),
            ],
            _MenuButton(
                label: 'START', onTap: onStart, theme: theme, primary: true),
            const SizedBox(height: 12),
            _MenuButton(label: 'STATISTICS', onTap: onStats, theme: theme),
            const SizedBox(height: 12),
            _MenuButton(
              label: 'THEME: $_themeName',
              onTap: onCycleTheme,
              theme: theme,
            ),
            const Spacer(),
            // Mini controls legend
            _ControlsLegend(theme: theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final TetrisTheme theme;
  final bool primary;

  const _MenuButton({
    required this.label,
    required this.onTap,
    required this.theme,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = theme == defaultTetrisTheme ? Colors.black : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: primary ? fg : Colors.transparent,
          border: Border.all(color: fg.withAlpha(primary ? 0 : 80), width: 1),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: primary ? theme.boardBackground : fg.withAlpha(200),
          ),
        ),
      ),
    );
  }
}

class _ControlsLegend extends StatelessWidget {
  final TetrisTheme theme;

  const _ControlsLegend({required this.theme});

  @override
  Widget build(BuildContext context) {
    final fg = theme == defaultTetrisTheme
        ? Colors.black.withAlpha(100)
        : Colors.white.withAlpha(80);
    final entries = [
      ('← →', 'Move'),
      ('↑ / W', 'Rotate CW'),
      ('Z', 'Rotate CCW'),
      ('↓ / S', 'Soft drop'),
      ('Space', 'Hard drop'),
      ('C', 'Hold'),
      ('P / Esc', 'Pause'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KEYBOARD',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: fg,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: entries
              .map(
                (e) => Text(
                  '${e.$1}  ${e.$2}',
                  style: TextStyle(fontSize: 10, color: fg),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─── Game screen ─────────────────────────────────────────────────────────────

class _GameScreen extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme theme;
  final VoidCallback onMenu;
  final VoidCallback onRestart;

  const _GameScreen({
    required this.game,
    required this.theme,
    required this.onMenu,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: OrientationBuilder(
        builder: (context, orientation) => orientation == Orientation.portrait
            ? _PortraitLayout(game: game, theme: theme, onMenu: onMenu)
            : _LandscapeLayout(game: game, theme: theme, onMenu: onMenu),
      ),
    );
  }
}

// Portrait: board center, panels above + below + side
class _PortraitLayout extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme theme;
  final VoidCallback onMenu;

  const _PortraitLayout({
    required this.game,
    required this.theme,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: onMenu,
                child: Icon(Icons.arrow_back_ios_new,
                    size: 18,
                    color: theme == defaultTetrisTheme
                        ? Colors.black54
                        : Colors.white38),
              ),
              const Spacer(),
              ScorePanel(game: game, theme: theme),
              const Spacer(),
              ListenableBuilder(
                listenable: game,
                builder: (_, __) => GestureDetector(
                  onTap: () => game.state.status == TetrisGameStatus.playing
                      ? game.pause()
                      : game.resume(),
                  child: Icon(
                    game.state.status == TetrisGameStatus.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 22,
                    color: theme == defaultTetrisTheme
                        ? Colors.black54
                        : Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Board + side panels
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left panel
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HoldPiecePreview(game: game, theme: theme),
                    const SizedBox(height: 16),
                    LevelPanel(game: game, theme: theme),
                    const SizedBox(height: 8),
                    LinesClearedPanel(game: game, theme: theme),
                  ],
                ),
              ),

              // Board — constrained so it doesn't overflow
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: TetrisBoard(
                  game: game,
                  theme: theme,
                  showGhostPiece: true,
                  enableKeyboard: true,
                  enableGestures: true,
                  pauseOverlayBuilder: (ctx, resume) => _CustomPauseOverlay(
                      theme: theme, onResume: resume, onMenu: onMenu),
                ),
              ),

              // Right panel
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: NextPiecePreview(game: game, theme: theme, count: 4),
              ),
            ],
          ),
        ),

        // Mobile D-pad
        _MobileDpad(game: game, theme: theme),
      ],
    );
  }
}

// Landscape: hold+stats left, board center, next right
class _LandscapeLayout extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme theme;
  final VoidCallback onMenu;

  const _LandscapeLayout({
    required this.game,
    required this.theme,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HoldPiecePreview(game: game, theme: theme),
              const SizedBox(height: 12),
              ScorePanel(game: game, theme: theme),
              const SizedBox(height: 8),
              LevelPanel(game: game, theme: theme),
              const SizedBox(height: 8),
              LinesClearedPanel(game: game, theme: theme),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onMenu,
                child: Text(
                  'MENU',
                  style: theme.labelStyle,
                ),
              ),
            ],
          ),
        ),

        // Board
        SizedBox(
          height: h * 0.92,
          child: AspectRatio(
            aspectRatio: 10 / 20,
            child: TetrisBoard(
              game: game,
              theme: theme,
              showGhostPiece: true,
              enableKeyboard: true,
              enableGestures: true,
              pauseOverlayBuilder: (ctx, resume) => _CustomPauseOverlay(
                  theme: theme, onResume: resume, onMenu: onMenu),
            ),
          ),
        ),

        // Right panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: NextPiecePreview(game: game, theme: theme, count: 5),
        ),
      ],
    );
  }
}

// ─── Custom pause overlay ─────────────────────────────────────────────────────

class _CustomPauseOverlay extends StatelessWidget {
  final TetrisTheme theme;
  final VoidCallback onResume;
  final VoidCallback onMenu;

  const _CustomPauseOverlay({
    required this.theme,
    required this.onResume,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.overlayBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: theme.valueStyle.copyWith(
                fontSize: 26,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 28),
            _OverlayBtn(label: 'RESUME', onTap: onResume, filled: true),
            const SizedBox(height: 10),
            _OverlayBtn(label: 'MENU', onTap: onMenu),
          ],
        ),
      ),
    );
  }
}

class _OverlayBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _OverlayBtn(
      {required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: filled ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Mobile D-pad ─────────────────────────────────────────────────────────────

class _MobileDpad extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme theme;

  const _MobileDpad({required this.game, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.panelBackground,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left / Right
          Row(
            children: [
              _DpadBtn(icon: Icons.chevron_left, onTap: game.moveLeft),
              const SizedBox(width: 8),
              _DpadBtn(icon: Icons.chevron_right, onTap: game.moveRight),
            ],
          ),
          // Rotate
          Row(
            children: [
              _DpadBtn(icon: Icons.rotate_left, onTap: game.rotateCCW),
              const SizedBox(width: 8),
              _DpadBtn(icon: Icons.rotate_right, onTap: game.rotateCW),
            ],
          ),
          // Hold + drops
          Row(
            children: [
              _DpadBtn(icon: Icons.save_outlined, onTap: game.holdPiece),
              const SizedBox(width: 8),
              _DpadBtn(icon: Icons.keyboard_arrow_down, onTap: game.softDrop),
              const SizedBox(width: 8),
              _DpadBtn(icon: Icons.vertical_align_bottom, onTap: game.hardDrop),
            ],
          ),
          // Pause / resume
          ListenableBuilder(
            listenable: game,
            builder: (_, __) => _DpadBtn(
              icon: game.state.status == TetrisGameStatus.playing
                  ? Icons.pause
                  : Icons.play_arrow,
              onTap: () => game.state.status == TetrisGameStatus.playing
                  ? game.pause()
                  : game.resume(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DpadBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DpadBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

// ─── Game over screen ─────────────────────────────────────────────────────────

class _GameOverScreen extends StatelessWidget {
  final TetrisTheme theme;
  final int score;
  final int level;
  final int lines;
  final int highScore;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const _GameOverScreen({
    required this.theme,
    required this.score,
    required this.level,
    required this.lines,
    required this.highScore,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final fg = theme == defaultTetrisTheme ? Colors.black : Colors.white;
    final isNewBest = score >= highScore && score > 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(
              'GAME\nOVER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: fg,
                letterSpacing: 6,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 48),
            if (isNewBest) ...[
              Text(
                'NEW BEST',
                style: theme.labelStyle.copyWith(
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 4),
            ],
            _StatRow(label: 'SCORE', value: score.toString(), theme: theme),
            const SizedBox(height: 12),
            _StatRow(label: 'BEST', value: highScore.toString(), theme: theme),
            const SizedBox(height: 12),
            _StatRow(label: 'LEVEL', value: level.toString(), theme: theme),
            const SizedBox(height: 12),
            _StatRow(label: 'LINES', value: lines.toString(), theme: theme),
            const SizedBox(height: 48),
            _MenuButton(
              label: 'PLAY AGAIN',
              onTap: onRestart,
              theme: theme,
              primary: true,
            ),
            const SizedBox(height: 12),
            _MenuButton(label: 'MENU', onTap: onMenu, theme: theme),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final TetrisTheme theme;

  const _StatRow(
      {required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.labelStyle),
        Text(value, style: theme.valueStyle.copyWith(fontSize: 20)),
      ],
    );
  }
}

// ─── Statistics screen ────────────────────────────────────────────────────────

class _StatsScreen extends StatelessWidget {
  final TetrisTheme theme;
  final TetrisStatistics statistics;
  final VoidCallback onBack;

  const _StatsScreen({
    required this.theme,
    required this.statistics,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final fg = theme == defaultTetrisTheme ? Colors.black : Colors.white;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Icon(Icons.arrow_back_ios_new,
                      size: 18, color: fg.withAlpha(120)),
                ),
                const SizedBox(width: 16),
                Text(
                  'STATISTICS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: StatisticsPanel(statistics: statistics, theme: theme),
            ),
          ),
        ],
      ),
    );
  }
}
