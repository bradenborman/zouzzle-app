import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/feedback_row.dart';
import 'feedback_row_widget.dart';

/// Displays the full guess history as a vertical grid: a header row of
/// attribute column names followed by one [FeedbackRowWidget] per submitted
/// guess, rendered in submission order.
class FeedbackGrid extends StatelessWidget {
  /// The list of feedback rows to display, in submission order.
  final List<FeedbackRow> feedbackRows;

  const FeedbackGrid({
    super.key,
    required this.feedbackRows,
  });

  @override
  Widget build(BuildContext context) {
    // Derive headers from first row's results (dynamic column count)
    final headers = feedbackRows.isNotEmpty
        ? feedbackRows.first.results.map((r) => r.attributeLabel).toList()
        : <String>[];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (headers.isNotEmpty) _buildHeaderRow(headers),
        if (headers.isNotEmpty) const SizedBox(height: 8),
        ...feedbackRows.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FeedbackRowWidget(feedbackRow: row),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(List<String> headers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: headers
          .map(
            (header) => SizedBox(
              width: 80,
              child: Text(
                header,
                style: const TextStyle(
                  color: AppTheme.mizzouGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
          .toList(),
    );
  }
}
