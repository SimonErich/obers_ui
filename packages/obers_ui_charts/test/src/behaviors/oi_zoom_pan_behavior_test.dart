import 'package:flutter/gestures.dart';
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

void main() {
  late OiZoomPanBehavior behavior;
  late _TestController controller;
  late OiChartBehaviorContext behaviorContext;

  setUp(() {
    behavior = OiZoomPanBehavior();
    controller = _TestController();

    behaviorContext = OiChartBehaviorContext(
      buildContext: _FakeBuildContext(),
      controller: controller,
      viewport: const OiChartViewport(size: Size(400, 300)),
      hitTester: _TestHitTester(),
      theme: const OiChartThemeData(),
    );

    behavior.attach(behaviorContext);
  });

  tearDown(() {
    behavior.detach();
    controller.dispose();
  });

  group('OiZoomPanBehavior', () {
    test('scroll up zooms in', () {
      const event = PointerScrollEvent(
        position: Offset(200, 150),
        scrollDelta: Offset(0, -120),
      );
      behavior.onPointerScroll(event);
      expect(controller.viewportState.zoomLevel, greaterThan(1.0));
    });

    test('scroll down zooms out', () {
      // First zoom in.
      controller.viewportState.zoomLevel = 2.0;

      const event = PointerScrollEvent(
        position: Offset(200, 150),
        scrollDelta: Offset(0, 120),
      );
      behavior.onPointerScroll(event);
      expect(controller.viewportState.zoomLevel, lessThan(2.0));
    });

    test('zoom is clamped to min/max', () {
      // Zoom way in.
      for (var i = 0; i < 100; i++) {
        behavior.onPointerScroll(
          const PointerScrollEvent(
            position: Offset(200, 150),
            scrollDelta: Offset(0, -120),
          ),
        );
      }
      expect(controller.viewportState.zoomLevel, lessThanOrEqualTo(20.0));

      // Zoom way out.
      for (var i = 0; i < 200; i++) {
        behavior.onPointerScroll(
          const PointerScrollEvent(
            position: Offset(200, 150),
            scrollDelta: Offset(0, 120),
          ),
        );
      }
      expect(controller.viewportState.zoomLevel, greaterThanOrEqualTo(0.5));
    });

    test('drag pan updates pan offset', () {
      behavior
        ..onPointerDown(
          const PointerDownEvent(pointer: 1, position: Offset(100, 100)),
        )
        ..onPointerMove(
          const PointerMoveEvent(
            pointer: 1,
            position: Offset(150, 120),
            delta: Offset(50, 20),
          ),
        );

      expect(controller.viewportState.panOffset, const Offset(50, 20));
    });

    test('onZoomChanged callback fires', () {
      double? reportedZoom;
      Offset? reportedPan;

      behavior.detach();
      behavior =
          OiZoomPanBehavior(
              onZoomChanged: (zoom, pan) {
                reportedZoom = zoom;
                reportedPan = pan;
              },
            )
            ..attach(behaviorContext)
            ..onPointerScroll(
              const PointerScrollEvent(
                position: Offset(200, 150),
                scrollDelta: Offset(0, -120),
              ),
            );

      expect(reportedZoom, isNotNull);
      expect(reportedPan, isNotNull);
    });

    test('wheel zoom disabled when config says so', () {
      behavior.detach();
      behavior =
          OiZoomPanBehavior(
              config: const OiZoomPanConfig(enableWheelZoom: false),
            )
            ..attach(behaviorContext)
            ..onPointerScroll(
              const PointerScrollEvent(
                position: Offset(200, 150),
                scrollDelta: Offset(0, -120),
              ),
            );

      expect(controller.viewportState.zoomLevel, 1.0);
    });
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}
