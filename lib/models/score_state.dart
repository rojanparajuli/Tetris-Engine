/// Tracks the current scoring state.
class ScoreState {
  final int score;
  final int combo;
  final bool backToBack; // B2B Tetris / T-Spin flag

  const ScoreState({
    this.score = 0,
    this.combo = 0,
    this.backToBack = false,
  });

  ScoreState copyWith({int? score, int? combo, bool? backToBack}) => ScoreState(
    score: score ?? this.score,
    combo: combo ?? this.combo,
    backToBack: backToBack ?? this.backToBack,
  );

  Map<String, dynamic> toJson() => {
    'score': score,
    'combo': combo,
    'backToBack': backToBack,
  };

  factory ScoreState.fromJson(Map<String, dynamic> json) => ScoreState(
    score: json['score'] as int,
    combo: json['combo'] as int,
    backToBack: json['backToBack'] as bool,
  );
}
