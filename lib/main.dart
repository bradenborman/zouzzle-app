import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'core/router.dart';

void main() {
  runApp(const ProviderScope(child: ZouzzleApp()));
}

class ZouzzleApp extends StatelessWidget {
  const ZouzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zouzzle',
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
