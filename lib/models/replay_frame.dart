/// One recorded action in a replay sequence.
class ReplayFrame {
  final int timestampMs;
  final String action; // 'moveLeft','moveRight','softDrop','hardDrop','rotCW','rotCCW','hold','pause'

  const ReplayFrame({required this.timestampMs, required this.action});

  Map<String, dynamic> toJson() => {
    'timestampMs': timestampMs,
    'action': action,
  };

  factory ReplayFrame.fromJson(Map<String, dynamic> json) => ReplayFrame(
    timestampMs: json['timestampMs'] as int,
    action: json['action'] as String,
  );
}
