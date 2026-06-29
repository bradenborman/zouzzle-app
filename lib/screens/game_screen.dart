import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../providers/game_provider.dart';
import '../widgets/feedback_grid.dart';
import '../widgets/guess_counter.dart';
import '../widgets/player_autocomplete_field.dart';

/// The main gameplay screen where users submit guesses and receive feedback.
///
/// Watches [gameProvider] for the current [GameState] and renders the
/// appropriate UI based on status (loading, error, active, won, lost).
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.sport});

  final Sport sport;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _autocompleteKey = GlobalKey<PlayerAutocompleteFieldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider(widget.sport));

    // Listen for terminal status transitions to navigate to the result screen.
    ref.listen(gameProvider(widget.sport), (previous, next) {
      if (next.status == GameStatus.won || next.status == GameStatus.lost) {
        if (previous?.status == GameStatus.active) {
          // Brief delay so user sees their final guess feedback
          Future.delayed(const Duration(milliseconds: 800), () {
            if (context.mounted) {
              context.go('/result/${widget.sport.name}');
            }
          });
        }
      }
    });

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
            Text(widget.sport.name[0].toUpperCase() +
                widget.sport.name.substring(1)),
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
              'Something went wrong loading the game.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
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

    return SingleChildScrollView(
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
                        .read(gameProvider(widget.sport).notifier)
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
                  : 'Better luck tomorrow!',
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
            const SizedBox(height: 16),
          ],
          FeedbackGrid(feedbackRows: gameState.guesses),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final text = _autocompleteKey.currentState?.text ?? '';
    if (text.isEmpty) return;

    final success = await ref
        .read(gameProvider(widget.sport).notifier)
        .submitGuess(text);

    if (success) {
      _autocompleteKey.currentState?.clear();
    }
  }
}
