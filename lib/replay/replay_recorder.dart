import 'dart:convert';
import '../models/replay_frame.dart';

/// Records player inputs as a list of [ReplayFrame]s for later playback.
class ReplayRecorder {
  final List<ReplayFrame> _frames = [];
  final Stopwatch _clock = Stopwatch();
  bool _recording = false;

  bool get isRecording => _recording;
  List<ReplayFrame> get frames => List.unmodifiable(_frames);

  void startRecording() {
    _frames.clear();
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
    _frames.add(ReplayFrame(timestampMs: _clock.elapsedMilliseconds, action: action));
  }

  String exportJson() => jsonEncode({'frames': _frames.map((f) => f.toJson()).toList()});

  void importJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    _frames
      ..clear()
      ..addAll((data['frames'] as List).map((f) => ReplayFrame.fromJson(f as Map<String, dynamic>)));
  }
}
