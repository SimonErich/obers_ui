// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and shows title', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    expect(find.text('obers_ui Showcase'), findsOneWidget);
  });

  testWidgets('app shows subtitle text', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    expect(
      find.text('Explore every widget through interactive mini-applications.'),
      findsOneWidget,
    );
  });
}
