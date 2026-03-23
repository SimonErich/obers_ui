// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey, PhysicalKeyboardKey;
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_accessibility_bridge.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_behavior.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_controller.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_hit_tester.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_sync_coordinator.dart';
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

class _TestHitTester extends OiChartHitTester {
  OiChartHitResult? result;

  @override
  OiChartHitResult? hitTest(Offset position, {double tolerance = 16}) =>
      result;

  @override
  List<OiChartHitResult> hitTestAll(Offset position,
          {double tolerance = 16}) =>
      result != null ? [result!] : [];
}

class _TestSyncCoordinator extends OiChartSyncCoordinator {
  @override
  String get groupId => 'test';

  @override
  void syncViewport(OiChartViewport viewport) {}

  @override
  void syncSelection(Set<OiChartDataRef> selection) {}

  @override
  void syncCrosshair(double? normalizedX) {}

  @override
  void addViewportListener(ValueChanged<OiChartViewport> listener) {}

  @override
  void removeViewportListener(ValueChanged<OiChartViewport> listener) {}

  @override
  void addSelectionListener(ValueChanged<Set<OiChartDataRef>> listener) {}

  @override
  void removeSelectionListener(ValueChanged<Set<OiChartDataRef>> listener) {}

  @override
  void addCrosshairListener(ValueChanged<double?> listener) {}

  @override
  void removeCrosshairListener(ValueChanged<double?> listener) {}
}

class _TestAccessibilityBridge extends OiChartAccessibilityBridge {
  _TestAccessibilityBridge(this._context);
  final BuildContext _context;
  final List<String> announcements = [];

  @override
  void announce(String message, {bool assertive = false}) {
    announcements.add(message);
  }

  @override
  String describeDataPoint(OiChartDataRef ref) =>
      'Series ${ref.seriesIndex}, Point ${ref.dataIndex}';

  @override
  String describeSelection(Set<OiChartDataRef> refs) =>
      '${refs.length} selected';

  @override
  void focusDataPoint(OiChartDataRef ref) {}

  @override
  bool get reducedMotion => false;

  @override
  bool get highContrast => false;

  @override
  BuildContext get context => _context;
}

// ── Concrete test behavior ────────────────────────────────────────────────────

class _TrackingBehavior extends OiChartBehavior {
  final List<String> events = [];

  @override
  void attach(OiChartBehaviorContext context) {
    super.attach(context);
    events.add('attach');
  }

  @override
  void detach() {
    events.add('detach');
    super.detach();
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    events.add('pointerDown');
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    events.add('pointerMove');
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    events.add('pointerUp');
  }

  @override
  void onPointerHover(PointerHoverEvent event) {
    events.add('pointerHover');
  }

  @override
  void onPointerScroll(PointerScrollEvent event) {
    events.add('pointerScroll');
  }

  @override
  void onPointerCancel(PointerCancelEvent event) {
    events.add('pointerCancel');
  }

  @override
  bool onKeyEvent(KeyEvent event) {
    events.add('keyEvent');
    return true;
  }

  @override
  void onSelectionChanged(Set<OiChartDataRef> selection) {
    events.add('selectionChanged:${selection.length}');
  }

  @override
  void onViewportChanged(OiChartViewport viewport) {
    events.add('viewportChanged');
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  const viewport = OiChartViewport(size: Size(400, 300));
  const theme = OiChartThemeData();

  late _TestController controller;
  late _TestHitTester hitTester;

  setUp(() {
    controller = _TestController();
    hitTester = _TestHitTester();
  });

  tearDown(() {
    controller.dispose();
  });

  OiChartBehaviorContext buildContext(BuildContext ctx) {
    return OiChartBehaviorContext(
      buildContext: ctx,
      controller: controller,
      viewport: viewport,
      hitTester: hitTester,
      theme: theme,
    );
  }

  group('OiChartBehaviorContext', () {
    testWidgets('provides all required fields', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final context = OiChartBehaviorContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              hitTester: hitTester,
              theme: theme,
            );

            expect(context.buildContext, same(ctx));
            expect(context.controller, same(controller));
            expect(context.viewport, same(viewport));
            expect(context.hitTester, same(hitTester));
            expect(context.theme, same(theme));
            expect(context.syncCoordinator, isNull);
            expect(context.accessibilityBridge, isNull);

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('provides optional sync coordinator and a11y bridge',
        (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final sync = _TestSyncCoordinator();
            final a11y = _TestAccessibilityBridge(ctx);
            final context = OiChartBehaviorContext(
              buildContext: ctx,
              controller: controller,
              viewport: viewport,
              hitTester: hitTester,
              theme: theme,
              syncCoordinator: sync,
              accessibilityBridge: a11y,
            );

            expect(context.syncCoordinator, same(sync));
            expect(context.accessibilityBridge, same(a11y));

            return const SizedBox();
          },
        ),
      );
    });
  });

  group('OiChartBehavior lifecycle', () {
    testWidgets('attach sets context and isAttached', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = _TrackingBehavior();
            expect(behavior.isAttached, isFalse);

            behavior.attach(buildContext(ctx));
            expect(behavior.isAttached, isTrue);
            expect(behavior.events, ['attach']);

            behavior.detach();

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('detach clears context and isAttached', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = _TrackingBehavior();
            behavior.attach(buildContext(ctx));
            behavior.detach();
            expect(behavior.isAttached, isFalse);
            expect(behavior.events, ['attach', 'detach']);

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('accessing context before attach throws StateError',
        (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = _TrackingBehavior();
            expect(
              () => behavior.context,
              throwsA(isA<StateError>()),
            );

            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('accessing context after detach throws StateError',
        (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = _TrackingBehavior();
            behavior.attach(buildContext(ctx));
            behavior.detach();
            expect(
              () => behavior.context,
              throwsA(isA<StateError>()),
            );

            return const SizedBox();
          },
        ),
      );
    });
  });

  group('OiChartBehavior pointer events', () {
    testWidgets('calls all pointer event handlers', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = _TrackingBehavior();
            behavior.attach(buildContext(ctx));

            behavior.onPointerDown(const PointerDownEvent());
            behavior.onPointerMove(const PointerMoveEvent());
            behavior.onPointerUp(const PointerUpEvent());
            behavior.onPointerHover(const PointerHoverEvent());
            behavior.onPointerScroll(const PointerScrollEvent());
            behavior.onPointerCancel(const PointerCancelEvent());

            expect(behavior.events, [
              'attach',
              'pointerDown',
              'pointerMove',
              'pointerUp',
              'pointerHover',
              'pointerScroll',
              'pointerCancel',
            ]);

            behavior.detach();
            return const SizedBox();
          },
        ),
      );
    });
  });

  group('OiChartBehavior key events', () {
    testWidgets('onKeyEvent returns handled status', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = _TrackingBehavior();
            behavior.attach(buildContext(ctx));

            final handled = behavior.onKeyEvent(
              KeyDownEvent(
                physicalKey: PhysicalKeyboardKey.enter,
                logicalKey: LogicalKeyboardKey.enter,
                timeStamp: Duration.zero,
              ),
            );

            expect(handled, isTrue);
            expect(behavior.events, contains('keyEvent'));

            behavior.detach();
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('default onKeyEvent returns false', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = OiChartBehaviorSubclass();
            behavior.attach(buildContext(ctx));

            final handled = behavior.onKeyEvent(
              KeyDownEvent(
                physicalKey: PhysicalKeyboardKey.enter,
                logicalKey: LogicalKeyboardKey.enter,
                timeStamp: Duration.zero,
              ),
            );

            expect(handled, isFalse);

            behavior.detach();
            return const SizedBox();
          },
        ),
      );
    });
  });

  group('OiChartBehavior state change events', () {
    testWidgets('onSelectionChanged receives selection', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = _TrackingBehavior();
            behavior.attach(buildContext(ctx));

            final refs = {
              const OiChartDataRef(seriesIndex: 0, dataIndex: 1),
              const OiChartDataRef(seriesIndex: 0, dataIndex: 2),
            };

            behavior.onSelectionChanged(refs);
            expect(behavior.events, contains('selectionChanged:2'));

            behavior.detach();
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('onViewportChanged receives new viewport', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = _TrackingBehavior();
            behavior.attach(buildContext(ctx));

            behavior.onViewportChanged(
              viewport.copyWith(zoomLevel: 2),
            );
            expect(behavior.events, contains('viewportChanged'));

            behavior.detach();
            return const SizedBox();
          },
        ),
      );
    });
  });

  group('OiChartBehavior default no-ops', () {
    testWidgets('default handlers are no-ops', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            final behavior = OiChartBehaviorSubclass();
            behavior.attach(buildContext(ctx));

            // All default handlers should simply not throw.
            behavior.onPointerDown(const PointerDownEvent());
            behavior.onPointerMove(const PointerMoveEvent());
            behavior.onPointerUp(const PointerUpEvent());
            behavior.onPointerHover(const PointerHoverEvent());
            behavior.onPointerScroll(const PointerScrollEvent());
            behavior.onPointerCancel(const PointerCancelEvent());
            behavior.onSelectionChanged({});
            behavior.onViewportChanged(viewport);

            behavior.detach();
            return const SizedBox();
          },
        ),
      );
    });
  });

  group('OiChartDataRef', () {
    test('equality', () {
      const a = OiChartDataRef(seriesIndex: 0, dataIndex: 1);
      const b = OiChartDataRef(seriesIndex: 0, dataIndex: 1);
      const c = OiChartDataRef(seriesIndex: 1, dataIndex: 1);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString', () {
      const ref = OiChartDataRef(seriesIndex: 2, dataIndex: 3);
      expect(ref.toString(), 'OiChartDataRef(series: 2, data: 3)');
    });
  });

  group('OiChartHitResult', () {
    test('equality', () {
      const ref = OiChartDataRef(seriesIndex: 0, dataIndex: 0);
      const a = OiChartHitResult(
        ref: ref,
        position: Offset(10, 20),
      );
      const b = OiChartHitResult(
        ref: ref,
        position: Offset(10, 20),
      );
      const c = OiChartHitResult(
        ref: ref,
        position: Offset(10, 20),
        distance: 5,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('default distance is 0', () {
      const hit = OiChartHitResult(
        ref: OiChartDataRef(seriesIndex: 0, dataIndex: 0),
        position: Offset.zero,
      );
      expect(hit.distance, 0);
    });
  });

  group('OiChartController', () {
    test('select and clearSelection', () {
      const ref = OiChartDataRef(seriesIndex: 0, dataIndex: 0);
      controller.select({ref});
      expect(controller.selection, {ref});

      controller.clearSelection();
      expect(controller.selection, isEmpty);
    });

    test('hover', () {
      const ref = OiChartDataRef(seriesIndex: 1, dataIndex: 2);
      controller.hover(ref);
      expect(controller.hovered, ref);

      controller.hover(null);
      expect(controller.hovered, isNull);
    });

    test('notifies listeners on select', () {
      var called = false;
      controller.addListener(() => called = true);

      const ref = OiChartDataRef(seriesIndex: 0, dataIndex: 0);
      controller.select({ref});
      expect(called, isTrue);
    });
  });

  group('OiChartHitTester', () {
    test('hitTest returns result when set', () {
      const ref = OiChartDataRef(seriesIndex: 0, dataIndex: 0);
      const hit = OiChartHitResult(ref: ref, position: Offset(50, 50));
      hitTester.result = hit;

      expect(hitTester.hitTest(const Offset(50, 50)), equals(hit));
    });

    test('hitTest returns null when no result', () {
      expect(hitTester.hitTest(const Offset(50, 50)), isNull);
    });

    test('hitTestAll returns list', () {
      const ref = OiChartDataRef(seriesIndex: 0, dataIndex: 0);
      const hit = OiChartHitResult(ref: ref, position: Offset(50, 50));
      hitTester.result = hit;

      expect(hitTester.hitTestAll(const Offset(50, 50)), [hit]);
    });
  });
}

/// Minimal subclass that uses default (no-op) implementations.
class OiChartBehaviorSubclass extends OiChartBehavior {}
