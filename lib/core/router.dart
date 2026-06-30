import 'package:go_router/go_router.dart';
import 'package:zouzzle/models/enums.dart';
import 'package:zouzzle/providers/game_provider.dart';
import 'package:zouzzle/screens/game_screen.dart';
import 'package:zouzzle/screens/home_screen.dart';
import 'package:zouzzle/screens/result_screen.dart';

Difficulty _parseDifficulty(String? value) {
  switch (value) {
    case 'easy':
      return Difficulty.easy;
    case 'medium':
      return Difficulty.medium;
    case 'hard':
      return Difficulty.hard;
    case 'open':
      return Difficulty.open;
    case 'recent':
      return Difficulty.recent;
    default:
      return Difficulty.open;
  }
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game/:sport/:difficulty',
      builder: (ctx, state) {
        final sport = Sport.fromString(state.pathParameters['sport']!);
        final difficulty = _parseDifficulty(state.pathParameters['difficulty']);
        return GameScreen(sport: sport, difficulty: difficulty);
      },
    ),
    GoRoute(
      path: '/result/:sport/:difficulty',
      builder: (ctx, state) {
        final sport = Sport.fromString(state.pathParameters['sport']!);
        final difficulty = _parseDifficulty(state.pathParameters['difficulty']);
        return ResultScreen(sport: sport, difficulty: difficulty);
      },
    ),
  ],
);
