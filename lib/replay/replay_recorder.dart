import 'dart:convert';
import '../models/replay_frame.dart';

/// Records player inputs as a list of [ReplayFrame]s for later playback.
///
/// The easiest way to record is to attach the recorder to a game with
/// `TetrisGame(recorder: recorder)`: every action, gravity step and lock is
/// then captured together with the game's seed, which is what makes playback
/// exact.
class ReplayRecorder {
  final List<ReplayFrame> _frames = [];
  final Stopwatch _clock = Stopwatch();
  bool _recording = false;
  int? _seed;

  bool get isRecording => _recording;
  List<ReplayFrame> get frames => List.unmodifiable(_frames);

  /// Seed of the recorded game, if known. Pass it to `ReplayPlayer.play` so
  /// the replay gets the same pieces.
  int? get seed => _seed;

  void startRecording({int? seed}) {
    _frames.clear();
    _seed = seed;
    _clock
      ..reset()
      ..start();
    _recording = true;
  }

  void stopRecording() {
    _clock.stop();
    _recording = false;
  }

  void record(String action) {
    if (!_recording) return;
    _frames.add(
      ReplayFrame(timestampMs: _clock.elapsedMilliseconds, action: action),
    );
  }

  String exportJson() => jsonEncode({
    if (_seed != null) 'seed': _seed,
    'frames': _frames.map((f) => f.toJson()).toList(),
  });

  void importJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    _seed = data['seed'] as int?;
    _frames
      ..clear()
      ..addAll(
        (data['frames'] as List).map(
          (f) => ReplayFrame.fromJson(f as Map<String, dynamic>),
        ),
      );
  }
}
