// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/layout/oi_page.dart';

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
      const OiPage(breakpoint: OiBreakpoint.compact, children: [Text('A')]),
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
      const OiPage(breakpoint: OiBreakpoint.compact, children: [Text('A')]),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.crossAxisAlignment, CrossAxisAlignment.stretch);
  });

  // ── Responsive gap ──────────────────────────────────────────────────────

  group('responsive gap', () {
    testWidgets('gap varies with breakpoint', (tester) async {
      final responsiveGap = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 8,
        OiBreakpoint.expanded: 24,
      });

      // Compact → gap 8.
      await pumpAtWidth(
        tester,
        OiPage(
          breakpoint: OiBreakpoint.compact,
          mainAxisSize: MainAxisSize.min,
          gap: responsiveGap,
          children: const [Text('A'), Text('B')],
        ),
        400,
      );
      var boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 8), hasLength(1));

      // Expanded → gap 24.
      await pumpAtWidth(
        tester,
        OiPage(
          breakpoint: OiBreakpoint.expanded,
          mainAxisSize: MainAxisSize.min,
          gap: responsiveGap,
          children: const [Text('A'), Text('B')],
        ),
        900,
      );
      boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 24), hasLength(1));
    });

    testWidgets('gap cascades to nearest smaller breakpoint', (tester) async {
      final responsiveGap = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 8,
        OiBreakpoint.large: 32,
      });

      // medium has no explicit value → cascades to compact → 8.
      await pumpAtWidth(
        tester,
        OiPage(
          breakpoint: OiBreakpoint.medium,
          mainAxisSize: MainAxisSize.min,
          gap: responsiveGap,
          children: const [Text('A'), Text('B')],
        ),
        700,
      );
      final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 8), hasLength(1));
    });
  });

  // ── Responsive padding ────────────────────────────────────────────────

  group('responsive padding', () {
    testWidgets('padding varies with breakpoint', (tester) async {
      final responsivePadding = OiResponsive<EdgeInsetsGeometry>.breakpoints({
        OiBreakpoint.compact: const EdgeInsets.all(16),
        OiBreakpoint.expanded: const EdgeInsets.all(48),
      });

      // Compact → padding 16.
      await pumpAtWidth(
        tester,
        OiPage(
          breakpoint: OiBreakpoint.compact,
          mainAxisSize: MainAxisSize.min,
          padding: responsivePadding,
          children: const [Text('padded')],
        ),
        400,
      );
      var padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(16));

      // Expanded → padding 48.
      await pumpAtWidth(
        tester,
        OiPage(
          breakpoint: OiBreakpoint.expanded,
          mainAxisSize: MainAxisSize.min,
          padding: responsivePadding,
          children: const [Text('padded')],
        ),
        900,
      );
      padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(48));
    });

    testWidgets('padding cascades to nearest smaller breakpoint', (
      tester,
    ) async {
      final responsivePadding = OiResponsive<EdgeInsetsGeometry>.breakpoints({
        OiBreakpoint.compact: const EdgeInsets.all(12),
        OiBreakpoint.large: const EdgeInsets.all(48),
      });

      // medium has no explicit value → cascades to compact → 12.
      await pumpAtWidth(
        tester,
        OiPage(
          breakpoint: OiBreakpoint.medium,
          mainAxisSize: MainAxisSize.min,
          padding: responsivePadding,
          children: const [Text('padded')],
        ),
        700,
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(12));
    });
  });

  // ── Explicit breakpoint parameter ─────────────────────────────────────

  group('explicit breakpoint parameter', () {
    testWidgets('breakpoint param overrides context for gap', (tester) async {
      final responsiveGap = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 4,
        OiBreakpoint.expanded: 24,
      });

      // Screen is compact-width (400), but breakpoint is explicitly expanded.
      await pumpAtWidth(
        tester,
        OiPage(
          gap: responsiveGap,
          breakpoint: OiBreakpoint.expanded,
          mainAxisSize: MainAxisSize.min,
          children: const [Text('A'), Text('B')],
        ),
        400,
      );
      final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 24), hasLength(1));
    });

    testWidgets('breakpoint param overrides context for padding', (
      tester,
    ) async {
      final responsivePadding = OiResponsive<EdgeInsetsGeometry>.breakpoints({
        OiBreakpoint.compact: const EdgeInsets.all(8),
        OiBreakpoint.expanded: const EdgeInsets.all(32),
      });

      // Screen is compact-width (400), but breakpoint is explicitly expanded.
      await pumpAtWidth(
        tester,
        OiPage(
          padding: responsivePadding,
          breakpoint: OiBreakpoint.expanded,
          mainAxisSize: MainAxisSize.min,
          children: const [Text('padded')],
        ),
        400,
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(32));
    });
  });

  // ── Explicit scale parameter ──────────────────────────────────────────

  group('explicit scale parameter', () {
    testWidgets('scale param resolves responsive values correctly', (
      tester,
    ) async {
      final customScale = OiBreakpointScale.standard();

      await pumpAtWidth(
        tester,
        OiPage(
          breakpoint: OiBreakpoint.medium,
          scale: customScale,
          mainAxisSize: MainAxisSize.min,
          gap: OiResponsive<double>.breakpoints({
            OiBreakpoint.compact: 4,
            OiBreakpoint.medium: 16,
          }),
          children: const [Text('A'), Text('B')],
        ),
        700,
      );

      final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 16), hasLength(1));
    });
  });

  // ── Zero magic: no context dependency ─────────────────────────────────

  testWidgets('works without OiTheme — scale defaults to standard', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: OiPage(
            breakpoint: OiBreakpoint.compact,
            mainAxisSize: MainAxisSize.min,
            gap: OiResponsive<double>.breakpoints({OiBreakpoint.compact: 8}),
            children: const [Text('A'), Text('B')],
          ),
        ),
      ),
    );
    // Should not throw — self-contained with explicit defaults.
    expect(tester.takeException(), isNull);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });
}
