import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_widgetbook/widgetbook.dart';

void main() {
  testWidgets('OiWidgetbook smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OiWidgetbook());
    expect(find.byType(OiWidgetbook), findsOneWidget);
  });
}
