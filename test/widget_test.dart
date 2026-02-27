import 'package:flutter_test/flutter_test.dart';

import 'package:talon/main.dart';

void main() {
  testWidgets('App renders with theme system', (WidgetTester tester) async {
    await tester.pumpWidget(const TalonApp());
    expect(find.text('Talon™'), findsOneWidget);
  });
}
