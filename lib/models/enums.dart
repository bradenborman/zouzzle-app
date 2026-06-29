enum Sport {
  basketball,
  football;

  /// Convert a URL path segment (e.g. 'basketball') to a [Sport] value.
  /// Throws [ArgumentError] for unknown values.
  static Sport fromString(String value) {
    return Sport.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown sport: $value'),
    );
  }

  String toJson() => name;

  static Sport fromJson(String json) => fromString(json);
}

enum StatisticalTier {
  allAmerican,
  starter,
  rolePlayer,
  walkOn;

  String toJson() {
    switch (this) {
      case allAmerican:
        return 'All-American';
      case starter:
        return 'Starter';
      case rolePlayer:
        return 'Role Player';
      case walkOn:
        return 'Walk-On';
    }
  }

  static StatisticalTier fromJson(String json) {
    switch (json) {
      case 'All-American':
        return allAmerican;
      case 'Starter':
        return starter;
      case 'Role Player':
        return rolePlayer;
      case 'Walk-On':
        return walkOn;
      default:
        throw ArgumentError('Unknown StatisticalTier: $json');
    }
  }
}

enum MatchState { exact, close, miss }

enum ArrowDirection { up, down }

enum GameStatus { loading, active, won, lost, error }
