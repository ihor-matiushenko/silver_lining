import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_lining_app/main.dart';

void main() {
  testWidgets('Silver Lining App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SilverLiningApp());

    // Verify that the localized app title is present.
    expect(find.text('Silver Lining'), findsOneWidget);

    // Verify that the language selector icon button is present.
    expect(find.byIcon(Icons.language), findsOneWidget);
  });
}
