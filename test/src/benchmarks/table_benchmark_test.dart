// Test helpers do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

/// Simple row model for benchmark tests.
class _BenchmarkRow {
  const _BenchmarkRow({required this.id, required this.name, required this.value});

  final int id;
  final String name;
  final String value;
}

void main() {
  group('OiTable benchmark (REQ-0176)', () {
    const rowCount = 10000;

    final rows = List<_BenchmarkRow>.generate(
      rowCount,
      (i) => _BenchmarkRow(
        id: i,
        name: 'Row $i',
        value: 'Value ${i % 100}',
      ),
    );

    final columns = <OiTableColumn<_BenchmarkRow>>[
      OiTableColumn<_BenchmarkRow>(
        id: 'id',
        header: 'ID',
        valueGetter: (r) => r.id.toString(),
        comparator: (a, b) => a.id.compareTo(b.id),
      ),
      OiTableColumn<_BenchmarkRow>(
        id: 'name',
        header: 'Name',
        valueGetter: (r) => r.name,
      ),
      OiTableColumn<_BenchmarkRow>(
        id: 'value',
        header: 'Value',
        valueGetter: (r) => r.value,
      ),
    ];

    testWidgets('renders 10k rows without errors', (tester) async {
      await tester.pumpObers(
        OiTable<_BenchmarkRow>(
          label: 'Benchmark table',
          rows: rows,
          columns: columns,
        ),
        surfaceSize: const Size(1000, 800),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(OiTable<_BenchmarkRow>), findsOneWidget);
    });

    testWidgets('sorts 10k rows by column', (tester) async {
      final controller = OiTableController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        OiTable<_BenchmarkRow>(
          label: 'Benchmark table',
          rows: rows,
          columns: columns,
          controller: controller,
        ),
        surfaceSize: const Size(1000, 800),
      );

      // Sort ascending by name.
      controller.sortBy('name', ascending: true);
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Sort descending by name.
      controller.sortBy('name', ascending: false);
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Sort by ID ascending.
      controller.sortBy('id', ascending: true);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('filters 10k rows by column value', (tester) async {
      final controller = OiTableController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        OiTable<_BenchmarkRow>(
          label: 'Benchmark table',
          rows: rows,
          columns: columns,
          controller: controller,
        ),
        surfaceSize: const Size(1000, 800),
      );

      // Apply filter on the value column.
      controller.activeFilters['value'] = 'Value 42';
      controller.notifyListeners();
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Clear filter.
      controller.activeFilters.clear();
      controller.notifyListeners();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
