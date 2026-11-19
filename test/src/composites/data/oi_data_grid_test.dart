// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/composites/data/oi_data_grid.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Widget grid({void Function(String row, int index)? onRowTap}) => SizedBox(
    width: 600,
    height: 400,
    child: OiDataGrid<String>(
      rows: const ['Alice', 'Bob'],
      columns: [
        OiDataGridColumn<String>.text(
          id: 'name',
          header: 'Name',
          valueOf: (row) => row,
        ),
        OiDataGridColumn<String>(
          id: 'actions',
          header: 'Actions',
          cellBuilder: (_, row, _) =>
              OiButton.primary(label: 'Edit $row', onTap: () {}),
        ),
      ],
      onRowTap: onRowTap,
    ),
  );

  testWidgets('onRowTap fires with the row and its index', (tester) async {
    final taps = <(String, int)>[];
    await tester.pumpObers(
      grid(onRowTap: (row, index) => taps.add((row, index))),
      surfaceSize: const Size(600, 400),
    );

    await tester.tap(find.text('Bob'));
    expect(taps, [('Bob', 1)]);
  });

  testWidgets('a tappable row announces its cells and keeps their controls', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(
      grid(onRowTap: (_, _) {}),
      surfaceSize: const Size(600, 400),
    );

    final row = tester.getSemantics(find.text('Alice'));
    expect(row.label, 'Row 1\nAlice');
    expect(row, isSemantics(isButton: true, hasTapAction: true));
    expect(find.bySemanticsLabel('Edit Alice'), findsOneWidget);
    handle.dispose();
  });
}
