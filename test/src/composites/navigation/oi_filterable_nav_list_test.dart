// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/composites/navigation/oi_filterable_nav_list.dart';

import '../../../helpers/pump_app.dart';

// ── Test data ───────────────────────────────────────────────────────────────

class _TestItem {
  const _TestItem(this.id, this.title, this.groupId, {this.chipIds = const {}});
  final String id;
  final String title;
  final String groupId;
  final Set<String> chipIds;
}

const _groups = [
  OiNavGroup(id: 'g1', label: 'Group A'),
  OiNavGroup(id: 'g2', label: 'Group B', sortOrder: 1),
];

const _items = [
  _TestItem('1', 'Alpha', 'g1'),
  _TestItem('2', 'Beta', 'g1'),
  _TestItem('3', 'Gamma', 'g2'),
  _TestItem('4', 'Delta', 'g2'),
];

const _chipFilters = [
  OiChipFilter(id: 'c1', label: 'Urgent', color: OiBadgeColor.error),
  OiChipFilter(id: 'c2', label: 'Normal'),
];

const _itemsWithChips = [
  _TestItem('1', 'Alpha', 'g1', chipIds: {'c1'}),
  _TestItem('2', 'Beta', 'g1', chipIds: {'c2'}),
  _TestItem('3', 'Gamma', 'g2', chipIds: {'c1', 'c2'}),
  _TestItem('4', 'Delta', 'g2', chipIds: {'c2'}),
];

// ── Helpers ─────────────────────────────────────────────────────────────────

Widget _buildList({
  List<_TestItem> items = _items,
  List<OiNavGroup> groups = _groups,
  String? selectedItemId,
  void Function(_TestItem)? onItemSelected,
  Widget? headerAction,
  Set<String>? itemLoadingIds,
  List<OiChipFilter>? chipFilters,
  Set<String> Function(_TestItem)? chipFilterOf,
}) {
  return SizedBox(
    width: 300,
    height: 600,
    child: OiFilterableNavList<_TestItem>(
      items: items,
      groups: groups,
      idOf: (i) => i.id,
      groupIdOf: (i) => i.groupId,
      titleOf: (i) => i.title,
      label: 'Test navigation',
      selectedItemId: selectedItemId,
      onItemSelected: onItemSelected,
      headerAction: headerAction,
      itemLoadingIds: itemLoadingIds,
      chipFilters: chipFilters,
      chipFilterOf: chipFilterOf,
    ),
  );
}

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('OiFilterableNavList', () {
    testWidgets('renders search input', (tester) async {
      await tester.pumpObers(_buildList());

      expect(find.byType(OiTextInput), findsOneWidget);
    });

    testWidgets('renders items grouped by group', (tester) async {
      await tester.pumpObers(_buildList());

      // Group headers
      expect(find.text('Group A'), findsOneWidget);
      expect(find.text('Group B'), findsOneWidget);

      // Items
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
      expect(find.text('Delta'), findsOneWidget);
    });

    testWidgets('filtering by search query hides non-matching items', (
      tester,
    ) async {
      await tester.pumpObers(_buildList());

      // All items visible initially.
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);

      // Type a query that only matches 'Alpha'.
      await tester.enterText(find.byType(EditableText), 'alph');
      await tester.pump();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsNothing);
      expect(find.text('Gamma'), findsNothing);
      expect(find.text('Delta'), findsNothing);
    });

    testWidgets('selected item is highlighted', (tester) async {
      await tester.pumpObers(_buildList(selectedItemId: '1'));

      // The selected item text should exist.
      expect(find.text('Alpha'), findsOneWidget);

      // Find the Container that wraps the selected item and verify
      // it has a non-null background color.
      final alphaText = find.text('Alpha');
      final container = find.ancestor(
        of: alphaText,
        matching: find.byType(Container),
      );
      expect(container, findsWidgets);

      // At least one Container ancestor should have a colored BoxDecoration.
      final containerWidget = tester.widgetList<Container>(container).where((
        c,
      ) {
        final dec = c.decoration;
        if (dec is BoxDecoration) {
          return dec.color != null;
        }
        return false;
      });
      expect(containerWidget, isNotEmpty);
    });

    testWidgets('tapping item fires onItemSelected', (tester) async {
      _TestItem? selected;
      await tester.pumpObers(
        _buildList(onItemSelected: (item) => selected = item),
      );

      await tester.tap(find.text('Gamma'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, '3');
      expect(selected!.title, 'Gamma');
    });

    testWidgets('header action renders when provided', (tester) async {
      await tester.pumpObers(
        _buildList(
          headerAction: const SizedBox(key: Key('header-action'), height: 32),
        ),
      );

      expect(find.byKey(const Key('header-action')), findsOneWidget);
    });

    testWidgets('loading items show spinner', (tester) async {
      await tester.pumpObers(_buildList(itemLoadingIds: {'2'}));

      // Item '2' (Beta) should show a progress indicator.
      expect(find.byType(OiProgress), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpObers(_buildList());

      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Test navigation',
      );
      expect(semantics, findsOneWidget);
    });

    testWidgets('renders without error with empty items', (tester) async {
      await tester.pumpObers(_buildList(items: const []));

      // Search input should still render.
      expect(find.byType(OiTextInput), findsOneWidget);

      // No items should be visible.
      expect(find.text('Alpha'), findsNothing);
    });

    testWidgets('chip filters toggle and narrow results', (tester) async {
      await tester.pumpObers(
        _buildList(
          items: _itemsWithChips,
          chipFilters: _chipFilters,
          chipFilterOf: (i) => i.chipIds,
        ),
      );

      // All items visible before any chip is active.
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
      expect(find.text('Delta'), findsOneWidget);

      // Tap the 'Urgent' chip filter.
      await tester.tap(find.text('Urgent'));
      await tester.pump();

      // Only items with 'c1' chip should remain.
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsNothing);
      expect(find.text('Gamma'), findsOneWidget);
      expect(find.text('Delta'), findsNothing);
    });

    testWidgets('collapsing group hides its items', (tester) async {
      await tester.pumpObers(_buildList());

      // Initially all items visible.
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);

      // Tap group header to collapse.
      await tester.tap(find.text('Group A'));
      await tester.pump();

      // Items in Group A should be hidden.
      expect(find.text('Alpha'), findsNothing);
      expect(find.text('Beta'), findsNothing);

      // Group B items should still be visible.
      expect(find.text('Gamma'), findsOneWidget);
      expect(find.text('Delta'), findsOneWidget);
    });
  });
}
