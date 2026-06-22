import 'package:flutter/material.dart';
import 'package:tetris_engine/engine/tetris_game.dart';
import 'package:tetris_engine/models/game_state.dart';
import 'package:tetris_engine/themes/colorblind_theme.dart';
import 'package:tetris_engine/themes/dark_theme.dart';
import 'package:tetris_engine/themes/default_theme.dart';
import 'package:tetris_engine/themes/tetris_theme.dart';
import 'package:tetris_engine/widgets/hold_piece_preview.dart';
import 'package:tetris_engine/widgets/next_piece_preview.dart';
import 'package:tetris_engine/widgets/score_panel.dart';
import 'package:tetris_engine/widgets/statistics_panel.dart';
import 'package:tetris_engine/widgets/tetris_board.dart';

void main() => runApp(const TetrisExampleApp());

class TetrisExampleApp extends StatelessWidget {
  const TetrisExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tetris',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const TetrisScreen(),
    );
  }
}

class TetrisScreen extends StatefulWidget {
  const TetrisScreen({super.key});

  @override
  State<TetrisScreen> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen> {
  late final TetrisGame _game;
  TetrisTheme _theme = darkTetrisTheme;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _game = TetrisGame(
   
    );
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  void _cycleTheme() {
    setState(() {
      if (_theme == darkTetrisTheme) {
        _theme = defaultTetrisTheme;
      } else if (_theme == defaultTetrisTheme) {
        _theme = colorblindTetrisTheme;
      } else {
        _theme = darkTetrisTheme;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'TETRIS',
          style: TextStyle(
            letterSpacing: 6,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showStats ? Icons.gamepad : Icons.bar_chart,
                color: Colors.white54),
            onPressed: () => setState(() => _showStats = !_showStats),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined, color: Colors.white54),
            onPressed: _cycleTheme,
          ),
        ],
      ),
      body: _showStats ? _buildStatsView() : _buildGameView(),
      bottomNavigationBar: _buildMobileControls(),
    );
  }

  Widget _buildGameView() {
    return SafeArea(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left panel
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HoldPiecePreview(game: _game, theme: _theme),
                  const SizedBox(height: 16),
                  ScorePanel(game: _game, theme: _theme),
                  const SizedBox(height: 8),
                  LevelPanel(game: _game, theme: _theme),
                  const SizedBox(height: 8),
                  LinesClearedPanel(game: _game, theme: _theme),
                ],
              ),
            ),

            // Board
            SizedBox(
              width: 200,
              child: TetrisBoard(
                game: _game,
                theme: _theme,
                showGhostPiece: true,
                enableKeyboard: true,
                enableGestures: true,
              ),
            ),

            // Right panel
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: NextPiecePreview(game: _game, theme: _theme, count: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StatisticsPanel(statistics: _game.statistics, theme: _theme),
      ),
    );
  }

  Widget _buildMobileControls() {
    // On-screen D-pad for mobile (desktop uses keyboard)
    return Container(
      color: const Color(0xFF0F0F18),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left / Right
          Row(
            children: [
              _ctrlBtn(Icons.arrow_left, () => _game.moveLeft()),
              const SizedBox(width: 8),
              _ctrlBtn(Icons.arrow_right, () => _game.moveRight()),
            ],
          ),
          // Rotate CCW / CW
          Row(
            children: [
              _ctrlBtn(Icons.rotate_left, () => _game.rotateCCW()),
              const SizedBox(width: 8),
              _ctrlBtn(Icons.rotate_right, () => _game.rotateCW()),
            ],
          ),
          // Hold / Soft drop / Hard drop
          Row(
            children: [
              _ctrlBtn(Icons.save_outlined, () => _game.holdPiece()),
              const SizedBox(width: 8),
              _ctrlBtn(Icons.keyboard_arrow_down, () => _game.softDrop()),
              const SizedBox(width: 8),
              _ctrlBtn(Icons.vertical_align_bottom, () => _game.hardDrop()),
            ],
          ),
          // Start / Pause
          _ctrlBtn(
            _game.state.status == TetrisGameStatus.playing
                ? Icons.pause
                : Icons.play_arrow,
            () {
              if (_game.state.status == TetrisGameStatus.idle) {
                _game.start();
              } else if (_game.state.status == TetrisGameStatus.playing) {
                _game.pause();
              } else if (_game.state.status == TetrisGameStatus.paused) {
                _game.resume();
              } else {
                _game.restart();
              }
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          border: Border.all(color: const Color(0xFF333355)),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
