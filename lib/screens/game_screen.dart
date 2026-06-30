import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../providers/game_provider.dart';
import '../widgets/feedback_grid.dart';
import '../widgets/guess_counter.dart';
import '../widgets/player_autocomplete_field.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.sport, required this.difficulty});

  final Sport sport;
  final Difficulty difficulty;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _autocompleteKey = GlobalKey<PlayerAutocompleteFieldState>();

  GameKey get _gameKey => GameKey(widget.sport, widget.difficulty);

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider(_gameKey));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/tiger-piece.png', height: 28),
            const SizedBox(width: 8),
            Text(widget.difficulty.name[0].toUpperCase() +
                widget.difficulty.name.substring(1)),
          ],
        ),
      ),
      body: _buildBody(gameState),
    );
  }

  Widget _buildBody(dynamic gameState) {
    if (gameState.status == GameStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gameState.status == GameStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Something went wrong.',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      );
    }

    final bool gameOver =
        gameState.status == GameStatus.won || gameState.status == GameStatus.lost;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (!gameOver) ...[
            GuessCounter(remainingGuesses: gameState.remainingGuesses),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PlayerAutocompleteField(
                    key: _autocompleteKey,
                    onSearch: (query) => ref
                        .read(gameProvider(_gameKey).notifier)
                        .autocompleteFor(query),
                    onSubmit: (_) => _handleSubmit(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text('Go'),
                ),
              ],
            ),
            if (gameState.validationMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  gameState.validationMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white12,
            ),
            const SizedBox(height: 16),
          ],
          if (gameOver) ...[
            const SizedBox(height: 8),
            Text(
              gameState.status == GameStatus.won
                  ? 'You got it!'
                  : 'Better luck next time!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1B82D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Answer: ${gameState.mysteryPlayer?.fullName ?? "Unknown"}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(gameProvider(_gameKey));
              },
              child: const Text('Play Again'),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: SingleChildScrollView(
              child: FeedbackGrid(feedbackRows: gameState.guesses),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final text = _autocompleteKey.currentState?.text ?? '';
    if (text.isEmpty) return;

    final success = await ref
        .read(gameProvider(_gameKey).notifier)
        .submitGuess(text);

    if (success) {
      _autocompleteKey.currentState?.clear();
    }
  }
}
