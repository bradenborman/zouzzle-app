import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../models/enums.dart';
import '../providers/game_provider.dart';

/// Displays the outcome of a completed puzzle — win or loss.
///
/// Watches [gameProvider] for the terminal [GameStatus] and shows:
/// - "You got it!" with guess score on win (Requirement 7.2)
/// - "Better luck tomorrow" on loss (Requirement 7.3)
/// - Mystery player's full name revealed (Requirement 7.2, 7.3)
/// - "New puzzle available tomorrow" message (Requirement 7.4)
/// - "Home" button to navigate back (Requirement 7.6)
///
/// When restored from [CompletionState] on same-day re-open, the same
/// display is reconstructed from persisted data (Requirement 8.2).
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.sport, required this.difficulty});

  final Sport sport;
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider(GameKey(sport, difficulty)));

    // If the game is not in a terminal state (won/lost), the user likely
    // navigated here directly. Redirect back to the game screen.
    if (gameState.status != GameStatus.won &&
        gameState.status != GameStatus.lost) {
      // Use a post-frame callback to avoid navigating during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/game/${sport.name}');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isWin = gameState.status == GameStatus.won;
    final mysteryName = gameState.mysteryPlayer?.fullName ?? 'Unknown';
    final guessCount = gameState.guesses.length;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Outcome message
                Text(
                  isWin ? 'You got it!' : 'Better luck tomorrow',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mizzouGold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Mystery player's full name
                Text(
                  mysteryName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Guess score (win only)
                if (isWin)
                  Text(
                    '$guessCount / 6',
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppTheme.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (isWin) const SizedBox(height: 24),

                // Next puzzle message
                const Text(
                  'New puzzle available tomorrow',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Home button
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
