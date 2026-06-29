# Design Document: Zouzzle App

## Overview

Zouzzle is a daily "Who Am I?" sports guessing game for University of Missouri football and basketball players. Built in Flutter/Dart targeting iOS first, the app presents a new mystery player each day per sport and challenges users to identify the player through color-coded attribute comparison feedback — green for exact matches, yellow for close numeric matches, and gray for misses. No backend is required for Phase 1; all player data is bundled as local JSON assets.

This design targets non-expert Flutter developers and therefore favors simplicity and clarity over advanced patterns. The architecture is intentionally shallow: a clean three-layer separation (UI → State/Logic → Data) using Riverpod for state management, GoRouter for navigation, and SharedPreferences for local persistence.

---

## Architecture

### Guiding Principles

- **Keep it flat**: Three logical layers — UI widgets, Notifiers/providers, and data services. No deep inheritance trees or complex abstractions.
- **No backend in Phase 1**: All data is read from bundled JSON assets at app launch. Networking code is explicitly excluded.
- **Testable core logic**: The attribute comparison engine and daily seed computation are pure functions with no Flutter dependencies, making them straightforward to unit-test and property-test.
- **Mizzou brand throughout**: Color theme defined once in a central `AppTheme` and referenced everywhere.

### Layer Diagram

```
┌─────────────────────────────────────────────────────────┐
│                        UI Layer                          │
│  HomeScreen  │  GameScreen  │  ResultScreen             │
│  Shared Widgets: FeedbackGrid, AttributeCell,           │
│  PlayerAutocompleteField, GuessCounter                  │
└──────────────────────┬──────────────────────────────────┘
                       │ reads/writes via Riverpod providers
┌──────────────────────▼──────────────────────────────────┐
│                  State / Logic Layer                     │
│  GameNotifier (Riverpod StateNotifier)                  │
│  ComparisonEngine (pure Dart functions)                 │
│  DailySeedService (pure Dart functions)                 │
└──────────────────────┬──────────────────────────────────┘
                       │ async calls
┌──────────────────────▼──────────────────────────────────┐
│                    Data Layer                            │
│  PlayerRepository  │  CompletionRepository              │
│  (JSON asset loader)  (SharedPreferences wrapper)       │
└─────────────────────────────────────────────────────────┘
```

### Technology Choices

| Concern | Choice | Rationale |
|---|---|---|
| State management | **Riverpod** (flutter_riverpod ^2.x) | Compile-safe providers, no BuildContext dependency for logic, straightforward for beginners once the mental model clicks. Preferred over Provider for new projects in 2024+. |
| Navigation | **GoRouter** (go_router ^14.x) | Declarative routes, minimal boilerplate for a three-screen app, officially supported by the Flutter team. |
| Local persistence | **shared_preferences** (^2.x) | Standard Flutter plugin for key-value storage; plenty of precedent for this scope of data. |
| Property-based tests | **glados** (^0.x) | The established Dart/Flutter PBT library; integrates directly with `flutter_test`. |
| JSON parsing | **dart:convert** + `json_serializable` | Code-generated `fromJson`/`toJson` keeps boilerplate minimal. |

---

## Components and Interfaces

### Navigation (GoRouter)

```dart
// lib/core/router.dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/',          builder: (ctx, state) => const HomeScreen()),
    GoRoute(path: '/game/:sport', builder: (ctx, state) {
      final sport = Sport.fromString(state.pathParameters['sport']!);
      return GameScreen(sport: sport);
    }),
    GoRoute(path: '/result/:sport', builder: (ctx, state) {
      final sport = Sport.fromString(state.pathParameters['sport']!);
      return ResultScreen(sport: sport);
    }),
  ],
);
```

Navigation calls from UI:
- `context.go('/game/basketball')` — from HomeScreen sport button
- `context.go('/result/basketball')` — auto-triggered by GameNotifier when win/lose
- `context.go('/')` — from the "Home" button on ResultScreen or GameScreen back arrow

### Screen Hierarchy

```
MaterialApp.router (GoRouter)
├── HomeScreen
│   ├── ZouzzleTitle (Text, 32sp+, gold color)
│   ├── SportButton("Basketball")
│   ├── SportButton("Football")
│   └── DisclaimerText
├── GameScreen(sport)
│   ├── AppBar (back arrow → HomeScreen)
│   ├── GuessCounter (remaining guesses display)
│   ├── FeedbackGrid (list of FeedbackRow widgets)
│   │   └── FeedbackRow → AttributeCell × 6 per row
│   ├── PlayerAutocompleteField (text input + dropdown)
│   └── SubmitButton
└── ResultScreen(sport)
    ├── OutcomeMessage ("You got it!" | "Better luck tomorrow")
    ├── MysteryPlayerReveal (player full name)
    ├── GuessScoreText (e.g., "3 / 6" — win only)
    ├── NextPuzzleMessage ("New puzzle available tomorrow")
    └── HomeButton → context.go('/')
```

### Riverpod Providers

```dart
// lib/providers/player_repository_provider.dart
final playerRepositoryProvider = FutureProvider.family<PlayerRepository, Sport>(
  (ref, sport) => PlayerRepository.load(sport),
);

// lib/providers/game_provider.dart
final gameProvider = StateNotifierProvider.family<GameNotifier, GameState, Sport>(
  (ref, sport) {
    final repoAsync = ref.watch(playerRepositoryProvider(sport));
    final completionRepo = ref.watch(completionRepositoryProvider);
    return GameNotifier(repoAsync, completionRepo, sport);
  },
);

// lib/providers/completion_repository_provider.dart
final completionRepositoryProvider = Provider<CompletionRepository>(
  (ref) => CompletionRepository(),
);
```

### GameNotifier Interface

```dart
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(AsyncValue<PlayerRepository> repoAsync,
               CompletionRepository completionRepo,
               Sport sport);

  /// Submit a player name as a guess. Returns false if invalid
  /// (not in dataset, already guessed, or game over).
  Future<bool> submitGuess(String playerName);

  /// Filter autocomplete suggestions given current input text.
  List<String> autocompleteFor(String input);
}
```

### GameState

```dart
@freezed
class GameState with _$GameState {
  const factory GameState({
    required Sport sport,
    required List<FeedbackRow> guesses,       // ordered list of submitted guesses + feedback
    required int remainingGuesses,             // starts at 6
    required GameStatus status,                // active | won | lost | loading | error
    required Player? mysteryPlayer,            // null while loading
    String? validationMessage,                 // inline error text
  }) = _GameState;
}

enum GameStatus { loading, active, won, lost, error }
```

### ComparisonEngine Interface (pure functions)

```dart
// lib/logic/comparison_engine.dart

/// Compare a single numeric attribute against the mystery player's value.
MatchState compareNumeric(int guessed, int mystery, int tolerance);

/// Compare a categorical or boolean attribute.
MatchState compareCategorical(Object guessed, Object mystery);

/// Produce a complete FeedbackRow for a guess against a mystery player.
FeedbackRow evaluateGuess(Player guessed, Player mystery);
```

### DailySeedService Interface (pure functions)

```dart
// lib/logic/daily_seed_service.dart

/// Returns a zero-based index into the player list for the given date and sport.
int computeDailyIndex(DateTime date, Sport sport, int datasetLength);

/// Convenience: pick the mystery player from the list.
Player selectMysteryPlayer(List<Player> players, DateTime date, Sport sport);
```

### PlayerRepository Interface

```dart
// lib/data/player_repository.dart
class PlayerRepository {
  final List<Player> players;

  static Future<PlayerRepository> load(Sport sport);  // reads JSON asset

  Player? findByName(String fullName);
  List<String> namesContaining(String substring);     // case-insensitive
}
```

### CompletionRepository Interface

```dart
// lib/data/completion_repository.dart
class CompletionRepository {
  Future<CompletionState?> loadForDate(Sport sport, DateTime date);
  Future<void> save(CompletionState state);
}
```

---

## Data Models

### Enums

```dart
enum Sport { basketball, football }

enum StatisticalTier { allAmerican, starter, rolePlayer, walkOn }

enum MatchState { exact, close, miss }
```

### Player (domain model)

```dart
@JsonSerializable()
class Player {
  final String fullName;
  final Sport sport;
  final String position;       // e.g., "Guard", "Quarterback"
  final int jerseyNumber;
  final int startYear;
  final int endYear;
  final bool wentPro;
  final StatisticalTier statisticalTier;
}
```

### FeedbackRow (result of evaluateGuess)

```dart
class FeedbackRow {
  final Player guessedPlayer;
  final List<AttributeResult> results;  // one per compared attribute, in fixed order
}

class AttributeResult {
  final String attributeLabel;   // "Position", "Jersey #", etc.
  final MatchState state;
  final ArrowDirection? arrow;   // non-null only when state == close (numeric)
}

enum ArrowDirection { up, down }
```

### CompletionState (persisted)

```dart
@JsonSerializable()
class CompletionState {
  final String sport;             // "basketball" | "football"
  final String date;             // "YYYY-MM-DD"
  final String outcome;          // "win" | "lose"
  final String mysteryPlayerName;
  final List<String> guesses;    // in submission order
}
```

### JSON Schema — Player Dataset

The bundled player files live at:
- `assets/data/basketball_players.json`
- `assets/data/football_players.json`
- `assets/data/player_schema.json` (co-bundled schema definition)

**basketball_players.json / football_players.json format:**

```json
{
  "players": [
    {
      "fullName": "Darius Miles",
      "sport": "basketball",
      "position": "Forward",
      "jerseyNumber": 0,
      "startYear": 2019,
      "endYear": 2023,
      "wentPro": true,
      "statisticalTier": "All-American"
    }
  ]
}
```

**player_schema.json (JSON Schema Draft-07):**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "PlayerDataset",
  "type": "object",
  "required": ["players"],
  "properties": {
    "players": {
      "type": "array",
      "minItems": 20,
      "items": {
        "type": "object",
        "required": ["fullName","sport","position","jerseyNumber",
                     "startYear","endYear","wentPro","statisticalTier"],
        "properties": {
          "fullName":        { "type": "string", "minLength": 1 },
          "sport":           { "type": "string", "enum": ["basketball","football"] },
          "position":        { "type": "string", "minLength": 1 },
          "jerseyNumber":    { "type": "integer", "minimum": 0, "maximum": 99 },
          "startYear":       { "type": "integer", "minimum": 1900 },
          "endYear":         { "type": "integer", "minimum": 1900 },
          "wentPro":         { "type": "boolean" },
          "statisticalTier": { "type": "string",
                               "enum": ["All-American","Starter","Role Player","Walk-On"] }
        }
      }
    }
  }
}
```

### Attribute Comparison Rules (reference table)

| Attribute | Type | Exact (green) | Close (yellow) | Miss (gray) |
|---|---|---|---|---|
| position | categorical | exact string match | — | otherwise |
| jerseyNumber | numeric | exact | within ±5 | outside ±5 |
| startYear | numeric | exact | within ±3 | outside ±3 |
| endYear | numeric | exact | within ±3 | outside ±3 |
| wentPro | boolean | exact | — | otherwise |
| statisticalTier | categorical | exact | — | otherwise |

Arrow on yellow numeric cells: ↑ if mystery > guessed, ↓ if mystery < guessed.

### Color Theme

```dart
// lib/core/app_theme.dart
class AppTheme {
  static const mizzouGold  = Color(0xFFF1B82D);
  static const mizzouBlack = Color(0xFF000000);
  static const exactGreen  = Color(0xFF538D4E);  // Wordle-style accessible green
  static const closeYellow = Color(0xFFB59F3B);  // Wordle-style accessible yellow
  static const missGray    = Color(0xFF3A3A3C);  // Wordle-style accessible gray
  static const white       = Color(0xFFFFFFFF);

  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.dark(
      primary: mizzouGold,
      onPrimary: mizzouBlack,
      surface: mizzouBlack,
    ),
    scaffoldBackgroundColor: mizzouBlack,
    appBarTheme: const AppBarTheme(
      backgroundColor: mizzouBlack,
      foregroundColor: mizzouGold,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: mizzouGold, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mizzouGold,
        foregroundColor: mizzouBlack,
      ),
    ),
  );
}
```

The disclaimer text on the HomeScreen is rendered white (`#FFFFFF`) on a black (`#000000`) background, yielding a 21:1 contrast ratio — far exceeding the WCAG AA threshold of 4.5:1.

### DailySeedService Algorithm

```
index = (daysSinceEpoch + sportOffset) mod datasetLength
```

Where:
- `daysSinceEpoch = date.difference(DateTime(2000,1,1)).inDays` — a stable integer that increments exactly once per calendar day using the device's local date.
- `sportOffset = sport == Sport.basketball ? 0 : 1000` — ensures basketball and football never share the same index on the same day.
- `datasetLength = players.length`.

This is pure arithmetic — no network, no randomness, deterministic for any (date, sport) pair. When all players have been cycled, the modulo naturally restarts from the beginning.

---

## Project File Structure

```
lib/
├── main.dart
├── core/
│   ├── app_theme.dart
│   └── router.dart
├── models/
│   ├── player.dart              (+ .g.dart generated)
│   ├── completion_state.dart    (+ .g.dart generated)
│   ├── feedback_row.dart
│   └── enums.dart
├── data/
│   ├── player_repository.dart
│   └── completion_repository.dart
├── logic/
│   ├── comparison_engine.dart
│   └── daily_seed_service.dart
├── providers/
│   ├── player_repository_provider.dart
│   ├── game_provider.dart
│   └── completion_repository_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── game_screen.dart
│   └── result_screen.dart
└── widgets/
    ├── sport_button.dart
    ├── feedback_grid.dart
    ├── feedback_row_widget.dart
    ├── attribute_cell.dart
    ├── player_autocomplete_field.dart
    ├── guess_counter.dart
    └── disclaimer_text.dart

assets/
└── data/
    ├── basketball_players.json
    ├── football_players.json
    └── player_schema.json

test/
├── unit/
│   ├── comparison_engine_test.dart
│   └── daily_seed_service_test.dart
├── property/
│   ├── comparison_engine_property_test.dart
│   └── daily_seed_property_test.dart
└── widget/
    ├── home_screen_test.dart
    ├── game_screen_test.dart
    └── result_screen_test.dart
```

---

## Error Handling

| Scenario | Behavior |
|---|---|
| JSON asset missing or malformed | `PlayerRepository.load()` catches and returns an error state; GameNotifier surfaces `GameStatus.error`; GameScreen shows non-blocking error banner with a "Go Home" button. App does not crash. |
| Player record missing required fields | `PlayerRepository.load()` uses `try/catch` on each record during parsing; invalid records are skipped; a minimum viable list is returned. |
| CompletionState data corrupt | `CompletionRepository.loadForDate()` catches `FormatException`; returns `null` (treat as unplayed). App does not crash. |
| Guess not in dataset | `GameNotifier.submitGuess()` returns `false`; GameState sets inline `validationMessage`; no guess is recorded. |
| Duplicate guess | Same as above — `validationMessage` is set to a "already guessed" message. |
| Guess submission when game over | `GameNotifier.submitGuess()` is a no-op; returns `false`. Submit button is also disabled in the UI via `GameStatus`. |
| Dataset length 0 after filtering | Game cannot proceed; `GameStatus.error` is set with "No valid players found" message. |

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

The comparison engine and daily seed logic are both pure functions — they take inputs and return outputs with no side effects, no network calls, and no Flutter widget dependencies. This makes them ideal candidates for property-based testing. The `glados` package (the established Dart PBT library) is used for all property tests, configured for a minimum of 100 iterations each.

---

### Property 1: Daily Seed Determinism

*For any* calendar date, sport, and positive dataset length, `computeDailyIndex` returns the same index when called multiple times with identical inputs.

This formalizes Requirement 2.2: the mystery player selection must be reproducible for a given (date, sport) pair — two users on the same date see the same player.

**Validates: Requirements 2.2, 2.3**

---

### Property 2: Daily Seed Index Is In Bounds

*For any* calendar date, sport, and dataset length N > 0, `computeDailyIndex` returns an integer in the range `[0, N)`.

This ensures the returned index is always a valid position in the player list, preventing index-out-of-bounds errors at runtime regardless of dataset size.

**Validates: Requirements 2.1, 2.2**

---

### Property 3: Daily Seed Full Cycle Coverage

*For any* dataset length N > 0 and any start date D, iterating `computeDailyIndex` over N consecutive dates for the same sport produces each index in `[0, N)` exactly once — and the index on day N equals the index on day D.

This confirms the wraparound behavior: no player repeats within a cycle, and the cycle restarts cleanly.

**Validates: Requirements 2.4, 2.5**

---

### Property 4: Self-Comparison Yields All Exact Matches

*For any* valid `Player` P, `evaluateGuess(P, P)` returns a `FeedbackRow` where every `AttributeResult` has `MatchState.exact`.

This is an identity invariant: a player compared against themselves must produce all-green feedback. If any attribute comparison returns something other than exact for identical inputs, the comparison logic is broken.

**Validates: Requirements 5.3**

---

### Property 5: Numeric Attribute Comparison Produces Correct Match States

*For any* numeric attribute value `guessed` and `mystery` with tolerance `t`:
- If `guessed == mystery`, the result is `MatchState.exact`.
- If `0 < |guessed - mystery| <= t`, the result is `MatchState.close`.
- If `|guessed - mystery| > t`, the result is `MatchState.miss`.

And when `state == MatchState.close`, the arrow direction satisfies: `arrow == ArrowDirection.up` if and only if `mystery > guessed`.

This property covers jersey number (tolerance ±5), start year (±3), and end year (±3) in one comprehensive numeric rule.

**Validates: Requirements 5.4, 5.6, 5.7**

---

### Property 6: Categorical and Boolean Comparisons Are Binary

*For any* categorical attribute (position, statisticalTier) or boolean attribute (wentPro), the comparison result is `MatchState.exact` if the values are equal and `MatchState.miss` otherwise. There is no close/yellow state for categorical or boolean attributes.

This ensures no intermediate state leaks into non-numeric comparisons.

**Validates: Requirements 5.3, 5.5**

---

### Property 7: Guess Validation Rejects Non-Dataset Names

*For any* `PlayerRepository` and any string that is not in the repository's player list, `submitGuess` returns `false` and the `GameState.guesses` list remains unchanged.

This covers both Requirement 4.5 (name must exist in dataset) and 4.7 (duplicate rejection): for any invalid input — whether the name doesn't exist or was already guessed — the guess is rejected without mutation.

**Validates: Requirements 4.5, 4.6, 4.7, 4.8**

---

### Property 8: Guess Count Is a Monotone-Decreasing Bounded Counter

*For any* sequence of valid guess submissions on an active game, `remainingGuesses` decrements by exactly 1 per valid submission and never falls below 0; `guesses.length` never exceeds 6.

This is an invariant of `GameState` throughout any game session.

**Validates: Requirements 6.1, 6.4, 6.6**

---

### Property 9: Malformed Records Are Silently Skipped

*For any* JSON array of player objects where some records are missing required fields, `PlayerRepository.load` returns a list containing only the valid records and does not throw.

Generators should produce arrays with random subsets of fields removed from arbitrary records, verifying that skipped records are excluded and valid records are preserved.

**Validates: Requirements 3.6**

---

### Property 10: Autocomplete Filter Is a Subset with Correct Containment

*For any* `PlayerRepository` and any non-empty query string Q, every name returned by `namesContaining(Q)` contains Q as a case-insensitive substring, and no name in the result contains a player not in the repository.

**Validates: Requirements 4.2**

---

### Property 11: Completion State Round-Trip Fidelity

*For any* `CompletionState` CS with date D, saving CS then loading for (sport, D) returns a `CompletionState` equal to CS. Loading for (sport, D') where D' ≠ D returns `null`.

This round-trip property validates both the persistence logic (Requirement 8.1) and the date-isolation behavior (Requirement 8.3) in one combined property.

**Validates: Requirements 8.1, 8.3**

---

## Testing Strategy

### Dual Testing Approach

The test suite combines unit/widget tests for concrete behavior with property-based tests for universal invariants.

**Unit and Widget Tests** (in `test/unit/` and `test/widget/`):
- Screen rendering: verify required UI elements are present (disclaimer text, sport buttons, column headers, guess counter)
- Navigation: verify sport button taps route to the correct GameScreen
- Win/Lose transitions: verify GameNotifier sets correct status after winning guess or 6th miss
- Error states: verify malformed JSON triggers error banner, not crash
- Result Screen content: verify correct outcome messages and player name reveal
- Initialization: verify remainingGuesses starts at 6

**Property-Based Tests** (in `test/property/`) using `glados ^0.x`:
- Minimum 100 iterations per test
- Each test is tagged with a comment referencing the design property
  - Tag format: `// Feature: zouzzle-app, Property N: <property_text>`
- Custom `Any` generators needed:
  - `Any.validPlayer` — generates a `Player` with all required fields populated and plausible values
  - `Any.playerPair` — generates `(guessedPlayer, mysteryPlayer)` pairs
  - `Any.dateInRange` — generates `DateTime` values in a reasonable range (2024–2040)
  - `Any.playerJsonArray` — generates JSON arrays with a mix of valid and invalid player records

**Property test file outline:**

```dart
// test/property/comparison_engine_property_test.dart
// Feature: zouzzle-app, Property 4: Self-Comparison Yields All Exact Matches
test('evaluateGuess(P, P) is all exact for any player P', () {
  Glados(Any.validPlayer).test((player) {
    final row = evaluateGuess(player, player);
    expect(row.results.every((r) => r.state == MatchState.exact), isTrue);
  });
});

// Feature: zouzzle-app, Property 5: Numeric Attribute Comparison
test('compareNumeric: exact/close/miss classification is correct', () {
  Glados2(Any.int, Any.int).test((guessed, mystery) {
    const tolerance = 5;
    final state = compareNumeric(guessed, mystery, tolerance);
    final diff = (guessed - mystery).abs();
    if (diff == 0) expect(state, MatchState.exact);
    else if (diff <= tolerance) expect(state, MatchState.close);
    else expect(state, MatchState.miss);
  });
});

// test/property/daily_seed_property_test.dart
// Feature: zouzzle-app, Property 1: Daily Seed Determinism
test('computeDailyIndex is deterministic for same inputs', () {
  Glados3(Any.dateInRange, Any.sport, Any.positiveInt).test((date, sport, n) {
    final i1 = computeDailyIndex(date, sport, n);
    final i2 = computeDailyIndex(date, sport, n);
    expect(i1, equals(i2));
  });
});

// Feature: zouzzle-app, Property 2: Daily Seed Index Is In Bounds
test('computeDailyIndex result is in [0, n)', () {
  Glados3(Any.dateInRange, Any.sport, Any.positiveInt).test((date, sport, n) {
    final idx = computeDailyIndex(date, sport, n);
    expect(idx, greaterThanOrEqualTo(0));
    expect(idx, lessThan(n));
  });
});
```

**Integration Tests** (optional, Phase 2):
- Full asset loading from real bundled JSON files
- SharedPreferences round-trip with the real plugin

### Why No PBT for UI Screens

HomeScreen, GameScreen, and ResultScreen are Flutter widget trees with no pure-function transformation logic. Their correctness is best verified through example-based widget tests (pump, find, expect) and visual review. Property-based testing over widget trees would be high-cost with little additional bug-finding value over concrete examples.
