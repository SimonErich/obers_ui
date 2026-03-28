
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiSeriesFill', () {
    test('solid fill has color and no gradient', () {
      const fill = OiSeriesFill.solid(Color(0xFFFF0000));
      expect(fill.isSolid, isTrue);
      expect(fill.isGradient, isFalse);
      expect(fill.color, const Color(0xFFFF0000));
      expect(fill.gradient, isNull);
    });

    test('gradient fill has gradient and no color', () {
      const gradient = LinearGradient(
        colors: [Color(0xFFFF0000), Color(0xFF0000FF)],
      );
      const fill = OiSeriesFill.gradient(gradient);
      expect(fill.isGradient, isTrue);
      expect(fill.isSolid, isFalse);
      expect(fill.gradient, gradient);
      expect(fill.color, isNull);
    });

    test('equality', () {
      const a = OiSeriesFill.solid(Color(0xFFFF0000));
      const b = OiSeriesFill.solid(Color(0xFFFF0000));
      const c = OiSeriesFill.solid(Color(0xFF00FF00));
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('OiSeriesStyle', () {
    test('merge prefers override values', () {
      const base = OiSeriesStyle(
        strokeColor: Color(0xFFFF0000),
        strokeWidth: 2,
        strokeCap: StrokeCap.round,
      );
      const override = OiSeriesStyle(
        strokeColor: Color(0xFF00FF00),
        dashPattern: [4, 2],
      );

      final merged = base.merge(override);
      expect(merged.strokeColor, const Color(0xFF00FF00));
      expect(merged.strokeWidth, 2.0);
      expect(merged.strokeCap, StrokeCap.round);
      expect(merged.dashPattern, [4, 2]);
    });

    test('merge with null returns self', () {
      const style = OiSeriesStyle(strokeWidth: 3);
      expect(style.merge(null), same(style));
    });

    test('hover/selected/inactive overrides merge correctly', () {
      const base = OiSeriesStyle(
        strokeColor: Color(0xFFFF0000),
        strokeWidth: 2,
        hoverStyle: OiSeriesStyle(strokeWidth: 4),
        selectedStyle: OiSeriesStyle(
          strokeColor: Color(0xFF0000FF),
          strokeWidth: 3,
        ),
        inactiveStyle: OiSeriesStyle(strokeWidth: 1),
      );

      // Merge base with hover override.
      final hovered = base.merge(base.hoverStyle);
      expect(hovered.strokeWidth, 4.0);
      expect(hovered.strokeColor, const Color(0xFFFF0000));

      // Merge base with selected override.
      final selected = base.merge(base.selectedStyle);
      expect(selected.strokeWidth, 3.0);
      expect(selected.strokeColor, const Color(0xFF0000FF));

      // Merge base with inactive override.
      final inactive = base.merge(base.inactiveStyle);
      expect(inactive.strokeWidth, 1.0);
    });

    test('equality', () {
      const a = OiSeriesStyle(
        strokeColor: Color(0xFFFF0000),
        dashPattern: [4, 2],
      );
      const b = OiSeriesStyle(
        strokeColor: Color(0xFFFF0000),
        dashPattern: [4, 2],
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith preserves unset fields', () {
      const style = OiSeriesStyle(
        strokeColor: Color(0xFFFF0000),
        strokeWidth: 2,
      );
      final copied = style.copyWith(strokeWidth: 5);
      expect(copied.strokeColor, const Color(0xFFFF0000));
      expect(copied.strokeWidth, 5.0);
    });
  });
}
