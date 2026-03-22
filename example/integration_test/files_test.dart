// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('file explorer renders folder names', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Navigate to Files.
    await tester.tap(find.text('Files'));
    await tester.pumpAndSettle();

    // The file explorer loads folders asynchronously, so allow extra time.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify a folder name is visible.
    expect(find.text('Documents'), findsWidgets);
  });
}
