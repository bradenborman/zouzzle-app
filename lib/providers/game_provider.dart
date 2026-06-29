import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/completion_repository.dart';
import '../data/player_repository.dart';
import '../logic/comparison_engine.dart';
import '../logic/daily_seed_service.dart';
import '../models/completion_state.dart';
import '../models/enums.dart';
import '../models/feedback_row.dart';
import '../models/game_state.dart';
import 'completion_repository_provider.dart';
import 'player_repository_provider.dart';

class GameNotifier extends StateNotifier<GameState> {
  final CompletionRepository _completionRepo;
  final Sport _sport;

  /// The loaded repository — set once data is available during [_init].
  /// Used by [submitGuess] and [autocompleteFor].
  PlayerRepository? _repo;

  GameNotifier(
    AsyncValue<PlayerRepository> repoAsync,
    CompletionRepository completionRepo,
    Sport sport,
  )   : _completionRepo = completionRepo,
        _sport = sport,
        super(GameState(
          sport: sport,
          guesses: const [],
          remainingGuesses: 6,
          status: GameStatus.loading,
          mysteryPlayer: null,
        )) {
    _init(repoAsync);
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> _init(AsyncValue<PlayerRepository> repoAsync) async {
    repoAsync.when(
      loading: () {
        // Stay in loading state — Riverpod will rebuild the provider when the
        // FutureProvider resolves and pass the new AsyncValue.
      },
      error: (_, __) {
        state = state.copyWith(status: GameStatus.error);
      },
      data: (repo) async {
        _repo = repo;

        if (repo.players.isEmpty) {
          state = state.copyWith(
            status: GameStatus.error,
            validationMessage: 'No valid players found',
          );
          return;
        }

        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        // Check whether the user already completed today's puzzle.
        final completion =
            await _completionRepo.loadForDate(_sport, todayDate);

        if (completion != null) {
          _restoreFromCompletion(repo, completion);
        } else {
          final mystery =
              selectMysteryPlayer(repo.players, todayDate, _sport);
          state = state.copyWith(
            mysteryPlayer: mystery,
            status: GameStatus.active,
          );
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Restore from persisted CompletionState (Requirement 8.2)
  // ---------------------------------------------------------------------------

  void _restoreFromCompletion(
      PlayerRepository repo, CompletionState completion) {
    final mystery = repo.findByName(completion.mysteryPlayerName);

    if (mystery == null) {
      // Mystery player no longer exists in dataset (data changed).
      // Fall back to a fresh game so the app doesn't get stuck.
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final newMystery =
          selectMysteryPlayer(repo.players, todayDate, _sport);
      state = state.copyWith(
        mysteryPlayer: newMystery,
        status: GameStatus.active,
      );
      return;
    }

    // Reconstruct FeedbackRows from persisted guess names.
    final reconstructedGuesses = <FeedbackRow>[];
    for (final guessName in completion.guesses) {
      final guessedPlayer = repo.findByName(guessName);
      // Skip gracefully if a previously guessed player is no longer in dataset.
      if (guessedPlayer == null) continue;
      reconstructedGuesses.add(evaluateGuess(guessedPlayer, mystery));
    }

    final status =
        completion.outcome == 'win' ? GameStatus.won : GameStatus.lost;
    final remaining =
        (6 - reconstructedGuesses.length).clamp(0, 6);

    state = state.copyWith(
      mysteryPlayer: mystery,
      guesses: reconstructedGuesses,
      remainingGuesses: remaining,
      status: status,
    );
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Submit a player name as a guess.
  ///
  /// Returns `false` when the guess is invalid (not in dataset, duplicate, or
  /// game already over). Returns `true` on a successfully recorded guess.
  ///
  /// Requirements: 4.5, 4.6, 4.7, 4.8, 6.1, 6.4, 6.5, 6.6, 7.1, 8.1
  Future<bool> submitGuess(String playerName) async {
    // Guard: game must be active.
    if (state.status != GameStatus.active) {
      return false;
    }

    // Guard: remaining guesses must be > 0 (Requirement 6.6).
    if (state.remainingGuesses <= 0) {
      return false;
    }

    final repo = _repo;
    if (repo == null) {
      return false;
    }

    // Validate: name must exist in the current sport's dataset (Req 4.5, 4.6).
    final guessedPlayer = repo.findByName(playerName);
    if (guessedPlayer == null) {
      state = state.copyWith(
        validationMessage: 'Player not found in dataset',
      );
      return false;
    }

    // Validate: no duplicate guesses (Req 4.7, 4.8).
    final alreadyGuessed =
        state.guesses.any((row) => row.guessedPlayer.fullName == playerName);
    if (alreadyGuessed) {
      state = state.copyWith(
        validationMessage: 'You already guessed that player',
      );
      return false;
    }

    final mystery = state.mysteryPlayer!;

    // Evaluate the guess and build the FeedbackRow.
    final feedbackRow = evaluateGuess(guessedPlayer, mystery);
    final updatedGuesses = [...state.guesses, feedbackRow];
    final updatedRemaining = state.remainingGuesses - 1;

    // Determine new game status.
    final GameStatus newStatus;
    if (guessedPlayer.fullName == mystery.fullName) {
      newStatus = GameStatus.won; // Requirement 7.1
    } else if (updatedRemaining <= 0) {
      newStatus = GameStatus.lost; // Requirement 6.5
    } else {
      newStatus = GameStatus.active;
    }

    state = state.copyWith(
      guesses: updatedGuesses,
      remainingGuesses: updatedRemaining,
      status: newStatus,
      validationMessage: null,
    );

    // Persist on terminal state (Requirement 8.1).
    if (newStatus == GameStatus.won || newStatus == GameStatus.lost) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final completionState = CompletionState(
        sport: _sport.toJson(),
        date: todayDate.toIso8601String().substring(0, 10),
        outcome: newStatus == GameStatus.won ? 'win' : 'lose',
        mysteryPlayerName: mystery.fullName,
        guesses: updatedGuesses
            .map((row) => row.guessedPlayer.fullName)
            .toList(),
      );
      await _completionRepo.save(completionState);
    }

    return true;
  }

  /// Returns autocomplete suggestions for [input].
  ///
  /// Delegates to [PlayerRepository.namesContaining]; returns an empty list
  /// when [input] is empty (Requirement 4.2).
  List<String> autocompleteFor(String input) {
    if (input.isEmpty) return [];
    return _repo?.namesContaining(input) ?? [];
  }
}

// -----------------------------------------------------------------------------
// Provider
// -----------------------------------------------------------------------------

final gameProvider =
    StateNotifierProvider.family<GameNotifier, GameState, Sport>(
  (ref, sport) {
    // Keep the provider alive so navigating back doesn't reset mid-game state.
    ref.keepAlive();
    final repoAsync = ref.watch(playerRepositoryProvider(sport));
    final completionRepo = ref.watch(completionRepositoryProvider);
    return GameNotifier(repoAsync, completionRepo, sport);
  },
);
