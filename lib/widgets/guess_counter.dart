import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class GuessCounter extends StatelessWidget {
  final int remainingGuesses;

  const GuessCounter({super.key, required this.remainingGuesses});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Guesses remaining: $remainingGuesses',
      style: const TextStyle(color: AppTheme.white),
    );
  }
}
