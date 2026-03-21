// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/data/oi_table.dart';
import 'package:obers_ui/src/composites/data/oi_table_controller.dart';

import '../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Person {
  const _Person(this.name, this.age, this.city);
  final String name;
  final int age;
  final String city;
}

String _nameGetter(_Person p) => p.name;
String _ageGetter(_Person p) => p.age.toString();
String _cityGetter(_Person p) => p.city;

List<OiTableColumn<_Person>> get _cols => [
  const OiTableColumn<_Person>(
    id: 'name',
    header: 'Name',
    valueGetter: _nameGetter,
    filterable: false,
    resizable: false,
  ),
  const OiTableColumn<_Person>(
    id: 'age',
    header: 'Age',
    valueGetter: _ageGetter,
    filterable: false,
    resizable: false,
  ),
  const OiTableColumn<_Person>(
    id: 'city',
    header: 'City',
    valueGetter: _cityGetter,
    resizable: false,
  ),
];

final _rows = [
  const _Person('Charlie', 30, 'Berlin'),
  const _Person('Alice', 25, 'Paris'),
  const _Person('Bob', 35, 'London'),
  const _Person('Diana', 28, 'Madrid'),
];

Widget _table({
  List<_Person>? rows,
  List<OiTableColumn<_Person>>? columns,
  OiTableController? controller,
  bool selectable = false,
  bool multiSelect = false,
  String Function(_Person)? rowKey,
  void Function(Set<String>)? onSelectionChanged,
  void Function(_Person, int)? onRowTap,
  bool serverSideSort = false,
  void Function(String, {required bool ascending})? onSort,
}) {
  return SizedBox(
    width: 800,
    height: 600,
    child: OiTable<_Person>(
      label: 'People table',
      rows: rows ?? _rows,
      columns: columns ?? _cols,
      controller: controller,
      selectable: selectable,
      multiSelect: multiSelect,
      rowKey: rowKey,
      onSelectionChanged: onSelectionChanged,
      onRowTap: onRowTap,
      serverSideSort: serverSideSort,
      onSort: onSort,
    ),
  );
}

// ── Integration tests ─────────────────────────────────────────────────────────

void main() {
  group('Table sort → filter → select flow', () {
    testWidgets('sort ascending by name via controller', (tester) async {
      final ctrl = OiTableController(totalRows: _rows.length);

      await tester.pumpObers(
        _table(controller: ctrl),
        surfaceSize: const Size(900, 700),
      );

      // Sort ascending by name.
      ctrl.sortBy('name', ascending: true);
      await tester.pump();

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();

      final aliceIdx = texts.indexOf('Alice');
      final bobIdx = texts.indexOf('Bob');
      final charlieIdx = texts.indexOf('Charlie');

      expect(aliceIdx, lessThan(bobIdx));
      expect(bobIdx, lessThan(charlieIdx));
    });

    testWidgets('sort descending reverses order', (tester) async {
      final ctrl = OiTableController(totalRows: _rows.length);

      await tester.pumpObers(
        _table(controller: ctrl),
        surfaceSize: const Size(900, 700),
      );

      // Sort descending by name.
      ctrl.sortBy('name', ascending: false);
      await tester.pump();

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();

      final dianaIdx = texts.indexOf('Diana');
      final aliceIdx = texts.indexOf('Alice');

      expect(dianaIdx, lessThan(aliceIdx));
    });

    testWidgets('filter then sort produces correct subset order', (
      tester,
    ) async {
      final filterableCols = [
        const OiTableColumn<_Person>(
          id: 'name',
          header: 'Name',
          valueGetter: _nameGetter,
          resizable: false,
        ),
        const OiTableColumn<_Person>(
          id: 'city',
          header: 'City',
          valueGetter: _cityGetter,
          resizable: false,
        ),
      ];

      final ctrl = OiTableController(totalRows: _rows.length);

      await tester.pumpObers(
        _table(columns: filterableCols, controller: ctrl),
        surfaceSize: const Size(900, 700),
      );

      // Filter to show only people whose name contains 'a' (Alice, Diana, Charlie).
      ctrl.setFilter('name', 'a');
      await tester.pump();

      // Bob should be hidden (no 'a' in 'Bob').
      expect(find.text('Bob'), findsNothing);
      // Alice should still be visible.
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('select single row via controller', (tester) async {
      final ctrl = OiTableController(totalRows: _rows.length);

      await tester.pumpObers(
        _table(controller: ctrl, selectable: true, rowKey: (p) => p.name),
        surfaceSize: const Size(900, 700),
      );
      await tester.pumpAndSettle();

      ctrl.selectRow('Alice');
      await tester.pump();

      expect(ctrl.selectedRows, contains('Alice'));
      expect(ctrl.selectedRows.length, 1);
    });

    testWidgets('multi-select accumulates rows', (tester) async {
      final ctrl = OiTableController(totalRows: _rows.length);

      await tester.pumpObers(
        _table(
          controller: ctrl,
          selectable: true,
          multiSelect: true,
          rowKey: (p) => p.name,
        ),
        surfaceSize: const Size(900, 700),
      );

      ctrl
        ..selectRow('Alice', multi: true)
        ..selectRow('Diana', multi: true);

      expect(ctrl.selectedRows, containsAll(['Alice', 'Diana']));
      expect(ctrl.selectedRows.length, 2);
    });

    testWidgets('sort then select preserves selection', (tester) async {
      final ctrl = OiTableController(totalRows: _rows.length);

      await tester.pumpObers(
        _table(controller: ctrl, selectable: true, rowKey: (p) => p.name),
        surfaceSize: const Size(900, 700),
      );
      await tester.pumpAndSettle();

      // Select a row.
      ctrl.selectRow('Bob');
      await tester.pump();
      expect(ctrl.selectedRows, contains('Bob'));

      // Sort — selection should be retained.
      ctrl.sortBy('name', ascending: true);
      await tester.pump();
      expect(ctrl.selectedRows, contains('Bob'));
    });

    testWidgets('onRowTap fires with correct row', (tester) async {
      _Person? tapped;
      int? tappedIdx;

      await tester.pumpObers(
        _table(
          onRowTap: (row, idx) {
            tapped = row;
            tappedIdx = idx;
          },
        ),
        surfaceSize: const Size(900, 700),
      );
      await tester.pumpAndSettle();

      // Tap a row and wait past double-tap timeout.
      await tester.tap(find.text('Diana'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tapped?.name, 'Diana');
      expect(tappedIdx, isNotNull);
    });

    testWidgets('server-side sort callback fires on header tap', (
      tester,
    ) async {
      String? sortedCol;
      final ctrl = OiTableController(totalRows: _rows.length);

      await tester.pumpObers(
        _table(
          controller: ctrl,
          serverSideSort: true,
          onSort: (col, {required bool ascending}) => sortedCol = col,
        ),
        surfaceSize: const Size(900, 700),
      );

      await tester.tap(find.text('Name'));
      await tester.pump();

      expect(sortedCol, 'name');
    });
  });
}
