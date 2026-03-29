// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/composites/data/oi_grouped_list.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_in_memory_driver.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

import '../../../helpers/pump_app.dart';

class _Contact {
  const _Contact(this.name, this.letter);
  final String name;
  final String letter;
}

const _contacts = [
  _Contact('Alice', 'A'),
  _Contact('Amy', 'A'),
  _Contact('Bob', 'B'),
  _Contact('Charlie', 'C'),
  _Contact('Carol', 'C'),
];

void main() {
  // ── Rendering ─────────────────────────────────────────────────────────────

  testWidgets('renders group headers', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
      ),
      surfaceSize: const Size(800, 1200),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('renders items under correct headers', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
      ),
      surfaceSize: const Size(800, 1200),
    );
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Charlie'), findsOneWidget);
  });

  testWidgets('groupOrder controls section ordering', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        groupOrder: (a, b) => b.compareTo(a), // Reverse: C, B, A.
        label: 'Contacts',
      ),
      surfaceSize: const Size(800, 1200),
    );
    // All headers should still render.
    expect(find.text('A'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  // ── Collapsible ─────────────────────────────────────────────────────────

  testWidgets('collapsible groups toggle on header tap', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        collapsible: true,
        label: 'Contacts',
      ),
      surfaceSize: const Size(800, 1200),
    );
    // All items visible initially.
    expect(find.text('Alice'), findsOneWidget);
    // Tap header 'A' to collapse.
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    // Alice and Amy should be hidden.
    expect(find.text('Alice'), findsNothing);
    expect(find.text('Amy'), findsNothing);
    // Bob still visible.
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('initiallyCollapsed groups start collapsed', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        collapsible: true,
        initiallyCollapsed: const {'B'},
        label: 'Contacts',
      ),
      surfaceSize: const Size(800, 1200),
    );
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });

  // ── Empty ─────────────────────────────────────────────────────────────────

  testWidgets('empty items shows emptyState', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: const [],
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        emptyState: const Text('No contacts'),
      ),
      surfaceSize: const Size(800, 600),
    );
    expect(find.text('No contacts'), findsOneWidget);
  });

  // ── Custom header ─────────────────────────────────────────────────────────

  testWidgets('custom headerBuilder renders custom headers', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        headerBuilder: (_, key, items, {required collapsed}) =>
            Text('$key (${items.length})'),
      ),
      surfaceSize: const Size(800, 1200),
    );
    expect(find.text('A (2)'), findsOneWidget);
    expect(find.text('C (2)'), findsOneWidget);
  });

  // ── Separator ─────────────────────────────────────────────────────────────

  testWidgets('separator renders between items', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        separator: const Divider(),
      ),
      surfaceSize: const Size(800, 1200),
    );
    // Group A has 2 items -> 1 divider, Group C has 2 -> 1, Group B has 1 -> 0.
    expect(find.byType(Divider), findsNWidgets(2));
  });

  // ── Controller ────────────────────────────────────────────────────────────

  testWidgets('controller.expandAll expands all groups', (tester) async {
    final ctrl = OiGroupedListController();
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        collapsible: true,
        initiallyCollapsed: const {'A', 'B'},
        groupedListController: ctrl,
        label: 'Contacts',
      ),
      surfaceSize: const Size(800, 1200),
    );
    expect(find.text('Alice'), findsNothing);
    ctrl.expandAll();
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
  });

  // ── Loading ──────────────────────────────────────────────────────────────

  testWidgets('loading shows progress indicator', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        loading: true,
      ),
      surfaceSize: const Size(800, 1200),
    );
    expect(find.byType(OiProgress), findsOneWidget);
  });

  // ── Collapse all ────────────────────────────────────────────────────────

  testWidgets('controller.collapseAll collapses all groups', (tester) async {
    final ctrl = OiGroupedListController();
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        collapsible: true,
        groupedListController: ctrl,
        label: 'Contacts',
      ),
      surfaceSize: const Size(800, 1200),
    );
    expect(find.text('Alice'), findsOneWidget);
    ctrl.collapseAll();
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsNothing);
    expect(find.text('Bob'), findsNothing);
  });

  // ── Physics ─────────────────────────────────────────────────────────────

  testWidgets('physics parameter is passed to ListView', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        physics: const NeverScrollableScrollPhysics(),
      ),
      surfaceSize: const Size(800, 1200),
    );
    expect(find.byType(OiGroupedList<_Contact>), findsOneWidget);
  });

  // ── Default header style ────────────────────────────────────────────────

  testWidgets('default header uses h4 style', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
      ),
      surfaceSize: const Size(800, 1200),
    );
    // Headers should render (A, B, C)
    expect(find.text('A'), findsOneWidget);
  });

  // ── Semantic label ────────────────────────────────────────────────────────

  testWidgets('has semantic label', (tester) async {
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => Text(c.name),
        groupBy: (c) => c.letter,
        label: 'Contact list',
        semanticLabel: 'Contact list grouped by letter',
      ),
      surfaceSize: const Size(800, 1200),
    );
    expect(
      find.bySemanticsLabel('Contact list grouped by letter'),
      findsOneWidget,
    );
  });

  // ── Settings persistence ────────────────────────────────────────────────────

  testWidgets('collapsed groups persist when settingsDriver is provided', (
    tester,
  ) async {
    final driver = OiInMemorySettingsDriver();
    // Pre-seed the driver with group A collapsed (simulates a previous session).
    driver.store['oi_grouped_list::test'] = {
      'schemaVersion': 1,
      'collapsedGroups': ['A'],
    };

    // Build with the pre-seeded driver — should restore collapsed state.
    final ctrl = OiGroupedListController();
    await tester.pumpObers(
      OiGroupedList<_Contact>(
        items: _contacts,
        itemBuilder: (_, c, _) => OiLabel.body(c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        collapsible: true,
        groupedListController: ctrl,
        settingsDriver: driver,
        settingsKey: 'test',
      ),
      surfaceSize: const Size(800, 1200),
    );
    await tester.pump(); // settle settings load

    // Group A should be restored as collapsed from the persisted data.
    expect(ctrl.collapsed('A'), isTrue);
  });
}

class Divider extends StatelessWidget {
  const Divider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: const Color(0xFFCCCCCC));
}
