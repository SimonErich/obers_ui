// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/oi_span.dart';
import 'package:obers_ui/src/primitives/layout/oi_aspect_ratio.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_container.dart';
import 'package:obers_ui/src/primitives/layout/oi_grid.dart';
import 'package:obers_ui/src/primitives/layout/oi_masonry.dart';
import 'package:obers_ui/src/primitives/layout/oi_page.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';
import 'package:obers_ui/src/primitives/layout/oi_section.dart';
import 'package:obers_ui/src/primitives/layout/oi_spacer.dart';
import 'package:obers_ui/src/primitives/layout/oi_wrap_layout.dart';

import '../../helpers/pump_app.dart';

/// Cross-cutting tests that verify the OiResponsive<T> contract:
///
/// > Any layout property that should vary by screen size accepts an
/// > OiResponsive<T> value. One type, one pattern, everywhere.
///
/// Every widget must:
/// 1. Accept OiResponsive<T> for all sizing/spacing/layout properties.
/// 2. Resolve responsive values via explicit breakpoint + scale (zero magic).
/// 3. Support mobile-first cascading (values inherit from smaller breakpoints).
/// 4. Work without OiTheme — scale defaults to OiBreakpointScale.defaultScale.
void main() {
  // A responsive gap that changes from 8 at compact to 24 at expanded.
  // Medium has no explicit value and should cascade to compact (8).
  final responsiveGap = OiResponsive<double>.breakpoints({
    OiBreakpoint.compact: 8,
    OiBreakpoint.expanded: 24,
  });

  // A responsive padding that changes from 16 at compact to 40 at expanded.
  final responsivePadding = OiResponsive<EdgeInsetsGeometry>.breakpoints({
    OiBreakpoint.compact: const EdgeInsets.all(16),
    OiBreakpoint.expanded: const EdgeInsets.all(40),
  });

  const child = Text('content');
  const children = [Text('A'), Text('B')];

  // ─────────────────────────────────────────────────────────────────────────
  // Contract: every widget resolves responsive values via explicit breakpoint
  // ─────────────────────────────────────────────────────────────────────────

  group('OiResponsive<T> contract — one type, one pattern, everywhere', () {
    testWidgets('OiRow: responsive gap resolves per breakpoint', (
      tester,
    ) async {
      await tester.pumpObers(
        OiRow(
          breakpoint: OiBreakpoint.compact,
          gap: responsiveGap,
          children: children,
        ),
      );
      var boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.width == 8), hasLength(1));

      await tester.pumpObers(
        OiRow(
          breakpoint: OiBreakpoint.expanded,
          gap: responsiveGap,
          children: children,
        ),
      );
      boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.width == 24), hasLength(1));
    });

    testWidgets('OiColumn: responsive gap resolves per breakpoint', (
      tester,
    ) async {
      await tester.pumpObers(
        OiColumn(
          breakpoint: OiBreakpoint.compact,
          gap: responsiveGap,
          children: children,
        ),
      );
      var boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 8), hasLength(1));

      await tester.pumpObers(
        OiColumn(
          breakpoint: OiBreakpoint.expanded,
          gap: responsiveGap,
          children: children,
        ),
      );
      boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 24), hasLength(1));
    });

    testWidgets('OiGrid: responsive columns and gap resolve per breakpoint', (
      tester,
    ) async {
      final responsiveCols = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.expanded: 3,
      });

      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: responsiveCols,
          gap: responsiveGap,
          children: const [Text('A'), Text('B'), Text('C')],
        ),
        surfaceSize: const Size(900, 600),
      );

      // Compact → 1 column → full width.
      final rectCompact = tester.getRect(find.text('A'));
      expect(rectCompact.width, closeTo(900, 1));

      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.expanded,
          columns: responsiveCols,
          gap: responsiveGap,
          children: const [Text('A'), Text('B'), Text('C')],
        ),
        surfaceSize: const Size(900, 600),
      );

      // Expanded → 3 columns with gap 24.
      final rectExpanded = tester.getRect(find.text('A'));
      // unitWidth = (900 - 24*2) / 3 = 284
      expect(rectExpanded.width, closeTo(284, 1));
    });

    testWidgets('OiSection: responsive gap and padding resolve per breakpoint', (
      tester,
    ) async {
      await tester.pumpObers(
        OiSection(
          breakpoint: OiBreakpoint.compact,
          gap: responsiveGap,
          padding: responsivePadding,
          children: children,
        ),
      );
      var boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 8), hasLength(1));
      var padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(16));

      await tester.pumpObers(
        OiSection(
          breakpoint: OiBreakpoint.expanded,
          gap: responsiveGap,
          padding: responsivePadding,
          children: children,
        ),
      );
      boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 24), hasLength(1));
      padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(40));
    });

    testWidgets('OiPage: responsive gap and padding resolve per breakpoint', (
      tester,
    ) async {
      await tester.pumpObers(
        OiPage(
          breakpoint: OiBreakpoint.compact,
          mainAxisSize: MainAxisSize.min,
          gap: responsiveGap,
          padding: responsivePadding,
          children: children,
        ),
      );
      var boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 8), hasLength(1));
      var padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(16));

      await tester.pumpObers(
        OiPage(
          breakpoint: OiBreakpoint.expanded,
          mainAxisSize: MainAxisSize.min,
          gap: responsiveGap,
          padding: responsivePadding,
          children: children,
        ),
      );
      boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 24), hasLength(1));
      padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(40));
    });

    testWidgets('OiMasonry: responsive columns and gap resolve per breakpoint', (
      tester,
    ) async {
      final responsiveCols = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 2,
        OiBreakpoint.expanded: 4,
      });

      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: responsiveCols,
          gap: responsiveGap,
          children: const [Text('1'), Text('2'), Text('3'), Text('4')],
        ),
      );
      expect(find.byType(Column), findsNWidgets(2));

      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.expanded,
          columns: responsiveCols,
          gap: responsiveGap,
          children: const [Text('1'), Text('2'), Text('3'), Text('4')],
        ),
      );
      expect(find.byType(Column), findsNWidgets(4));
    });

    testWidgets(
      'OiContainer: responsive maxWidth and padding resolve per breakpoint',
      (tester) async {
        final responsiveMaxWidth = OiResponsive<double>.breakpoints({
          OiBreakpoint.compact: double.infinity,
          OiBreakpoint.expanded: 960,
        });

        await tester.pumpObers(
          OiContainer(
            breakpoint: OiBreakpoint.compact,
            maxWidth: responsiveMaxWidth,
            padding: responsivePadding,
            child: child,
          ),
        );
        var constrained = tester
            .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
            .toList();
        expect(
          constrained.any((b) => b.constraints.maxWidth == double.infinity),
          isTrue,
        );
        var padding = tester.widget<Padding>(find.byType(Padding));
        expect(padding.padding, const EdgeInsets.all(16));

        await tester.pumpObers(
          OiContainer(
            breakpoint: OiBreakpoint.expanded,
            maxWidth: responsiveMaxWidth,
            padding: responsivePadding,
            child: child,
          ),
        );
        constrained = tester
            .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
            .toList();
        expect(constrained.any((b) => b.constraints.maxWidth == 960), isTrue);
        padding = tester.widget<Padding>(find.byType(Padding));
        expect(padding.padding, const EdgeInsets.all(40));
      },
    );

    testWidgets('OiWrapLayout: responsive spacing resolves per breakpoint', (
      tester,
    ) async {
      await tester.pumpObers(
        OiWrapLayout(
          breakpoint: OiBreakpoint.compact,
          spacing: responsiveGap,
          runSpacing: responsiveGap,
          children: children,
        ),
      );
      var wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 8);
      expect(wrap.runSpacing, 8);

      await tester.pumpObers(
        OiWrapLayout(
          breakpoint: OiBreakpoint.expanded,
          spacing: responsiveGap,
          runSpacing: responsiveGap,
          children: children,
        ),
      );
      wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 24);
      expect(wrap.runSpacing, 24);
    });

    testWidgets('OiSpacer: responsive size resolves per breakpoint', (
      tester,
    ) async {
      final responsiveSize = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 8,
        OiBreakpoint.expanded: 24,
      });

      await tester.pumpObers(
        Column(children: [
          OiSpacer(breakpoint: OiBreakpoint.compact, size: responsiveSize),
        ]),
      );
      var box = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(box.height, 8);

      await tester.pumpObers(
        Column(children: [
          OiSpacer(breakpoint: OiBreakpoint.expanded, size: responsiveSize),
        ]),
      );
      box = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(box.height, 24);
    });

    testWidgets('OiAspectRatio: responsive ratio resolves per breakpoint', (
      tester,
    ) async {
      final responsiveRatio = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 4 / 3,
        OiBreakpoint.expanded: 16 / 9,
      });

      await tester.pumpObers(
        OiAspectRatio(
          breakpoint: OiBreakpoint.compact,
          ratio: responsiveRatio,
          child: const ColoredBox(color: Color(0xFF000000)),
        ),
      );
      var ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(ar.aspectRatio, closeTo(4 / 3, 0.001));

      await tester.pumpObers(
        OiAspectRatio(
          breakpoint: OiBreakpoint.expanded,
          ratio: responsiveRatio,
          child: const ColoredBox(color: Color(0xFF000000)),
        ),
      );
      ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(ar.aspectRatio, closeTo(16 / 9, 0.001));
    });

    testWidgets('OiSpan: responsive span values resolve per breakpoint', (
      tester,
    ) async {
      final responsiveSpan = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.expanded: 2,
      });

      // Compact → span 1 → unitWidth.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          children: [
            const Text('A').span(columnSpan: responsiveSpan),
            const Text('B'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );
      final rectCompact = tester.getRect(find.text('A'));
      expect(rectCompact.width, closeTo(400, 1));

      // Expanded → span 2 → full width.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.expanded,
          columns: 2.responsive,
          children: [
            const Text('A').span(columnSpan: responsiveSpan),
            const Text('B'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );
      final rectExpanded = tester.getRect(find.text('A'));
      expect(rectExpanded.width, closeTo(800, 1));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Contract: mobile-first cascading works uniformly
  // ─────────────────────────────────────────────────────────────────────────

  group('mobile-first cascading — uniform across all widgets', () {
    // Gap with value only at compact. All higher breakpoints should cascade.
    final cascadingGap = OiResponsive<double>.breakpoints({
      OiBreakpoint.compact: 10,
    });

    testWidgets('OiRow cascades gap from compact to medium', (tester) async {
      await tester.pumpObers(
        OiRow(
          breakpoint: OiBreakpoint.medium,
          gap: cascadingGap,
          children: children,
        ),
      );
      final boxes =
          tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.width == 10), hasLength(1));
    });

    testWidgets('OiColumn cascades gap from compact to expanded', (
      tester,
    ) async {
      await tester.pumpObers(
        OiColumn(
          breakpoint: OiBreakpoint.expanded,
          gap: cascadingGap,
          children: children,
        ),
      );
      final boxes =
          tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 10), hasLength(1));
    });

    testWidgets('OiSection cascades gap from compact to large', (
      tester,
    ) async {
      await tester.pumpObers(
        OiSection(
          breakpoint: OiBreakpoint.large,
          gap: cascadingGap,
          children: children,
        ),
      );
      final boxes =
          tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 10), hasLength(1));
    });

    testWidgets('OiPage cascades gap from compact to extraLarge', (
      tester,
    ) async {
      await tester.pumpObers(
        OiPage(
          breakpoint: OiBreakpoint.extraLarge,
          mainAxisSize: MainAxisSize.min,
          gap: cascadingGap,
          children: children,
        ),
      );
      final boxes =
          tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.height == 10), hasLength(1));
    });

    testWidgets('OiWrapLayout cascades spacing from compact to large', (
      tester,
    ) async {
      await tester.pumpObers(
        OiWrapLayout(
          breakpoint: OiBreakpoint.large,
          spacing: cascadingGap,
          children: children,
        ),
      );
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 10);
    });

    testWidgets('OiGrid cascades gap from compact to expanded', (
      tester,
    ) async {
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.expanded,
          columns: const OiResponsive<int>(2),
          gap: cascadingGap,
          children: children,
        ),
      );
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 10);
    });

    testWidgets('OiSpacer cascades size from compact to large', (
      tester,
    ) async {
      final cascadingSize = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 10,
      });
      await tester.pumpObers(
        Column(children: [
          OiSpacer(breakpoint: OiBreakpoint.large, size: cascadingSize),
        ]),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(box.height, 10);
    });

    testWidgets('OiAspectRatio cascades ratio from compact to expanded', (
      tester,
    ) async {
      final cascadingRatio = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 4 / 3,
      });
      await tester.pumpObers(
        OiAspectRatio(
          breakpoint: OiBreakpoint.expanded,
          ratio: cascadingRatio,
          child: const ColoredBox(color: Color(0xFF000000)),
        ),
      );
      final ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(ar.aspectRatio, closeTo(4 / 3, 0.001));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Contract: convenience extensions produce valid OiResponsive values
  // ─────────────────────────────────────────────────────────────────────────

  group('convenience extensions', () {
    final scale = OiBreakpointScale.standard();

    test('int.responsive creates static OiResponsive<int>', () {
      final r = 4.responsive;
      expect(r.isStatic, isTrue);
      expect(r.resolve(OiBreakpoint.compact, scale), 4);
      expect(r.resolve(OiBreakpoint.extraLarge, scale), 4);
    });

    test('double.responsive creates static OiResponsive<double>', () {
      final r = 16.0.responsive;
      expect(r.isStatic, isTrue);
      expect(r.resolve(OiBreakpoint.compact, scale), 16.0);
    });

    test('bool.responsive creates static OiResponsive<bool>', () {
      final r = true.responsive;
      expect(r.isStatic, isTrue);
      expect(r.resolve(OiBreakpoint.compact, scale), isTrue);
    });

    test('EdgeInsets.responsive creates static OiResponsive<EdgeInsetsGeometry>', () {
      final r = const EdgeInsets.all(8).responsive;
      expect(r.isStatic, isTrue);
      expect(r.resolve(OiBreakpoint.compact, scale), const EdgeInsets.all(8));
    });

    test('Map.responsive creates breakpoint-keyed OiResponsive', () {
      final r = {OiBreakpoint.compact: 1, OiBreakpoint.large: 4}.responsive;
      expect(r.isStatic, isFalse);
      expect(r.resolve(OiBreakpoint.compact, scale), 1);
      expect(r.resolve(OiBreakpoint.large, scale), 4);
      // Cascading: expanded inherits from compact.
      expect(r.resolve(OiBreakpoint.expanded, scale), 1);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Contract: resolveFor(context) works as shorthand
  // ─────────────────────────────────────────────────────────────────────────

  group('resolveFor(context)', () {
    testWidgets('static value resolves without reading widget tree', (
      tester,
    ) async {
      const r = OiResponsive<int>(42);
      await tester.pumpObers(
        Builder(builder: (context) {
          final value = r.resolveFor(context);
          return Text('$value');
        }),
      );
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('breakpoints value resolves from context breakpoint', (
      tester,
    ) async {
      final r = OiResponsive<String>.breakpoints({
        OiBreakpoint.compact: 'small',
        OiBreakpoint.expanded: 'wide',
      });
      await tester.pumpObers(
        Builder(builder: (context) {
          final value = r.resolveFor(context);
          return Text(value);
        }),
      );
      // Default pumpObers uses 800x600 → compact breakpoint → 'small'.
      expect(find.text('small'), findsOneWidget);
    });
  });
}
