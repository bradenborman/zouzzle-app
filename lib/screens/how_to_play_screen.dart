import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guess the Player!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.mizzouGold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStep('1', 'A mystery Mizzou basketball player is chosen at random.'),
            _buildStep('2', 'Type a player name and tap Go to submit your guess.'),
            _buildStep('3', 'After each guess, you\'ll see clues:'),
            const SizedBox(height: 12),
            _buildClue(AppTheme.exactGreen, 'Green', 'Exact match'),
            _buildClue(AppTheme.closeYellow, 'Yellow', 'Close (within 2 inches for height)'),
            _buildClue(AppTheme.missGray, 'Gray', 'No match'),
            const SizedBox(height: 16),
            const Text(
              'Columns:',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildColumn('Pos', 'Position — green if same position'),
            _buildColumn('Height', 'Height with ↑/↓ arrow showing direction'),
            _buildColumn('Years', 'Years at Mizzou — green if they overlapped (teammates)'),
            _buildColumn('Stat', 'A random stat (Pts/Reb/Ast/Stl) with ↑/↓ arrow'),
            const SizedBox(height: 16),
            _buildStep('4', 'You have 6 guesses to figure it out.'),
            _buildStep('5', 'Choose a difficulty to control how well-known the mystery player is.'),
            const SizedBox(height: 24),
            const Text(
              'Difficulty Levels:',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildDifficulty('Easy', 'Stars — 10+ ppg or 7+ rpg or 3+ apg', AppTheme.exactGreen),
            _buildDifficulty('Medium', 'Contributors — 6+ ppg or 4+ rpg', AppTheme.closeYellow),
            _buildDifficulty('Hard', 'Deep cuts — 2+ ppg or 1+ rpg', Colors.redAccent),
            _buildDifficulty('Open', 'Anyone who saw the court', Colors.white54),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.mizzouGold,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClue(Color color, String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$label — $description',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$name: ',
              style: const TextStyle(
                color: AppTheme.mizzouGold,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficulty(String label, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            '$label — ',
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
