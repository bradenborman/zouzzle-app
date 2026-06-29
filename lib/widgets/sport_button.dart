import 'package:flutter/material.dart';

/// A themed sport-selection button used on the Home Screen.
///
/// Renders as an [ElevatedButton] styled with the app's gold/black palette
/// (inherited from [AppTheme.elevatedButtonTheme]). Enforces a minimum 48×48
/// touch target for accessibility compliance.
class SportButton extends StatelessWidget {
  const SportButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  /// Display text for the button (e.g., "Basketball", "Football").
  final String label;

  /// Callback invoked when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: Text(label),
    );
  }
}
