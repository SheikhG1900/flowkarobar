// FlowPaisa Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/main.dart';

void main() {
  testWidgets('FlowPaisa app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: FlowPaisaApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('FlowPaisa'), findsWidgets);
  });
}
