// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_heatmap.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _cells = [
  OiHeatmapCell(row: 0, column: 0, value: 10),
  OiHeatmapCell(row: 0, column: 1, value: 50),
  OiHeatmapCell(row: 1, column: 0, value: 30),
  OiHeatmapCell(row: 1, column: 1, value: 90),
];

Widget _heatmap({
  List<OiHeatmapCell> cells = _cells,
  String label = 'Test Heatmap',
  List<String>? rowLabels,
  List<String>? columnLabels,
  double? minValue,
  double? maxValue,
  Color? lowColor,
  Color? highColor,
  bool showValues = true,
  ValueChanged<OiHeatmapCell>? onCellTap,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: OiHeatmap(
      cells: cells,
      label: label,
      rowLabels: rowLabels,
      columnLabels: columnLabels,
      minValue: minValue,
      maxValue: maxValue,
      lowColor: lowColor,
      highColor: highColor,
      showValues: showValues,
      onCellTap: onCellTap,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Renders without errors.
  testWidgets('renders without errors', (tester) async {
    await tester.pumpObers(_heatmap());
    expect(find.byType(OiHeatmap), findsOneWidget);
  });

  // 2. Data displays correctly — cell widgets present.
  testWidgets('renders cell widgets', (tester) async {
    await tester.pumpObers(_heatmap());
    expect(find.byKey(const Key('oi_heatmap_cell_0_0')), findsOneWidget);
    expect(find.byKey(const Key('oi_heatmap_cell_0_1')), findsOneWidget);
    expect(find.byKey(const Key('oi_heatmap_cell_1_0')), findsOneWidget);
    expect(find.byKey(const Key('oi_heatmap_cell_1_1')), findsOneWidget);
  });

  // 3. Labels render — row and column labels shown.
  testWidgets('displays row and column labels', (tester) async {
    await tester.pumpObers(
      _heatmap(
        rowLabels: const ['Mon', 'Tue'],
        columnLabels: const ['AM', 'PM'],
      ),
    );
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Tue'), findsOneWidget);
    expect(find.text('AM'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
  });

  // 4. Custom colors applied.
  testWidgets('renders with custom low and high colors', (tester) async {
    await tester.pumpObers(
      _heatmap(
        lowColor: const Color(0xFF0000FF),
        highColor: const Color(0xFFFF0000),
      ),
    );
    expect(find.byType(OiHeatmap), findsOneWidget);
  });

  // 5. onCellTap fires.
  testWidgets('onCellTap fires with correct cell', (tester) async {
    OiHeatmapCell? tappedCell;
    await tester.pumpObers(_heatmap(onCellTap: (cell) => tappedCell = cell));
    await tester.tap(find.byKey(const Key('oi_heatmap_cell_1_0')));
    await tester.pump();
    expect(tappedCell?.row, 1);
    expect(tappedCell?.column, 0);
    expect(tappedCell?.value, 30);
  });

  // 6. Empty data handles gracefully.
  testWidgets('handles empty cells gracefully', (tester) async {
    await tester.pumpObers(_heatmap(cells: const []));
    expect(find.byType(OiHeatmap), findsOneWidget);
    expect(find.byKey(const Key('oi_heatmap_empty')), findsOneWidget);
  });

  // 7. Semantics label present.
  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_heatmap(label: 'Activity Map'));
    final semantics = tester.getSemantics(find.byType(OiHeatmap));
    expect(semantics.label, contains('Activity Map'));
  });

  // 8. Size adapts to container.
  testWidgets('adapts to container width', (tester) async {
    await tester.pumpObers(_heatmap());
    expect(find.byKey(const Key('oi_heatmap')), findsOneWidget);
  });

  // 9. showValues displays cell values.
  testWidgets('shows values when showValues is true', (tester) async {
    await tester.pumpObers(_heatmap());
    expect(find.text('10'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
  });

  // 10. showValues false hides values.
  testWidgets('hides values when showValues is false', (tester) async {
    await tester.pumpObers(_heatmap(showValues: false));
    expect(find.text('10'), findsNothing);
    expect(find.text('50'), findsNothing);
  });

  // 11. Custom minValue/maxValue.
  testWidgets('renders with custom minValue and maxValue', (tester) async {
    await tester.pumpObers(_heatmap(minValue: 0, maxValue: 200));
    expect(find.byType(OiHeatmap), findsOneWidget);
  });

  // 12. onCellTap null does not throw.
  testWidgets('tapping cell without onCellTap does not throw', (tester) async {
    await tester.pumpObers(_heatmap());
    await tester.tap(find.byKey(const Key('oi_heatmap_cell_0_0')));
    await tester.pump();
    expect(find.byType(OiHeatmap), findsOneWidget);
  });

  // REQ-0025: color is never the sole indicator — showValues defaults to true.
  testWidgets('REQ-0025: showValues defaults to true', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 400,
        height: 300,
        child: OiHeatmap(cells: _cells, label: 'Default values'),
      ),
    );
    // Values should be visible by default.
    expect(find.text('10'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
  });
}
