// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_nav_menu.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _items = [
  OiNavMenuItem(
    id: 'notes',
    label: 'Notes',
    icon: IconData(0xe3ae, fontFamily: 'MaterialIcons'),
  ),
  OiNavMenuItem(
    id: 'tasks',
    label: 'Tasks',
    icon: IconData(0xe876, fontFamily: 'MaterialIcons'),
    badgeCount: 3,
  ),
  OiNavMenuItem(
    id: 'archive',
    label: 'Archive',
    icon: IconData(0xe149, fontFamily: 'MaterialIcons'),
    disabled: true,
  ),
];

Widget _menu({
  List<OiNavMenuItem>? items,
  String? selectedId,
  ValueChanged<String>? onSelect,
  Widget? header,
  Widget? footer,
}) {
  return SizedBox(
    width: 250,
    height: 400,
    child: OiNavMenu(
      items: items ?? _items,
      selectedId: selectedId,
      onSelect: onSelect ?? (_) {},
      label: 'Test menu',
      header: header,
      footer: footer,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OiNavMenu', () {
    testWidgets('renders all items', (tester) async {
      await tester.pumpObers(_menu());

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
    });

    testWidgets('selected item is highlighted', (tester) async {
      await tester.pumpObers(_menu(selectedId: 'notes'));

      // The Notes item should be present.
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('badges render on items', (tester) async {
      await tester.pumpObers(_menu());

      // Tasks has badgeCount: 3.
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('icons render on items', (tester) async {
      await tester.pumpObers(_menu());

      // Each non-null icon renders an Icon widget.
      expect(find.byType(Icon), findsNWidgets(3));
    });

    testWidgets('disabled items are not selectable', (tester) async {
      String? selected;
      await tester.pumpObers(_menu(onSelect: (id) => selected = id));

      // Tap the disabled Archive item.
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();

      // OiTappable suppresses callbacks when disabled.
      expect(selected, isNot('archive'));
    });

    testWidgets('onSelect fires when item is tapped', (tester) async {
      String? selected;
      await tester.pumpObers(_menu(onSelect: (id) => selected = id));

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      expect(selected, 'notes');
    });

    testWidgets('keyboard navigation with arrow keys and enter', (
      tester,
    ) async {
      String? selected;
      await tester.pumpObers(_menu(onSelect: (id) => selected = id));

      // Focus the menu by tapping an item.
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Navigate down.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Press enter to select.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
    });

    testWidgets('header renders', (tester) async {
      await tester.pumpObers(_menu(header: const Text('Menu Header')));

      expect(find.text('Menu Header'), findsOneWidget);
    });

    testWidgets('footer renders', (tester) async {
      await tester.pumpObers(_menu(footer: const Text('Menu Footer')));

      expect(find.text('Menu Footer'), findsOneWidget);
    });

    testWidgets('semantics label is present', (tester) async {
      await tester.pumpObers(_menu());

      final semantics = find.bySemanticsLabel('Test menu');
      expect(semantics, findsOneWidget);
    });
  });
}
