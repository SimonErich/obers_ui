// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/composites/social/oi_avatar_stack.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _users = [
  OiAvatarStackItem(label: 'Alice', initials: 'AL'),
  OiAvatarStackItem(label: 'Bob', initials: 'BO'),
  OiAvatarStackItem(label: 'Charlie', initials: 'CH'),
  OiAvatarStackItem(label: 'Diana', initials: 'DI'),
  OiAvatarStackItem(label: 'Eve', initials: 'EV'),
  OiAvatarStackItem(label: 'Frank', initials: 'FR'),
];

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('avatars overlap via positioned left offsets', (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiAvatarStack(users: _users, maxVisible: 3),
      ),
    );

    final positioned = tester
        .widgetList<Positioned>(find.byType(Positioned))
        .where((p) => p.left != null)
        .toList();
    final lefts = positioned.map((p) => p.left!).toList();

    // At least 2 positioned items with increasing left values (overlap means
    // the step is less than the full avatar diameter).
    expect(lefts.length, greaterThanOrEqualTo(2));
    for (var i = 1; i < lefts.length; i++) {
      expect(lefts[i], greaterThan(lefts[i - 1]));
    }
  });

  testWidgets('maxVisible caps the number of displayed avatars',
      (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiAvatarStack(users: _users, maxVisible: 2),
      ),
    );

    // Only 2 OiAvatar widgets should be rendered (not 6).
    expect(find.byType(OiAvatar), findsNWidgets(2));
  });

  testWidgets('overflow indicator shows +N when users exceed maxVisible',
      (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiAvatarStack(users: _users),
      ),
    );

    // 6 users - 4 visible (default maxVisible) = +2.
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('no overflow indicator when users fit within maxVisible',
      (tester) async {
    const twoUsers = [
      OiAvatarStackItem(label: 'Alice', initials: 'AL'),
      OiAvatarStackItem(label: 'Bob', initials: 'BO'),
    ];
    await tester.pumpObers(
      const Center(
        child: OiAvatarStack(users: twoUsers),
      ),
    );

    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('tooltip wraps each avatar with the user name', (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiAvatarStack(
          users: [OiAvatarStackItem(label: 'Alice', initials: 'AL')],
        ),
      ),
    );

    // Each avatar is wrapped in an OiTooltip whose message is the user label.
    final tooltip = tester.widget<OiTooltip>(find.byType(OiTooltip).first);
    expect(tooltip.message, 'Alice');
  });

  testWidgets('onTap fires with the correct user', (tester) async {
    OiAvatarStackItem? tappedUser;

    await tester.pumpObers(
      Center(
        child: OiAvatarStack(
          users: const [
            OiAvatarStackItem(label: 'Alice', initials: 'AL'),
          ],
          onTap: (user) => tappedUser = user,
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();

    expect(tappedUser?.label, 'Alice');
  });

  testWidgets('empty user list renders nothing', (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiAvatarStack(users: []),
      ),
    );

    expect(find.byType(OiAvatar), findsNothing);
  });
}
