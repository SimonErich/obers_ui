import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiChartAnnotation', () {
    test('horizontalLine factory creates correct type', () {
      const annotation = OiChartAnnotation.horizontalLine(
        value: 50,
        label: 'Target',
      );
      expect(annotation.type, OiAnnotationType.horizontalLine);
      expect(annotation.value, 50);
      expect(annotation.label, 'Target');
      expect(annotation.visible, isTrue);
    });

    test('verticalLine factory creates correct type', () {
      const annotation = OiChartAnnotation.verticalLine(
        value: 100,
        label: 'Deadline',
      );
      expect(annotation.type, OiAnnotationType.verticalLine);
      expect(annotation.value, 100);
    });

    test('region factory creates correct type with range', () {
      const annotation = OiChartAnnotation.region(
        start: 10,
        end: 50,
        label: 'Safe zone',
      );
      expect(annotation.type, OiAnnotationType.region);
      expect(annotation.start, 10);
      expect(annotation.end, 50);
    });

    test('equality', () {
      const a = OiChartAnnotation.horizontalLine(value: 50, label: 'A');
      const b = OiChartAnnotation.horizontalLine(value: 50, label: 'A');
      const c = OiChartAnnotation.horizontalLine(value: 75, label: 'A');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('OiAnnotationStyle', () {
    test('copyWith preserves unset fields', () {
      const style = OiAnnotationStyle(
        color: Color(0xFFFF0000),
        strokeWidth: 2.0,
        dashPattern: [4, 2],
      );
      final copied = style.copyWith(strokeWidth: 3.0);
      expect(copied.color, const Color(0xFFFF0000));
      expect(copied.strokeWidth, 3.0);
      expect(copied.dashPattern, [4, 2]);
    });

    test('equality', () {
      const a = OiAnnotationStyle(
        color: Color(0xFFFF0000),
        dashPattern: [4, 2],
      );
      const b = OiAnnotationStyle(
        color: Color(0xFFFF0000),
        dashPattern: [4, 2],
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('OiChartThreshold', () {
    test('creates with required value', () {
      const threshold = OiChartThreshold(value: 100, label: 'Max');
      expect(threshold.value, 100);
      expect(threshold.label, 'Max');
      expect(threshold.showLabel, isTrue);
      expect(threshold.labelPosition, OiThresholdLabelPosition.end);
    });

    test('equality', () {
      const a = OiChartThreshold(value: 100, label: 'Max');
      const b = OiChartThreshold(value: 100, label: 'Max');
      const c = OiChartThreshold(value: 200, label: 'Max');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
