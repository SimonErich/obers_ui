// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('chat shows channel list', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Navigate to Chat.
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // Verify channel list is visible.
    expect(find.text('#general'), findsOneWidget);
    expect(find.text('Channels'), findsOneWidget);
  });

  testWidgets('tapping a channel loads messages', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // The #general channel is selected by default. Verify messages are loaded.
    // The first message in #general is from Anna about Kaffeepause.
    expect(find.textContaining('Kaffeepause'), findsOneWidget);
  });

  testWidgets('switching channels loads different messages', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // Tap on #food-reviews channel.
    await tester.tap(find.text('#food-reviews'));
    await tester.pumpAndSettle();

    // Verify food-reviews messages are loaded.
    expect(find.textContaining('Tafelspitz'), findsOneWidget);
  });

  testWidgets('can enter and send a message', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // Find the EditableText input for typing a message.
    final editableTextFinder = find.byType(EditableText).last;
    await tester.tap(editableTextFinder);
    await tester.pumpAndSettle();

    // Enter a message.
    await tester.enterText(editableTextFinder, 'Hello from integration test');
    await tester.pumpAndSettle();

    // Tap the send button.
    await tester.tap(find.bySemanticsLabel('Send message'));
    await tester.pumpAndSettle();

    // Verify the sent message appears in the chat.
    expect(find.text('Hello from integration test'), findsOneWidget);

    // Wait for the typing indicator to appear (1.5s delay in ChatAutoResponder).
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    // Verify typing indicator is visible ("X is typing...").
    expect(find.textContaining('is typing'), findsOneWidget);

    // Wait for the auto-response to arrive (2s more in ChatAutoResponder).
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    // Verify an auto-response from kGeneralResponses appeared.
    // The message "Hello from integration test" has no food/work keywords,
    // so it picks from the general response pool.
    expect(find.textContaining('Kaffeepause'), findsWidgets);
  });
}
