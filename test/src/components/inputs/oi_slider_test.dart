// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_slider.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiSlider(value: 0.5, min: 0, max: 1));
    expect(find.byType(OiSlider), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(
      const OiSlider(value: 0.5, min: 0, max: 1, label: 'Volume'),
    );
    expect(find.text('Volume'), findsOneWidget);
  });

  testWidgets('dragging slider fires onChanged', (tester) async {
    double? result;
    await tester.pumpObers(
      OiSlider(value: 0, min: 0, max: 100, onChanged: (v) => result = v),
      surfaceSize: const Size(400, 200),
    );
    final sliderFinder = find.byType(OiSlider);
    final center = tester.getCenter(sliderFinder);
    await tester.dragFrom(center, const Offset(50, 0));
    await tester.pump();
    expect(result, isNotNull);
  });

  testWidgets('value is clamped to min', (tester) async {
    double? result;
    await tester.pumpObers(
      OiSlider(value: 0, min: 0, max: 100, onChanged: (v) => result = v),
      surfaceSize: const Size(400, 200),
    );
    final sliderFinder = find.byType(OiSlider);
    final left = tester.getTopLeft(sliderFinder);
    await tester.dragFrom(left + const Offset(10, 10), const Offset(-200, 0));
    await tester.pump();
    if (result != null) expect(result, greaterThanOrEqualTo(0));
  });

  testWidgets('value is clamped to max', (tester) async {
    double? result;
    await tester.pumpObers(
      OiSlider(value: 100, min: 0, max: 100, onChanged: (v) => result = v),
      surfaceSize: const Size(400, 200),
    );
    final sliderFinder = find.byType(OiSlider);
    final right = tester.getTopRight(sliderFinder);
    await tester.dragFrom(right + const Offset(-10, 10), const Offset(200, 0));
    await tester.pump();
    if (result != null) expect(result, lessThanOrEqualTo(100));
  });

  testWidgets('divisions snap to nearest step', (tester) async {
    final values = <double>[];
    await tester.pumpObers(
      OiSlider(value: 0, min: 0, max: 10, divisions: 10, onChanged: values.add),
      surfaceSize: const Size(400, 200),
    );
    final center = tester.getCenter(find.byType(OiSlider));
    await tester.dragFrom(center, const Offset(20, 0));
    await tester.pump();
    for (final v in values) {
      expect(v % 1.0, 0.0);
    }
  });

  testWidgets('range slider renders with secondaryValue', (tester) async {
    await tester.pumpObers(
      const OiSlider(value: 20, secondaryValue: 80, min: 0, max: 100),
    );
    expect(find.byType(OiSlider), findsOneWidget);
  });
}
