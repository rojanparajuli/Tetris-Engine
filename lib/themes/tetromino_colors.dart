import 'package:flutter/material.dart';
import '../models/tetromino.dart';

/// Per-type fill and border colors for tetromino cells.
class TetrominoColors {
  final Map<TetrominoType, Color> fill;
  final Map<TetrominoType, Color> border;

  const TetrominoColors({required this.fill, required this.border});

  Color fillFor(TetrominoType type) => fill[type] ?? Colors.grey;
  Color borderFor(TetrominoType type) => border[type] ?? Colors.grey.shade700;

  /// Guideline colors
  static const TetrominoColors guideline = TetrominoColors(
    fill: {
      TetrominoType.I: Color(0xFF00BFFF),
      TetrominoType.O: Color(0xFFFFD700),
      TetrominoType.T: Color(0xFFBF00FF),
      TetrominoType.S: Color(0xFF00C800),
      TetrominoType.Z: Color(0xFFFF2020),
      TetrominoType.J: Color(0xFF0028FF),
      TetrominoType.L: Color(0xFFFF8C00),
    },
    border: {
      TetrominoType.I: Color(0xFF007FAA),
      TetrominoType.O: Color(0xFFAA8E00),
      TetrominoType.T: Color(0xFF7F00AA),
      TetrominoType.S: Color(0xFF008500),
      TetrominoType.Z: Color(0xFFAA0000),
      TetrominoType.J: Color(0xFF001BAA),
      TetrominoType.L: Color(0xFFAA5D00),
    },
  );

  /// Colorblind-safe palette (uses shape-distinguishable hues)
  static const TetrominoColors colorblind = TetrominoColors(
    fill: {
      TetrominoType.I: Color(0xFF56B4E9),
      TetrominoType.O: Color(0xFFF0E442),
      TetrominoType.T: Color(0xFFCC79A7),
      TetrominoType.S: Color(0xFF009E73),
      TetrominoType.Z: Color(0xFFD55E00),
      TetrominoType.J: Color(0xFF0072B2),
      TetrominoType.L: Color(0xFFE69F00),
    },
    border: {
      TetrominoType.I: Color(0xFF2E7DAF),
      TetrominoType.O: Color(0xFFB0A800),
      TetrominoType.T: Color(0xFF8A4F6F),
      TetrominoType.S: Color(0xFF006B4E),
      TetrominoType.Z: Color(0xFF8F3E00),
      TetrominoType.J: Color(0xFF004C78),
      TetrominoType.L: Color(0xFF9A6A00),
    },
  );
}
