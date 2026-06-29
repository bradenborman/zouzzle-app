import 'package:flutter_test/flutter_test.dart';
import 'package:zouzzle/logic/comparison_engine.dart';
import 'package:zouzzle/models/enums.dart';

void main() {
  group('compareNumeric', () {
    const tolerance = 5;

    test('returns exact when values are equal', () {
      expect(compareNumeric(10, 10, tolerance), MatchState.exact);
      expect(compareNumeric(0, 0, tolerance), MatchState.exact);
      expect(compareNumeric(-3, -3, tolerance), MatchState.exact);
    });

    test('returns close when diff is within tolerance (above)', () {
      expect(compareNumeric(10, 14, tolerance), MatchState.close); // diff = 4
      expect(compareNumeric(10, 15, tolerance), MatchState.close); // diff = 5 (boundary)
    });

    test('returns close when diff is within tolerance (below)', () {
      expect(compareNumeric(15, 10, tolerance), MatchState.close); // diff = 5 (boundary)
      expect(compareNumeric(14, 10, tolerance), MatchState.close); // diff = 4
    });

    test('returns miss when diff exceeds tolerance', () {
      expect(compareNumeric(10, 16, tolerance), MatchState.miss); // diff = 6
      expect(compareNumeric(16, 10, tolerance), MatchState.miss); // diff = 6
      expect(compareNumeric(0, 100, tolerance), MatchState.miss);
    });

    test('returns miss when diff is exactly tolerance + 1', () {
      expect(compareNumeric(0, 6, tolerance), MatchState.miss); // diff = 6
      expect(compareNumeric(6, 0, tolerance), MatchState.miss); // diff = 6
    });

    test('uses provided tolerance — jersey number (±5)', () {
      expect(compareNumeric(50, 55, 5), MatchState.close);
      expect(compareNumeric(50, 56, 5), MatchState.miss);
    });

    test('uses provided tolerance — year (±3)', () {
      expect(compareNumeric(2018, 2021, 3), MatchState.close);
      expect(compareNumeric(2018, 2022, 3), MatchState.miss);
    });
  });

  group('compareCategorical', () {
    test('returns exact for equal strings', () {
      expect(compareCategorical('Guard', 'Guard'), MatchState.exact);
      expect(compareCategorical('Forward', 'Forward'), MatchState.exact);
    });

    test('returns miss for different strings', () {
      expect(compareCategorical('Guard', 'Forward'), MatchState.miss);
      expect(compareCategorical('Quarterback', 'Guard'), MatchState.miss);
    });

    test('returns exact for equal booleans', () {
      expect(compareCategorical(true, true), MatchState.exact);
      expect(compareCategorical(false, false), MatchState.exact);
    });

    test('returns miss for different booleans', () {
      expect(compareCategorical(true, false), MatchState.miss);
      expect(compareCategorical(false, true), MatchState.miss);
    });

    test('returns exact for equal StatisticalTier values', () {
      expect(
        compareCategorical(StatisticalTier.allAmerican, StatisticalTier.allAmerican),
        MatchState.exact,
      );
      expect(
        compareCategorical(StatisticalTier.walkOn, StatisticalTier.walkOn),
        MatchState.exact,
      );
    });

    test('returns miss for different StatisticalTier values', () {
      expect(
        compareCategorical(StatisticalTier.allAmerican, StatisticalTier.walkOn),
        MatchState.miss,
      );
    });

    test('returns miss for mixed types that are not equal', () {
      // e.g., a string "true" vs bool true — not equal, so miss
      expect(compareCategorical('true', true), MatchState.miss);
    });
  });
}
