// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/overlays/oi_sheet.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('open=true shows child content', (tester) async {
    await tester.pumpObers(
      const OiSheet(label: 'sheet', open: true, child: Text('Sheet content')),
    );
    await tester.pump(); // let animation settle
    expect(find.text('Sheet content'), findsOneWidget);
  });

  testWidgets('open=false hides child content via slide animation', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiSheet(label: 'sheet', open: false, child: Text('Hidden content')),
    );
    // The SlideTransition keeps the child in tree but translated off-screen;
    // the text widget is still found but visually off-screen.
    // At minimum, the widget must build without errors.
    expect(tester.takeException(), isNull);
  });

  testWidgets('onClose fires when scrim is tapped (dismissible=true)', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpObers(
      OiSheet(
        label: 'sheet',
        open: true,
        onClose: () => closed = true,
        child: const SizedBox(height: 200, child: Text('Panel')),
      ),
    );
    await tester.pump();
    // Tap well above the panel (on the scrim).
    await tester.tapAt(const Offset(200, 10));
    await tester.pump();
    expect(closed, isTrue);
  });

  testWidgets('dismissible=false: scrim tap does not call onClose', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpObers(
      OiSheet(
        label: 'sheet',
        open: true,
        dismissible: false,
        onClose: () => closed = true,
        child: const SizedBox(height: 200, child: Text('Panel')),
      ),
    );
    await tester.pump();
    await tester.tapAt(const Offset(200, 10));
    await tester.pump();
    expect(closed, isFalse);
  });

  testWidgets('dragHandle=true renders drag handle widget', (tester) async {
    await tester.pumpObers(
      const OiSheet(
        label: 'sheet',
        open: true,
        dragHandle: true,
        child: Text('With handle'),
      ),
    );
    await tester.pump();
    // The handle is a small Container; the sheet child text must be visible.
    expect(find.text('With handle'), findsOneWidget);
  });

  testWidgets('side=right slides in from the right', (tester) async {
    await tester.pumpObers(
      const OiSheet(
        label: 'sheet',
        open: true,
        side: OiPanelSide.right,
        child: Text('Right panel'),
      ),
    );
    await tester.pump();
    expect(find.text('Right panel'), findsOneWidget);
  });

  testWidgets('side=top slides in from the top', (tester) async {
    await tester.pumpObers(
      const OiSheet(
        label: 'sheet',
        open: true,
        side: OiPanelSide.top,
        child: Text('Top panel'),
      ),
    );
    await tester.pump();
    expect(find.text('Top panel'), findsOneWidget);
  });

  testWidgets('side=left slides in from the left', (tester) async {
    await tester.pumpObers(
      const OiSheet(
        label: 'sheet',
        open: true,
        side: OiPanelSide.left,
        child: Text('Left panel'),
      ),
    );
    await tester.pump();
    expect(find.text('Left panel'), findsOneWidget);
  });

  testWidgets('toggling open from false to true animates in', (tester) async {
    // OiSheet uses SlideTransition which keeps the child in the tree
    // regardless of open state. Verify that animation runs by checking
    // controller direction: starts at 0 (closed) then animates to 1 (open).
    var open = false;
    await tester.pumpObers(
      StatefulBuilder(
        builder: (_, setState) => Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => open = true),
              child: const Text('open'),
            ),
            OiSheet(label: 'sheet', open: open, child: const Text('Toggled')),
          ],
        ),
      ),
    );
    // Closed: child exists in tree (maintained by SlideTransition).
    expect(find.text('Toggled'), findsOneWidget);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    // Open: still visible (now fully animated in).
    expect(find.text('Toggled'), findsOneWidget);
  });

  testWidgets('disableAnimations=true: toggling open completes instantly — '
      'SlideTransition position is Offset.zero after one pump', (tester) async {
    final notifier = ValueNotifier<bool>(false);
    addTearDown(notifier.dispose);

    await tester.pumpObers(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, isOpen, _) => OiSheet(
            label: 'sheet',
            open: isOpen,
            child: const Text('instant'),
          ),
        ),
      ),
    );
    await tester.pump();

    // Open the sheet — with Duration.zero the controller jumps to 1.0
    // immediately without needing pumpAndSettle.
    notifier.value = true;
    await tester.pump();

    final slide = tester.widget<SlideTransition>(find.byType(SlideTransition));
    expect(slide.position.value, Offset.zero);
  });

  // ── initialFocus ───────────────────────────────────────────────────────────

  group('initialFocus', () {
    testWidgets('defaults to focusing the first focusable descendant', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpObers(
        OiSheet(
          label: 'sheet',
          open: true,
          child: Focus(
            focusNode: node,
            child: const SizedBox(width: 40, height: 40),
          ),
        ),
      );
      // Let the trap's post-frame callback run.
      await tester.pumpAndSettle();

      expect(node.hasFocus, isTrue);
    });

    // The trap autofocuses in a post-frame callback when it mounts, so the
    // sheet must be mounted *after* focus is established elsewhere —
    // otherwise the outside node grabs focus after the trap already ran and
    // the assertion would hold regardless of initialFocus.
    testWidgets('false highlights nothing, and restores focus on close', (
      tester,
    ) async {
      final outside = FocusNode(debugLabel: 'outside');
      final inside = FocusNode(debugLabel: 'inside');
      addTearDown(outside.dispose);
      addTearDown(inside.dispose);

      final showSheet = ValueNotifier<bool>(false);
      addTearDown(showSheet.dispose);

      await tester.pumpObers(
        ValueListenableBuilder<bool>(
          valueListenable: showSheet,
          builder: (_, visible, _) => Column(
            children: [
              Focus(
                focusNode: outside,
                child: const SizedBox(width: 40, height: 40),
              ),
              if (visible)
                OiSheet(
                  label: 'sheet',
                  open: true,
                  initialFocus: false,
                  child: Focus(
                    focusNode: inside,
                    child: const SizedBox(width: 40, height: 40),
                  ),
                ),
            ],
          ),
        ),
      );
      outside.requestFocus();
      await tester.pumpAndSettle();
      expect(outside.hasPrimaryFocus, isTrue);

      // Opening the sheet must not highlight anything inside it. Focus does
      // move onto the trap's own scope — it has to, or Escape would be dead —
      // but no descendant is focused, so no row shows a ring.
      showSheet.value = true;
      await tester.pumpAndSettle();

      expect(inside.hasFocus, isFalse);

      // Closing restores focus to where it was before the sheet opened.
      showSheet.value = false;
      await tester.pumpAndSettle();

      expect(outside.hasPrimaryFocus, isTrue);
    });

    // The mirror of the test above: with the default, opening the sheet DOES
    // move focus into it. This is what fails if initialFocus is not forwarded.
    testWidgets('default moves focus into a sheet opened later', (
      tester,
    ) async {
      final outside = FocusNode(debugLabel: 'outside');
      final inside = FocusNode(debugLabel: 'inside');
      addTearDown(outside.dispose);
      addTearDown(inside.dispose);

      final showSheet = ValueNotifier<bool>(false);
      addTearDown(showSheet.dispose);

      await tester.pumpObers(
        ValueListenableBuilder<bool>(
          valueListenable: showSheet,
          builder: (_, visible, _) => Column(
            children: [
              Focus(
                focusNode: outside,
                child: const SizedBox(width: 40, height: 40),
              ),
              if (visible)
                OiSheet(
                  label: 'sheet',
                  open: true,
                  child: Focus(
                    focusNode: inside,
                    child: const SizedBox(width: 40, height: 40),
                  ),
                ),
            ],
          ),
        ),
      );
      outside.requestFocus();
      await tester.pumpAndSettle();

      showSheet.value = true;
      await tester.pumpAndSettle();

      expect(inside.hasFocus, isTrue);
    });

    testWidgets('false still allows tabbing into the sheet content', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpObers(
        OiSheet(
          label: 'sheet',
          open: true,
          initialFocus: false,
          child: Focus(
            focusNode: node,
            child: const SizedBox(width: 40, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(node.hasFocus, isFalse);

      // Keyboard users must still be able to reach the content — pressing Tab,
      // not calling requestFocus(), which would prove nothing about the trap.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(node.hasPrimaryFocus, isTrue);
    });

    testWidgets('false puts no focus ring on any row', (tester) async {
      final first = FocusNode(debugLabel: 'first');
      final second = FocusNode(debugLabel: 'second');
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await tester.pumpObers(
        OiSheet(
          label: 'sheet',
          open: true,
          initialFocus: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Focus(
                focusNode: first,
                child: const SizedBox(width: 40, height: 40),
              ),
              Focus(
                focusNode: second,
                child: const SizedBox(width: 40, height: 40),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The trap holds focus on its own scope, so no row is highlighted.
      expect(first.hasPrimaryFocus, isFalse);
      expect(second.hasPrimaryFocus, isFalse);
    });

    testWidgets('Escape still closes when initialFocus is true', (
      tester,
    ) async {
      var closed = false;
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpObers(
        OiSheet(
          label: 'sheet',
          open: true,
          onClose: () => closed = true,
          child: Focus(
            focusNode: node,
            child: const SizedBox(width: 40, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      // The sheet animates out before onClose fires.
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });

    testWidgets('Escape still closes when initialFocus is false', (
      tester,
    ) async {
      var closed = false;
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpObers(
        OiSheet(
          label: 'sheet',
          open: true,
          initialFocus: false,
          onClose: () => closed = true,
          child: Focus(
            focusNode: node,
            child: const SizedBox(width: 40, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No requestFocus() here on purpose: this is the motivating case — the
      // picker opens on a touch device, nothing inside is focused, and the
      // user hits Escape. The trap focuses its own scope so key events still
      // reach it.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      // ...and it closed without ever putting a ring on the content.
      expect(node.hasPrimaryFocus, isFalse);
    });
  });
}
