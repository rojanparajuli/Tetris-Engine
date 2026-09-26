import 'package:flutter/material.dart';
import '../models/tetromino.dart';
import 'tetris_theme.dart';
import 'tetromino_colors.dart';

/// Piece and board colors used for one level.
///
/// The board colors are optional; when null the base theme's colors are kept.
class LevelPalette {
  final TetrominoColors pieces;
  final Color? boardBackground;
  final Color? boardBorderColor;
  final Color? gridLineColor;
  final Color? panelBackground;

  const LevelPalette({
    required this.pieces,
    this.boardBackground,
    this.boardBorderColor,
    this.gridLineColor,
    this.panelBackground,
  });

  /// Builds a palette from piece fill colors; borders are darker shades of
  /// the fills.
  factory LevelPalette.fromFills(
    Map<TetrominoType, Color> fills, {
    Color? boardBackground,
    Color? boardBorderColor,
    Color? gridLineColor,
    Color? panelBackground,
  }) => LevelPalette(
    pieces: TetrominoColors(
      fill: fills,
      border: {
        for (final e in fills.entries)
          e.key: Color.lerp(e.value, Colors.black, 0.4)!,
      },
    ),
    boardBackground: boardBackground,
    boardBorderColor: boardBorderColor,
    gridLineColor: gridLineColor,
    panelBackground: panelBackground,
  );

  /// Returns [base] with this palette applied. When [recolorBoard] is false
  /// only the piece colors change.
  TetrisTheme applyTo(TetrisTheme base, {bool recolorBoard = true}) =>
      base.copyWith(
        tetrominoColors: pieces,
        boardBackground: recolorBoard ? boardBackground : null,
        boardBorderColor: recolorBoard ? boardBorderColor : null,
        gridLineColor: recolorBoard ? gridLineColor : null,
        panelBackground: recolorBoard ? panelBackground : null,
      );

  static LevelPalette _classic(
    List<int> fills,
    int background,
    int border,
    int grid,
  ) => LevelPalette.fromFills(
    {
      for (var i = 0; i < TetrominoType.values.length; i++)
        TetrominoType.values[i]: Color(fills[i]),
    },
    boardBackground: Color(background),
    boardBorderColor: Color(border),
    gridLineColor: Color(grid),
    panelBackground: Color(background),
  );

  /// Ten dark palettes, one per level, cycling like classic Tetris.
  ///
  /// Piece colors are listed in [TetrominoType.values] order.
  static final List<LevelPalette> classic = [
    // 1 — guideline
    LevelPalette(
      pieces: TetrominoColors.guideline,
      boardBackground: const Color(0xFF0A0A0F),
      boardBorderColor: const Color(0xFF444466),
      gridLineColor: const Color(0xFF1E1E2E),
      panelBackground: const Color(0xFF12121C),
    ),
    // 2 — lime
    _classic(
      [
        0xFF7CFC00,
        0xFFC6FF3D,
        0xFF32CD32,
        0xFF00E676,
        0xFFB2FF59,
        0xFF2E7D32,
        0xFF9CCC65,
      ],
      0xFF08120A,
      0xFF3A5A2E,
      0xFF15261A,
    ),
    // 3 — magenta
    _classic(
      [
        0xFFFF4FD8,
        0xFFFF80AB,
        0xFFD500F9,
        0xFFF06292,
        0xFFE040FB,
        0xFFAD1457,
        0xFFFF6E9C,
      ],
      0xFF140810,
      0xFF5E2E52,
      0xFF2A1424,
    ),
    // 4 — ocean
    _classic(
      [
        0xFF18FFFF,
        0xFF80D8FF,
        0xFF2979FF,
        0xFF00BFA5,
        0xFF40C4FF,
        0xFF1A237E,
        0xFF64B5F6,
      ],
      0xFF050B16,
      0xFF2E4466,
      0xFF111D33,
    ),
    // 5 — ember
    _classic(
      [
        0xFFFFAB00,
        0xFFFFD54F,
        0xFFFF6D00,
        0xFFFFC400,
        0xFFFF3D00,
        0xFFB71C1C,
        0xFFFF9E80,
      ],
      0xFF140A05,
      0xFF6B3A1E,
      0xFF2B170C,
    ),
    // 6 — mint & violet
    _classic(
      [
        0xFF64FFDA,
        0xFFB388FF,
        0xFF7C4DFF,
        0xFF1DE9B6,
        0xFFEA80FC,
        0xFF4527A0,
        0xFFA7FFEB,
      ],
      0xFF0B0816,
      0xFF473A6E,
      0xFF1D1733,
    ),
    // 7 — gold
    _classic(
      [
        0xFFFFE57F,
        0xFFFFD700,
        0xFFFFA000,
        0xFFFFF176,
        0xFFFFC107,
        0xFF8D6E00,
        0xFFFFCA28,
      ],
      0xFF12100A,
      0xFF5E5230,
      0xFF262112,
    ),
    // 8 — crimson
    _classic(
      [
        0xFFFF1744,
        0xFFFF8A80,
        0xFFC51162,
        0xFFFF5252,
        0xFFD50000,
        0xFF880E4F,
        0xFFFF4081,
      ],
      0xFF160508,
      0xFF6B2330,
      0xFF2E0E14,
    ),
    // 9 — ice
    _classic(
      [
        0xFFE0F7FA,
        0xFFB3E5FC,
        0xFF81D4FA,
        0xFFCFD8DC,
        0xFF90CAF9,
        0xFF5C6BC0,
        0xFFB2EBF2,
      ],
      0xFF0A0E14,
      0xFF4A5A70,
      0xFF1A2230,
    ),
    // 10 — neon
    _classic(
      [
        0xFF00FFFF,
        0xFFFFFF00,
        0xFFFF00FF,
        0xFF00FF00,
        0xFFFF0055,
        0xFF5500FF,
        0xFFFF8800,
      ],
      0xFF000000,
      0xFF555555,
      0xFF151515,
    ),
  ];
}

/// Maps game levels to themes so colors change as the player levels up.
///
/// Each level uses the next palette in [palettes], wrapping around after the
/// last one. Themes are built once, so the same level always returns the same
/// [TetrisTheme] instance.
///
/// ```dart
/// final levelThemes = LevelThemes(base: darkTetrisTheme);
///
/// LevelThemeBuilder(
///   game: game,
///   levelThemes: levelThemes,
///   builder: (context, theme, _) => TetrisBoard(game: game, theme: theme),
/// );
/// ```
class LevelThemes {
  /// Theme the palettes are applied on top of; supplies text styles, border
  /// width, radius and any colors a palette leaves out.
  final TetrisTheme base;

  /// Palettes in level order.
  final List<LevelPalette> palettes;

  /// How many consecutive levels share a palette.
  final int levelsPerPalette;

  final List<TetrisTheme> _themes;

  /// When [recolorBoard] is null, board colors are replaced only if [base]
  /// has a dark board, so the built-in dark palettes do not clash with light
  /// themes' text styles.
  LevelThemes({
    required this.base,
    List<LevelPalette>? palettes,
    this.levelsPerPalette = 1,
    bool? recolorBoard,
  }) : assert(levelsPerPalette > 0, 'levelsPerPalette must be positive'),
       palettes = palettes ?? LevelPalette.classic,
       _themes = [
         for (final p in palettes ?? LevelPalette.classic)
           p.applyTo(
             base,
             recolorBoard:
                 recolorBoard ?? base.boardBackground.computeLuminance() < 0.5,
           ),
       ] {
    assert(_themes.isNotEmpty, 'palettes must not be empty');
  }

  /// Theme for [level] (1-based).
  TetrisTheme forLevel(int level) {
    final index = ((level - 1) ~/ levelsPerPalette) % _themes.length;
    return _themes[index < 0 ? index + _themes.length : index];
  }
}
