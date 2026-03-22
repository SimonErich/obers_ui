// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('project kanban board renders columns', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Navigate to Projects.
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    // Kanban tab is selected by default. Verify column titles.
    expect(find.text('Backlog'), findsOneWidget);
    expect(find.text('To Do'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
  });

  testWidgets('switching to Gantt tab renders', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    // Tap the Gantt tab.
    await tester.tap(find.text('Gantt'));
    await tester.pumpAndSettle();

    // Verify Gantt content renders (the tab should be selected).
    // Kanban columns should no longer be visible.
    expect(find.text('Backlog'), findsNothing);
  });

  testWidgets('switching to Calendar tab renders', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    // Tap the Calendar tab.
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    // Verify Kanban columns are no longer visible.
    expect(find.text('Backlog'), findsNothing);
  });

  testWidgets('switching to Timeline tab renders', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    // Tap the Timeline tab.
    await tester.tap(find.text('Timeline'));
    await tester.pumpAndSettle();

    // Verify Kanban columns are no longer visible.
    expect(find.text('Backlog'), findsNothing);
  });
}
