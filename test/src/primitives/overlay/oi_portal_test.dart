// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/overlay/oi_portal.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. active=false renders nothing in overlay ────────────────────────────

  testWidgets('active=false: child is not visible', (tester) async {
    await tester.pumpObers(const OiPortal(child: Text('portal content')));
    await tester.pump();
    expect(find.text('portal content'), findsNothing);
  });

  // ── 2. active=true renders child in overlay ───────────────────────────────

  testWidgets('active=true: child is rendered in the overlay', (tester) async {
    await tester.pumpObers(
      const OiPortal(active: true, child: Text('portal content')),
    );
    // Post-frame callback defers the insert; pump twice to flush it.
    await tester.pump();
    await tester.pump();
    expect(find.text('portal content'), findsOneWidget);
  });

  // ── 3. toggling active inserts and removes the overlay entry ─────────────

  testWidgets('toggling active shows and hides child', (tester) async {
    final notifier = ValueNotifier<bool>(false);
    addTearDown(notifier.dispose);

    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (context, isActive, _) =>
            OiPortal(active: isActive, child: const Text('portal content')),
      ),
    );
    await tester.pump();

    // Initially not active.
    expect(find.text('portal content'), findsNothing);

    // Activate via notifier (bypasses hit-test issues).
    notifier.value = true;
    await tester.pump();
    await tester.pump();
    expect(find.text('portal content'), findsOneWidget);

    // Deactivate — the scheduled remove needs a post-frame callback to fire.
    notifier.value = false;
    await tester.pump();
    await tester.pump();
    expect(find.text('portal content'), findsNothing);
  });

  // ── 4. OiPortal itself contributes no visible widget in-tree ─────────────

  testWidgets('OiPortal in-tree widget is a SizedBox.shrink', (tester) async {
    await tester.pumpObers(const OiPortal(child: Text('portal content')));
    await tester.pump();
    // The in-tree representation is a zero-size box (SizedBox.shrink()).
    final box = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(OiPortal),
        matching: find.byType(SizedBox),
      ),
    );
    expect(box.width, 0.0);
    expect(box.height, 0.0);
  });

  // ── 5. child update while active marks entry as needing rebuild ───────────

  testWidgets('updating child while active rebuilds the overlay entry', (
    tester,
  ) async {
    final notifier = ValueNotifier<String>('first');
    addTearDown(notifier.dispose);

    await tester.pumpObers(
      ValueListenableBuilder<String>(
        valueListenable: notifier,
        builder: (context, label, _) =>
            OiPortal(active: true, child: Text(label)),
      ),
    );
    // Flush post-frame insert.
    await tester.pump();
    await tester.pump();
    expect(find.text('first'), findsOneWidget);

    notifier.value = 'second';
    // Three pumps: first to trigger didUpdateWidget, second for the
    // post-frame markNeedsBuild, third to rebuild the overlay entry.
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('second'), findsOneWidget);
  });
}
