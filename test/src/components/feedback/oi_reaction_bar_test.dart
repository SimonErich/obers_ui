// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/feedback/oi_reaction_bar.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders reactions with emoji and count', (tester) async {
    await tester.pumpObers(
      const OiReactionBar(
        reactions: [
          OiReactionData(emoji: '👍', count: 3),
          OiReactionData(emoji: '❤️', count: 7),
        ],
      ),
    );
    expect(find.text('👍'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('❤️'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('tapping a reaction chip calls onReact with correct emoji',
      (tester) async {
    String? reacted;
    await tester.pumpObers(
      OiReactionBar(
        reactions: const [
          OiReactionData(emoji: '😂', count: 5),
        ],
        onReact: (e) => reacted = e,
      ),
    );
    await tester.tap(find.text('😂'));
    await tester.pump();
    expect(reacted, '😂');
  });

  testWidgets('add reaction button is present', (tester) async {
    await tester.pumpObers(
      const OiReactionBar(reactions: []),
    );
    expect(find.text('+ Add'), findsOneWidget);
  });

  testWidgets('selected reaction is rendered', (tester) async {
    await tester.pumpObers(
      const OiReactionBar(
        reactions: [
          OiReactionData(emoji: '🔥', count: 2, selected: true),
        ],
      ),
    );
    expect(find.text('🔥'), findsOneWidget);
  });

  testWidgets('multiple reactions all render', (tester) async {
    await tester.pumpObers(
      const OiReactionBar(
        reactions: [
          OiReactionData(emoji: '👍', count: 1),
          OiReactionData(emoji: '👎', count: 2),
          OiReactionData(emoji: '❤️', count: 3),
        ],
      ),
    );
    expect(find.text('👍'), findsOneWidget);
    expect(find.text('👎'), findsOneWidget);
    expect(find.text('❤️'), findsOneWidget);
  });
}
