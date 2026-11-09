import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shrink-wrapped tables fit short pages and scroll longer pages', (
    tester,
  ) async {
    Future<void> pump(List<String> rows) async {
      await tester.pumpObers(
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 500),
            child: OiTable<String>(
              label: 'Notes',
              shrinkWrap: true,
              rows: rows,
              showStatusBar: false,
              rowHeight: 40,
              columns: [
                OiTableColumn(
                  id: 'name',
                  header: 'Name',
                  valueGetter: (row) => row,
                ),
              ],
            ),
          ),
        ),
        surfaceSize: const Size(800, 700),
      );
      await tester.pumpAndSettle();
    }

    await pump(['One', 'Two']);
    expect(tester.getSize(find.byType(OiTable<String>)).height, lessThan(200));
    expect(find.text('Two').hitTestable(), findsOneWidget);
    await pump(List.generate(30, (index) => 'Row $index'));
    expect(tester.getSize(find.byType(OiTable<String>)).height, 300);
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('Row 29').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changed preset column widths keep headers and cells aligned', (
    tester,
  ) async {
    Future<void> pump(double firstWidth) async {
      await tester.pumpObers(
        SizedBox(
          width: 600,
          height: 250,
          child: OiTable<String>(
            label: 'Orders',
            rows: const ['A'],
            showStatusBar: false,
            columns: [
              OiTableColumn(
                id: 'first',
                header: 'First',
                width: firstWidth,
                valueGetter: (_) => 'First cell',
              ),
              OiTableColumn(
                id: 'second',
                header: 'Second',
                width: 160,
                valueGetter: (_) => 'Second cell',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pump(220);
    final before = tester.getTopLeft(find.text('Second')).dx;
    await pump(140);
    expect(tester.getTopLeft(find.text('Second')).dx, before - 80);
    expect(
      tester.getTopLeft(find.text('Second')).dx,
      tester.getTopLeft(find.text('Second cell')).dx,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('row selection exposes labels and mixed header state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = OiTableController();
    await tester.pumpObers(
      OiTable<String>(
        label: 'Customers',
        rows: const ['Alice', 'Bob'],
        controller: controller,
        selectable: true,
        multiSelect: true,
        rowKey: (row) => row,
        columns: [
          OiTableColumn(id: 'name', header: 'Name', valueGetter: (row) => row),
        ],
        labels: OiTableLabels(selectRow: (index) => 'Choose customer $index'),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Choose customer 1'));
    await tester.pump();
    expect(controller.selectedRows, {'Alice'});
    final header = tester.widget<OiCheckbox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is OiCheckbox && widget.semanticLabel == 'Select all',
      ),
    );
    expect(header.value, isNull);
    await tester.tap(find.bySemanticsLabel('Choose customer 2'));
    await tester.pump();
    expect(controller.selectedRows, {'Alice', 'Bob'});
    expect(
      tester
          .widget<OiCheckbox>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is OiCheckbox && widget.semanticLabel == 'Select all',
            ),
          )
          .value,
      isTrue,
    );
    semantics.dispose();
    controller.dispose();
  });
  testWidgets('table forwards localized footer and column labels', (
    tester,
  ) async {
    await tester.pumpObers(
      OiTable<String>(
        label: 'Customers',
        showColumnManager: true,
        paginationMode: OiTablePaginationMode.pages,
        rows: const ['A', 'B'],
        columns: [
          OiTableColumn(id: 'name', header: 'Name', valueGetter: (row) => row),
        ],
        labels: OiTableLabels(
          columns: 'Spalten',
          manageColumns: 'Spalten verwalten',
          rows: 'Zeilen',
          pagination: OiPaginationLabels(
            perPage: 'Pro Seite:',
            total: (start, end, total, _) => '$start–$end von $total',
          ),
        ),
      ),
      surfaceSize: const Size(1200, 600),
    );
    expect(find.text('Spalten'), findsOneWidget);
    expect(find.text('Pro Seite:'), findsOneWidget);
    expect(find.text('1–2 von 2'), findsOneWidget);
  });
  testWidgets('load more exposes host translated labels', (tester) async {
    await tester.pumpObers(
      OiPagination.loadMore(
        totalItems: 10,
        loadedCount: 2,
        label: 'rows',
        labels: OiPaginationLabels(
          loadMore: 'Mehr laden',
          loadedProgress: (loaded, total, _) => '$loaded von $total',
        ),
        onLoadMore: () {},
      ),
      surfaceSize: const Size(1200, 600),
    );
    expect(find.text('Mehr laden'), findsOneWidget);
    expect(find.text('2 von 10'), findsOneWidget);
  });
}
