// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CMS shows article list', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Navigate to Content.
    await tester.tap(find.text('Content'));
    await tester.pumpAndSettle();

    // Verify article list renders.
    expect(find.text('Articles'), findsOneWidget);
    expect(
      find.text('The Art of the Perfect Schnitzel: A Scientific Approach'),
      findsOneWidget,
    );
  });

  testWidgets('tapping article shows detail with comments', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Content'));
    await tester.pumpAndSettle();

    // Tap on the first article.
    await tester.tap(
      find.text('The Art of the Perfect Schnitzel: A Scientific Approach'),
    );
    await tester.pumpAndSettle();

    // Verify article detail renders (the article content or title is visible).
    expect(find.textContaining('Schnitzel'), findsWidgets);

    // Verify comments section is present by checking for a comment author name.
    expect(find.textContaining('Maximilian'), findsWidgets);
  });

  testWidgets('tapping edit navigates to edit screen', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Content'));
    await tester.pumpAndSettle();

    // Tap on the first article to open detail.
    await tester.tap(
      find.text('The Art of the Perfect Schnitzel: A Scientific Approach'),
    );
    await tester.pumpAndSettle();

    // Tap the edit button (semanticLabel: 'Edit article').
    await tester.tap(find.bySemanticsLabel('Edit article'));
    await tester.pumpAndSettle();

    // Verify the edit screen renders with form fields.
    expect(find.text('Edit Article'), findsOneWidget);
    expect(find.text('Article Details'), findsOneWidget);
  });
}
