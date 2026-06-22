import 'package:flutter/material.dart';
import '../statistics/tetris_statistics.dart';
import '../models/tetromino.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';

class StatisticsPanel extends StatelessWidget {
  final TetrisStatistics statistics;
  final TetrisTheme? theme;

  const StatisticsPanel({super.key, required this.statistics, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.panelBackground,
        border: Border.all(color: t.boardBorderColor.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STATISTICS', style: t.labelStyle),
          const SizedBox(height: 12),
          _row('Games Played', statistics.totalGames.toString(), t),
          _row('High Score', statistics.highestScore.toString(), t),
          _row('Avg Score', statistics.averageScore.toStringAsFixed(0), t),
          _row('Total Lines', statistics.totalLinesCleared.toString(), t),
          _row('Highest Level', statistics.highestLevel.toString(), t),
          _row('Play Time',
              _formatDuration(Duration(milliseconds: statistics.totalPlayTimeMs)), t),
          const SizedBox(height: 12),
          Text('PIECE USAGE', style: t.labelStyle),
          const SizedBox(height: 8),
          ...TetrominoType.values.map((type) => _row(
              type.name,
              statistics.pieceUsage[type]?.toString() ?? '0',
              t)),
        ],
      ),
    );
  }

  Widget _row(String label, String value, TetrisTheme t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: t.labelStyle),
          Text(value, style: t.valueStyle.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
