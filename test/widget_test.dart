import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zouzzle/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZouzzleApp()));
    await tester.pumpAndSettle();

    // Verify that the HomeScreen title renders.
    expect(find.text('Zouzzle'), findsOneWidget);
  });
}
