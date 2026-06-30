import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../widgets/disclaimer_text.dart';
import 'how_to_play_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showDifficultyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.missGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Difficulty',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _DifficultyOption(
              label: 'Easy',
              description: '10+ ppg or 7+ rpg or 3+ apg',
              color: AppTheme.exactGreen,
              onTap: () {
                Navigator.pop(ctx);
                context.go('/game/basketball/easy');
              },
            ),
            const SizedBox(height: 12),
            _DifficultyOption(
              label: 'Medium',
              description: '6+ ppg or 4+ rpg',
              color: AppTheme.closeYellow,
              onTap: () {
                Navigator.pop(ctx);
                context.go('/game/basketball/medium');
              },
            ),
            const SizedBox(height: 12),
            _DifficultyOption(
              label: 'Hard',
              description: '2+ ppg or 1+ rpg',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(ctx);
                context.go('/game/basketball/hard');
              },
            ),
            const SizedBox(height: 12),
            _DifficultyOption(
              label: 'Open',
              description: 'All players who saw the court',
              color: Colors.white54,
              onTap: () {
                Navigator.pop(ctx);
                context.go('/game/basketball/open');
              },
            ),
            const SizedBox(height: 12),
            _DifficultyOption(
              label: 'Recent',
              description: 'Last 5 years, 2+ ppg',
              color: Colors.blueAccent,
              onTap: () {
                Navigator.pop(ctx);
                context.go('/game/basketball/recent');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 8),
                const Text(
                  'Guess the player',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SportTile(
                      label: 'Basketball',
                      iconPath: 'assets/images/basketball-icon.png',
                      onTap: () => _showDifficultyPicker(context),
                    ),
                    // TODO: Uncomment when football is ready
                    // const SizedBox(width: 24),
                    // _SportTile(
                    //   label: 'Football',
                    //   iconPath: 'assets/images/football-icon.png',
                    //   enabled: false,
                    //   onTap: () {},
                    // ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                  ),
                  icon: const Icon(Icons.help_outline, color: Colors.white38),
                  tooltip: 'How to Play',
                ),
                const SizedBox(height: 8),
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
    this.enabled = true,
  });

  final String label;
  final String iconPath;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: AppTheme.missGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled ? AppTheme.mizzouGold : Colors.white24,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath, width: 60, height: 60),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: enabled ? AppTheme.white : Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!enabled)
                const Text(
                  'Coming Soon',
                  style: TextStyle(color: Colors.white24, fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              description,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
