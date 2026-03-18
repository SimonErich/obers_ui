// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/layout/oi_masonry.dart';

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

  testWidgets('renders all children', (tester) async {
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        children: [Text('A'), Text('B'), Text('C'), Text('D')],
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('renders outer Row with CrossAxisAlignment.start', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        columns: OiResponsive<int>(3),
        children: [Text('X'), Text('Y'), Text('Z')],
      ),
    );
    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.crossAxisAlignment, CrossAxisAlignment.start);
  });

  // ── Column count ───────────────────────────────────────────────────────────

  testWidgets('creates one Column per masonry column', (tester) async {
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        columns: OiResponsive<int>(3),
        children: [Text('1'), Text('2'), Text('3'), Text('4'), Text('5')],
      ),
    );
    // One Column per masonry column.
    expect(find.byType(Column), findsNWidgets(3));
  });

  // ── Gap spacing ────────────────────────────────────────────────────────────

  testWidgets('gap inserts SizedBox with given width between columns', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        gap: OiResponsive<double>(12),
        children: [Text('A'), Text('B')],
      ),
    );
    // One horizontal SizedBox between the two Expanded columns.
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final widthBoxes = boxes.where((b) => b.width == 12).toList();
    expect(widthBoxes, hasLength(1));
  });

  testWidgets('gap inserts vertical SizedBox between items in same column', (
    tester,
  ) async {
    // 2 columns, 4 items → each column gets 2 items → 1 vertical spacer each.
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        gap: OiResponsive<double>(8),
        children: [Text('A'), Text('B'), Text('C'), Text('D')],
      ),
    );
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final heightBoxes = boxes.where((b) => b.height == 8).toList();
    // 2 columns × 1 spacer each = 2 vertical spacers.
    expect(heightBoxes, hasLength(2));
  });

  // ── Responsive layout props ───────────────────────────────────────────────

  group('responsive layout props', () {
    testWidgets('responsive columns changes column count with breakpoint', (
      tester,
    ) async {
      final responsiveCols = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 2,
        OiBreakpoint.expanded: 4,
      });

      // Compact → 2 columns.
      await tester.pumpObers(
        OiMasonry(
          columns: responsiveCols,
          breakpoint: OiBreakpoint.compact,
          children: const [
            Text('1'),
            Text('2'),
            Text('3'),
            Text('4'),
          ],
        ),
      );
      expect(find.byType(Column), findsNWidgets(2));

      // Expanded → 4 columns.
      await tester.pumpObers(
        OiMasonry(
          columns: responsiveCols,
          breakpoint: OiBreakpoint.expanded,
          children: const [
            Text('1'),
            Text('2'),
            Text('3'),
            Text('4'),
          ],
        ),
      );
      expect(find.byType(Column), findsNWidgets(4));
    });

    testWidgets('responsive gap changes spacing with breakpoint', (
      tester,
    ) async {
      final responsiveGap = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 4,
        OiBreakpoint.expanded: 16,
      });

      // Compact → gap 4.
      await pumpAtWidth(
        tester,
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          gap: responsiveGap,
          children: const [Text('A'), Text('B')],
        ),
        400,
      );
      var boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.width == 4), hasLength(1));

      // Expanded → gap 16.
      await pumpAtWidth(
        tester,
        OiMasonry(
          breakpoint: OiBreakpoint.expanded,
          gap: responsiveGap,
          children: const [Text('A'), Text('B')],
        ),
        900,
      );
      boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.width == 16), hasLength(1));
    });
  });

  // ── Explicit breakpoint parameter ─────────────────────────────────────────

  group('explicit breakpoint parameter', () {
    testWidgets('breakpoint param overrides context for column count', (
      tester,
    ) async {
      final responsiveCols = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 2,
        OiBreakpoint.expanded: 4,
      });

      // Screen is compact-width (400), but breakpoint is explicitly expanded.
      await pumpAtWidth(
        tester,
        OiMasonry(
          columns: responsiveCols,
          breakpoint: OiBreakpoint.expanded,
          children: const [Text('1'), Text('2'), Text('3'), Text('4')],
        ),
        400,
      );
      // Expanded → 4 columns, despite narrow viewport.
      expect(find.byType(Column), findsNWidgets(4));
    });
  });
}
