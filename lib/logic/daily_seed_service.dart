import 'package:zouzzle/models/enums.dart';
import 'package:zouzzle/models/player.dart';

/// Returns a zero-based index into the player list for the given date and sport.
///
/// Algorithm: `index = (daysSinceEpoch + sportOffset) % datasetLength`
/// - `daysSinceEpoch = date.difference(DateTime(2000,1,1)).inDays`
/// - `sportOffset = sport == Sport.basketball ? 0 : 1000`
///
/// Throws [AssertionError] if [datasetLength] <= 0.
int computeDailyIndex(DateTime date, Sport sport, int datasetLength) {
  assert(datasetLength > 0, 'datasetLength must be greater than 0');

  final epoch = DateTime(2000, 1, 1);
  final daysSinceEpoch = date.difference(epoch).inDays;
  final sportOffset = sport == Sport.basketball ? 0 : 1000;

  return (daysSinceEpoch + sportOffset) % datasetLength;
}

/// Convenience: pick the mystery player from the list using [computeDailyIndex].
Player selectMysteryPlayer(List<Player> players, DateTime date, Sport sport) {
  assert(players.isNotEmpty, 'players list must not be empty');
  final index = computeDailyIndex(date, sport, players.length);
  return players[index];
}
