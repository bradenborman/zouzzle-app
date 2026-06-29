import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_theme.dart';
import '../models/enums.dart';
import '../providers/game_provider.dart';
import '../widgets/disclaimer_text.dart';

/// The landing screen of the Zouzzle app.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/images/tiger-piece.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Zouzzle',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mizzouGold,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SportTile(
                      label: 'Basketball',
                      iconPath: 'assets/images/basketball-icon.png',
                      onTap: () => context.go('/game/basketball'),
                    ),
                    const SizedBox(width: 24),
                    _SportTile(
                      label: 'Football',
                      iconPath: 'assets/images/football-icon.png',
                      onTap: () => context.go('/game/football'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () async {
                    // Clear persisted completion state for today
                    final prefs = await SharedPreferences.getInstance();
                    final today = DateTime.now();
                    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                    await prefs.remove('completion_basketball_$dateStr');
                    await prefs.remove('completion_football_$dateStr');

                    // Invalidate providers to force re-init
                    ref.invalidate(gameProvider(Sport.basketball));
                    ref.invalidate(gameProvider(Sport.football));

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Game reset! Play again.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white54, size: 18),
                  label: const Text(
                    'Reset today\'s game',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
                const Spacer(),
                const DisclaimerText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SportTile extends StatelessWidget {
  const _SportTile({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: AppTheme.missGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.mizzouGold, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
