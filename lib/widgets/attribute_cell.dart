import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/enums.dart';
import '../models/feedback_row.dart';

/// A single colored square cell representing the comparison result
/// for one attribute, with an optional directional arrow and a label below.
class AttributeCell extends StatelessWidget {
  /// The match state determines the cell's background color.
  final MatchState state;

  /// Optional arrow direction shown inside the cell when [state] is [MatchState.close].
  final ArrowDirection? arrow;

  /// The label displayed below the cell (e.g., "Position", "Jersey #").
  final String attributeLabel;

  /// Optional display value to show inside the cell.
  final String? displayValue;

  const AttributeCell({
    super.key,
    required this.state,
    required this.attributeLabel,
    this.arrow,
    this.displayValue,
  });

  /// Convenience constructor that extracts fields from an [AttributeResult].
  factory AttributeCell.fromResult({
    Key? key,
    required AttributeResult result,
  }) {
    return AttributeCell(
      key: key,
      state: result.state,
      arrow: result.arrow,
      attributeLabel: result.attributeLabel,
      displayValue: result.displayValue,
    );
  }

  Color _backgroundColor() {
    switch (state) {
      case MatchState.exact:
        return AppTheme.exactGreen;
      case MatchState.close:
        return AppTheme.closeYellow;
      case MatchState.miss:
        return AppTheme.missGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 52,
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final children = <Widget>[];

    // Show display value if available
    if (displayValue != null) {
      children.add(Text(
        displayValue!,
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ));
    }

    // Show arrow for non-exact jersey
    if (arrow != null) {
      children.add(Icon(
        arrow == ArrowDirection.up ? Icons.arrow_upward : Icons.arrow_downward,
        color: AppTheme.white,
        size: 16,
      ));
    }

    if (children.isEmpty) return const SizedBox.shrink();
    if (children.length == 1) return children.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

}
