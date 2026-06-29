import 'package:json_annotation/json_annotation.dart';

part 'completion_state.g.dart';

/// Persisted record of a completed puzzle for a given sport and date.
///
/// [sport]             — "basketball" | "football"
/// [date]              — "YYYY-MM-DD"
/// [outcome]           — "win" | "lose"
/// [mysteryPlayerName] — the full name of the mystery player
/// [guesses]           — player names in submission order
@JsonSerializable()
class CompletionState {
  final String sport;
  final String date;
  final String outcome;
  final String mysteryPlayerName;
  final List<String> guesses;

  const CompletionState({
    required this.sport,
    required this.date,
    required this.outcome,
    required this.mysteryPlayerName,
    required this.guesses,
  });

  factory CompletionState.fromJson(Map<String, dynamic> json) =>
      _$CompletionStateFromJson(json);

  Map<String, dynamic> toJson() => _$CompletionStateToJson(this);
}
