// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/interaction/oi_focus_trap.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(const OiFocusTrap(child: Text('inside trap')));
    expect(find.text('inside trap'), findsOneWidget);
  });

  // ── 2. initialFocus=true: first focusable element gets focus ───────────────

  testWidgets('initialFocus=true: first focusable element gets focus', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpObers(
      OiFocusTrap(
        child: Focus(
          focusNode: focusNode,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    );
    // Allow the post-frame callback to execute.
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
  });

  // ── 3. initialFocus=false: no auto-focus ───────────────────────────────────

  testWidgets('initialFocus=false: no element receives focus automatically', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpObers(
      OiFocusTrap(
        initialFocus: false,
        child: Focus(
          focusNode: focusNode,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    );
    await tester.pump();

    expect(focusNode.hasPrimaryFocus, isFalse);
  });

  // ── 4. onEscape called on Escape key press ────────────────────────────────

  testWidgets('onEscape called on Escape key press', (tester) async {
    var escaped = false;
    final innerNode = FocusNode();
    addTearDown(innerNode.dispose);

    await tester.pumpObers(
      OiFocusTrap(
        onEscape: () => escaped = true,
        child: Focus(
          focusNode: innerNode,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    );
    // Focus something inside the scope so key events flow through it.
    innerNode.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(escaped, isTrue);
  });

  // ── 5. restoreFocus=true: previous focus restored after dispose ────────────

  testWidgets(
    'restoreFocus=true: previous focus node regains focus on dispose',
    (tester) async {
      final outerNode = FocusNode(debugLabel: 'outer');
      addTearDown(outerNode.dispose);

      var showTrap = true;

      await tester.pumpObers(
        StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 400,
              height: 400,
              child: Column(
                children: [
                  Focus(
                    focusNode: outerNode,
                    child: const SizedBox(width: 40, height: 40),
                  ),
                  if (showTrap)
                    OiFocusTrap(
                      initialFocus: false,
                      child: GestureDetector(
                        onTap: () => setState(() => showTrap = false),
                        child: const SizedBox(width: 40, height: 40),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );

      // Give focus to the outer node before the trap takes over.
      outerNode.requestFocus();
      await tester.pump();
      expect(outerNode.hasPrimaryFocus, isTrue);

      // Dismiss the trap by tapping the GestureDetector inside it.
      await tester.tap(find.byType(GestureDetector), warnIfMissed: false);
      await tester.pump();

      // The outer node should have regained focus after trap disposal.
      expect(outerNode.hasPrimaryFocus, isTrue);
    },
  );

  // ── 6. Tab navigation stays within trap ────────────────────────────────────

  testWidgets('Tab navigation stays within the focus trap', (tester) async {
    final nodeA = FocusNode(debugLabel: 'A');
    final nodeB = FocusNode(debugLabel: 'B');
    final outerNode = FocusNode(debugLabel: 'outer');
    addTearDown(nodeA.dispose);
    addTearDown(nodeB.dispose);
    addTearDown(outerNode.dispose);

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            // Outer focus node sits OUTSIDE the trap.
            Focus(
              focusNode: outerNode,
              child: const SizedBox(width: 40, height: 40),
            ),
            OiFocusTrap(
              initialFocus: false,
              child: Column(
                children: [
                  Focus(
                    focusNode: nodeA,
                    child: const SizedBox(width: 40, height: 40),
                  ),
                  Focus(
                    focusNode: nodeB,
                    child: const SizedBox(width: 40, height: 40),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Start with focus on nodeA inside the trap.
    nodeA.requestFocus();
    await tester.pump();
    expect(nodeA.hasPrimaryFocus, isTrue);

    // Tab forward — should stay inside the trap (move to nodeB or wrap back).
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      outerNode.hasPrimaryFocus,
      isFalse,
      reason: 'Tab should not escape the trap to outerNode',
    );

    // Shift+Tab backward — should stay inside the trap.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pump();
    expect(
      outerNode.hasPrimaryFocus,
      isFalse,
      reason: 'Shift+Tab should not escape the trap to outerNode',
    );
  });
}
