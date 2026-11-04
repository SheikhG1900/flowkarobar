// FlowKarobar Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/main.dart';

void main() {
  testWidgets('FlowKarobar app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: FlowpaisaApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('FlowKarobar'), findsWidgets);
  });
}
