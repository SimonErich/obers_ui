// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/primitives/layout/oi_section.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Basic rendering ──────────────────────────────────────────────────────

  testWidgets('renders children vertically', (tester) async {
    await tester.pumpObers(
      const OiSection(
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
      const OiSection(
        breakpoint: OiBreakpoint.compact,
        gap: OiResponsive<double>(16),
        children: [Text('A'), Text('B')],
      ),
    );
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final spacer = boxes.where((b) => b.height == 16).toList();
    expect(spacer, isNotEmpty);
  });

  testWidgets('no gap spacer when gap is 0', (tester) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: OiBreakpoint.compact,
        gap: OiResponsive<double>(0),
        children: [Text('A'), Text('B')],
      ),
    );
    // Only the two Text widgets should be children of the Column.
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.children.length, 2);
  });

  // ── Padding ──────────────────────────────────────────────────────────────

  testWidgets('applies padding when provided', (tester) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: OiBreakpoint.compact,
        padding: OiResponsive<EdgeInsetsGeometry>(EdgeInsets.all(24)),
        children: [Text('padded')],
      ),
    );
    expect(find.byType(Padding), findsOneWidget);
    final padding = tester.widget<Padding>(find.byType(Padding));
    expect(padding.padding, const EdgeInsets.all(24));
  });

  testWidgets('no Padding widget when padding is null', (tester) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: OiBreakpoint.compact,
        children: [Text('no-pad')],
      ),
    );
    // Padding from the Semantics → Column path should not include an
    // extra Padding widget.
    final paddingFinder = find.descendant(
      of: find.byType(Semantics),
      matching: find.byType(Padding),
    );
    expect(paddingFinder, findsNothing);
  });

  // ── Semantics ────────────────────────────────────────────────────────────

  testWidgets('wraps content in Semantics with label', (tester) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: OiBreakpoint.compact,
        semanticLabel: 'Hero section',
        children: [Text('hero')],
      ),
    );
    // Find the Semantics widget that is an ancestor of our Column.
    final semanticsFinder = find.ancestor(
      of: find.byType(Column),
      matching: find.byType(Semantics),
    );
    final semantics = tester.widget<Semantics>(semanticsFinder.first);
    expect(semantics.properties.label, 'Hero section');
  });

  // ── MainAxisSize ─────────────────────────────────────────────────────────

  testWidgets('defaults to MainAxisSize.min', (tester) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: OiBreakpoint.compact,
        children: [Text('A')],
      ),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.min);
  });

  testWidgets('accepts MainAxisSize.max override', (tester) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: OiBreakpoint.compact,
        mainAxisSize: MainAxisSize.max,
        children: [Text('A')],
      ),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.max);
  });

  // ── CrossAxisAlignment ───────────────────────────────────────────────────

  testWidgets('defaults to CrossAxisAlignment.start', (tester) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: OiBreakpoint.compact,
        children: [Text('A')],
      ),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.crossAxisAlignment, CrossAxisAlignment.start);
  });
}
