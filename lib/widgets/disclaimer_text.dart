import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// A disclaimer widget displayed on the Home Screen clarifying that Zouzzle
/// has no official affiliation with the University of Missouri.
///
/// Renders white text on the app's black background, providing a 21:1 contrast
/// ratio that exceeds the WCAG AA minimum of 4.5:1 for normal text.
class DisclaimerText extends StatelessWidget {
  const DisclaimerText({super.key});

  static const _disclaimerMessage =
      'Zouzzle is not affiliated with, endorsed by, or sponsored by '
      'the University of Missouri or its athletic programs.';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _disclaimerMessage,
      child: const Text(
        _disclaimerMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
