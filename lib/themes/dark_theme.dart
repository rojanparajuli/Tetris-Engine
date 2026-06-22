import 'package:flutter/material.dart';
import 'tetris_theme.dart';
import 'tetromino_colors.dart';

/// Dark theme — deep background, vivid pieces.
final TetrisTheme darkTetrisTheme = TetrisTheme(
  boardBackground: const Color(0xFF0A0A0F),
  boardBorderColor: const Color(0xFF444466),
  boardBorderWidth: 1.5,
  gridLineColor: const Color(0xFF1E1E2E),
  showGridLines: true,
  tetrominoColors: TetrominoColors.guideline,
  ghostCellColor: const Color(0x33FFFFFF),
  cellBorderRadius: 3.0,
  panelBackground: const Color(0xFF12121C),
  labelStyle: const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFF666699),
    letterSpacing: 1.2,
  ),
  valueStyle: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Color(0xFFEEEEFF),
  ),
  overlayBackground: const Color(0xCC000011),
);
