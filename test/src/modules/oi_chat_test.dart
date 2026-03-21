// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';

import '../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2025, 1, 15, 10, 30);

  OiChatMessage msg({
    String key = '1',
    String senderId = 'user-a',
    String senderName = 'Alice',
    String content = 'Hello!',
    bool pending = false,
    DateTime? timestamp,
  }) {
    return OiChatMessage(
      key: key,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: timestamp ?? now,
      pending: pending,
    );
  }

  testWidgets('messages render their content', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [msg(content: 'Hello world')],
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
          messages: [msg(senderId: 'me')],
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
          messages: [msg(senderId: 'other')],
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
          messages: [msg(senderId: 'other', senderName: 'Bob')],
          currentUserId: 'me',
          label: 'Chat',
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
          messages: [msg()],
          currentUserId: 'user-b',
          label: 'Chat',
        ),
      ),
    );
    expect(find.text('10:30'), findsOneWidget);
  });

  testWidgets('typing indicator shows when typingUsers is not empty', (
    tester,
  ) async {
    await tester.pumpObers(
      const SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [],
          currentUserId: 'me',
          label: 'Chat',
          typingUsers: ['Alice'],
        ),
      ),
    );
    expect(find.text('Alice is typing...'), findsOneWidget);
  });

  testWidgets('typing indicator for multiple users', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [],
          currentUserId: 'me',
          label: 'Chat',
          typingUsers: ['Alice', 'Bob'],
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
          messages: [msg()],
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
          messages: [msg(senderId: 'me', pending: true)],
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
      const SizedBox(
        width: 400,
        height: 600,
        child: OiChat(messages: [], currentUserId: 'me', label: 'Chat'),
      ),
    );
    expect(find.text('No messages yet'), findsOneWidget);
  });

  testWidgets('compose bar is hidden when messages list is empty', (
    tester,
  ) async {
    await tester.pumpObers(
      const SizedBox(
        width: 400,
        height: 600,
        child: OiChat(messages: [], currentUserId: 'me', label: 'Chat'),
      ),
    );
    expect(find.bySemanticsLabel('Send message'), findsNothing);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('compose bar is visible when messages exist', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiChat(
          messages: [msg()],
          currentUserId: 'user-b',
          label: 'Chat',
        ),
      ),
    );
    expect(find.bySemanticsLabel('Send message'), findsOneWidget);
    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 400,
        height: 600,
        child: OiChat(messages: [], currentUserId: 'me', label: 'Team Chat'),
      ),
    );
    expect(find.bySemanticsLabel('Team Chat'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Consecutive message grouping
  // -------------------------------------------------------------------------

  group('consecutive message grouping', () {
    testWidgets(
      'consecutive messages from same sender within threshold are grouped',
      (tester) async {
        final messages = [
          msg(
            senderId: 'bob',
            senderName: 'Bob',
            content: 'First message',
            timestamp: now,
          ),
          msg(
            key: '2',
            senderId: 'bob',
            senderName: 'Bob',
            content: 'Second message',
            timestamp: now.add(const Duration(seconds: 30)),
          ),
        ];

        await tester.pumpObers(
          SizedBox(
            width: 400,
            height: 600,
            child: OiChat(
              messages: messages,
              currentUserId: 'me',
              label: 'Chat',
            ),
          ),
        );

        // Both messages render their content.
        expect(find.text('First message'), findsOneWidget);
        expect(find.text('Second message'), findsOneWidget);

        // Only the first message shows the sender name; the continuation
        // message does not repeat it.
        expect(find.text('Bob'), findsOneWidget);

        // Only one avatar initial (first message in group).
        expect(find.text('B'), findsOneWidget);
      },
    );

    testWidgets('first message in group shows avatar and sender name', (
      tester,
    ) async {
      final messages = [
        msg(
          senderId: 'bob',
          senderName: 'Bob',
          content: 'Hello',
          timestamp: now,
        ),
      ];

      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiChat(messages: messages, currentUserId: 'me', label: 'Chat'),
        ),
      );

      // Avatar initial and sender name are both visible.
      expect(find.text('B'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets(
      'continuation messages show reduced spacing (no avatar, no name)',
      (tester) async {
        final messages = [
          msg(
            senderId: 'bob',
            senderName: 'Bob',
            content: 'First',
            timestamp: now,
          ),
          msg(
            key: '2',
            senderId: 'bob',
            senderName: 'Bob',
            content: 'Second',
            timestamp: now.add(const Duration(seconds: 30)),
          ),
          msg(
            key: '3',
            senderId: 'bob',
            senderName: 'Bob',
            content: 'Third',
            timestamp: now.add(const Duration(minutes: 1)),
          ),
        ];

        await tester.pumpObers(
          SizedBox(
            width: 400,
            height: 600,
            child: OiChat(
              messages: messages,
              currentUserId: 'me',
              label: 'Chat',
            ),
          ),
        );

        // All three messages render.
        expect(find.text('First'), findsOneWidget);
        expect(find.text('Second'), findsOneWidget);
        expect(find.text('Third'), findsOneWidget);

        // Sender name appears only once (first message).
        expect(find.text('Bob'), findsOneWidget);

        // Avatar initial appears only once (first message).
        expect(find.text('B'), findsOneWidget);
      },
    );

    testWidgets('messages beyond consecutiveThreshold are not grouped', (
      tester,
    ) async {
      final messages = [
        msg(
          senderId: 'bob',
          senderName: 'Bob',
          content: 'Before',
          timestamp: now,
        ),
        msg(
          key: '2',
          senderId: 'bob',
          senderName: 'Bob',
          content: 'After',
          timestamp: now.add(const Duration(minutes: 5)),
        ),
      ];

      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiChat(messages: messages, currentUserId: 'me', label: 'Chat'),
        ),
      );

      // Both messages show sender name because the gap exceeds the
      // threshold — they are not grouped.
      expect(find.text('Bob'), findsNWidgets(2));
      // Both show avatar initial.
      expect(find.text('B'), findsNWidgets(2));
    });

    testWidgets('different senders are never grouped', (tester) async {
      final messages = [
        msg(senderId: 'bob', senderName: 'Bob', content: 'Hi', timestamp: now),
        msg(
          key: '2',
          senderId: 'carol',
          senderName: 'Carol',
          content: 'Hey',
          timestamp: now.add(const Duration(seconds: 10)),
        ),
      ];

      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiChat(messages: messages, currentUserId: 'me', label: 'Chat'),
        ),
      );

      // Both sender names appear.
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
      // Both avatars appear.
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('groupConsecutive=false disables grouping', (tester) async {
      final messages = [
        msg(senderId: 'bob', senderName: 'Bob', content: 'One', timestamp: now),
        msg(
          key: '2',
          senderId: 'bob',
          senderName: 'Bob',
          content: 'Two',
          timestamp: now.add(const Duration(seconds: 10)),
        ),
      ];

      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiChat(
            messages: messages,
            currentUserId: 'me',
            label: 'Chat',
            groupConsecutive: false,
          ),
        ),
      );

      // With grouping disabled both messages show name and avatar.
      expect(find.text('Bob'), findsNWidgets(2));
      expect(find.text('B'), findsNWidgets(2));
    });
  });

  // -------------------------------------------------------------------------
  // onLoadOlder via scroll
  // -------------------------------------------------------------------------

  group('onLoadOlder via scroll', () {
    testWidgets('onLoadOlder fires when scrolling to top', (tester) async {
      var called = false;
      final messages = List.generate(
        30,
        (i) => msg(
          key: 'msg-$i',
          content: 'Message $i',
          timestamp: now.add(Duration(minutes: i)),
        ),
      );

      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiChat(
            messages: messages,
            currentUserId: 'user-b',
            label: 'Chat',
            olderMessagesAvailable: true,
            onLoadOlder: () async {
              called = true;
            },
          ),
        ),
      );

      // The list is reversed, so scrolling "up" means dragging down visually
      // but increasing scroll offset toward maxScrollExtent (older messages).
      // Fling toward older messages (upward visually = toward maxScrollExtent
      // in a reversed list).
      await tester.fling(find.byType(ListView), const Offset(0, 600), 1000);
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets(
      'onLoadOlder does not fire when olderMessagesAvailable is false',
      (tester) async {
        var called = false;
        final messages = List.generate(
          30,
          (i) => msg(
            key: 'msg-$i',
            content: 'Message $i',
            timestamp: now.add(Duration(minutes: i)),
          ),
        );

        await tester.pumpObers(
          SizedBox(
            width: 400,
            height: 600,
            child: OiChat(
              messages: messages,
              currentUserId: 'user-b',
              label: 'Chat',
              onLoadOlder: () async {
                called = true;
              },
            ),
          ),
        );

        await tester.fling(find.byType(ListView), const Offset(0, 600), 1000);
        await tester.pumpAndSettle();

        expect(called, isFalse);
      },
    );

    testWidgets('manual Load older messages button is removed', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiChat(
            messages: [msg()],
            currentUserId: 'user-b',
            label: 'Chat',
            olderMessagesAvailable: true,
            onLoadOlder: () async {},
          ),
        ),
      );

      expect(find.text('Load older messages'), findsNothing);
    });
  });
}
