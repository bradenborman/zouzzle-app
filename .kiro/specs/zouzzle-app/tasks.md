# Implementation Plan: Zouzzle App

## Overview

Implement a Flutter/Dart iOS-first daily sports guessing game following the three-layer architecture (UI → State/Logic → Data) defined in the design document. Tasks are ordered by dependency: scaffold and theme first, then models and data assets, then repositories, then pure logic, then state management, then screens, then tests.

---

## Tasks

- [x] 1. Scaffold Flutter project and configure dependencies
  - [x] 1.1 Create `pubspec.yaml` with all required dependencies and asset declarations
    - Add `flutter_riverpod: ^2.x`, `go_router: ^14.x`, `shared_preferences: ^2.x`, `freezed: ^2.x`, `freezed_annotation: ^2.x`, `json_annotation: ^4.x`, `json_serializable: ^6.x` to `dependencies`
    - Add `build_runner`, `freezed`, `json_serializable` to `dev_dependencies`
    - Add `glados: ^0.x` to `dev_dependencies`
    - Declare `assets/data/` under the `flutter → assets` section
    - _Requirements: 3.1, 3.4_

  - [x] 1.2 Create project folder structure and `main.dart`
    - Create directories: `lib/core/`, `lib/models/`, `lib/data/`, `lib/logic/`, `lib/providers/`, `lib/screens/`, `lib/widgets/`
    - Create `test/unit/`, `test/property/`, `test/widget/`
    - Write `lib/main.dart` that wraps `MaterialApp.router` with `ProviderScope` and wires in `AppTheme.theme` and the GoRouter instance
    - _Requirements: 1.1, 1.6_

  - [x] 1.3 Implement `AppTheme` in `lib/core/app_theme.dart`
    - Define color constants: `mizzouGold (#F1B82D)`, `mizzouBlack (#000000)`, `exactGreen (#538D4E)`, `closeYellow (#B59F3B)`, `missGray (#3A3A3C)`, `white (#FFFFFF)`
    - Implement `AppTheme.theme` returning a dark `ThemeData` as specified in the design
    - _Requirements: 1.6, 9.1_

  - [x] 1.4 Implement GoRouter in `lib/core/router.dart`
    - Define routes for `/`, `/game/:sport`, `/result/:sport`
    - Wire `Sport.fromString()` in the `/game/:sport` and `/result/:sport` builders
    - _Requirements: 1.1, 1.3, 7.6_

- [x] 2. Define data models and enums
  - [x] 2.1 Create enums in `lib/models/enums.dart`
    - Define `Sport` enum with `basketball` and `football` values; add `fromString` factory and `toJson`/`fromJson` helpers
    - Define `StatisticalTier` enum with `allAmerican`, `starter`, `rolePlayer`, `walkOn`; add JSON string mapping (`"All-American"`, `"Starter"`, `"Role Player"`, `"Walk-On"`)
    - Define `MatchState` enum: `exact`, `close`, `miss`
    - Define `ArrowDirection` enum: `up`, `down`
    - Define `GameStatus` enum: `loading`, `active`, `won`, `lost`, `error`
    - _Requirements: 2.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 2.2 Create `Player` model in `lib/models/player.dart`
    - Annotate with `@JsonSerializable()`
    - Include all required fields: `fullName`, `sport`, `position`, `jerseyNumber`, `startYear`, `endYear`, `wentPro`, `statisticalTier`
    - Run `build_runner` to generate `player.g.dart`
    - _Requirements: 3.2_

  - [x] 2.3 Create `FeedbackRow` and `AttributeResult` models in `lib/models/feedback_row.dart`
    - Define `AttributeResult` with `attributeLabel`, `state`, and optional `arrow`
    - Define `FeedbackRow` with `guessedPlayer` and `List<AttributeResult> results`
    - _Requirements: 5.1, 5.7, 5.9_

  - [x] 2.4 Create `CompletionState` model in `lib/models/completion_state.dart`
    - Annotate with `@JsonSerializable()`
    - Include fields: `sport` (String), `date` (String YYYY-MM-DD), `outcome` (String), `mysteryPlayerName`, `guesses` (List<String>)
    - Run `build_runner` to generate `completion_state.g.dart`
    - _Requirements: 8.1_

  - [x] 2.5 Create `GameState` with Freezed in `lib/models/game_state.dart`
    - Annotate with `@freezed`; generate using `build_runner`
    - Fields: `sport`, `guesses` (List<FeedbackRow>), `remainingGuesses` (int, default 6), `status` (GameStatus), `mysteryPlayer` (Player?), `validationMessage` (String?)
    - _Requirements: 6.2, 6.3_

- [x] 3. Create JSON asset files
  - [x] 3.1 Create `assets/data/basketball_players.json` with 20+ placeholder players
    - Each entry must include all required fields matching the schema: `fullName`, `sport: "basketball"`, `position`, `jerseyNumber`, `startYear`, `endYear`, `wentPro`, `statisticalTier`
    - Use a variety of positions (Guard, Forward, Center), years (1995–2024), statistical tiers, and jersey numbers (0–99)
    - _Requirements: 3.1, 3.2, 3.4_

  - [x] 3.2 Create `assets/data/football_players.json` with 20+ placeholder players
    - Each entry must include all required fields; `sport` must be `"football"`
    - Use a variety of positions (Quarterback, Running Back, Wide Receiver, Linebacker, Cornerback, etc.)
    - _Requirements: 3.1, 3.2, 3.4_

  - [x] 3.3 Create `assets/data/player_schema.json`
    - JSON Schema Draft-07 document exactly as specified in the design
    - Document all required fields, their types, allowed values, and constraints
    - _Requirements: 3.5_

- [x] 4. Implement `PlayerRepository` in `lib/data/player_repository.dart`
  - [x] 4.1 Implement `PlayerRepository.load(Sport sport)` static factory
    - Load the correct JSON asset file based on sport
    - Parse the JSON; for each record, wrap parse in `try/catch` and skip invalid/incomplete records (Requirement 3.6)
    - If asset is unreadable/malformed, throw a typed exception that `GameNotifier` can catch
    - Store the resulting `List<Player>` as `players`
    - _Requirements: 3.1, 3.3, 3.6_

  - [x] 4.2 Implement `findByName(String fullName)` and `namesContaining(String substring)` methods
    - `findByName`: case-sensitive exact match on `player.fullName`; returns `Player?`
    - `namesContaining`: case-insensitive substring filter; returns `List<String>` of full names
    - _Requirements: 4.2, 4.5_

- [x] 5. Implement `CompletionRepository` in `lib/data/completion_repository.dart`
  - [x] 5.1 Implement `loadForDate(Sport sport, DateTime date)` method
    - Read from `SharedPreferences` using a key derived from sport and date (`"completion_${sport.name}_${date.toIso8601String().substring(0,10)}"`)
    - Decode stored JSON string to `CompletionState` via `fromJson`
    - Wrap in `try/catch`; return `null` on any error (corrupt data) — do not crash
    - _Requirements: 8.1, 8.4_

  - [x] 5.2 Implement `save(CompletionState state)` method
    - Serialize `CompletionState` to JSON string and write to `SharedPreferences` under the derived key
    - _Requirements: 8.1_

- [x] 6. Implement `DailySeedService` pure functions in `lib/logic/daily_seed_service.dart`
  - [x] 6.1 Implement `computeDailyIndex(DateTime date, Sport sport, int datasetLength)`
    - Use the algorithm: `index = (daysSinceEpoch + sportOffset) % datasetLength`
    - `daysSinceEpoch = date.difference(DateTime(2000,1,1)).inDays`
    - `sportOffset = sport == Sport.basketball ? 0 : 1000`
    - Assert `datasetLength > 0` and return a value in `[0, datasetLength)`
    - _Requirements: 2.2, 2.3, 2.5_

  - [x] 6.2 Implement `selectMysteryPlayer(List<Player> players, DateTime date, Sport sport)`
    - Call `computeDailyIndex` then index into `players`
    - _Requirements: 2.1, 2.2_

- [x] 7. Implement `ComparisonEngine` pure functions in `lib/logic/comparison_engine.dart`
  - [x] 7.1 Implement `compareNumeric(int guessed, int mystery, int tolerance)`
    - Return `MatchState.exact` if values equal
    - Return `MatchState.close` if `0 < |guessed - mystery| <= tolerance`
    - Return `MatchState.miss` otherwise
    - _Requirements: 5.3, 5.4, 5.6_

  - [x] 7.2 Implement `compareCategorical(Object guessed, Object mystery)`
    - Return `MatchState.exact` if equal, `MatchState.miss` otherwise
    - Handles `String` (position, statisticalTier) and `bool` (wentPro)
    - _Requirements: 5.3, 5.5_

  - [x] 7.3 Implement `evaluateGuess(Player guessed, Player mystery)`
    - Compare all six attributes in the fixed order defined in the design: position, jerseyNumber, startYear, endYear, wentPro, statisticalTier
    - For each numeric attribute, compute `ArrowDirection` when state is `close` (↑ if mystery > guessed, ↓ if mystery < guessed)
    - Return a `FeedbackRow` with correctly labeled `AttributeResult` entries
    - _Requirements: 5.1, 5.2, 5.7, 5.9_

- [x] 8. Implement `GameNotifier` and wire Riverpod providers
  - [x] 8.1 Create `CompletionRepository` provider in `lib/providers/completion_repository_provider.dart`
    - Expose `completionRepositoryProvider` as a `Provider<CompletionRepository>`
    - _Requirements: 8.1_

  - [x] 8.2 Create `PlayerRepository` provider in `lib/providers/player_repository_provider.dart`
    - Expose `playerRepositoryProvider` as a `FutureProvider.family<PlayerRepository, Sport>`
    - _Requirements: 3.1_

  - [x] 8.3 Implement `GameNotifier` in `lib/providers/game_provider.dart`
    - Constructor: receive `AsyncValue<PlayerRepository>`, `CompletionRepository`, and `Sport`
    - On init: if repository loaded, check `CompletionRepository` for today's completed puzzle; if found, restore `GameState` from `CompletionState` with correct `status` (won/lost) and reconstructed `guesses` (FeedbackRows); otherwise select mystery player via `DailySeedService` and set `status = active`
    - `submitGuess(String playerName)`: validate name exists in dataset (return false + set `validationMessage` if not); validate not duplicate (return false + set `validationMessage`); validate game not over; call `evaluateGuess`; append `FeedbackRow` to `guesses`; decrement `remainingGuesses`; check win (name matches mystery); check lose (remainingGuesses == 0); persist `CompletionState` on terminal state; return true
    - `autocompleteFor(String input)`: delegate to `PlayerRepository.namesContaining`; return empty list when input is empty
    - Expose `gameProvider` as `StateNotifierProvider.family<GameNotifier, GameState, Sport>`
    - _Requirements: 4.5, 4.6, 4.7, 4.8, 4.9, 6.1, 6.2, 6.4, 6.5, 6.6, 7.1, 7.5, 8.1, 8.2_

- [x] 9. Implement shared widgets
  - [x] 9.1 Create `SportButton` widget in `lib/widgets/sport_button.dart`
    - Accepts `label` (String) and `onTap` (VoidCallback)
    - Renders as an `ElevatedButton` with `AppTheme` gold/black styling; minimum touch target 48×48
    - _Requirements: 1.2, 1.6_

  - [x] 9.2 Create `DisclaimerText` widget in `lib/widgets/disclaimer_text.dart`
    - Display the exact disclaimer text from Requirement 9.4 in white on black background
    - Use a font size that keeps the text readable; ensure semantic label is set for accessibility
    - _Requirements: 1.4, 9.4, 9.5_

  - [x] 9.3 Create `AttributeCell` widget in `lib/widgets/attribute_cell.dart`
    - Renders a colored square cell based on `MatchState` (green/yellow/gray via `AppTheme`)
    - When `state == close` and `arrow` is non-null, render ↑ or ↓ icon inside the cell
    - Display `attributeLabel` text below the cell
    - _Requirements: 5.3, 5.4, 5.5, 5.7_

  - [x] 9.4 Create `FeedbackRowWidget` in `lib/widgets/feedback_row_widget.dart`
    - Renders a horizontal row of six `AttributeCell` widgets from a `FeedbackRow`
    - _Requirements: 5.1, 5.8_

  - [x] 9.5 Create `FeedbackGrid` widget in `lib/widgets/feedback_grid.dart`
    - Renders column headers (attribute names) above the stack of `FeedbackRowWidget` entries
    - Accepts `List<FeedbackRow>` and renders them in submission order
    - _Requirements: 5.8, 5.9_

  - [x] 9.6 Create `PlayerAutocompleteField` widget in `lib/widgets/player_autocomplete_field.dart`
    - Text input that calls `GameNotifier.autocompleteFor` on each keystroke and shows a dropdown of suggestions
    - Selecting a suggestion populates the field and closes the dropdown
    - When the suggestion list is empty, hide the dropdown
    - Expose an `onSubmit` callback for wiring to the submit button
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x] 9.7 Create `GuessCounter` widget in `lib/widgets/guess_counter.dart`
    - Display remaining guess count as a numeric value (e.g., "Guesses remaining: 4")
    - Reads `GameState.remainingGuesses` from provider
    - _Requirements: 6.3_

- [x] 10. Implement screens
  - [x] 10.1 Implement `HomeScreen` in `lib/screens/home_screen.dart`
    - Render `ZouzzleTitle` text widget at 32sp+ in `mizzouGold`
    - Render two `SportButton` widgets: "Basketball" → `context.go('/game/basketball')`, "Football" → `context.go('/game/football')`
    - Render `DisclaimerText` at the bottom
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 9.2, 9.4_

  - [x] 10.2 Implement `GameScreen` in `lib/screens/game_screen.dart`
    - Show `AppBar` with back arrow navigating to `/` via `context.go('/')`
    - Watch `gameProvider(sport)` for state; show loading indicator while `status == loading`, error banner with "Go Home" button if `status == error`
    - Render `GuessCounter`, `FeedbackGrid`, `PlayerAutocompleteField`, and a `SubmitButton`
    - Wire `SubmitButton` to call `GameNotifier.submitGuess`; disable button when `status != active`
    - Show `validationMessage` as inline text below the input field when non-null
    - When `status` transitions to `won` or `lost`, navigate to `/result/:sport` via `context.go`
    - _Requirements: 1.7, 4.1, 4.6, 4.8, 4.9, 5.8, 6.3, 7.1, 7.5, 8.2_

  - [x] 10.3 Implement `ResultScreen` in `lib/screens/result_screen.dart`
    - Watch `gameProvider(sport)` to read `status`, `mysteryPlayer`, and `guesses`
    - When `status == won`: display "You got it!", mystery player's full name, and guess score (e.g., "3 / 6")
    - When `status == lost`: display "Better luck tomorrow" and mystery player's full name revealed
    - Display "New puzzle available tomorrow"
    - Display a "Home" button that navigates to `/` via `context.go('/')`
    - When status is restored from `CompletionState` (user re-opens same day), reconstruct the same display
    - _Requirements: 7.2, 7.3, 7.4, 7.5, 7.6, 8.2_

- [x] 11. Checkpoint — wire everything together and verify basic app flow
  - Ensure all providers are registered and the app compiles
  - Verify `main.dart` → `ProviderScope` → `MaterialApp.router` → `HomeScreen` renders without errors
  - Run `flutter analyze` and fix any static analysis errors
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Write property-based tests for `ComparisonEngine`
  - [ ]* 12.1 Write property test: Self-comparison yields all exact matches (Property 4)
    - **Property 4: Self-Comparison Yields All Exact Matches**
    - Use `Glados(Any.validPlayer)` to verify `evaluateGuess(P, P)` returns all `MatchState.exact`
    - **Validates: Requirements 5.3**

  - [ ]* 12.2 Write property test: Numeric comparison correctness (Property 5)
    - **Property 5: Numeric Attribute Comparison Produces Correct Match States**
    - Use `Glados2(Any.int, Any.int)` with tolerance 5; verify exact/close/miss classification and arrow direction when close
    - **Validates: Requirements 5.4, 5.6, 5.7**

  - [ ]* 12.3 Write property test: Categorical/boolean comparisons are binary (Property 6)
    - **Property 6: Categorical and Boolean Comparisons Are Binary**
    - Verify `compareCategorical` returns only `exact` or `miss`, never `close`
    - **Validates: Requirements 5.3, 5.5**

- [ ] 13. Write property-based tests for `DailySeedService`
  - [ ]* 13.1 Write property test: Daily seed determinism (Property 1)
    - **Property 1: Daily Seed Determinism**
    - Use `Glados3(Any.dateInRange, Any.sport, Any.positiveInt)` to verify two calls with identical inputs return the same index
    - **Validates: Requirements 2.2, 2.3**

  - [ ]* 13.2 Write property test: Daily seed index is in bounds (Property 2)
    - **Property 2: Daily Seed Index Is In Bounds**
    - Verify `computeDailyIndex` always returns a value in `[0, N)` for any N > 0
    - **Validates: Requirements 2.1, 2.2**

  - [ ]* 13.3 Write property test: Full cycle coverage (Property 3)
    - **Property 3: Daily Seed Full Cycle Coverage**
    - Iterate over N consecutive dates; verify all indices `[0, N)` appear exactly once and index wraps back on day N
    - **Validates: Requirements 2.4, 2.5**

- [ ] 14. Write unit tests for `ComparisonEngine` and `DailySeedService`
  - [ ]* 14.1 Write unit tests for `compareNumeric`, `compareCategorical`, and `evaluateGuess`
    - Cover exact boundary values, tolerance edges (±1 of tolerance), and outside-tolerance cases
    - Verify arrow direction for close matches: `↑` when mystery > guessed, `↓` when mystery < guessed
    - _Requirements: 5.3, 5.4, 5.5, 5.6, 5.7_

  - [ ]* 14.2 Write unit tests for `computeDailyIndex` and `selectMysteryPlayer`
    - Test known date/sport combos; verify basketball and football produce different indices on the same date
    - Test cycle wraparound: index at day N equals index at day 0
    - _Requirements: 2.2, 2.3, 2.5_

- [ ] 15. Write widget tests for all three screens
  - [ ]* 15.1 Write widget tests for `HomeScreen`
    - Verify "Zouzzle" title renders at ≥32sp
    - Verify two sport buttons are present and tapping each navigates to the correct game route
    - Verify disclaimer text is present on screen
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 9.4_

  - [ ]* 15.2 Write widget tests for `GameScreen`
    - Verify `GuessCounter` shows 6 remaining guesses at game start
    - Verify submitting an invalid name shows a validation message and does not record a guess
    - Verify submitting a valid guess appends a `FeedbackRowWidget` and decrements the counter
    - Verify error banner appears (not crash) when `GameStatus.error`
    - Verify back arrow navigates to HomeScreen
    - _Requirements: 1.7, 4.6, 4.8, 5.1, 5.8, 6.3_

  - [ ]* 15.3 Write widget tests for `ResultScreen`
    - Verify win state shows "You got it!", mystery player name, and correct guess score
    - Verify lose state shows "Better luck tomorrow" and mystery player name
    - Verify "New puzzle available tomorrow" message is present
    - Verify "Home" button navigates to `/`
    - _Requirements: 7.2, 7.3, 7.4, 7.6_

- [ ] 16. Final checkpoint — full test suite and static analysis
  - Run `flutter test` and resolve all failures
  - Run `flutter analyze` and fix any remaining warnings
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP build.
- Each task references specific requirements for traceability.
- Run `flutter pub run build_runner build --delete-conflicting-outputs` after completing tasks 2.2, 2.4, and 2.5 to generate `.g.dart` and `.freezed.dart` files.
- Property tests use the `glados` package. Define custom generators (`Any.validPlayer`, `Any.dateInRange`, `Any.sport`, `Any.positiveInt`) in a shared `test/helpers/generators.dart` file before writing tests in tasks 12 and 13.
- The `glados` integration with `flutter_test` means property tests live in the `test/property/` directory and run with the standard `flutter test` command.
- All property test blocks must include the tag comment: `// Feature: zouzzle-app, Property N: <property_text>`.

---

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["1.3", "1.4", "2.1"] },
    { "id": 2, "tasks": ["2.2", "2.3", "2.4", "2.5"] },
    { "id": 3, "tasks": ["3.1", "3.2", "3.3", "4.1", "6.1", "7.1", "7.2"] },
    { "id": 4, "tasks": ["4.2", "5.1", "5.2", "6.2", "7.3"] },
    { "id": 5, "tasks": ["8.1", "8.2"] },
    { "id": 6, "tasks": ["8.3"] },
    { "id": 7, "tasks": ["9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7"] },
    { "id": 8, "tasks": ["10.1", "10.2", "10.3"] },
    { "id": 9, "tasks": ["12.1", "12.2", "12.3", "13.1", "13.2", "13.3", "14.1", "14.2"] },
    { "id": 10, "tasks": ["15.1", "15.2", "15.3"] }
  ]
}
```
