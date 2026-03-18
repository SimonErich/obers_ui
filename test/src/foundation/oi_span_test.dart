// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/oi_span.dart';

void main() {
  final scale = OiBreakpointScale.standard();

  // ─────────────────────────────────────────────────────────────────────────
  // OiSpanData
  // ─────────────────────────────────────────────────────────────────────────

  group('OiSpanData', () {
    test('default values resolve to 1 span, null start/order', () {
      const data = OiSpanData();
      expect(data.resolveColumnSpan(OiBreakpoint.compact, scale), 1);
      expect(data.resolveColumnStart(OiBreakpoint.compact, scale), isNull);
      expect(data.resolveColumnOrder(OiBreakpoint.compact, scale), isNull);
    });

    test('static columnSpan resolves to same value at all breakpoints', () {
      const data = OiSpanData(columnSpan: OiResponsive<int>(3));
      expect(data.resolveColumnSpan(OiBreakpoint.compact, scale), 3);
      expect(data.resolveColumnSpan(OiBreakpoint.large, scale), 3);
    });

    test('responsive columnSpan resolves per breakpoint', () {
      final data = OiSpanData(
        columnSpan: OiResponsive<int>.breakpoints({
          OiBreakpoint.compact: 1,
          OiBreakpoint.medium: 2,
          OiBreakpoint.large: 4,
        }),
      );
      expect(data.resolveColumnSpan(OiBreakpoint.compact, scale), 1);
      expect(data.resolveColumnSpan(OiBreakpoint.medium, scale), 2);
      // expanded cascades to medium
      expect(data.resolveColumnSpan(OiBreakpoint.expanded, scale), 2);
      expect(data.resolveColumnSpan(OiBreakpoint.large, scale), 4);
    });

    test('columnStart resolves responsively', () {
      final data = OiSpanData(
        columnStart: OiResponsive<int>.breakpoints({
          OiBreakpoint.compact: 1,
          OiBreakpoint.expanded: 3,
        }),
      );
      expect(data.resolveColumnStart(OiBreakpoint.compact, scale), 1);
      expect(data.resolveColumnStart(OiBreakpoint.medium, scale), 1);
      expect(data.resolveColumnStart(OiBreakpoint.expanded, scale), 3);
    });

    test('columnOrder resolves responsively', () {
      final data = OiSpanData(
        columnOrder: OiResponsive<int>.breakpoints({
          OiBreakpoint.compact: 2,
          OiBreakpoint.large: 1,
        }),
      );
      expect(data.resolveColumnOrder(OiBreakpoint.compact, scale), 2);
      expect(data.resolveColumnOrder(OiBreakpoint.medium, scale), 2);
      expect(data.resolveColumnOrder(OiBreakpoint.large, scale), 1);
    });

    test('full constant uses sentinel value', () {
      expect(
        OiSpanData.full.resolveColumnSpan(OiBreakpoint.compact, scale),
        fullSpanSentinel,
      );
      expect(
        OiSpanData.full.resolveColumnSpan(OiBreakpoint.large, scale),
        fullSpanSentinel,
      );
    });

    test('equality works', () {
      const a = OiSpanData(columnSpan: OiResponsive<int>(2));
      const b = OiSpanData(columnSpan: OiResponsive<int>(2));
      expect(a, equals(b));
    });

    test('inequality works', () {
      const a = OiSpanData(columnSpan: OiResponsive<int>(2));
      const b = OiSpanData(columnSpan: OiResponsive<int>(3));
      expect(a, isNot(equals(b)));
    });

    test('default rowSpan resolves to 1', () {
      const data = OiSpanData();
      expect(data.resolveRowSpan(OiBreakpoint.compact, scale), 1);
      expect(data.resolveRowSpan(OiBreakpoint.large, scale), 1);
    });

    test('static rowSpan resolves to same value at all breakpoints', () {
      const data = OiSpanData(rowSpan: OiResponsive<int>(3));
      expect(data.resolveRowSpan(OiBreakpoint.compact, scale), 3);
      expect(data.resolveRowSpan(OiBreakpoint.large, scale), 3);
    });

    test('responsive rowSpan resolves per breakpoint', () {
      final data = OiSpanData(
        rowSpan: OiResponsive<int>.breakpoints({
          OiBreakpoint.compact: 1,
          OiBreakpoint.medium: 2,
          OiBreakpoint.large: 3,
        }),
      );
      expect(data.resolveRowSpan(OiBreakpoint.compact, scale), 1);
      expect(data.resolveRowSpan(OiBreakpoint.medium, scale), 2);
      // expanded cascades to medium
      expect(data.resolveRowSpan(OiBreakpoint.expanded, scale), 2);
      expect(data.resolveRowSpan(OiBreakpoint.large, scale), 3);
    });

    test('equality includes rowSpan', () {
      const a = OiSpanData(
        columnSpan: OiResponsive<int>(2),
        rowSpan: OiResponsive<int>(3),
      );
      const b = OiSpanData(
        columnSpan: OiResponsive<int>(2),
        rowSpan: OiResponsive<int>(3),
      );
      const c = OiSpanData(
        columnSpan: OiResponsive<int>(2),
        rowSpan: OiResponsive<int>(1),
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // OiSpan widget
  // ─────────────────────────────────────────────────────────────────────────

  group('OiSpan', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OiSpan(
            data: const OiSpanData(columnSpan: OiResponsive<int>(2)),
            child: const Text('hello'),
          ),
        ),
      );
      expect(find.text('hello'), findsOneWidget);
    });

    test('maybeOf returns data for OiSpan widget', () {
      const data = OiSpanData(columnSpan: OiResponsive<int>(2));
      const widget = OiSpan(data: data, child: SizedBox.shrink());
      expect(OiSpan.maybeOf(widget), equals(data));
    });

    test('maybeOf returns null for non-OiSpan widget', () {
      const widget = SizedBox.shrink();
      expect(OiSpan.maybeOf(widget), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Widget extension
  // ─────────────────────────────────────────────────────────────────────────

  group('OiSpanExt', () {
    testWidgets('.span() wraps widget with OiSpan', (tester) async {
      final widget = const Text('test').span(
        columnSpan: const OiResponsive<int>(2),
        columnStart: const OiResponsive<int>(3),
      );
      expect(widget, isA<OiSpan>());
      final span = widget as OiSpan;
      expect(span.data.columnSpan, const OiResponsive<int>(2));
      expect(span.data.columnStart, const OiResponsive<int>(3));
      expect(span.data.columnOrder, isNull);
    });

    testWidgets('.span() passes rowSpan through to OiSpanData', (
      tester,
    ) async {
      final widget = const Text('test').span(
        columnSpan: const OiResponsive<int>(2),
        rowSpan: const OiResponsive<int>(3),
      );
      expect(widget, isA<OiSpan>());
      final span = widget as OiSpan;
      expect(span.data.columnSpan, const OiResponsive<int>(2));
      expect(span.data.rowSpan, const OiResponsive<int>(3));
    });

    testWidgets('.spanFull() wraps widget with full span', (tester) async {
      final widget = const Text('test').spanFull();
      expect(widget, isA<OiSpan>());
      final span = widget as OiSpan;
      expect(span.data, OiSpanData.full);
    });

    testWidgets('.span() renders child correctly', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const Text(
            'spanned',
          ).span(columnSpan: const OiResponsive<int>(2)),
        ),
      );
      expect(find.text('spanned'), findsOneWidget);
    });

    testWidgets('.spanFull() renders child correctly', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const Text('full width').spanFull(),
        ),
      );
      expect(find.text('full width'), findsOneWidget);
    });
  });
}
