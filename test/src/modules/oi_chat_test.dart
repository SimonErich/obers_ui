// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';

import '../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2025, 1, 15, 10, 30);

  OiChatMessage _msg({
    String key = '1',
    String senderId = 'user-a',
    String senderName = 'Alice',
    String content = 'Hello!',
    bool pending = false,
  }) {
    return OiChatMessage(
      key: key,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: now,
      pending: pending,
    );
  }

  testWidgets('messages render their content', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [_msg(content: 'Hello world')],
          currentUserId: 'user-b',
          label: 'Chat',
        ),
      ),
    );
    expect(find.text('Hello world'), findsOneWidget);
  });

  testWidgets('own messages align to the right', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [_msg(senderId: 'me')],
          currentUserId: 'me',
          label: 'Chat',
        ),
      ),
    );

    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.mainAxisAlignment, MainAxisAlignment.end);
  });

  testWidgets('other messages align to the left', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [_msg(senderId: 'other')],
          currentUserId: 'me',
          label: 'Chat',
        ),
      ),
    );

    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.mainAxisAlignment, MainAxisAlignment.start);
  });

  testWidgets('avatars show for other users when showAvatars is true', (
    tester,
  ) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [_msg(senderId: 'other', senderName: 'Bob')],
          currentUserId: 'me',
          label: 'Chat',
          showAvatars: true,
        ),
      ),
    );
    // Avatar shows initial letter
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('timestamps show when showTimestamps is true', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [_msg()],
          currentUserId: 'user-b',
          label: 'Chat',
          showTimestamps: true,
        ),
      ),
    );
    expect(find.text('10:30'), findsOneWidget);
  });

  testWidgets('typing indicator shows when typingUsers is not empty', (
    tester,
  ) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: const [],
          currentUserId: 'me',
          label: 'Chat',
          typingUsers: const ['Alice'],
        ),
      ),
    );
    expect(find.text('Alice is typing...'), findsOneWidget);
  });

  testWidgets('typing indicator for multiple users', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: const [],
          currentUserId: 'me',
          label: 'Chat',
          typingUsers: const ['Alice', 'Bob'],
        ),
      ),
    );
    expect(find.text('Alice and Bob are typing...'), findsOneWidget);
  });

  testWidgets('send button fires onSend', (tester) async {
    String? sent;
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: const [],
          currentUserId: 'me',
          label: 'Chat',
          onSend: (text) => sent = text,
        ),
      ),
    );

    // Type text into the input
    await tester.enterText(find.byType(EditableText), 'Test message');
    await tester.pump();

    // Tap send
    await tester.tap(find.bySemanticsLabel('Send message'));
    await tester.pump();

    expect(sent, 'Test message');
  });

  testWidgets('pending message renders with reduced opacity', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [_msg(senderId: 'me', pending: true)],
          currentUserId: 'me',
          label: 'Chat',
        ),
      ),
    );

    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, 0.5);
  });

  testWidgets('empty chat shows empty message', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(messages: const [], currentUserId: 'me', label: 'Chat'),
      ),
    );
    expect(find.text('No messages yet'), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: const [],
          currentUserId: 'me',
          label: 'Team Chat',
        ),
      ),
    );
    expect(find.bySemanticsLabel('Team Chat'), findsOneWidget);
  });
}
