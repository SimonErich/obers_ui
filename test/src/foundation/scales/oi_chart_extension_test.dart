// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show Canvas, Offset, PictureRecorder, Rect, Size;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_controller.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_extension.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_viewport.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_chart_theme_data.dart';

// ── Test doubles ──────────────────────────────────────────────────────────────

class _TestController extends OiChartController {
  Set<OiChartDataRef> _selection = {};
  OiChartDataRef? _hovered;

  @override
  Set<OiChartDataRef> get selection => _selection;

  @override
  void select(Set<OiChartDataRef> refs) {
    _selection = refs;
    notifyListeners();
  }

  @override
  void clearSelection() {
    _selection = {};
    notifyListeners();
  }

  @override
  OiChartDataRef? get hovered => _hovered;

  @override
  void hover(OiChartDataRef? ref) {
    _hovered = ref;
    notifyListeners();
  }

  @override
  bool get isLoading => false;

  @override
  String? get error => null;
}

// ── Tracking extension ────────────────────────────────────────────────────────

class _TrackingExtension extends OiChartExtension {
  _TrackingExtension({this.consumeHitTest = false});

  final List<String> events = [];
  final bool consumeHitTest;

  @override
  String get id => 'tracking';

  @override
  void beforeLayout(OiChartExtensionContext context) {
    events.add('beforeLayout');
  }

  @override
  void afterLayout(OiChartExtensionContext context) {
    events.add('afterLayout');
  }

  @override
  void beforePaint(Canvas canvas, OiChartExtensionContext context) {
    events.add('beforePaint');
  }

  @override
  void afterPaint(Canvas canvas, OiChartExtensionContext context) {
    events.add('afterPaint');
  }

  @override
  bool beforeHitTest(Offset position, OiChartExtensionContext context) {
    events.add('beforeHitTest:$position');
    return consumeHitTest;
  }

  @override
  void afterHitTest(
    Offset position,
    OiChartDataRef? hitRef,
    OiChartExtensionContext context,
  ) {
    events.add('afterHitTest:$position:${hitRef?.seriesIndex}');
  }

  @override
  void onEvent(OiChartEvent event, OiChartExtensionContext context) {
    events.add('onEvent:${event.type.name}');
  }
}

/// Minimal no-op extension to test default implementations.
class _NoOpExtension extends OiChartExtension {
  @override
  String get id => 'noop';
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  const viewport = OiChartViewport(size: Size(400, 300));
  const theme = OiChartThemeData();

  late _TestController controller;

  setUp(() {
    controller = _TestController();
  });

  tearDown(() {
    controller.dispose();
  });

  // ── OiChartExtensionContext ──────────────────────────────────────────────

  group('OiChartExtensionContext', () {
    testWidgets('provides all required fields', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            expect(context.buildContext, same(ctx));
            expect(context.controller, same(controller));
            expect(context.viewport, same(viewport));
            expect(context.theme, same(theme));
            expect(context.chartSize, const Size(400, 300));
            expect(
              context.plotArea,
              const Rect.fromLTWH(40, 20, 340, 260),
            );

            return const SizedBox();
          },
        ),
      );
    });
  });

  // ── OiChartEvent ────────────────────────────────────────────────────────

  group('OiChartEvent', () {
    test('stores type, position, and optional dataRef', () {
      const event = OiChartEvent(
        type: OiChartEventType.tap,
        localPosition: Offset(100, 200),
      );

      expect(event.type, OiChartEventType.tap);
      expect(event.localPosition, const Offset(100, 200));
      expect(event.dataRef, isNull);
    });

    test('stores dataRef', () {
      const ref = OiChartDataRef(seriesIndex: 1, dataIndex: 3);
      const event = OiChartEvent(
        type: OiChartEventType.hover,
        localPosition: Offset(50, 75),
        dataRef: ref,
      );

      expect(event.dataRef, ref);
    });

    test('equality', () {
      const a = OiChartEvent(
        type: OiChartEventType.tap,
        localPosition: Offset(10, 20),
      );
      const b = OiChartEvent(
        type: OiChartEventType.tap,
        localPosition: Offset(10, 20),
      );
      const c = OiChartEvent(
        type: OiChartEventType.hover,
        localPosition: Offset(10, 20),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  // ── OiChartEventType ────────────────────────────────────────────────────

  group('OiChartEventType', () {
    test('has all expected values', () {
      expect(OiChartEventType.values, hasLength(5));
      expect(OiChartEventType.values, containsAll([
        OiChartEventType.tap,
        OiChartEventType.hover,
        OiChartEventType.hoverExit,
        OiChartEventType.longPress,
        OiChartEventType.scroll,
      ]));
    });
  });

  // ── OiChartExtension lifecycle ──────────────────────────────────────────

  group('OiChartExtension', () {
    testWidgets('id is accessible', (tester) async {
      final ext = _TrackingExtension();
      expect(ext.id, 'tracking');
    });

    testWidgets('beforeLayout and afterLayout are called', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final ext = _TrackingExtension();
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            ext.beforeLayout(context);
            ext.afterLayout(context);

            expect(ext.events, ['beforeLayout', 'afterLayout']);

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('beforePaint and afterPaint receive canvas', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final ext = _TrackingExtension();
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            final recorder = PictureRecorder();
            final canvas = Canvas(recorder);

            ext.beforePaint(canvas, context);
            ext.afterPaint(canvas, context);

            expect(ext.events, ['beforePaint', 'afterPaint']);

            recorder.endRecording();

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('beforeHitTest can consume hit test', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final ext = _TrackingExtension(consumeHitTest: true);
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            final consumed = ext.beforeHitTest(
              const Offset(100, 150),
              context,
            );

            expect(consumed, isTrue);
            expect(ext.events, contains('beforeHitTest:Offset(100.0, 150.0)'));

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('beforeHitTest returns false by default', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final ext = _TrackingExtension();
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            final consumed = ext.beforeHitTest(
              const Offset(100, 150),
              context,
            );

            expect(consumed, isFalse);

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('afterHitTest receives position and hit ref', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final ext = _TrackingExtension();
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            const ref = OiChartDataRef(seriesIndex: 2, dataIndex: 5);
            ext.afterHitTest(const Offset(100, 150), ref, context);

            expect(
              ext.events,
              contains('afterHitTest:Offset(100.0, 150.0):2'),
            );

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('afterHitTest handles null hit ref', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final ext = _TrackingExtension();
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            ext.afterHitTest(const Offset(100, 150), null, context);

            expect(
              ext.events,
              contains('afterHitTest:Offset(100.0, 150.0):null'),
            );

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('onEvent receives chart events', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final ext = _TrackingExtension();
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            ext.onEvent(
              const OiChartEvent(
                type: OiChartEventType.tap,
                localPosition: Offset(50, 50),
              ),
              context,
            );
            ext.onEvent(
              const OiChartEvent(
                type: OiChartEventType.hover,
                localPosition: Offset(60, 70),
              ),
              context,
            );

            expect(ext.events, ['onEvent:tap', 'onEvent:hover']);

            return const SizedBox();
          },
        ),
      );
    });
  });

  // ── Default no-op implementations ───────────────────────────────────────

  group('OiChartExtension defaults', () {
    testWidgets('all default hooks are no-ops', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final ext = _NoOpExtension();
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            final recorder = PictureRecorder();
            final canvas = Canvas(recorder);

            // All of these should simply not throw.
            ext.beforeLayout(context);
            ext.afterLayout(context);
            ext.beforePaint(canvas, context);
            ext.afterPaint(canvas, context);

            final consumed = ext.beforeHitTest(Offset.zero, context);
            expect(consumed, isFalse);

            ext.afterHitTest(Offset.zero, null, context);
            ext.onEvent(
              const OiChartEvent(
                type: OiChartEventType.tap,
                localPosition: Offset.zero,
              ),
              context,
            );

            recorder.endRecording();

            return const SizedBox();
          },
        ),
      );
    });
  });

  // ── Full lifecycle simulation ───────────────────────────────────────────

  group('Full lifecycle', () {
    testWidgets('simulates complete chart lifecycle', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final ext = _TrackingExtension();
            final context = OiChartExtensionContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              theme: theme,
              chartSize: const Size(400, 300),
              plotArea: const Rect.fromLTWH(40, 20, 340, 260),
            );

            final recorder = PictureRecorder();
            final canvas = Canvas(recorder);

            // Layout phase.
            ext.beforeLayout(context);
            ext.afterLayout(context);

            // Paint phase.
            ext.beforePaint(canvas, context);
            ext.afterPaint(canvas, context);

            // Hit test phase.
            ext.beforeHitTest(const Offset(100, 100), context);
            const ref = OiChartDataRef(seriesIndex: 0, dataIndex: 1);
            ext.afterHitTest(const Offset(100, 100), ref, context);

            // Event phase.
            ext.onEvent(
              const OiChartEvent(
                type: OiChartEventType.tap,
                localPosition: Offset(100, 100),
                dataRef: ref,
              ),
              context,
            );

            expect(ext.events, [
              'beforeLayout',
              'afterLayout',
              'beforePaint',
              'afterPaint',
              'beforeHitTest:Offset(100.0, 100.0)',
              'afterHitTest:Offset(100.0, 100.0):0',
              'onEvent:tap',
            ]);

            recorder.endRecording();

            return const SizedBox();
          },
        ),
      );
    });
  });
}
