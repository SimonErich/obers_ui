// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/gesture/oi_long_press_menu.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(
      const OiLongPressMenu(
        items: [],
        child: Text('hold me'),
      ),
    );
    expect(find.text('hold me'), findsOneWidget);
  });

  // ── 2. Long press shows overlay menu ─────────────────────────────────────

  testWidgets('long press shows overlay menu items', (tester) async {
    await tester.pumpObers(
      OiLongPressMenu(
        items: [
          OiLongPressMenuItem(label: 'Copy', onTap: () {}),
          OiLongPressMenuItem(label: 'Share', onTap: () {}),
        ],
        child: const SizedBox(
          width: 100,
          height: 50,
          child: Text('hold me'),
        ),
      ),
    );

    await tester.longPress(find.byType(OiLongPressMenu));
    await tester.pump();

    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });

  // ── 3. enabled=false: long press ignored ─────────────────────────────────

  testWidgets('enabled=false: long press does not show menu', (tester) async {
    await tester.pumpObers(
      OiLongPressMenu(
        enabled: false,
        items: [
          OiLongPressMenuItem(label: 'Copy', onTap: () {}),
        ],
        child: const SizedBox(
          width: 100,
          height: 50,
          child: Text('hold me'),
        ),
      ),
    );

    await tester.longPress(find.byType(OiLongPressMenu));
    await tester.pump();

    expect(find.text('Copy'), findsNothing);
  });

  // ── 4. Tapping a menu item calls onTap and closes menu ───────────────────

  testWidgets('tapping menu item calls onTap and closes menu', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiLongPressMenu(
        items: [
          OiLongPressMenuItem(label: 'Copy', onTap: () => tapped = true),
        ],
        child: const SizedBox(
          width: 100,
          height: 50,
          child: Text('hold me'),
        ),
      ),
    );

    await tester.longPress(find.byType(OiLongPressMenu));
    await tester.pump();

    expect(find.text('Copy'), findsOneWidget);

    await tester.tap(find.text('Copy'));
    await tester.pump();

    expect(tapped, isTrue);
    expect(find.text('Copy'), findsNothing);
  });

  // ── 5. Menu items are visible in overlay ─────────────────────────────────

  testWidgets('multiple menu items all visible after long press', (tester) async {
    await tester.pumpObers(
      OiLongPressMenu(
        items: [
          OiLongPressMenuItem(label: 'Cut', onTap: () {}),
          OiLongPressMenuItem(label: 'Copy', onTap: () {}),
          OiLongPressMenuItem(label: 'Paste', onTap: () {}),
        ],
        child: const SizedBox(
          width: 100,
          height: 50,
          child: Text('hold me'),
        ),
      ),
    );

    await tester.longPress(find.byType(OiLongPressMenu));
    await tester.pump();

    expect(find.text('Cut'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Paste'), findsOneWidget);
  });
}
