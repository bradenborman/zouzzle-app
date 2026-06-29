import 'package:go_router/go_router.dart';
import 'package:zouzzle/models/enums.dart';
import 'package:zouzzle/screens/game_screen.dart';
import 'package:zouzzle/screens/home_screen.dart';
import 'package:zouzzle/screens/result_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game/:sport',
      builder: (ctx, state) {
        final sport = Sport.fromString(state.pathParameters['sport']!);
        return GameScreen(sport: sport);
      },
    ),
    GoRoute(
      path: '/result/:sport',
      builder: (ctx, state) {
        final sport = Sport.fromString(state.pathParameters['sport']!);
        return ResultScreen(sport: sport);
      },
    ),
  ],
);
