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

class _FakeResolver implements OiChartTooltipEntryResolver {
  @override
  OiChartTooltipModel resolve({
    required List<OiChartHitResult> hits,
    required Offset pointerPosition,
    required Offset globalPosition,
    required OiChartViewport viewport,
  }) {
    return OiChartTooltipModel(
      globalPosition: globalPosition,
      entries: const [
        OiChartTooltipEntry(
          seriesLabel: 'Series A',
          formattedX: '1',
          formattedY: '10',
        ),
      ],
    );
  }
}

void main() {
  late OiChartTooltipBehavior behavior;
  late _TestController controller;
  late OiChartBehaviorContext behaviorContext;

  setUp(() {
    behavior = OiChartTooltipBehavior(resolver: _FakeResolver());
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
    if (behavior.isAttached) behavior.detach();
    controller.dispose();
  });

  group('OiChartTooltipBehavior', () {
    test('is attached after attach()', () {
      expect(behavior.isAttached, isTrue);
    });

    test('is not attached after detach()', () {
      behavior.detach();
      expect(behavior.isAttached, isFalse);
    });

    test('detach clears currentModel', () {
      // No model is set since we never triggered a pointer event.
      expect(behavior.currentModel, isNull);
      behavior.detach();
      expect(behavior.currentModel, isNull);
    });

    test('detach and reattach is safe', () {
      behavior.detach();
      expect(behavior.isAttached, isFalse);
      // OiChartTooltipBehavior does not dispose internal notifiers,
      // so it is safe to reattach the same instance.
      behavior.attach(behaviorContext);
      expect(behavior.isAttached, isTrue);
    });

    test('currentModel starts as null', () {
      expect(behavior.currentModel, isNull);
    });

    test('isAttached reflects attachment state', () {
      expect(behavior.isAttached, isTrue);
      behavior.detach();
      expect(behavior.isAttached, isFalse);
    });
  });

  group('OiChartTooltipConfig', () {
    test('default config has enabled = true', () {
      const config = OiChartTooltipConfig();
      expect(config.enabled, isTrue);
    });

    test('default trigger mode is both', () {
      const config = OiChartTooltipConfig();
      expect(config.trigger, equals(OiChartTooltipTrigger.both));
    });

    test('default anchor mode is nearestPoint', () {
      const config = OiChartTooltipConfig();
      expect(config.anchor, equals(OiChartTooltipAnchor.nearestPoint));
    });

    test('default showDelay is 200ms', () {
      const config = OiChartTooltipConfig();
      expect(config.showDelay, equals(const Duration(milliseconds: 200)));
    });

    test('default hideDelay is 100ms', () {
      const config = OiChartTooltipConfig();
      expect(config.hideDelay, equals(const Duration(milliseconds: 100)));
    });

    test('default hitTestTolerance is 24.0', () {
      const config = OiChartTooltipConfig();
      expect(config.hitTestTolerance, equals(24.0));
    });

    test('default builder is null', () {
      const config = OiChartTooltipConfig();
      expect(config.builder, isNull);
    });

    test('equality holds when all fields match', () {
      const a = OiChartTooltipConfig(
        trigger: OiChartTooltipTrigger.hover,
        anchor: OiChartTooltipAnchor.pointer,
        showDelay: Duration(milliseconds: 300),
        hideDelay: Duration(milliseconds: 150),
        hitTestTolerance: 16,
      );
      const b = OiChartTooltipConfig(
        trigger: OiChartTooltipTrigger.hover,
        anchor: OiChartTooltipAnchor.pointer,
        showDelay: Duration(milliseconds: 300),
        hideDelay: Duration(milliseconds: 150),
        hitTestTolerance: 16,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality when enabled differs', () {
      const a = OiChartTooltipConfig();
      const b = OiChartTooltipConfig(enabled: false);
      expect(a, isNot(equals(b)));
    });

    test('inequality when trigger differs', () {
      const a = OiChartTooltipConfig(trigger: OiChartTooltipTrigger.hover);
      const b = OiChartTooltipConfig(trigger: OiChartTooltipTrigger.tap);
      expect(a, isNot(equals(b)));
    });

    test('inequality when anchor differs', () {
      const a = OiChartTooltipConfig(anchor: OiChartTooltipAnchor.pointer);
      const b = OiChartTooltipConfig(anchor: OiChartTooltipAnchor.xAxis);
      expect(a, isNot(equals(b)));
    });
  });

  group('OiChartTooltipModel', () {
    const entry = OiChartTooltipEntry(
      seriesLabel: 'Revenue',
      formattedX: 'Jan',
      formattedY: r'$1,000',
    );

    test('equality holds when all fields match', () {
      const a = OiChartTooltipModel(
        globalPosition: Offset(100, 50),
        entries: [entry],
        title: 'Q1',
        footer: 'Source: data',
        anchorPosition: Offset(10, 20),
      );
      const b = OiChartTooltipModel(
        globalPosition: Offset(100, 50),
        entries: [entry],
        title: 'Q1',
        footer: 'Source: data',
        anchorPosition: Offset(10, 20),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality when globalPosition differs', () {
      const a = OiChartTooltipModel(
        globalPosition: Offset(100, 50),
        entries: [],
      );
      const b = OiChartTooltipModel(
        globalPosition: Offset(200, 50),
        entries: [],
      );
      expect(a, isNot(equals(b)));
    });

    test('inequality when entries differ', () {
      const a = OiChartTooltipModel(
        globalPosition: Offset.zero,
        entries: [entry],
      );
      const b = OiChartTooltipModel(globalPosition: Offset.zero, entries: []);
      expect(a, isNot(equals(b)));
    });

    test('inequality when title differs', () {
      const a = OiChartTooltipModel(
        globalPosition: Offset.zero,
        entries: [],
        title: 'A',
      );
      const b = OiChartTooltipModel(
        globalPosition: Offset.zero,
        entries: [],
        title: 'B',
      );
      expect(a, isNot(equals(b)));
    });

    test('title and footer default to null', () {
      const model = OiChartTooltipModel(
        globalPosition: Offset.zero,
        entries: [],
      );
      expect(model.title, isNull);
      expect(model.footer, isNull);
      expect(model.anchorPosition, isNull);
    });

    test('toString contains entry count and title', () {
      const model = OiChartTooltipModel(
        globalPosition: Offset(10, 20),
        entries: [entry],
        title: 'MyTitle',
      );
      final s = model.toString();
      expect(s, contains('1'));
      expect(s, contains('MyTitle'));
    });
  });

  group('OiChartTooltipEntry', () {
    test('equality holds when all fields match', () {
      const a = OiChartTooltipEntry(
        seriesLabel: 'Revenue',
        formattedX: 'Jan',
        formattedY: '100',
        pointLabel: 'Peak',
        color: Color(0xFFFF0000),
        ref: OiChartDataRef(seriesIndex: 0, dataIndex: 3),
      );
      const b = OiChartTooltipEntry(
        seriesLabel: 'Revenue',
        formattedX: 'Jan',
        formattedY: '100',
        pointLabel: 'Peak',
        color: Color(0xFFFF0000),
        ref: OiChartDataRef(seriesIndex: 0, dataIndex: 3),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality when seriesLabel differs', () {
      const a = OiChartTooltipEntry(
        seriesLabel: 'A',
        formattedX: 'x',
        formattedY: 'y',
      );
      const b = OiChartTooltipEntry(
        seriesLabel: 'B',
        formattedX: 'x',
        formattedY: 'y',
      );
      expect(a, isNot(equals(b)));
    });

    test('inequality when formattedY differs', () {
      const a = OiChartTooltipEntry(
        seriesLabel: 'A',
        formattedX: 'x',
        formattedY: '10',
      );
      const b = OiChartTooltipEntry(
        seriesLabel: 'A',
        formattedX: 'x',
        formattedY: '20',
      );
      expect(a, isNot(equals(b)));
    });

    test('inequality when ref differs', () {
      const a = OiChartTooltipEntry(
        seriesLabel: 'A',
        formattedX: 'x',
        formattedY: 'y',
        ref: OiChartDataRef(seriesIndex: 0, dataIndex: 0),
      );
      const b = OiChartTooltipEntry(
        seriesLabel: 'A',
        formattedX: 'x',
        formattedY: 'y',
        ref: OiChartDataRef(seriesIndex: 0, dataIndex: 1),
      );
      expect(a, isNot(equals(b)));
    });

    test('optional fields default to null', () {
      const entry = OiChartTooltipEntry(
        seriesLabel: 'S',
        formattedX: 'x',
        formattedY: 'y',
      );
      expect(entry.pointLabel, isNull);
      expect(entry.color, isNull);
      expect(entry.ref, isNull);
    });

    test('toString contains seriesLabel', () {
      const entry = OiChartTooltipEntry(
        seriesLabel: 'Revenue',
        formattedX: 'Jan',
        formattedY: '500',
      );
      expect(entry.toString(), contains('Revenue'));
    });
  });
}
