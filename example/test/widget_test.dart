import 'package:flutter_test/flutter_test.dart';

import 'package:obers_ui_example/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    expect(find.byType(ShowcaseApp), findsOneWidget);
  });
}
