// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/primitives/layout/oi_page.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Basic rendering ──────────────────────────────────────────────────────

  testWidgets('renders children vertically', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: OiBreakpoint.compact,
        children: [Text('A'), Text('B')],
      ),
    );
    expect(find.byType(Column), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  // ── Gap spacing ──────────────────────────────────────────────────────────

  testWidgets('inserts SizedBox with correct height for gap', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: OiBreakpoint.compact,
        gap: OiResponsive<double>(24),
        children: [Text('A'), Text('B')],
      ),
    );
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final spacer = boxes.where((b) => b.height == 24).toList();
    expect(spacer, isNotEmpty);
  });

  testWidgets('no gap spacer when gap is 0', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: OiBreakpoint.compact,
        gap: OiResponsive<double>(0),
        children: [Text('A'), Text('B')],
      ),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.children.length, 2);
  });

  // ── Padding ──────────────────────────────────────────────────────────────

  testWidgets('applies padding when provided', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: OiBreakpoint.compact,
        padding: OiResponsive<EdgeInsetsGeometry>(EdgeInsets.all(32)),
        children: [Text('padded')],
      ),
    );
    expect(find.byType(Padding), findsOneWidget);
    final padding = tester.widget<Padding>(find.byType(Padding));
    expect(padding.padding, const EdgeInsets.all(32));
  });

  testWidgets('no Padding widget when padding is null', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: OiBreakpoint.compact,
        mainAxisSize: MainAxisSize.min,
        children: [Text('no-pad')],
      ),
    );
    expect(find.byType(Padding), findsNothing);
  });

  // ── MainAxisSize ─────────────────────────────────────────────────────────

  testWidgets('defaults to MainAxisSize.max', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: OiBreakpoint.compact,
        children: [Text('A')],
      ),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.max);
  });

  testWidgets('accepts MainAxisSize.min override', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: OiBreakpoint.compact,
        mainAxisSize: MainAxisSize.min,
        children: [Text('A')],
      ),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.min);
  });

  // ── CrossAxisAlignment ───────────────────────────────────────────────────

  testWidgets('defaults to CrossAxisAlignment.stretch', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: OiBreakpoint.compact,
        children: [Text('A')],
      ),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.crossAxisAlignment, CrossAxisAlignment.stretch);
  });
}
