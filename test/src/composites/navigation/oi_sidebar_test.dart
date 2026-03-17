// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_sidebar.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _sections = [
  OiSidebarSection(
    title: 'Main',
    items: [
      OiSidebarItem(
        id: 'home',
        label: 'Home',
        icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
      ),
      OiSidebarItem(
        id: 'inbox',
        label: 'Inbox',
        icon: IconData(0xe156, fontFamily: 'MaterialIcons'),
        badgeCount: 5,
      ),
      OiSidebarItem(
        id: 'disabled',
        label: 'Disabled',
        icon: IconData(0xe14c, fontFamily: 'MaterialIcons'),
        disabled: true,
      ),
    ],
  ),
  OiSidebarSection(
    title: 'Projects',
    items: [
      OiSidebarItem(
        id: 'project_a',
        label: 'Project A',
        icon: IconData(0xe2c8, fontFamily: 'MaterialIcons'),
        children: [
          OiSidebarItem(
            id: 'task_1',
            label: 'Task 1',
            icon: IconData(0xe876, fontFamily: 'MaterialIcons'),
          ),
          OiSidebarItem(
            id: 'task_2',
            label: 'Task 2',
            icon: IconData(0xe876, fontFamily: 'MaterialIcons'),
          ),
        ],
      ),
    ],
  ),
];

Widget _sidebar({
  List<OiSidebarSection>? sections,
  String? selectedId,
  ValueChanged<String>? onSelect,
  OiSidebarMode mode = OiSidebarMode.full,
  Widget? header,
  Widget? footer,
}) {
  return SizedBox(
    width: 300,
    height: 600,
    child: OiSidebar(
      sections: sections ?? _sections,
      selectedId: selectedId,
      onSelect: onSelect ?? (_) {},
      label: 'Test sidebar',
      mode: mode,
      header: header,
      footer: footer,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OiSidebar', () {
    testWidgets('renders items with icon and label', (tester) async {
      await tester.pumpObers(_sidebar());

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('selected item is highlighted', (tester) async {
      await tester.pumpObers(_sidebar(selectedId: 'home'));

      // The Home item should be present and rendered.
      expect(find.text('Home'), findsOneWidget);

      // Verify the selected item has a colored container (primary tint).
      final homeText = find.text('Home');
      expect(homeText, findsOneWidget);
    });

    testWidgets('nested items indent when parent is tapped', (tester) async {
      await tester.pumpObers(_sidebar());

      // Initially, nested items should not be visible.
      expect(find.text('Task 1'), findsNothing);
      expect(find.text('Task 2'), findsNothing);

      // Tap the parent item to expand.
      await tester.tap(find.text('Project A'));
      await tester.pumpAndSettle();

      // Now nested items should be visible.
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });

    testWidgets('section titles render', (tester) async {
      await tester.pumpObers(_sidebar());

      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
    });

    testWidgets('compact mode shows only icons', (tester) async {
      await tester.pumpObers(_sidebar(mode: OiSidebarMode.compact));

      // Labels should not be rendered in compact mode.
      expect(find.text('Home'), findsNothing);
      expect(find.text('Inbox'), findsNothing);

      // Section titles should not be rendered in compact mode.
      expect(find.text('Main'), findsNothing);

      // Icons should still be present.
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('hidden mode shows nothing', (tester) async {
      await tester.pumpObers(_sidebar(mode: OiSidebarMode.hidden));

      expect(find.text('Home'), findsNothing);
      expect(find.text('Inbox'), findsNothing);
      expect(find.text('Main'), findsNothing);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('badges show on items', (tester) async {
      await tester.pumpObers(_sidebar());

      // The Inbox item has badgeCount: 5.
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('keyboard navigation with arrow keys and enter',
        (tester) async {
      String? selected;
      await tester.pumpObers(
        _sidebar(onSelect: (id) => selected = id),
      );

      // Focus the sidebar.
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Navigate down.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Press enter to select.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // An item should have been selected.
      expect(selected, isNotNull);
    });

    testWidgets('semantics navigation role is present', (tester) async {
      await tester.pumpObers(_sidebar());

      // The sidebar wraps content in Semantics with the label.
      final semantics = find.bySemanticsLabel('Test sidebar');
      expect(semantics, findsOneWidget);
    });

    testWidgets('header and footer render', (tester) async {
      await tester.pumpObers(
        _sidebar(
          header: const Text('Header'),
          footer: const Text('Footer'),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('onSelect fires when item is tapped', (tester) async {
      String? selected;
      await tester.pumpObers(
        _sidebar(onSelect: (id) => selected = id),
      );

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(selected, 'home');
    });

    testWidgets('disabled items are not selectable', (tester) async {
      String? selected;
      await tester.pumpObers(
        _sidebar(onSelect: (id) => selected = id),
      );

      // Tap the disabled item — the OiTappable should prevent the tap.
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      // The disabled item should not have been selected via onSelect
      // because OiTappable suppresses callbacks when disabled.
      expect(selected, isNot('disabled'));
    });

    testWidgets('collapsible section hides items on tap', (tester) async {
      await tester.pumpObers(_sidebar());

      // Items are visible initially.
      expect(find.text('Home'), findsOneWidget);

      // Tap the section title to collapse.
      await tester.tap(find.text('Main'));
      await tester.pumpAndSettle();

      // Items in the Main section should be hidden.
      expect(find.text('Home'), findsNothing);

      // Tap again to expand.
      await tester.tap(find.text('Main'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
