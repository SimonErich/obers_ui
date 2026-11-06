// Tests do not require documentation comments.

import 'package:flutter/semantics.dart';
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

  group('semantics', () {
    SemanticsData dataOf(WidgetTester tester, String label) =>
        find.semantics.byLabel(label).evaluate().single.getSemanticsData();

    testWidgets('a slider with its value and increase / decrease', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      double? moved;
      await tester.pumpObers(
        OiSlider(
          value: 5,
          min: 0,
          max: 10,
          divisions: 10,
          semanticLabel: 'Volume',
          onChanged: (v) => moved = v,
        ),
      );

      final data = dataOf(tester, 'Volume');
      expect(data.flagsCollection.isSlider, isTrue);
      expect(data.value, '5');
      expect(data.increasedValue, '6');
      expect(data.decreasedValue, '4');

      tester.semantics.increase(find.semantics.byLabel('Volume'));
      expect(moved, 6);
      tester.semantics.decrease(find.semantics.byLabel('Volume'));
      expect(moved, 4);
      handle.dispose();
    });

    testWidgets('a continuous slider moves by a tenth of the range', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        OiSlider(
          value: 0.5,
          min: 0,
          max: 1,
          semanticLabel: 'Mix',
          onChanged: (_) {},
        ),
      );

      final data = dataOf(tester, 'Mix');
      expect(data.value, '0.5');
      expect(data.increasedValue, '0.6');
      handle.dispose();
    });

    testWidgets('offers increase / decrease, not scroll or tap', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        OiSlider(
          value: 5,
          min: 0,
          max: 10,
          semanticLabel: 'Vol',
          onChanged: (_) {},
        ),
      );

      expect(find.semantics.byAction(SemanticsAction.scrollLeft), findsNothing);
      expect(
        find.semantics.byAction(SemanticsAction.scrollRight),
        findsNothing,
      );
      expect(find.semantics.byAction(SemanticsAction.tap), findsNothing);
      expect(find.semantics.byAction(SemanticsAction.increase), findsOneWidget);
      handle.dispose();
    });

    testWidgets('says a value as it is shown: 0.25 stays 0.25', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        OiSlider(
          value: 0.25,
          min: 0,
          max: 1,
          divisions: 4,
          showLabels: true,
          semanticLabel: 'Step',
          onChanged: (_) {},
        ),
      );

      final data = dataOf(tester, 'Step');
      expect(data.value, '0.25');
      expect(data.increasedValue, '0.5');
      expect(data.decreasedValue, '0');
      handle.dispose();
    });

    testWidgets('no action past the ends, none when disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        OiSlider(
          value: 10,
          min: 0,
          max: 10,
          divisions: 10,
          semanticLabel: 'End',
          onChanged: (_) {},
        ),
      );
      var data = dataOf(tester, 'End');
      expect(data.hasAction(SemanticsAction.increase), isFalse);
      expect(data.hasAction(SemanticsAction.decrease), isTrue);

      await tester.pumpObers(
        const OiSlider(
          value: 5,
          min: 0,
          max: 10,
          semanticLabel: 'Off',
          enabled: false,
        ),
      );
      data = dataOf(tester, 'Off');
      expect(data.hasAction(SemanticsAction.increase), isFalse);
      expect(data.hasAction(SemanticsAction.decrease), isFalse);
      handle.dispose();
    });

    testWidgets('a range has one slider per thumb, kept in order', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      (double, double)? range;
      await tester.pumpObers(
        OiSlider(
          value: 2,
          secondaryValue: 8,
          min: 0,
          max: 10,
          divisions: 10,
          semanticLabel: 'Price',
          onRangeChanged: (a, b) => range = (a, b),
        ),
      );

      final nodes = find.semantics.byLabel('Price');
      expect(nodes, findsNWidgets(2));
      expect(nodes.evaluate().first.getSemanticsData().value, '2');
      expect(nodes.evaluate().last.getSemanticsData().value, '8');

      tester.semantics.increase(find.semantics.byLabel('Price').first);
      expect(range, (3.0, 8.0));
      tester.semantics.decrease(find.semantics.byLabel('Price').last);
      expect(range, (2.0, 7.0));
      handle.dispose();
    });
  });
}
