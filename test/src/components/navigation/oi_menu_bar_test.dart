// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_menu_bar.dart';
import 'package:obers_ui/src/components/overlays/oi_menu_item.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

import '../../../helpers/pump_app.dart';

/// Wraps the menu bar at the top of the screen so dropdown overlays
/// remain within the test viewport.
Widget _top(Widget child) => Align(alignment: Alignment.topLeft, child: child);

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders top-level item labels', (tester) async {
    await tester.pumpObers(
      _top(
        const OiMenuBar(
          label: 'Main menu',
          items: [
            OiMenuItem(label: 'File'),
            OiMenuItem(label: 'Edit'),
            OiMenuItem(label: 'View'),
          ],
        ),
      ),
    );

    expect(find.text('File'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
  });

  testWidgets('renders with correct height', (tester) async {
    await tester.pumpObers(
      _top(
        const OiMenuBar(
          label: 'Main menu',
          height: 36,
          items: [OiMenuItem(label: 'File')],
        ),
      ),
    );

    // The OiMenuBar uses a Container with a fixed height. Find the
    // outermost Container that has a height constraint matching 36.
    final containers = tester.widgetList<Container>(
      find.descendant(
        of: find.byType(OiMenuBar),
        matching: find.byType(Container),
      ),
    );
    final heightContainer = containers.where(
      (c) => c.constraints?.maxHeight == 36,
    );
    expect(heightContainer, isNotEmpty);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      _top(
        const OiMenuBar(
          label: 'App menu',
          items: [OiMenuItem(label: 'File')],
        ),
      ),
    );

    expect(find.bySemanticsLabel('App menu'), findsOneWidget);
  });

  // ── Dropdown ──────────────────────────────────────────────────────────────

  testWidgets('tapping top-level item opens dropdown', (tester) async {
    await tester.pumpObers(
      _top(
        const OiMenuBar(
          label: 'Main menu',
          items: [
            OiMenuItem(
              label: 'File',
              children: [
                OiMenuItem(label: 'New'),
                OiMenuItem(label: 'Open'),
              ],
            ),
          ],
        ),
      ),
    );

    // Dropdown items should not be visible initially.
    expect(find.text('New'), findsNothing);
    expect(find.text('Open'), findsNothing);

    // Tap the top-level item to open the dropdown.
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();

    // Dropdown items should now be visible.
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('dropdown shows child item labels', (tester) async {
    await tester.pumpObers(
      _top(
        const OiMenuBar(
          label: 'Main menu',
          items: [
            OiMenuItem(
              label: 'Edit',
              children: [
                OiMenuItem(label: 'Undo'),
                OiMenuItem(label: 'Redo'),
                OiMenuItem(label: 'Cut'),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Redo'), findsOneWidget);
    expect(find.text('Cut'), findsOneWidget);
  });

  testWidgets('shortcut text is displayed', (tester) async {
    await tester.pumpObers(
      _top(
        const OiMenuBar(
          label: 'Main menu',
          items: [
            OiMenuItem(
              label: 'File',
              children: [
                OiMenuItem(label: 'Save', shortcut: 'Cmd+S'),
                OiMenuItem(label: 'Quit', shortcut: 'Cmd+Q'),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();

    expect(find.text('Cmd+S'), findsOneWidget);
    expect(find.text('Cmd+Q'), findsOneWidget);
  });

  // ── Item states ───────────────────────────────────────────────────────────

  testWidgets('disabled items are non-interactive', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      _top(
        OiMenuBar(
          label: 'Main menu',
          items: [
            OiMenuItem(
              label: 'File',
              children: [
                OiMenuItem(
                  label: 'Disabled',
                  enabled: false,
                  onTap: () => tapped = true,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();

    // Tap the disabled item -- warnIfMissed is false because the item is
    // intentionally disabled (OiTappable renders at reduced opacity and
    // suppresses interaction).
    await tester.tap(find.text('Disabled'), warnIfMissed: false);
    await tester.pump();

    expect(tapped, isFalse);
  });

  testWidgets('destructive items have correct widget structure', (
    tester,
  ) async {
    await tester.pumpObers(
      _top(
        const OiMenuBar(
          label: 'Main menu',
          items: [
            OiMenuItem(
              label: 'File',
              children: [OiMenuItem(label: 'Delete All', destructive: true)],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();

    // The destructive item should be rendered.
    expect(find.text('Delete All'), findsOneWidget);
  });

  testWidgets('checked items show checkmark icon', (tester) async {
    await tester.pumpObers(
      _top(
        const OiMenuBar(
          label: 'Main menu',
          items: [
            OiMenuItem(
              label: 'View',
              children: [
                OiMenuItem(label: 'Sidebar', checked: true),
                OiMenuItem(label: 'Minimap', checked: false),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();

    // A checked item should show a decorative OiIcon with the check icon.
    final checkIcons = tester.widgetList<OiIcon>(
      find.byWidgetPredicate((w) => w is OiIcon && w.icon == OiIcons.check),
    );
    expect(checkIcons, hasLength(1));
  });

  // ── Divider ───────────────────────────────────────────────────────────────

  testWidgets('OiMenuDivider renders separator', (tester) async {
    await tester.pumpObers(
      _top(
        const OiMenuBar(
          label: 'Main menu',
          items: [
            OiMenuItem(
              label: 'File',
              children: [
                OiMenuItem(label: 'New'),
                OiMenuDivider(),
                OiMenuItem(label: 'Quit'),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();

    // Both items should be visible, separated by a divider.
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Quit'), findsOneWidget);

    // The divider renders as a 1px-high Container — find it among the
    // dropdown's children. We look for a Container with height 1.
    final dividers = tester.widgetList<Container>(
      find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxHeight == 1,
      ),
    );
    expect(dividers, isNotEmpty);
  });
}
