import 'package:flutter/material.dart';
import 'tetris_theme.dart';
import 'tetromino_colors.dart';

/// Bright light theme — clean, high contrast.
final TetrisTheme defaultTetrisTheme = TetrisTheme(
  boardBackground: const Color(0xFFF0F0F0),
  boardBorderColor: const Color(0xFF222222),
  boardBorderWidth: 2.0,
  gridLineColor: const Color(0xFFCCCCCC),
  showGridLines: true,
  tetrominoColors: TetrominoColors.guideline,
  ghostCellColor: const Color(0x44000000),
  cellBorderRadius: 2.0,
  panelBackground: const Color(0xFFFFFFFF),
  labelStyle: const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFF888888),
    letterSpacing: 1.2,
  ),
  valueStyle: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Color(0xFF111111),
  ),
  overlayBackground: const Color(0xCC000000),
);
