import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter/app.dart';

void main() {
  testWidgets('App bootstrap renders login page', (WidgetTester tester) async {
    final app = await AppBootstrap.initialize();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('Sales Admin Dashboard'), findsOneWidget);
  });
}
