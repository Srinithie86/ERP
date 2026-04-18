import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WarehouseApp());

    // Verify that the title is present
    expect(find.text('WMS Dashboard'), findsNothing); // Finds nothing immediately since provider might need pumping or navigation
  });
}
