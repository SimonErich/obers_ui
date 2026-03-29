// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/data/oi_table_controller.dart';
import 'package:obers_ui/src/models/settings/oi_table_settings.dart';

void main() {
  group('OiTableController', () {
    // ── Initial state ────────────────────────────────────────────────────────

    test('default constructor has expected initial values', () {
      final ctrl = OiTableController();
      expect(ctrl.sortColumnId, isNull);
      expect(ctrl.sortAscending, isTrue);
      expect(ctrl.selectedRows, isEmpty);
      expect(ctrl.selectAll, isFalse);
      expect(ctrl.activeFilters, isEmpty);
      expect(ctrl.columnVisibility, isEmpty);
      expect(ctrl.columnWidths, isEmpty);
      expect(ctrl.columnOrder, isEmpty);
      expect(ctrl.groupByColumnId, isNull);
      expect(ctrl.expandedGroups, isEmpty);
      expect(ctrl.frozenColumns, 0);
      expect(ctrl.showStatusBar, isTrue);
    });

    test('pageSize and totalRows are forwarded to pagination', () {
      final ctrl = OiTableController(pageSize: 10, totalRows: 100);
      expect(ctrl.pagination.pageSize, 10);
      expect(ctrl.pagination.totalItems, 100);
    });

    // ── Sort ─────────────────────────────────────────────────────────────────

    test('sortBy sets column and defaults to ascending', () {
      final ctrl = OiTableController()..sortBy('name');
      expect(ctrl.sortColumnId, 'name');
      expect(ctrl.sortAscending, isTrue);
    });

    test(
      'sortBy toggles direction when same column called without ascending',
      () {
        final ctrl = OiTableController()
          ..sortBy('name')
          ..sortBy('name');
        expect(ctrl.sortAscending, isFalse);
      },
    );

    test('sortBy resets to ascending when switching to a new column', () {
      final ctrl = OiTableController()
        ..sortBy('name')
        ..sortBy('name') // now descending
        ..sortBy('age'); // new column — should be ascending
      expect(ctrl.sortColumnId, 'age');
      expect(ctrl.sortAscending, isTrue);
    });

    test('sortBy with explicit ascending=false sets descending', () {
      final ctrl = OiTableController()..sortBy('id', ascending: false);
      expect(ctrl.sortAscending, isFalse);
    });

    test('sortBy notifies listeners', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..sortBy('id');
      expect(count, 1);
    });

    test('clearSort removes active sort', () {
      final ctrl = OiTableController()
        ..sortBy('name')
        ..clearSort();
      expect(ctrl.sortColumnId, isNull);
      expect(ctrl.sortAscending, isTrue);
    });

    test('clearSort does not notify when already unsorted', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..clearSort();
      expect(count, 0);
    });

    // ── Selection ─────────────────────────────────────────────────────────────

    test('selectRow adds key to selectedRows', () {
      final ctrl = OiTableController()..selectRow('k3');
      expect(ctrl.selectedRows, contains('k3'));
    });

    test('selectRow without multi clears previous selection', () {
      final ctrl = OiTableController()
        ..selectRow('k1')
        ..selectRow('k2');
      expect(ctrl.selectedRows, {'k2'});
    });

    test('selectRow with multi=true appends to selection', () {
      final ctrl = OiTableController()
        ..selectRow('k1')
        ..selectRow('k2', multi: true)
        ..selectRow('k3', multi: true);
      expect(ctrl.selectedRows, {'k1', 'k2', 'k3'});
    });

    test('selectRow notifies listeners', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..selectRow('k0');
      expect(count, 1);
    });

    test('deselectRow removes the key', () {
      final ctrl = OiTableController()
        ..selectRow('k5', multi: true)
        ..selectRow('k6', multi: true)
        ..deselectRow('k5');
      expect(ctrl.selectedRows, {'k6'});
    });

    test('deselectRow does not notify when key not selected', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..deselectRow('k99');
      expect(count, 0);
    });

    test('selectAllRows fills selectedRows with all provided keys', () {
      final ctrl = OiTableController()
        ..selectAllRows({'k0', 'k1', 'k2', 'k3', 'k4'});
      expect(ctrl.selectedRows, {'k0', 'k1', 'k2', 'k3', 'k4'});
      expect(ctrl.selectAll, isTrue);
    });

    test('clearSelection empties selectedRows', () {
      final ctrl = OiTableController()
        ..selectAllRows({'k0', 'k1', 'k2'})
        ..clearSelection();
      expect(ctrl.selectedRows, isEmpty);
      expect(ctrl.selectAll, isFalse);
    });

    test('clearSelection does not notify when already empty', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..clearSelection();
      expect(count, 0);
    });

    test('toggleRow adds unselected row to selection', () {
      final ctrl = OiTableController()
        ..selectRow('k0')
        ..toggleRow('k1');
      expect(ctrl.selectedRows, {'k0', 'k1'});
    });

    test('toggleRow removes already-selected row', () {
      final ctrl = OiTableController()
        ..selectRow('k0', multi: true)
        ..selectRow('k1', multi: true)
        ..toggleRow('k0');
      expect(ctrl.selectedRows, {'k1'});
    });

    test('toggleRow notifies listeners', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..toggleRow('k0');
      expect(count, 1);
    });

    test('selectRange selects exact key set', () {
      final ctrl = OiTableController()..selectRange({'k1', 'k2', 'k3', 'k4'});
      expect(ctrl.selectedRows, {'k1', 'k2', 'k3', 'k4'});
    });

    test('selectRange clears previous selection', () {
      final ctrl = OiTableController()
        ..selectRow('k10', multi: true)
        ..selectRange({'k0', 'k1', 'k2'});
      expect(ctrl.selectedRows, {'k0', 'k1', 'k2'});
    });

    test('selectRange notifies listeners', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..selectRange({'k0', 'k1', 'k2'});
      expect(count, 1);
    });

    // ── Filters ───────────────────────────────────────────────────────────────

    test('setFilter stores value and resets to page 0', () {
      final ctrl = OiTableController(pageSize: 10, totalRows: 100)
        ..pagination.goToPage(3)
        ..setFilter('name', 'Alice');
      expect(ctrl.activeFilters['name'], 'Alice');
      expect(ctrl.pagination.currentPage, 0);
    });

    test('setFilter notifies listeners', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..setFilter('col', 'val');
      expect(count, greaterThan(0));
    });

    test('clearFilter removes the entry', () {
      final ctrl = OiTableController()
        ..setFilter('name', 'Bob')
        ..clearFilter('name');
      expect(ctrl.activeFilters, isEmpty);
    });

    test('clearFilter does not notify when key absent', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..clearFilter('nonexistent');
      expect(count, 0);
    });

    test('clearAllFilters removes all entries', () {
      final ctrl = OiTableController()
        ..setFilter('a', '1')
        ..setFilter('b', '2')
        ..clearAllFilters();
      expect(ctrl.activeFilters, isEmpty);
    });

    test('clearAllFilters does not notify when already empty', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..clearAllFilters();
      expect(count, 0);
    });

    // ── Column management ─────────────────────────────────────────────────────

    test('setColumnVisible stores visibility flag', () {
      final ctrl = OiTableController()..setColumnVisible('col', visible: false);
      expect(ctrl.columnVisibility['col'], isFalse);
    });

    test('setColumnVisible does not notify when value unchanged', () {
      final ctrl = OiTableController()..setColumnVisible('col', visible: false);
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..setColumnVisible('col', visible: false);
      expect(count, 0);
    });

    test('setColumnWidth stores width', () {
      final ctrl = OiTableController()..setColumnWidth('col', 120);
      expect(ctrl.columnWidths['col'], 120);
    });

    test('setColumnWidth does not notify when value unchanged', () {
      final ctrl = OiTableController()..setColumnWidth('col', 100);
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..setColumnWidth('col', 100);
      expect(count, 0);
    });

    test('reorderColumns moves item to new position', () {
      final ctrl = OiTableController()
        ..columnOrder.addAll(['a', 'b', 'c', 'd'])
        ..reorderColumns(0, 3); // move 'a' after 'b','c'
      expect(ctrl.columnOrder, ['b', 'c', 'a', 'd']);
    });

    test('reorderColumns does not notify when oldIndex == newIndex', () {
      final ctrl = OiTableController()..columnOrder.addAll(['a', 'b']);
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..reorderColumns(0, 0);
      expect(count, 0);
    });

    test('resetColumns clears order, visibility, and widths', () {
      final ctrl = OiTableController()
        ..columnOrder.addAll(['a', 'b'])
        ..setColumnVisible('a', visible: false)
        ..setColumnWidth('b', 80)
        ..resetColumns();
      expect(ctrl.columnOrder, isEmpty);
      expect(ctrl.columnVisibility, isEmpty);
      expect(ctrl.columnWidths, isEmpty);
    });

    // ── Grouping ──────────────────────────────────────────────────────────────

    test('groupBy sets the groupByColumnId', () {
      final ctrl = OiTableController()..groupBy('category');
      expect(ctrl.groupByColumnId, 'category');
    });

    test('groupBy clears expandedGroups', () {
      final ctrl = OiTableController()
        ..groupBy('cat')
        ..toggleGroup('A')
        ..groupBy('other');
      expect(ctrl.expandedGroups, isEmpty);
    });

    test('groupBy with null clears grouping', () {
      final ctrl = OiTableController()
        ..groupBy('cat')
        ..groupBy(null);
      expect(ctrl.groupByColumnId, isNull);
    });

    test('groupBy does not notify when value unchanged', () {
      final ctrl = OiTableController()..groupBy('cat');
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..groupBy('cat');
      expect(count, 0);
    });

    test('toggleGroup expands a collapsed group', () {
      final ctrl = OiTableController()..toggleGroup('G1');
      expect(ctrl.expandedGroups, contains('G1'));
    });

    test('toggleGroup collapses an expanded group', () {
      final ctrl = OiTableController()
        ..toggleGroup('G1')
        ..toggleGroup('G1');
      expect(ctrl.expandedGroups, isNot(contains('G1')));
    });

    test('toggleGroup notifies listeners', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..toggleGroup('G1');
      expect(count, 1);
    });

    // ── Frozen columns ──────────────────────────────────────────────────────

    test('setFrozenColumns stores the count', () {
      final ctrl = OiTableController()..setFrozenColumns(3);
      expect(ctrl.frozenColumns, 3);
    });

    test('setFrozenColumns notifies listeners', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..setFrozenColumns(2);
      expect(count, 1);
    });

    test('setFrozenColumns does not notify when value unchanged', () {
      final ctrl = OiTableController()..setFrozenColumns(1);
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..setFrozenColumns(1);
      expect(count, 0);
    });

    // ── Status bar ────────────────────────────────────────────────────────

    test('setShowStatusBar stores the flag', () {
      final ctrl = OiTableController()..setShowStatusBar(visible: false);
      expect(ctrl.showStatusBar, isFalse);
    });

    test('setShowStatusBar notifies listeners', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..setShowStatusBar(visible: false);
      expect(count, 1);
    });

    test('setShowStatusBar does not notify when value unchanged', () {
      final ctrl = OiTableController();
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..setShowStatusBar(visible: true); // default is true
      expect(count, 0);
    });

    // ── toSettings / applySettings round-trip ─────────────────────────────────

    test('toSettings captures current controller state', () {
      final ctrl = OiTableController(pageSize: 10, totalRows: 100)
        ..columnOrder.addAll(['a', 'b'])
        ..setColumnVisible('b', visible: false)
        ..setColumnWidth('a', 120)
        ..sortBy('a', ascending: false)
        ..setFilter('b', 'foo')
        ..groupBy('a')
        ..toggleGroup('G1')
        ..toggleGroup('G2')
        ..setFrozenColumns(2)
        ..setShowStatusBar(visible: false)
        ..pagination.goToPage(2);
      final settings = ctrl.toSettings();
      expect(settings.columnOrder, ['a', 'b']);
      expect(settings.columnVisibility, {'b': false});
      expect(settings.columnWidths, {'a': 120});
      expect(settings.sortColumnId, 'a');
      expect(settings.sortAscending, isFalse);
      expect(settings.activeFilters, {'b': 'foo'});
      expect(settings.groupByColumnId, 'a');
      expect(settings.pageSize, 10);
      expect(settings.pageIndex, 2);
      expect(settings.frozenColumns, 2);
      expect(settings.showStatusBar, isFalse);
      expect(settings.expandedGroups, {'G1', 'G2'});
    });

    test('applySettings restores controller state', () {
      const settings = OiTableSettings(
        columnOrder: ['x', 'y'],
        columnVisibility: {'y': false},
        columnWidths: {'x': 200},
        sortColumnId: 'x',
        sortAscending: false,
        activeFilters: {'x': 'hello'},
        pageSize: 20,
        pageIndex: 1,
        groupByColumnId: 'y',
        frozenColumns: 3,
        showStatusBar: false,
        expandedGroups: {'G1', 'G2'},
      );
      final ctrl = OiTableController(totalRows: 100)..applySettings(settings);
      expect(ctrl.columnOrder, ['x', 'y']);
      expect(ctrl.columnVisibility, {'y': false});
      expect(ctrl.columnWidths, {'x': 200});
      expect(ctrl.sortColumnId, 'x');
      expect(ctrl.sortAscending, isFalse);
      expect(ctrl.activeFilters, {'x': 'hello'});
      expect(ctrl.groupByColumnId, 'y');
      expect(ctrl.pagination.pageSize, 20);
      expect(ctrl.pagination.currentPage, 1);
      expect(ctrl.frozenColumns, 3);
      expect(ctrl.showStatusBar, isFalse);
      expect(ctrl.expandedGroups, {'G1', 'G2'});
    });

    test('toSettings / applySettings round-trip is lossless', () {
      final original = OiTableController(pageSize: 5, totalRows: 50)
        ..columnOrder.addAll(['id', 'name'])
        ..sortBy('name')
        ..setFilter('id', '42')
        ..setFrozenColumns(1)
        ..setShowStatusBar(visible: false)
        ..groupBy('name')
        ..toggleGroup('A')
        ..toggleGroup('B');
      final settings = original.toSettings();

      final restored = OiTableController(totalRows: 50)
        ..applySettings(settings);
      expect(restored.toSettings(), equals(settings));
    });

    // ── Pagination delegation ─────────────────────────────────────────────────

    test('pagination change notifies table controller listeners', () {
      final ctrl = OiTableController(pageSize: 10, totalRows: 100);
      var count = 0;
      ctrl.addListener(() => count++);
      ctrl.pagination.nextPage();
      expect(count, 1);
    });

    // ── dispose ───────────────────────────────────────────────────────────────

    test('dispose does not throw', () {
      final ctrl = OiTableController();
      expect(ctrl.dispose, returnsNormally);
    });
  });
}
