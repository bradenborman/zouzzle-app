import 'dart:math';

import '../models/enums.dart';
import '../models/feedback_row.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';

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
double _getStatValue(Player player, StatCategory cat) {
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

/// Picks a random stat with points weighted at 50% probability.
StatCategory _pickWeightedStat() {
  final rand = Random();
  final roll = rand.nextInt(100);
  if (roll < 50) return StatCategory.points;        // 50%
  if (roll < 70) return StatCategory.rebounds;      // 20%
  if (roll < 85) return StatCategory.assists;       // 15%
  return StatCategory.steals;                        // 15%
}

/// Build a stat AttributeResult for a given category.
AttributeResult _buildStatResult(Player guessed, Player mystery) {
  final statCat = _pickWeightedStat();
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
  return AttributeResult(
    attributeLabel: 'Stat',
    state: statState,
    arrow: statArrow,
    displayValue: '${statCategoryLabel(statCat)} $guessedStat',
  );
}

/// Produce a complete [FeedbackRow] for a guess against a mystery player.
///
/// Columns vary by difficulty:
/// - Recent mode: Pos, Height, Stat, Stat (two stat columns, no years)
/// - All other modes: Pos, Height, Years, Stat
FeedbackRow evaluateGuess(Player guessed, Player mystery, {Difficulty? difficulty}) {

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
  final ft = guessed.height ~/ 12;
  final inches = guessed.height % 12;
  final heightDisplay = "$ft'$inches\"";

  // Build results based on difficulty
  final results = <AttributeResult>[
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
  ];

  if (difficulty == Difficulty.recent) {
    // Recent mode: two stat columns instead of years (guaranteed different)
    final stat1 = _buildStatResult(guessed, mystery);
    // Pick second stat ensuring it's a different category
    AttributeResult stat2 = _buildStatResult(guessed, mystery);
    int attempts = 0;
    while (stat2.displayValue!.substring(0, 3) == stat1.displayValue!.substring(0, 3) && attempts < 10) {
      stat2 = _buildStatResult(guessed, mystery);
      attempts++;
    }
    results.add(stat1);
    results.add(stat2);
  } else {
    // All other modes: years + one stat
    // 3. Years — did their years overlap?
    final bool wereTeammates =
        guessed.startYear <= mystery.endYear && guessed.endYear >= mystery.startYear;
    final teammatesState = wereTeammates ? MatchState.exact : MatchState.miss;
    final yearsDisplay = "'${(guessed.startYear % 100).toString().padLeft(2, '0')}-'${(guessed.endYear % 100).toString().padLeft(2, '0')}";

    final ArrowDirection? yearsArrow;
    if (wereTeammates) {
      yearsArrow = null;
    } else if (mystery.startYear > guessed.endYear) {
      yearsArrow = ArrowDirection.up;
    } else {
      yearsArrow = ArrowDirection.down;
    }

    results.add(AttributeResult(
      attributeLabel: 'Years',
      state: teammatesState,
      arrow: yearsArrow,
      displayValue: yearsDisplay,
    ));
    results.add(_buildStatResult(guessed, mystery));
  }

  return FeedbackRow(
    guessedPlayer: guessed,
    results: results,
  );
}
