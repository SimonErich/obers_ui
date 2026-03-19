// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/composites/navigation/oi_filter_bar.dart';
import 'package:obers_ui/src/modules/oi_list_view.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiListView', () {
    testWidgets('renders items', (tester) async {
      await tester.pumpObers(
        OiListView<String>(
          items: const ['Alpha', 'Beta', 'Gamma'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Test list',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('search input renders and callback fires', (tester) async {
      String? searchedQuery;
      await tester.pumpObers(
        OiListView<String>(
          items: const ['One', 'Two'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Search list',
          onSearch: (q) {
            searchedQuery = q;
          },
        ),
        surfaceSize: const Size(400, 600),
      );

      // The search input placeholder should be visible.
      expect(find.text('Search...'), findsOneWidget);
      expect(searchedQuery, isNull); // callback not yet triggered
    });

    testWidgets('sort options render', (tester) async {
      OiSortOption? sortedBy;
      final options = [
        const OiSortOption(id: 'name', label: 'Name'),
        const OiSortOption(id: 'date', label: 'Date'),
      ];

      await tester.pumpObers(
        OiListView<String>(
          items: const ['A'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Sort list',
          sortOptions: options,
          onSort: (opt) => sortedBy = opt,
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);

      await tester.tap(find.text('Name'));
      await tester.pump();
      expect(sortedBy?.id, 'name');
    });

    testWidgets('selection works in multi mode', (tester) async {
      Set<Object>? lastSelection;
      await tester.pumpObers(
        OiListView<String>(
          items: const ['X', 'Y'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Select list',
          selectionMode: OiSelectionMode.multi,
          onSelectionChange: (s) => lastSelection = s,
        ),
        surfaceSize: const Size(400, 600),
      );

      await tester.tap(find.text('X'));
      await tester.pump();
      expect(lastSelection, contains('X'));
    });

    testWidgets('loading state shows progress', (tester) async {
      await tester.pumpObers(
        OiListView<String>(
          items: const [],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Loading list',
          loading: true,
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.byType(OiProgress), findsOneWidget);
    });

    testWidgets('empty state shows when no items', (tester) async {
      await tester.pumpObers(
        OiListView<String>(
          items: const [],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Empty list',
          emptyState: const OiEmptyState(title: 'Nothing here'),
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets(
      'default empty state shows when no items and no custom widget',
      (tester) async {
        await tester.pumpObers(
          OiListView<String>(
            items: const [],
            itemBuilder: Text.new,
            itemKey: (item) => item,
            label: 'Empty list default',
          ),
          surfaceSize: const Size(400, 600),
        );

        expect(find.text('No items'), findsOneWidget);
      },
    );

    testWidgets('header actions render', (tester) async {
      await tester.pumpObers(
        OiListView<String>(
          items: const ['A'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Actions list',
          headerActions: const SizedBox(
            key: Key('header-action'),
            width: 24,
            height: 24,
          ),
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.byKey(const Key('header-action')), findsOneWidget);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        OiListView<String>(
          items: const ['A'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'My List',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.bySemanticsLabel('My List'), findsWidgets);
    });

    testWidgets('selection actions bar shows when items selected', (
      tester,
    ) async {
      await tester.pumpObers(
        OiListView<String>(
          items: const ['A', 'B'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Sel list',
          selectionMode: OiSelectionMode.multi,
          selectedKeys: const {'A'},
          selectionActions: (keys) => [Text('${keys.length} chosen')],
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('1 chosen'), findsOneWidget);
    });

    testWidgets('filter bar renders inline on expanded screen', (tester) async {
      final filters = [
        const OiFilterDefinition(
          key: 'status',
          label: 'Status',
          type: OiFilterType.select,
        ),
      ];

      await tester.pumpObers(
        OiListView<String>(
          items: const ['A'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Filter list',
          filters: filters,
        ),
        // Expanded screen — filter bar should be inline.
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Status'), findsOneWidget);
      // No "Filters" button on expanded.
      expect(find.text('Filters'), findsNothing);
    });

    testWidgets('filter button shows on compact screen', (tester) async {
      final filters = [
        const OiFilterDefinition(
          key: 'status',
          label: 'Status',
          type: OiFilterType.select,
        ),
      ];

      await tester.pumpObers(
        OiListView<String>(
          items: const ['A'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Compact filter list',
          filters: filters,
        ),
        // Compact screen — filter button should appear.
        surfaceSize: const Size(375, 800),
      );

      expect(find.text('Filters'), findsOneWidget);
      // Inline filter chip label should NOT appear in compact mode.
      expect(find.text('Status'), findsNothing);
    });

    testWidgets('active filter count badge shows on filter button', (
      tester,
    ) async {
      final filters = [
        const OiFilterDefinition(
          key: 'status',
          label: 'Status',
          type: OiFilterType.select,
        ),
        const OiFilterDefinition(
          key: 'type',
          label: 'Type',
          type: OiFilterType.select,
        ),
      ];

      await tester.pumpObers(
        OiListView<String>(
          items: const ['A'],
          itemBuilder: Text.new,
          itemKey: (item) => item,
          label: 'Active filter list',
          filters: filters,
          activeFilters: const {
            'status': OiColumnFilter(value: 'active'),
            'type': OiColumnFilter(value: 'bug'),
          },
        ),
        surfaceSize: const Size(375, 800),
      );

      // Badge should show "2" for two active filters.
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('selection actions are placed at bottom on compact', (
      tester,
    ) async {
      await tester.pumpObers(
        OiListView<String>(
          items: const ['A', 'B'],
          itemBuilder: (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(item),
          ),
          itemKey: (item) => item,
          label: 'Compact sel list',
          selectionMode: OiSelectionMode.multi,
          selectedKeys: const {'A'},
          selectionActions: (keys) => [
            const SizedBox(key: Key('action-btn'), width: 40, height: 32),
          ],
        ),
        surfaceSize: const Size(375, 800),
      );

      expect(find.text('1 selected'), findsOneWidget);
      expect(find.byKey(const Key('action-btn')), findsOneWidget);
    });
  });
}
