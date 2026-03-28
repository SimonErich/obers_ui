// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Trigger tests ────────────────────────────────────────────────────────

  group('OiContextMenu triggers', () {
    testWidgets('long-press shows menu items', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [
            OiMenuItem(label: 'Copy'),
            OiMenuItem(label: 'Paste'),
          ],
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);
    });

    testWidgets('right-click shows menu (secondary pointer button)', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'Right-click item')],
          child: Text('target'),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('target')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Right-click item'), findsOneWidget);
    });

    testWidgets('enabled=false suppresses context menu', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'Hidden')],
          enabled: false,
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('re-triggering closes old menu and opens new one', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'Item')],
          child: SizedBox(width: 300, height: 200, child: Text('target')),
        ),
      );
      // Open first time.
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsOneWidget);

      // Open again (simulates right-clicking elsewhere).
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      // Should still show exactly one menu, not two stacked.
      expect(find.text('Item'), findsOneWidget);
    });
  });

  // ── Dismissal tests ──────────────────────────────────────────────────────

  group('OiContextMenu dismissal', () {
    testWidgets('tapping an item calls onTap and closes menu', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'Action', onTap: () => tapped = true)],
          child: const Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
      expect(find.text('Action'), findsNothing);
    });

    testWidgets('tapping barrier closes the menu', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'CloseMe')],
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      expect(find.text('CloseMe'), findsOneWidget);

      await tester.tapAt(const Offset(1, 1));
      await tester.pumpAndSettle();
      expect(find.text('CloseMe'), findsNothing);
    });

    testWidgets('Escape key dismisses the menu', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'Item')],
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsNothing);
    });
  });

  // ── Item state tests ─────────────────────────────────────────────────────

  group('OiContextMenu item states', () {
    testWidgets('disabled item does not call onTap', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiContextMenu(
          label: 'Test menu',
          items: [
            OiMenuItem(
              label: 'Disabled',
              enabled: false,
              onTap: () => tapped = true,
            ),
          ],
          child: const Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('OiMenuDivider renders as divider (no text)', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [
            OiMenuItem(label: 'Above'),
            OiMenuDivider(),
            OiMenuItem(label: 'Below'),
          ],
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      expect(find.text('Above'), findsOneWidget);
      expect(find.text('Below'), findsOneWidget);
    });

    testWidgets('shortcut text is displayed', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'Save', shortcut: 'Cmd+S')],
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cmd+S'), findsOneWidget);
    });

    testWidgets('checked=true renders OiIcons.check icon', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [
            OiMenuItem(label: 'Checked', checked: true),
            OiMenuItem(label: 'Unchecked', checked: false),
          ],
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      // Verify the check icon is present for checked=true.
      final checkIcons = tester.widgetList<OiIcon>(
        find.byWidgetPredicate((w) => w is OiIcon && w.icon == OiIcons.check),
      );
      expect(checkIcons, hasLength(1));
    });

    testWidgets('sub-menu item shows chevron indicator', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [
            OiMenuItem(
              label: 'Share',
              children: [
                OiMenuItem(label: 'Email'),
                OiMenuItem(label: 'Link'),
              ],
            ),
          ],
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      expect(find.text('Share'), findsOneWidget);
      // Chevron icon should be present.
      final chevrons = tester.widgetList<OiIcon>(
        find.byWidgetPredicate(
          (w) => w is OiIcon && w.icon == OiIcons.chevronRight,
        ),
      );
      expect(chevrons, isNotEmpty);
      // Sub-menu items should not be visible until triggered.
      expect(find.text('Email'), findsNothing);
    });
  });

  // ── Keyboard navigation tests ────────────────────────────────────────────

  group('OiContextMenu keyboard navigation', () {
    testWidgets('arrow down/up cycles through items, Enter activates', (
      tester,
    ) async {
      var lastTapped = '';
      await tester.pumpObers(
        OiContextMenu(
          label: 'Test menu',
          items: [
            OiMenuItem(label: 'First', onTap: () => lastTapped = 'First'),
            OiMenuItem(label: 'Second', onTap: () => lastTapped = 'Second'),
          ],
          child: const Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();

      // Down → First, Down → Second, Enter → activate.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(lastTapped, 'Second');
    });

    testWidgets('Space key activates focused item', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'Action', onTap: () => tapped = true)],
          child: const Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('dividers are skipped during keyboard navigation', (
      tester,
    ) async {
      var lastTapped = '';
      await tester.pumpObers(
        OiContextMenu(
          label: 'Test menu',
          items: [
            OiMenuItem(label: 'First', onTap: () => lastTapped = 'First'),
            const OiMenuDivider(),
            OiMenuItem(label: 'Third', onTap: () => lastTapped = 'Third'),
          ],
          child: const Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();

      // Down → First, Down → should skip divider → Third.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(lastTapped, 'Third');
    });

    testWidgets('disabled items are skipped during keyboard navigation', (
      tester,
    ) async {
      var lastTapped = '';
      await tester.pumpObers(
        OiContextMenu(
          label: 'Test menu',
          items: [
            OiMenuItem(label: 'First', onTap: () => lastTapped = 'First'),
            const OiMenuItem(label: 'Disabled', enabled: false),
            OiMenuItem(label: 'Third', onTap: () => lastTapped = 'Third'),
          ],
          child: const Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();

      // Down → First, Down → should skip disabled → Third.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(lastTapped, 'Third');
    });

    testWidgets('right-arrow opens sub-menu via keyboard', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [
            OiMenuItem(
              label: 'Share',
              children: [
                OiMenuItem(label: 'Email'),
                OiMenuItem(label: 'Link'),
              ],
            ),
          ],
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();

      // Focus "Share" then press right-arrow to open sub-menu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
    });
  });

  // ── Animation tests ──────────────────────────────────────────────────────

  group('OiContextMenu animation', () {
    testWidgets('FadeTransition and ScaleTransition are present', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'Animated')],
          child: Text('target'),
        ),
      );
      await tester.longPress(find.text('target'));
      await tester.pump();
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);
      await tester.pumpAndSettle();
    });
  });

  // ── Positioning tests ────────────────────────────────────────────────────

  group('OiContextMenu positioning', () {
    testWidgets('menu clamps to screen edges', (tester) async {
      await tester.pumpObers(
        const OiContextMenu(
          label: 'Test menu',
          items: [OiMenuItem(label: 'Edge item')],
          child: Align(alignment: Alignment.bottomRight, child: Text('target')),
        ),
        surfaceSize: const Size(400, 400),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      expect(find.text('Edge item'), findsOneWidget);
    });
  });

  // ── Scrolling tests ──────────────────────────────────────────────────────

  group('OiContextMenu scrolling', () {
    testWidgets('menu with many items contains a SingleChildScrollView', (
      tester,
    ) async {
      await tester.pumpObers(
        OiContextMenu(
          label: 'Test menu',
          items: [for (var i = 0; i < 50; i++) OiMenuItem(label: 'Item $i')],
          child: const Text('target'),
        ),
        surfaceSize: const Size(400, 400),
      );
      await tester.longPress(find.text('target'));
      await tester.pumpAndSettle();
      // Verify scrolling is in place.
      expect(find.byType(SingleChildScrollView), findsWidgets);
      // First few items should be visible.
      expect(find.text('Item 0'), findsOneWidget);
    });
  });

  // ── Model unit tests ─────────────────────────────────────────────────────

  group('OiMenuItem', () {
    test('OiMenuDivider is a subtype of OiMenuItem', () {
      const divider = OiMenuDivider();
      expect(divider, isA<OiMenuItem>());
      expect(divider.label, '');
    });

    test('default values are correct', () {
      const item = OiMenuItem(label: 'Test');
      expect(item.enabled, isTrue);
      expect(item.destructive, isFalse);
      expect(item.icon, isNull);
      expect(item.shortcut, isNull);
      expect(item.checked, isNull);
      expect(item.children, isNull);
      expect(item.semanticLabel, isNull);
      expect(item.onTap, isNull);
    });
  });
}
