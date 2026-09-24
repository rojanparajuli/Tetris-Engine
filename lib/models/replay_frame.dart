/// One recorded action in a replay sequence.
class ReplayFrame {
  final int timestampMs;

  /// An [InputController] action name, e.g. `moveLeft`, `hardDrop` or
  /// `gravity`.
  final String action;

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
