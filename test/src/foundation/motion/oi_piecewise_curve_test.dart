import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

// Literal stops from the original --vl-ease-spring CSS, not fitted physics.
const List<Offset> _springStops = [
  Offset.zero,
  Offset(.006, .013),
  Offset(.012, .05),
  Offset(.025, .2),
  Offset(.043, .44),
  Offset(.068, .74),
  Offset(.091, .92),
  Offset(.116, 1.04),
  Offset(.145, 1.1),
  Offset(.17, 1.107),
  Offset(.204, 1.09),
  Offset(.265, 1.03),
  Offset(.309, 1.004),
  Offset(.364, .992),
  Offset(.48, .996),
  Offset(1, 1),
];

void main() {
  test('piecewise motion retains every authored spring stop and overshoot', () {
    final curve = OiPiecewiseCurve(_springStops);
    for (final stop in _springStops) {
      expect(curve.transform(stop.dx), closeTo(stop.dy, 1e-12));
    }
    // Independently worked segment midpoints, including return from overshoot.
    expect(curve.transform(.1575), closeTo(1.1035, 1e-12));
    expect(curve.transform(.187), closeTo(1.0985, 1e-12));
    expect(curve.transform(.3365), closeTo(.998, 1e-12));
    expect(curve.transform(.74), closeTo(.998, 1e-12));
    expect(curve.transform(.17), greaterThan(1));
    expect(curve.transform(0), 0);
    expect(curve.transform(1), 1);
  });

  test('later caller edits cannot change an already authored motion curve', () {
    final stops = [Offset.zero, const Offset(.5, .75), const Offset(1, 1)];
    final curve = OiPiecewiseCurve(stops);
    stops[1] = const Offset(.5, -9);
    expect(curve.transform(.5), .75);
    stops.clear();
    expect(curve.transform(.25), .375);
  });

  test(
    'invalid motion stops are rejected before an animation can use them',
    () {
      for (final stops in <List<Offset>>[
        [],
        [Offset.zero],
        [const Offset(.1, 0), const Offset(1, 1)],
        [const Offset(0, .1), const Offset(1, 1)],
        [Offset.zero, const Offset(.9, 1)],
        [Offset.zero, const Offset(1, .9)],
        [
          Offset.zero,
          const Offset(.5, 1),
          const Offset(.5, .8),
          const Offset(1, 1),
        ],
        [
          Offset.zero,
          const Offset(.6, .8),
          const Offset(.4, .9),
          const Offset(1, 1),
        ],
        [Offset.zero, const Offset(-.1, .5), const Offset(1, 1)],
        [Offset.zero, const Offset(1.1, .5), const Offset(1, 1)],
        [Offset.zero, const Offset(double.nan, .5), const Offset(1, 1)],
        [Offset.zero, const Offset(.5, double.infinity), const Offset(1, 1)],
        [Offset.zero, const Offset(.5, double.nan), const Offset(1, 1)],
      ]) {
        expect(() => OiPiecewiseCurve(stops), throwsArgumentError);
      }
    },
  );

  test(
    'finite opposite-sign stops interpolate without overflowing a delta',
    () {
      final curve = OiPiecewiseCurve(const [
        Offset.zero,
        Offset(.25, -double.maxFinite),
        Offset(.75, double.maxFinite),
        Offset(1, 1),
      ]);
      expect(curve.transform(.5), 0);
      expect(curve.transform(.25), -double.maxFinite);
      expect(curve.transform(.75), double.maxFinite);
    },
  );

  test('authored constant segments preserve their finite output exactly', () {
    for (final value in [double.minPositive, double.maxFinite]) {
      final curve = OiPiecewiseCurve([
        Offset.zero,
        Offset(.25, value),
        Offset(.75, value),
        const Offset(1, 1),
      ]);
      expect(curve.transform(.5), value);
      expect(curve.transform(.45), value);
    }
  });

  testWidgets(
    'authored spring follows the controller clock and reverses in place',
    (
      tester,
    ) async {
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 320),
      );
      final animation = CurvedAnimation(
        parent: controller,
        curve: OiPiecewiseCurve(_springStops),
      );
      try {
        controller.forward();
        await tester.pump();
        await tester.pump(const Duration(microseconds: 54400));
        expect(controller.value, closeTo(.17, 1e-12));
        expect(animation.value, closeTo(1.107, 1e-12));
        controller.reverse();
        expect(animation.value, closeTo(1.107, 1e-12));
        await tester.pump();
        await tester.pump(const Duration(microseconds: 27200));
        expect(controller.value, closeTo(.085, 1e-12));
        expect(animation.value, closeTo(.8730434782608696, 1e-12));
        await tester.pump(const Duration(microseconds: 27200));
        expect(animation.value, 0);
        // SDK simulation completion is strictly past the duration, not at it.
        await tester.pump(const Duration(microseconds: 1));
        expect(controller.isAnimating, isFalse);
      } finally {
        animation.dispose();
        controller.dispose();
      }
    },
  );
}
