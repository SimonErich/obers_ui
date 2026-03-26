import 'dart:ui' show Offset, Size;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart' show OiChartThemeData;
import 'package:obers_ui_charts/obers_ui_charts.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';

// ── Test doubles ─────────────────────────────────────────────────────────────

class _TestController extends OiDefaultChartController {}

class _TestHitTester extends OiChartHitTester {
  @override
  OiChartHitResult? hitTest(Offset position, {double tolerance = 16}) => null;

  @override
  List<OiChartHitResult> hitTestAll(Offset position, {double tolerance = 16}) =>
      [];
}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late OiChartCrosshairBehavior behavior;
  late _TestController controller;
  late OiChartBehaviorContext behaviorContext;

  setUp(() {
    behavior = OiChartCrosshairBehavior();
    controller = _TestController();

    behaviorContext = OiChartBehaviorContext(
      buildContext: _FakeBuildContext(),
      controller: controller,
      viewport: const OiChartViewport(size: Size(400, 300)),
      hitTester: _TestHitTester(),
      theme: OiChartThemeData(),
    );

    behavior.attach(behaviorContext);
  });

  tearDown(() {
    if (behavior.isAttached) behavior.detach();
    controller.dispose();
  });

  group('OiChartCrosshairBehavior', () {
    test('is attached after attach()', () {
      expect(behavior.isAttached, isTrue);
    });

    test('is not attached after detach()', () {
      behavior.detach();
      expect(behavior.isAttached, isFalse);
    });

    test('state is null initially', () {
      expect(behavior.state, isNull);
    });

    test('detach clears state and is safe', () {
      behavior.detach();
      expect(behavior.isAttached, isFalse);
    });

    test('repaintListenable is accessible when attached', () {
      expect(behavior.repaintListenable, isNotNull);
    });

    test('createPainter returns an OiChartCrosshairPainter', () {
      final painter = behavior.createPainter();
      expect(painter, isA<OiChartCrosshairPainter>());
    });

    test('painter references the behavior', () {
      final painter = behavior.createPainter();
      expect(painter.behavior, same(behavior));
    });

    test('onCrosshairUpdate callback is invoked when state changes', () {
      OiChartCrosshairState? receivedState;

      behavior.detach();
      behavior = OiChartCrosshairBehavior(
        onCrosshairUpdate: (state) => receivedState = state,
      );
      behavior.attach(behaviorContext);

      // Simulate a pointer hover inside the plot area.
      behavior.onPointerHover(
        const PointerHoverEvent(position: Offset(200, 150)),
      );

      // The viewport plot area encompasses (0,0)-(400,300); 200,150 is inside.
      expect(receivedState, isNotNull);
      expect(receivedState!.position, isNotNull);
    });

    test('pointer outside plot area clears state via onCrosshairUpdate', () {
      final states = <OiChartCrosshairState?>[];

      behavior.detach();
      behavior = OiChartCrosshairBehavior(
        onCrosshairUpdate: (state) => states.add(state),
      );
      behavior.attach(behaviorContext);

      // First move inside the plot area.
      behavior.onPointerHover(
        const PointerHoverEvent(position: Offset(200, 150)),
      );
      // Then move outside (negative coords are outside plot).
      behavior.onPointerHover(
        const PointerHoverEvent(position: Offset(-10, -10)),
      );

      expect(states.last, isNull);
    });

    test('pointer cancel clears state', () {
      OiChartCrosshairState? lastState = const OiChartCrosshairState(
        position: Offset(1, 1),
      );

      behavior.detach();
      behavior = OiChartCrosshairBehavior(
        onCrosshairUpdate: (state) => lastState = state,
      );
      behavior.attach(behaviorContext);

      behavior.onPointerCancel(const PointerCancelEvent());

      expect(lastState, isNull);
    });
  });

  group('OiChartCrosshairConfig', () {
    test('default config has enabled = true', () {
      const config = OiChartCrosshairConfig();
      expect(config.enabled, isTrue);
    });

    test('default snap mode is free', () {
      const config = OiChartCrosshairConfig();
      expect(config.snap, equals(OiChartCrosshairSnap.free));
    });

    test('default axis mode is both', () {
      const config = OiChartCrosshairConfig();
      expect(config.axis, equals(OiChartCrosshairAxis.both));
    });

    test('default color is null (uses theme default)', () {
      const config = OiChartCrosshairConfig();
      expect(config.color, isNull);
    });

    test('default width is 1.0', () {
      const config = OiChartCrosshairConfig();
      expect(config.width, equals(1.0));
    });

    test('default showLabel is false', () {
      const config = OiChartCrosshairConfig();
      expect(config.showLabel, isFalse);
    });

    test('default hitTestTolerance is 24.0', () {
      const config = OiChartCrosshairConfig();
      expect(config.hitTestTolerance, equals(24.0));
    });

    test('default dashPattern is null', () {
      const config = OiChartCrosshairConfig();
      expect(config.dashPattern, isNull);
    });

    test('equality holds when all fields match', () {
      const a = OiChartCrosshairConfig(
        enabled: true,
        snap: OiChartCrosshairSnap.nearestPoint,
        axis: OiChartCrosshairAxis.vertical,
        width: 2.0,
        showLabel: true,
        hitTestTolerance: 16.0,
      );
      const b = OiChartCrosshairConfig(
        enabled: true,
        snap: OiChartCrosshairSnap.nearestPoint,
        axis: OiChartCrosshairAxis.vertical,
        width: 2.0,
        showLabel: true,
        hitTestTolerance: 16.0,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality when enabled differs', () {
      const a = OiChartCrosshairConfig(enabled: true);
      const b = OiChartCrosshairConfig(enabled: false);
      expect(a, isNot(equals(b)));
    });

    test('inequality when snap mode differs', () {
      const a = OiChartCrosshairConfig(snap: OiChartCrosshairSnap.free);
      const b = OiChartCrosshairConfig(snap: OiChartCrosshairSnap.nearestPoint);
      expect(a, isNot(equals(b)));
    });

    test('inequality when axis differs', () {
      const a = OiChartCrosshairConfig(axis: OiChartCrosshairAxis.vertical);
      const b = OiChartCrosshairConfig(axis: OiChartCrosshairAxis.horizontal);
      expect(a, isNot(equals(b)));
    });

    test('inequality when width differs', () {
      const a = OiChartCrosshairConfig(width: 1.0);
      const b = OiChartCrosshairConfig(width: 2.0);
      expect(a, isNot(equals(b)));
    });
  });

  group('OiChartCrosshairState', () {
    test('equality holds when all fields match', () {
      const ref = OiChartDataRef(seriesIndex: 0, dataIndex: 2);
      const a = OiChartCrosshairState(
        position: Offset(100, 50),
        snappedPosition: Offset(105, 52),
        normalizedX: 0.25,
        normalizedY: 0.17,
        snappedRef: ref,
      );
      const b = OiChartCrosshairState(
        position: Offset(100, 50),
        snappedPosition: Offset(105, 52),
        normalizedX: 0.25,
        normalizedY: 0.17,
        snappedRef: ref,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality when position differs', () {
      const a = OiChartCrosshairState(position: Offset(10, 20));
      const b = OiChartCrosshairState(position: Offset(30, 40));
      expect(a, isNot(equals(b)));
    });

    test('inequality when snappedRef differs', () {
      const a = OiChartCrosshairState(
        position: Offset(10, 20),
        snappedRef: OiChartDataRef(seriesIndex: 0, dataIndex: 0),
      );
      const b = OiChartCrosshairState(
        position: Offset(10, 20),
        snappedRef: OiChartDataRef(seriesIndex: 0, dataIndex: 1),
      );
      expect(a, isNot(equals(b)));
    });

    test('optional fields default to null', () {
      const state = OiChartCrosshairState(position: Offset(0, 0));
      expect(state.snappedPosition, isNull);
      expect(state.normalizedX, isNull);
      expect(state.normalizedY, isNull);
      expect(state.snappedRef, isNull);
    });
  });
}
