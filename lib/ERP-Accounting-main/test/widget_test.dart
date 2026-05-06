import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accountings/main.dart';

void main() {
  testWidgets('shows home screen UI directly on launch', (WidgetTester tester) async {
    // Build the app — home screen (MainShell) appears immediately
    await tester.pumpWidget(const MyApp());

    // Give the first frame time to render
    await tester.pump();

    // ── Verify home screen UI elements are present ──────────────────────────
    expect(find.text('Accounting'), findsWidgets); // Title on Dashboard
    // Splash screen elements should NOT be found
    expect(find.text('Preparing your workspace'), findsNothing);
  });
}
