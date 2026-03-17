// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

import '../../../helpers/pump_app.dart';

/// Pumps [widget] with an explicit [MediaQuery] at the given [width].
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

  testWidgets('renders as Row by default', (tester) async {
    await tester.pumpObers(const OiRow(children: [Text('A'), Text('B')]));
    expect(find.byType(Row), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  // ── Gap spacing ────────────────────────────────────────────────────────────

  testWidgets('inserts SizedBox with correct width for gap', (tester) async {
    await tester.pumpObers(
      const OiRow(gap: 12, children: [Text('A'), Text('B'), Text('C')]),
    );
    // Two gaps for three children.
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final gapBoxes = boxes.where((b) => b.width == 12).toList();
    expect(gapBoxes, hasLength(2));
  });

  testWidgets('no SizedBox spacers when gap is 0', (tester) async {
    await tester.pumpObers(const OiRow(children: [Text('A'), Text('B')]));
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    expect(boxes.where((b) => b.width != null && b.width! > 0), isEmpty);
  });

  // ── Collapse ───────────────────────────────────────────────────────────────

  testWidgets('collapses to Column at compact breakpoint', (tester) async {
    // Compact width = 400dp, collapse threshold = medium (600dp).
    // 400 <= 600 → should collapse.
    await pumpAtWidth(
      tester,
      const OiRow(
        collapse: OiBreakpoint.medium,
        children: [Text('A'), Text('B')],
      ),
      400,
    );
    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Row), findsNothing);
  });

  testWidgets('does not collapse above collapse breakpoint', (tester) async {
    // Wide width = 900dp, breakpoint = expanded (840), collapse = medium (600).
    // expanded.minWidth (840) > medium.minWidth (600) → should NOT collapse.
    await pumpAtWidth(
      tester,
      const OiRow(
        collapse: OiBreakpoint.medium,
        children: [Text('A'), Text('B')],
      ),
      900,
    );
    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(Column), findsNothing);
  });

  testWidgets('collapsed layout uses height SizedBox spacers', (tester) async {
    await pumpAtWidth(
      tester,
      const OiRow(
        gap: 8,
        collapse: OiBreakpoint.medium,
        children: [Text('A'), Text('B')],
      ),
      400,
    );
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final heightBoxes = boxes.where((b) => b.height == 8).toList();
    expect(heightBoxes, hasLength(1));
  });
}
