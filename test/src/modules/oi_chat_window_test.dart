// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_markdown.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/modules/oi_chat_window.dart';

import '../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2025, 6, 15, 14, 30);

  OiChatWindowMessage msg({
    String id = '1',
    String role = 'assistant',
    String content = 'Hello!',
    bool error = false,
    DateTime? timestamp,
    List<OiChatSuggestion>? suggestions,
    List<String>? selectedSuggestionIds,
  }) {
    return OiChatWindowMessage(
      id: id,
      role: role,
      content: content,
      timestamp: timestamp ?? now,
      error: error,
      suggestions: suggestions,
      selectedSuggestionIds: selectedSuggestionIds,
    );
  }

  testWidgets('renders message content', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(
          messages: [msg(content: 'Hello world')],
          label: 'Chat',
        ),
      ),
    );
    // OiMarkdown renders the text.
    expect(find.text('Hello world'), findsOneWidget);
  });

  testWidgets('user messages render with right alignment', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(
          messages: [msg(role: 'user', content: 'My message')],
          label: 'Chat',
        ),
      ),
    );

    final align = tester.widget<Align>(
      find.ancestor(of: find.byType(OiMarkdown), matching: find.byType(Align)),
    );
    expect(align.alignment, Alignment.centerRight);
  });

  testWidgets('assistant messages render with left alignment', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(
          messages: [msg(content: 'Bot reply')],
          label: 'Chat',
        ),
      ),
    );

    final align = tester.widget<Align>(
      find.ancestor(of: find.byType(OiMarkdown), matching: find.byType(Align)),
    );
    expect(align.alignment, Alignment.centerLeft);
  });

  testWidgets('input field renders with placeholder', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(
          messages: [msg()],
          label: 'Chat',
          inputPlaceholder: 'Ask me anything...',
        ),
      ),
    );

    expect(find.byType(OiTextInput), findsOneWidget);
    expect(find.text('Ask me anything...'), findsOneWidget);
  });

  testWidgets('error message has error styling', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(
          messages: [msg(error: true, content: 'Something went wrong')],
          label: 'Chat',
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);

    // Find the decorated container wrapping the error message.
    final container = tester.widget<Container>(
      find
          .ancestor(
            of: find.byType(OiMarkdown),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
  });

  testWidgets('streaming content renders when streaming', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(
          messages: [],
          label: 'Chat',
          streaming: true,
          streamingContent: 'Streaming text here',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Streaming text here'), findsOneWidget);
    // The blinking cursor character should be present.
    expect(find.text('\u258C'), findsOneWidget);
  });

  testWidgets('provider selector renders when provided', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(
          messages: [],
          label: 'Chat',
          providerSelector: Text('GPT-4'),
        ),
      ),
    );

    expect(find.text('GPT-4'), findsOneWidget);
  });

  testWidgets('input actions render when provided', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(
          messages: [],
          label: 'Chat',
          inputActions: [Icon(IconData(0xe042), size: 20)],
        ),
      ),
    );

    expect(find.byType(Icon), findsWidgets);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(messages: [], label: 'AI Assistant'),
      ),
    );

    expect(find.bySemanticsLabel('AI Assistant'), findsOneWidget);
  });

  testWidgets('renders without error with empty messages', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(messages: [], label: 'Chat'),
      ),
    );

    // Should render the input area even with no messages.
    expect(find.byType(OiTextInput), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('suggestion chips render for assistant messages', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 700,
        child: OiChatWindow(
          messages: [
            msg(
              suggestions: const [
                OiChatSuggestion(id: 's1', text: 'Option A'),
                OiChatSuggestion(id: 's2', text: 'Option B'),
              ],
            ),
          ],
          label: 'Chat',
        ),
      ),
    );

    expect(find.text('Option A'), findsOneWidget);
    expect(find.text('Option B'), findsOneWidget);
    expect(find.byType(OiBadge), findsNWidgets(2));
  });
}
