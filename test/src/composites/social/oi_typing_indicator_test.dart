// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/social/oi_typing_indicator.dart';

import '../../../helpers/pump_app.dart';

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('one user shows "Alice is typing"', (tester) async {
    await tester.pumpObers(
      const Center(child: OiTypingIndicator(typingUsers: ['Alice'])),
    );

    expect(find.text('Alice is typing'), findsOneWidget);
  });

  testWidgets('two users shows "Alice and Bob are typing"', (tester) async {
    await tester.pumpObers(
      const Center(child: OiTypingIndicator(typingUsers: ['Alice', 'Bob'])),
    );

    expect(find.text('Alice and Bob are typing'), findsOneWidget);
  });

  testWidgets('three or more users shows "N people are typing"', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: OiTypingIndicator(typingUsers: ['Alice', 'Bob', 'Charlie']),
      ),
    );

    expect(find.text('3 people are typing'), findsOneWidget);
  });

  testWidgets('empty list renders nothing', (tester) async {
    await tester.pumpObers(
      const Center(child: OiTypingIndicator(typingUsers: [])),
    );

    // SizedBox.shrink is rendered.
    expect(find.text('is typing'), findsNothing);
    expect(find.textContaining('typing'), findsNothing);
  });

  testWidgets('animated dots are present', (tester) async {
    await tester.pumpObers(
      const Center(child: OiTypingIndicator(typingUsers: ['Alice'])),
    );

    // The dots are rendered as three '.' Text widgets.
    expect(find.text('.'), findsNWidgets(3));
  });

  testWidgets('animation controller is active', (tester) async {
    await tester.pumpObers(
      const Center(child: OiTypingIndicator(typingUsers: ['Alice'])),
    );

    // Pump a frame to advance animation — no errors.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Alice is typing'), findsOneWidget);

    // Pump another frame — the dots still render.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('.'), findsNWidgets(3));
  });
}
