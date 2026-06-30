import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/player_repository.dart';
import '../logic/comparison_engine.dart';
import '../models/enums.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import 'player_repository_provider.dart';

/// Difficulty levels that filter the player pool.
enum Difficulty { easy, medium, hard, open, recent }

/// Filter players based on difficulty.
/// All modes exclude players who never really played (< 2 ppg AND < 1 rpg).
List<Player> filterByDifficulty(List<Player> players, Difficulty difficulty) {
  final currentYear = DateTime.now().year;
  return players.where((p) {
    switch (difficulty) {
      case Difficulty.easy:
        return p.points >= 10 || p.rebounds >= 7 || p.assists >= 5;
      case Difficulty.medium:
        return p.points >= 6 || p.rebounds >= 4;
      case Difficulty.hard:
      case Difficulty.open:
        return p.points >= 2 || p.rebounds >= 1;
      case Difficulty.recent:
        return (p.endYear >= currentYear - 5) && (p.points >= 2 || p.rebounds >= 1);
    }
  }).toList();
}

class GameNotifier extends StateNotifier<GameState> {
  final Difficulty _difficulty;
  PlayerRepository? _repo;
  List<Player> _eligiblePlayers = [];

  GameNotifier(
    AsyncValue<PlayerRepository> repoAsync,
    Sport sport,
    Difficulty difficulty,
  )   : _difficulty = difficulty,
        super(GameState(
          sport: sport,
          guesses: const [],
          remainingGuesses: 6,
          status: GameStatus.loading,
          mysteryPlayer: null,
        )) {
    _init(repoAsync);
  }

  void _init(AsyncValue<PlayerRepository> repoAsync) {
    repoAsync.when(
      loading: () {},
      error: (_, __) {
        state = state.copyWith(status: GameStatus.error);
      },
      data: (repo) {
        _repo = repo;
        _eligiblePlayers = filterByDifficulty(repo.players, _difficulty);

        if (_eligiblePlayers.isEmpty) {
          state = state.copyWith(
            status: GameStatus.error,
            validationMessage: 'No players found for this difficulty',
          );
          return;
        }

        // Pick a random mystery player
        final random = Random();
        final mystery = _eligiblePlayers[random.nextInt(_eligiblePlayers.length)];

        state = state.copyWith(
          mysteryPlayer: mystery,
          status: GameStatus.active,
        );
      },
    );
  }

  /// Submit a player name as a guess.
  Future<bool> submitGuess(String playerName) async {
    if (state.status != GameStatus.active) return false;
    if (state.remainingGuesses <= 0) return false;

    final repo = _repo;
    if (repo == null) return false;

    final guessedPlayer = repo.findByName(playerName);
    if (guessedPlayer == null) {
      state = state.copyWith(validationMessage: 'Player not found');
      return false;
    }

    final alreadyGuessed =
        state.guesses.any((row) => row.guessedPlayer.fullName == playerName);
    if (alreadyGuessed) {
      state = state.copyWith(validationMessage: 'Already guessed');
      return false;
    }

    final mystery = state.mysteryPlayer!;
    final feedbackRow = evaluateGuess(guessedPlayer, mystery);
    final updatedGuesses = [...state.guesses, feedbackRow];
    final updatedRemaining = state.remainingGuesses - 1;

    final GameStatus newStatus;
    if (guessedPlayer.fullName == mystery.fullName) {
      newStatus = GameStatus.won;
    } else if (updatedRemaining <= 0) {
      newStatus = GameStatus.lost;
    } else {
      newStatus = GameStatus.active;
    }

    state = state.copyWith(
      guesses: updatedGuesses,
      remainingGuesses: updatedRemaining,
      status: newStatus,
      validationMessage: null,
    );

    return true;
  }

  /// Autocomplete suggestions from the full player list (not just eligible).
  List<String> autocompleteFor(String input) {
    if (input.isEmpty) return [];
    return _repo?.namesContaining(input) ?? [];
  }
}

// -----------------------------------------------------------------------------
// Provider — keyed by (Sport, Difficulty) pair
// -----------------------------------------------------------------------------

/// Unique key for the game provider combining sport and difficulty.
class GameKey {
  final Sport sport;
  final Difficulty difficulty;

  const GameKey(this.sport, this.difficulty);

  @override
  bool operator ==(Object other) =>
      other is GameKey && sport == other.sport && difficulty == other.difficulty;

  @override
  int get hashCode => Object.hash(sport, difficulty);
}

final gameProvider =
    StateNotifierProvider.family<GameNotifier, GameState, GameKey>(
  (ref, key) {
    final repoAsync = ref.watch(playerRepositoryProvider(key.sport));
    return GameNotifier(repoAsync, key.sport, key.difficulty);
  },
);
