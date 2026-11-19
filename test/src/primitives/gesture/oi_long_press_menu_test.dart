// Tests do not require documentation comments.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/gesture/oi_long_press_menu.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(
      const OiLongPressMenu(items: [], child: Text('hold me')),
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
        child: const SizedBox(width: 100, height: 50, child: Text('hold me')),
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
        items: [OiLongPressMenuItem(label: 'Copy', onTap: () {})],
        child: const SizedBox(width: 100, height: 50, child: Text('hold me')),
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
        items: [OiLongPressMenuItem(label: 'Copy', onTap: () => tapped = true)],
        child: const SizedBox(width: 100, height: 50, child: Text('hold me')),
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

  testWidgets('multiple menu items all visible after long press', (
    tester,
  ) async {
    await tester.pumpObers(
      OiLongPressMenu(
        items: [
          OiLongPressMenuItem(label: 'Cut', onTap: () {}),
          OiLongPressMenuItem(label: 'Copy', onTap: () {}),
          OiLongPressMenuItem(label: 'Paste', onTap: () {}),
        ],
        child: const SizedBox(width: 100, height: 50, child: Text('hold me')),
      ),
    );

    await tester.longPress(find.byType(OiLongPressMenu));
    await tester.pump();

    expect(find.text('Cut'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Paste'), findsOneWidget);
  });

  // ── Positioning ───────────────────────────────────────────────────────────

  group('positioning', () {
    const screen = Size(400, 300);

    Widget menuAt(Alignment alignment, {Axis direction = Axis.vertical}) =>
        Align(
          alignment: alignment,
          child: OiLongPressMenu(
            direction: direction,
            items: [
              OiLongPressMenuItem(label: 'Copy', onTap: () {}),
              OiLongPressMenuItem(label: 'Share', onTap: () {}),
              OiLongPressMenuItem(label: 'Delete', onTap: () {}),
            ],
            child: const SizedBox(
              key: Key('target'),
              width: 100,
              height: 50,
              child: ColoredBox(color: Color(0xFF888888)),
            ),
          ),
        );

    Rect panelRect(WidgetTester tester) => tester.getRect(
      find.byKey(const ValueKey('oi_long_press_menu_panel')),
    );

    testWidgets('opens at the press point when there is room', (tester) async {
      await tester.pumpObers(menuAt(Alignment.topLeft), surfaceSize: screen);

      await tester.longPressAt(const Offset(40, 30));
      await tester.pump();

      expect(panelRect(tester).topLeft, const Offset(40, 30));
    });

    for (final direction in Axis.values) {
      testWidgets('stays on screen near the bottom-right corner '
          '(${direction.name})', (tester) async {
        await tester.pumpObers(
          menuAt(Alignment.bottomRight, direction: direction),
          surfaceSize: screen,
        );

        await tester.longPressAt(const Offset(390, 290));
        await tester.pump();

        final rect = panelRect(tester);
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.top, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(screen.width));
        expect(rect.bottom, lessThanOrEqualTo(screen.height));
        expect(find.text('Delete').hitTestable(), findsOneWidget);
      });
    }

    testWidgets('stays on screen near the bottom-left corner', (tester) async {
      await tester.pumpObers(menuAt(Alignment.bottomLeft), surfaceSize: screen);

      await tester.longPressAt(const Offset(5, 295));
      await tester.pump();

      final rect = panelRect(tester);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(screen.height));
    });
  });

  // ── Theming ───────────────────────────────────────────────────────────────

  group('theming', () {
    for (final theme in [OiThemeData.light(), OiThemeData.dark()]) {
      testWidgets('panel uses ${theme.brightness.name} theme tokens', (
        tester,
      ) async {
        await tester.pumpObers(
          OiLongPressMenu(
            items: [OiLongPressMenuItem(label: 'Copy', onTap: () {})],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: ColoredBox(color: Color(0xFF888888)),
            ),
          ),
          theme: theme,
        );
        await tester.longPress(find.byType(OiLongPressMenu));
        await tester.pump();

        final panel = tester.widget<DecoratedBox>(
          find.byKey(const ValueKey('oi_long_press_menu_panel')),
        );
        final decoration = panel.decoration as BoxDecoration;
        expect(decoration.color, theme.colors.surface);
        expect(decoration.boxShadow, theme.shadows.md);
        expect(decoration.borderRadius, theme.radius.md);

        final label = tester.renderObject<RenderParagraph>(find.text('Copy'));
        expect(label.text.style?.color, theme.colors.text);
      });
    }
  });

  // ── Dismissal ─────────────────────────────────────────────────────────────

  group('dismissal', () {
    Widget menu() => Align(
      alignment: Alignment.topLeft,
      child: OiLongPressMenu(
        items: [OiLongPressMenuItem(label: 'Copy', onTap: () {})],
        child: const SizedBox(
          width: 100,
          height: 50,
          child: ColoredBox(color: Color(0xFF888888)),
        ),
      ),
    );

    testWidgets('a tap outside closes the menu', (tester) async {
      await tester.pumpObers(menu(), surfaceSize: const Size(400, 300));
      await tester.longPressAt(const Offset(20, 20));
      await tester.pump();
      expect(find.text('Copy'), findsOneWidget);

      await tester.tapAt(const Offset(350, 250));
      await tester.pump();

      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('a tap on the child closes the menu', (tester) async {
      await tester.pumpObers(menu(), surfaceSize: const Size(400, 300));
      await tester.longPressAt(const Offset(20, 5));
      await tester.pump();
      expect(find.text('Copy'), findsOneWidget);

      // Still on the child, but clear of the open menu.
      await tester.tapAt(const Offset(5, 2));
      await tester.pump();

      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('unmounting with the menu open leaves nothing behind', (
      tester,
    ) async {
      await tester.pumpObers(menu(), surfaceSize: const Size(400, 300));
      await tester.longPressAt(const Offset(20, 20));
      await tester.pump();

      await tester.pumpObers(const SizedBox.shrink());

      expect(find.text('Copy'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
