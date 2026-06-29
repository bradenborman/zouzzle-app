import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/feedback_row.dart';
import 'attribute_cell.dart';

/// A horizontal row of [AttributeCell] widgets representing the feedback
/// for a single guess. Displays the guessed player's name above the cells.
class FeedbackRowWidget extends StatelessWidget {
  /// The feedback data for a single guess.
  final FeedbackRow feedbackRow;

  const FeedbackRowWidget({
    super.key,
    required this.feedbackRow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white24,
          ),
        ),
        Text(
          feedbackRow.guessedPlayer.fullName,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: feedbackRow.results
              .map((result) => AttributeCell.fromResult(result: result))
              .toList(),
        ),
      ],
    );
  }
}
