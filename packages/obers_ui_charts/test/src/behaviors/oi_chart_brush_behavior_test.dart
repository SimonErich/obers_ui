import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

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
  late OiChartBrushBehavior behavior;
  late _TestController controller;
  late OiChartBehaviorContext behaviorContext;

  setUp(() {
    controller = _TestController();
    behaviorContext = OiChartBehaviorContext(
      buildContext: _FakeBuildContext(),
      controller: controller,
      viewport: const OiChartViewport(size: Size(400, 300)),
      hitTester: _TestHitTester(),
      theme: const OiChartThemeData(),
    );
    behavior = OiChartBrushBehavior()..attach(behaviorContext);
  });

  tearDown(() {
    if (behavior.isAttached) behavior.detach();
    controller.dispose();
  });

  group('OiChartBrushBehavior', () {
    test('is attached after attach()', () {
      expect(behavior.isAttached, isTrue);
    });

    test('is not attached after detach()', () {
      behavior.detach();
      expect(behavior.isAttached, isFalse);
    });

    test('currentSelection is null initially', () {
      expect(behavior.currentSelection, isNull);
    });

    test('isDragging is false initially', () {
      expect(behavior.isDragging, isFalse);
    });

    test('detach resets state safely', () {
      behavior.detach();
      expect(behavior.isAttached, isFalse);
      expect(behavior.currentSelection, isNull);
      expect(behavior.isDragging, isFalse);
    });

    test('repaintListenable is accessible when attached', () {
      expect(behavior.repaintListenable, isNotNull);
    });

    test('createPainter returns an OiChartBrushPainter', () {
      final painter = behavior.createPainter();
      expect(painter, isA<OiChartBrushPainter>());
    });

    test('painter references the behavior', () {
      final painter = behavior.createPainter();
      expect(painter.behavior, same(behavior));
    });

    test('drag gesture triggers onBrushStart', () {
      OiChartBrushSelection? startSelection;

      behavior
        ..detach()
        ..attach(behaviorContext);
      behavior =
          OiChartBrushBehavior(onBrushStart: (sel) => startSelection = sel)
            ..attach(behaviorContext)
            // Press inside plot area.
            // Move enough to trigger drag (> 8px minDragDistance).
            ..onPointerDown(
              const PointerDownEvent(pointer: 1, position: Offset(50, 150)),
            )
            ..onPointerMove(
              const PointerMoveEvent(
                pointer: 1,
                position: Offset(150, 150),
                delta: Offset(100, 0),
              ),
            );

      expect(startSelection, isNotNull);
      expect(behavior.isDragging, isTrue);
    });

    test('continued drag triggers onBrushUpdate', () {
      OiChartBrushSelection? updateSelection;

      behavior.detach();
      behavior =
          OiChartBrushBehavior(onBrushUpdate: (sel) => updateSelection = sel)
            ..attach(behaviorContext)
            ..onPointerDown(
              const PointerDownEvent(pointer: 1, position: Offset(50, 150)),
            )
            // First move starts the drag.
            ..onPointerMove(
              const PointerMoveEvent(
                pointer: 1,
                position: Offset(150, 150),
                delta: Offset(100, 0),
              ),
            )
            // Second move triggers onBrushUpdate.
            ..onPointerMove(
              const PointerMoveEvent(
                pointer: 1,
                position: Offset(200, 150),
                delta: Offset(50, 0),
              ),
            );

      expect(updateSelection, isNotNull);
    });

    test('pointer up after drag triggers onBrushEnd and resets state', () {
      OiChartBrushSelection? endSelection;

      behavior.detach();
      behavior = OiChartBrushBehavior(onBrushEnd: (sel) => endSelection = sel)
        ..attach(behaviorContext)
        ..onPointerDown(
          const PointerDownEvent(pointer: 1, position: Offset(50, 150)),
        )
        ..onPointerMove(
          const PointerMoveEvent(
            pointer: 1,
            position: Offset(200, 150),
            delta: Offset(150, 0),
          ),
        )
        ..onPointerUp(
          const PointerUpEvent(pointer: 1, position: Offset(200, 150)),
        );

      expect(endSelection, isNotNull);
      expect(behavior.isDragging, isFalse);
      expect(behavior.currentSelection, isNull);
    });

    test('pointer cancel resets state and clears selection', () {
      behavior
        ..onPointerDown(
          const PointerDownEvent(pointer: 1, position: Offset(50, 150)),
        )
        ..onPointerMove(
          const PointerMoveEvent(
            pointer: 1,
            position: Offset(200, 150),
            delta: Offset(150, 0),
          ),
        )
        ..onPointerCancel(const PointerCancelEvent());

      expect(behavior.isDragging, isFalse);
      expect(behavior.currentSelection, isNull);
    });

    test('disabled brush ignores pointer events', () {
      behavior.detach();
      behavior =
          OiChartBrushBehavior(config: const OiChartBrushConfig(enabled: false))
            ..attach(behaviorContext)
            ..onPointerDown(
              const PointerDownEvent(pointer: 1, position: Offset(50, 150)),
            )
            ..onPointerMove(
              const PointerMoveEvent(
                pointer: 1,
                position: Offset(200, 150),
                delta: Offset(150, 0),
              ),
            );

      expect(behavior.isDragging, isFalse);
      expect(behavior.currentSelection, isNull);
    });
  });

  group('OiChartBrushConfig', () {
    test('default config has enabled = true', () {
      const config = OiChartBrushConfig();
      expect(config.enabled, isTrue);
    });

    test('default axis is x', () {
      const config = OiChartBrushConfig();
      expect(config.axis, equals(OiChartBrushAxis.x));
    });

    test('default color is null (uses theme semi-transparent accent)', () {
      const config = OiChartBrushConfig();
      expect(config.color, isNull);
    });

    test('default borderColor is null', () {
      const config = OiChartBrushConfig();
      expect(config.borderColor, isNull);
    });

    test('default borderWidth is 1.0', () {
      const config = OiChartBrushConfig();
      expect(config.borderWidth, equals(1.0));
    });

    test('default minDragDistance is 8.0', () {
      const config = OiChartBrushConfig();
      expect(config.minDragDistance, equals(8.0));
    });

    test('equality holds when all fields match', () {
      const a = OiChartBrushConfig(
        axis: OiChartBrushAxis.xy,
        borderWidth: 2,
        minDragDistance: 12,
      );
      const b = OiChartBrushConfig(
        axis: OiChartBrushAxis.xy,
        borderWidth: 2,
        minDragDistance: 12,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality when enabled differs', () {
      const a = OiChartBrushConfig();
      const b = OiChartBrushConfig(enabled: false);
      expect(a, isNot(equals(b)));
    });

    test('inequality when axis differs', () {
      const a = OiChartBrushConfig();
      const b = OiChartBrushConfig(axis: OiChartBrushAxis.y);
      expect(a, isNot(equals(b)));
    });

    test('inequality when borderWidth differs', () {
      const a = OiChartBrushConfig();
      const b = OiChartBrushConfig(borderWidth: 3);
      expect(a, isNot(equals(b)));
    });

    test('inequality when minDragDistance differs', () {
      const a = OiChartBrushConfig();
      const b = OiChartBrushConfig(minDragDistance: 16);
      expect(a, isNot(equals(b)));
    });
  });

  group('OiChartBrushSelection', () {
    const startNorm = Offset(0.1, 0);
    const endNorm = Offset(0.6, 1);
    const startWidget = Offset(40, 0);
    const endWidget = Offset(240, 300);

    const selection = OiChartBrushSelection(
      startNormalized: startNorm,
      endNormalized: endNorm,
      startWidget: startWidget,
      endWidget: endWidget,
      axis: OiChartBrushAxis.x,
    );

    test('equality holds when all fields match', () {
      const other = OiChartBrushSelection(
        startNormalized: startNorm,
        endNormalized: endNorm,
        startWidget: startWidget,
        endWidget: endWidget,
        axis: OiChartBrushAxis.x,
      );

      expect(selection, equals(other));
      expect(selection.hashCode, equals(other.hashCode));
    });

    test('inequality when axis differs', () {
      const other = OiChartBrushSelection(
        startNormalized: startNorm,
        endNormalized: endNorm,
        startWidget: startWidget,
        endWidget: endWidget,
        axis: OiChartBrushAxis.y,
      );
      expect(selection, isNot(equals(other)));
    });

    test('inequality when startNormalized differs', () {
      const other = OiChartBrushSelection(
        startNormalized: Offset(0.2, 0),
        endNormalized: endNorm,
        startWidget: startWidget,
        endWidget: endWidget,
        axis: OiChartBrushAxis.x,
      );
      expect(selection, isNot(equals(other)));
    });

    test('xRange returns clamped min/max values', () {
      final (minX, maxX) = selection.xRange;
      expect(minX, closeTo(0.1, 0.001));
      expect(maxX, closeTo(0.6, 0.001));
    });

    test('xRange handles reversed start/end', () {
      const reversed = OiChartBrushSelection(
        startNormalized: Offset(0.8, 0),
        endNormalized: Offset(0.3, 1),
        startWidget: Offset(320, 0),
        endWidget: Offset(120, 300),
        axis: OiChartBrushAxis.x,
      );
      final (minX, maxX) = reversed.xRange;
      expect(minX, closeTo(0.3, 0.001));
      expect(maxX, closeTo(0.8, 0.001));
    });

    test('yRange returns clamped min/max values', () {
      final (minY, maxY) = selection.yRange;
      expect(minY, closeTo(0.0, 0.001));
      expect(maxY, closeTo(1.0, 0.001));
    });

    test('widgetRect is computed from startWidget and endWidget', () {
      final rect = selection.widgetRect;
      expect(rect, isA<Rect>());
      expect(rect.left, equals(40));
      expect(rect.right, equals(240));
      expect(rect.top, equals(0));
      expect(rect.bottom, equals(300));
    });

    test('toString contains OiChartBrushSelection', () {
      expect(selection.toString(), contains('OiChartBrushSelection'));
    });
  });
}
