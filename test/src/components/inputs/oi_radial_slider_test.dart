// Tests do not require documentation comments.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

const double _start = 3 * math.pi / 4; // 135°
const double _sweep = 3 * math.pi / 2; // 270°

Widget _dial({
  double value = 30,
  double min = 0,
  double max = 100,
  double? step,
  double size = 200,
  bool enabled = true,
  ValueChanged<double>? onChanged,
}) {
  return Center(
    child: OiRadialSlider(
      value: value,
      min: min,
      max: max,
      step: step,
      size: size,
      enabled: enabled,
      onChanged: onChanged,
    ),
  );
}

void main() {
  group('OiRadialSliderGeometry', () {
    test('angleForValue spans the sweep from min to max', () {
      expect(
        OiRadialSliderGeometry.angleForValue(
          value: 0,
          min: 0,
          max: 100,
          startAngle: _start,
          sweepAngle: _sweep,
        ),
        closeTo(_start, 1e-9),
      );
      expect(
        OiRadialSliderGeometry.angleForValue(
          value: 100,
          min: 0,
          max: 100,
          startAngle: _start,
          sweepAngle: _sweep,
        ),
        closeTo(_start + _sweep, 1e-9),
      );
      expect(
        OiRadialSliderGeometry.angleForValue(
          value: 50,
          min: 0,
          max: 100,
          startAngle: _start,
          sweepAngle: _sweep,
        ),
        closeTo(_start + _sweep / 2, 1e-9),
      );
    });

    test('valueForAngle inverts angleForValue on the arc', () {
      expect(
        OiRadialSliderGeometry.valueForAngle(
          angle: _start,
          min: 0,
          max: 100,
          startAngle: _start,
          sweepAngle: _sweep,
        ),
        closeTo(0, 1e-9),
      );
      // 12 o'clock (−90°) sits at the midpoint of the default arc.
      expect(
        OiRadialSliderGeometry.valueForAngle(
          angle: -math.pi / 2,
          min: 0,
          max: 100,
          startAngle: _start,
          sweepAngle: _sweep,
        ),
        closeTo(50, 1e-9),
      );
    });

    test('valueForAngle snaps gap angles to the nearest end', () {
      // Just past the arc end → clamps to max.
      expect(
        OiRadialSliderGeometry.valueForAngle(
          angle: _start + _sweep + 0.1,
          min: 0,
          max: 100,
          startAngle: _start,
          sweepAngle: _sweep,
        ),
        closeTo(100, 1e-9),
      );
      // Just before the arc start → clamps to min.
      expect(
        OiRadialSliderGeometry.valueForAngle(
          angle: _start - 0.1,
          min: 0,
          max: 100,
          startAngle: _start,
          sweepAngle: _sweep,
        ),
        closeTo(0, 1e-9),
      );
    });

    test('offsetForAngle places points on the circle', () {
      final east = OiRadialSliderGeometry.offsetForAngle(
        angle: 0,
        center: Offset.zero,
        radius: 10,
      );
      expect(east.dx, closeTo(10, 1e-9));
      expect(east.dy, closeTo(0, 1e-9));
    });
  });

  group('OiRadialSlider', () {
    testWidgets('renders and shows the value', (tester) async {
      await tester.pumpObers(_dial());
      expect(find.byType(OiRadialSlider), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('dragging to the top sets the mid value', (tester) async {
      double? changed;
      await tester.pumpObers(_dial(onChanged: (v) => changed = v));
      final painter = find.byKey(const Key('oi_radial_slider_painter'));
      final center = tester.getCenter(painter);
      final topCenter = Offset(center.dx, tester.getTopLeft(painter).dy + 1);
      final gesture = await tester.startGesture(center);
      await gesture.moveTo(topCenter);
      await gesture.up();
      await tester.pump();
      expect(changed, isNotNull);
      expect(changed, closeTo(50, 1.5));
    });

    testWidgets('snaps to the step increment', (tester) async {
      double? changed;
      await tester.pumpObers(_dial(step: 7, onChanged: (v) => changed = v));
      final painter = find.byKey(const Key('oi_radial_slider_painter'));
      final center = tester.getCenter(painter);
      final topCenter = Offset(center.dx, tester.getTopLeft(painter).dy + 1);
      final gesture = await tester.startGesture(center);
      await gesture.moveTo(topCenter);
      await gesture.up();
      await tester.pump();
      // ~50 snapped to the nearest multiple of 7 → 49.
      expect(changed, closeTo(49, 0.001));
    });

    testWidgets('does not fire onChanged when disabled', (tester) async {
      double? changed;
      await tester.pumpObers(
        _dial(enabled: false, onChanged: (v) => changed = v),
      );
      final painter = find.byKey(const Key('oi_radial_slider_painter'));
      final center = tester.getCenter(painter);
      final gesture = await tester.startGesture(center);
      await gesture.moveTo(Offset(center.dx, center.dy - 80));
      await gesture.up();
      await tester.pump();
      expect(changed, isNull);
    });

    testWidgets('exposes slider semantics with the current value', (
      tester,
    ) async {
      await tester.pumpObers(_dial());
      final semantics = tester.getSemantics(
        find.byKey(const Key('oi_radial_slider_painter')),
      );
      expect(semantics.flagsCollection.isSlider, isTrue);
      expect(semantics.value, '30');
    });
  });
}
