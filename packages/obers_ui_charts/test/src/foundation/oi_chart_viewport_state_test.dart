import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiChartViewportState', () {
    test('defaults to no zoom and no pan', () {
      final state = OiChartViewportState();
      expect(state.zoomLevel, 1.0);
      expect(state.panOffset, Offset.zero);
      expect(state.isZoomed, isFalse);
    });

    test('isZoomed returns true when zoom != 1', () {
      final state = OiChartViewportState(zoomLevel: 2);
      expect(state.isZoomed, isTrue);
    });

    test('isZoomed returns true when pan is non-zero', () {
      final state = OiChartViewportState(panOffset: const Offset(10, 0));
      expect(state.isZoomed, isTrue);
    });

    test('zoom is clamped to 0.1..100', () {
      final state = OiChartViewportState()..zoomLevel = 0.01;
      expect(state.zoomLevel, 0.1);
      state.zoomLevel = 200;
      expect(state.zoomLevel, 100.0);
    });

    test('reset restores defaults', () {
      final state = OiChartViewportState(
        xMin: 10,
        xMax: 100,
        yMin: 0,
        yMax: 50,
        zoomLevel: 3,
        panOffset: const Offset(20, 30),
      );
      expect(state.isZoomed, isTrue);

      state.reset();

      expect(state.zoomLevel, 1.0);
      expect(state.panOffset, Offset.zero);
      expect(state.xMin, isNull);
      expect(state.xMax, isNull);
      expect(state.yMin, isNull);
      expect(state.yMax, isNull);
      expect(state.isZoomed, isFalse);
    });

    test('copyWith creates independent copy', () {
      final original = OiChartViewportState(xMin: 5, zoomLevel: 2);
      final copy = original.copyWith(xMax: 100);
      expect(copy.xMin, 5);
      expect(copy.xMax, 100);
      expect(copy.zoomLevel, 2.0);

      // Mutations on copy don't affect original.
      copy.xMin = 99;
      expect(original.xMin, 5);
    });
  });
}
