// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

import '../../../helpers/pump_app.dart';

Future<void> pumpAtWidth(
  WidgetTester tester,
  Widget widget,
  double width,
) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OiTheme(data: OiThemeData.light(), child: widget),
      ),
    ),
  );
}

void main() {
  // ── Basic rendering ────────────────────────────────────────────────────────

  testWidgets('renders as Column by default', (tester) async {
    await tester.pumpObers(const OiColumn(children: [Text('A'), Text('B')]));
    expect(find.byType(Column), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  // ── Gap spacing ────────────────────────────────────────────────────────────

  testWidgets('inserts SizedBox with correct height for gap', (tester) async {
    await tester.pumpObers(
      const OiColumn(gap: 16, children: [Text('A'), Text('B'), Text('C')]),
    );
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final gapBoxes = boxes.where((b) => b.height == 16).toList();
    expect(gapBoxes, hasLength(2));
  });

  testWidgets('no SizedBox spacers when gap is 0', (tester) async {
    await tester.pumpObers(const OiColumn(children: [Text('A'), Text('B')]));
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    expect(boxes.where((b) => b.height != null && b.height! > 0), isEmpty);
  });

  // ── Collapse (expand to Row) ───────────────────────────────────────────────

  testWidgets('expands to Row at or above collapse breakpoint', (tester) async {
    // Width 900dp → expanded breakpoint (minWidth=840) >= medium (600) → Row.
    await pumpAtWidth(
      tester,
      const OiColumn(
        collapse: OiBreakpoint.medium,
        children: [Text('A'), Text('B')],
      ),
      900,
    );
    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(Column), findsNothing);
  });

  testWidgets('stays as Column below collapse breakpoint', (tester) async {
    // Width 400dp → compact breakpoint (minWidth=0) < medium (600) → Column.
    await pumpAtWidth(
      tester,
      const OiColumn(
        collapse: OiBreakpoint.medium,
        children: [Text('A'), Text('B')],
      ),
      400,
    );
    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Row), findsNothing);
  });

  testWidgets('expanded layout uses width SizedBox spacers', (tester) async {
    await pumpAtWidth(
      tester,
      const OiColumn(
        gap: 10,
        collapse: OiBreakpoint.medium,
        children: [Text('A'), Text('B')],
      ),
      900,
    );
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final widthBoxes = boxes.where((b) => b.width == 10).toList();
    expect(widthBoxes, hasLength(1));
  });
}
