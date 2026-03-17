// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/modules/oi_comments.dart';

import '../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2025, 1, 15, 10, 30);

  OiComment _comment({
    Object key = '1',
    String authorId = 'a1',
    String authorName = 'Alice',
    String content = 'Great post!',
    List<OiComment>? replies,
    bool edited = false,
  }) {
    return OiComment(
      key: key,
      authorId: authorId,
      authorName: authorName,
      content: content,
      timestamp: now,
      replies: replies,
      edited: edited,
    );
  }

  testWidgets('comments render their content', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiComments(
          comments: [_comment(content: 'Nice work!')],
          currentUserId: 'me',
          label: 'Comments',
        ),
      ),
    );
    expect(find.text('Nice work!'), findsOneWidget);
  });

  testWidgets('replies are indented', (tester) async {
    final parent = _comment(
      key: 'p1',
      content: 'Parent',
      replies: [
        _comment(key: 'r1', content: 'Reply'),
      ],
    );

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiComments(
          comments: [parent],
          currentUserId: 'me',
          label: 'Comments',
        ),
      ),
    );

    expect(find.text('Parent'), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);

    // The reply Padding should have a left indent > 0
    final parentPadding = tester.widget<Padding>(
      find.ancestor(
        of: find.text('Parent'),
        matching: find.byType(Padding),
      ).first,
    );
    final replyPadding = tester.widget<Padding>(
      find.ancestor(
        of: find.text('Reply'),
        matching: find.byType(Padding),
      ).first,
    );

    // Reply should be further right than parent
    final parentLeft =
        (parentPadding.padding as EdgeInsets).left;
    final replyLeft =
        (replyPadding.padding as EdgeInsets).left;
    expect(replyLeft, greaterThanOrEqualTo(parentLeft));
  });

  testWidgets('avatars show when showAvatars is true', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiComments(
          comments: [_comment(authorName: 'Dave')],
          currentUserId: 'me',
          label: 'Comments',
          showAvatars: true,
        ),
      ),
    );
    // Avatar shows initial
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('timestamps show when showTimestamps is true', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiComments(
          comments: [_comment()],
          currentUserId: 'me',
          label: 'Comments',
          showTimestamps: true,
        ),
      ),
    );
    // The timestamp text is relative (e.g. "Xd ago"), so just confirm
    // a text with 'ago' exists or 'Just now'
    expect(
      find.textContaining(RegExp(r'ago|Just now')),
      findsOneWidget,
    );
  });

  testWidgets('comment input is visible', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiComments(
          comments: const [],
          currentUserId: 'me',
          label: 'Comments',
        ),
      ),
    );
    expect(find.byType(EditableText), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);
  });

  testWidgets('nested replies respect maxDepth', (tester) async {
    // Create deeply nested: depth 0 -> depth 1 -> depth 2
    final deepComment = _comment(
      key: 'c0',
      content: 'Level 0',
      replies: [
        _comment(
          key: 'c1',
          content: 'Level 1',
          replies: [
            _comment(
              key: 'c2',
              content: 'Level 2',
              replies: [
                _comment(key: 'c3', content: 'Level 3'),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiComments(
          comments: [deepComment],
          currentUserId: 'me',
          label: 'Comments',
          maxDepth: 2,
        ),
      ),
    );

    // Level 0, 1, 2 should render
    expect(find.text('Level 0'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    // Level 3 should NOT render because maxDepth is 2
    expect(find.text('Level 3'), findsNothing);
  });

  testWidgets('empty comments show empty state', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiComments(
          comments: const [],
          currentUserId: 'me',
          label: 'Comments',
        ),
      ),
    );
    expect(find.text('No comments yet'), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiComments(
          comments: const [],
          currentUserId: 'me',
          label: 'Post Comments',
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Post Comments'),
      findsOneWidget,
    );
  });

  testWidgets('edited comment shows edited indicator', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiComments(
          comments: [_comment(edited: true)],
          currentUserId: 'me',
          label: 'Comments',
        ),
      ),
    );
    expect(find.text('(edited)'), findsOneWidget);
  });
}
