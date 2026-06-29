import 'enums.dart';
import 'player.dart';

/// The result of comparing a single attribute between a guessed player
/// and the mystery player.
class AttributeResult {
  /// Human-readable label for the attribute, e.g. "Position", "Jersey #".
  final String attributeLabel;

  /// Whether the guessed value was an exact match, close, or a miss.
  final MatchState state;

  /// Direction hint shown on close numeric comparisons.
  /// Non-null only when [state] == [MatchState.close].
  final ArrowDirection? arrow;

  /// Optional display value to show inside the cell (e.g., jersey number "25").
  final String? displayValue;

  const AttributeResult({
    required this.attributeLabel,
    required this.state,
    this.arrow,
    this.displayValue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeResult &&
          runtimeType == other.runtimeType &&
          attributeLabel == other.attributeLabel &&
          state == other.state &&
          arrow == other.arrow &&
          displayValue == other.displayValue;

  @override
  int get hashCode => Object.hash(attributeLabel, state, arrow, displayValue);

  @override
  String toString() =>
      'AttributeResult(attributeLabel: $attributeLabel, state: $state, arrow: $arrow, displayValue: $displayValue)';
}

/// The result of evaluating a single guess against the mystery player.
/// Contains the guessed player and one [AttributeResult] per compared attribute,
/// in the fixed comparison order defined by the design.
class FeedbackRow {
  final Player guessedPlayer;

  /// One entry per compared attribute, in fixed order:
  /// position, jerseyNumber, startYear, endYear, wentPro, statisticalTier.
  final List<AttributeResult> results;

  const FeedbackRow({
    required this.guessedPlayer,
    required this.results,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackRow &&
          runtimeType == other.runtimeType &&
          guessedPlayer == other.guessedPlayer &&
          _listsEqual(results, other.results);

  @override
  int get hashCode => Object.hash(guessedPlayer, Object.hashAll(results));

  @override
  String toString() =>
      'FeedbackRow(guessedPlayer: ${guessedPlayer.fullName}, results: $results)';
}

bool _listsEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
