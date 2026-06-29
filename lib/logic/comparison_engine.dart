import '../models/enums.dart';
import '../models/feedback_row.dart';
import '../models/player.dart';

/// Compare a single numeric attribute against the mystery player's value.
MatchState compareNumeric(int guessed, int mystery, int tolerance) {
  final diff = (guessed - mystery).abs();
  if (diff == 0) return MatchState.exact;
  if (diff <= tolerance) return MatchState.close;
  return MatchState.miss;
}

/// Compare a categorical or boolean attribute.
MatchState compareCategorical(Object guessed, Object mystery) {
  return guessed == mystery ? MatchState.exact : MatchState.miss;
}

/// The stat categories available for the random stat column.
enum StatCategory { points, rebounds, assists, steals }

/// Picks a stat category deterministically for the given date.
/// Same date = same stat for everyone.
StatCategory dailyStatCategory(DateTime date) {
  final epoch = DateTime(2000, 1, 1);
  final days = date.difference(epoch).inDays;
  const categories = StatCategory.values;
  return categories[days % categories.length];
}

/// Returns the display name for a stat category.
String statCategoryLabel(StatCategory cat) {
  switch (cat) {
    case StatCategory.points:
      return 'Pts';
    case StatCategory.rebounds:
      return 'Reb';
    case StatCategory.assists:
      return 'Ast';
    case StatCategory.steals:
      return 'Stl';
  }
}

/// Gets the stat value from a player for a given category.
int _getStatValue(Player player, StatCategory cat) {
  switch (cat) {
    case StatCategory.points:
      return player.points;
    case StatCategory.rebounds:
      return player.rebounds;
    case StatCategory.assists:
      return player.assists;
    case StatCategory.steals:
      return player.steals;
  }
}

/// Produce a complete [FeedbackRow] for a guess against a mystery player.
///
/// Columns: Position, Jersey, Teammates, daily Stat
FeedbackRow evaluateGuess(Player guessed, Player mystery) {

  // 1. Position — categorical match
  final positionState = compareCategorical(guessed.position, mystery.position);

  // 2. Height — show height, green if match, yellow if within 2 inches, arrow if not
  final MatchState heightState;
  final ArrowDirection? heightArrow;
  if (guessed.height == mystery.height) {
    heightState = MatchState.exact;
    heightArrow = null;
  } else {
    final diff = (guessed.height - mystery.height).abs();
    heightState = diff <= 2 ? MatchState.close : MatchState.miss;
    heightArrow = mystery.height > guessed.height
        ? ArrowDirection.up
        : ArrowDirection.down;
  }
  // Format height as feet'inches"
  final ft = guessed.height ~/ 12;
  final inches = guessed.height % 12;
  final heightDisplay = "$ft'$inches\"";

  // 3. Teammates — did their years at Mizzou overlap?
  final bool wereTeammates =
      guessed.startYear <= mystery.endYear && guessed.endYear >= mystery.startYear;
  final teammatesState = wereTeammates ? MatchState.exact : MatchState.miss;
  final yearsDisplay = "'${(guessed.startYear % 100).toString().padLeft(2, '0')}-'${(guessed.endYear % 100).toString().padLeft(2, '0')}";

  // 4. Random stat — picks a random category each guess
  final statCat = StatCategory.values[DateTime.now().microsecond % StatCategory.values.length];
  final guessedStat = _getStatValue(guessed, statCat);
  final mysteryStat = _getStatValue(mystery, statCat);
  final MatchState statState;
  final ArrowDirection? statArrow;
  if (guessedStat == mysteryStat) {
    statState = MatchState.exact;
    statArrow = null;
  } else {
    statState = MatchState.miss;
    statArrow = mysteryStat > guessedStat
        ? ArrowDirection.up
        : ArrowDirection.down;
  }

  return FeedbackRow(
    guessedPlayer: guessed,
    results: [
      AttributeResult(
        attributeLabel: 'Pos',
        state: positionState,
        displayValue: guessed.position,
      ),
      AttributeResult(
        attributeLabel: 'Height',
        state: heightState,
        arrow: heightArrow,
        displayValue: heightDisplay,
      ),
      AttributeResult(
        attributeLabel: 'Years',
        state: teammatesState,
        displayValue: yearsDisplay,
      ),
      AttributeResult(
        attributeLabel: 'Stat',
        state: statState,
        arrow: statArrow,
        displayValue: '${statCategoryLabel(statCat)} $guessedStat',
      ),
    ],
  );
}
