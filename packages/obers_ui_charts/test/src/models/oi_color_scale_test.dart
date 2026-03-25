import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiColorScale', () {
    test('linear maps endpoints correctly', () {
      final scale = OiColorScale.linear(
        minColor: const Color(0xFF0000FF),
        maxColor: const Color(0xFFFF0000),
        min: 0,
        max: 100,
      );

      expect(scale.resolve(0), const Color(0xFF0000FF));
      expect(scale.resolve(100), const Color(0xFFFF0000));
    });

    test('linear maps midpoint to interpolated color', () {
      final scale = OiColorScale.linear(
        minColor: const Color(0xFF000000),
        maxColor: const Color(0xFFFFFFFF),
        min: 0,
        max: 100,
      );

      final mid = scale.resolve(50);
      // Midpoint between black and white should be ~gray.
      expect(mid.red, closeTo(128, 2));
      expect(mid.green, closeTo(128, 2));
      expect(mid.blue, closeTo(128, 2));
    });

    test('linear clamps values outside range', () {
      final scale = OiColorScale.linear(
        minColor: const Color(0xFF0000FF),
        maxColor: const Color(0xFFFF0000),
        min: 0,
        max: 100,
      );

      // Below min → minColor.
      expect(scale.resolve(-50), const Color(0xFF0000FF));
      // Above max → maxColor.
      expect(scale.resolve(200), const Color(0xFFFF0000));
    });

    test('gradient maps across stops', () {
      final scale = OiColorScale.gradient(
        colors: const [Color(0xFF0000FF), Color(0xFF00FF00), Color(0xFFFF0000)],
        stops: const [0.0, 0.5, 1.0],
        min: 0,
        max: 100,
      );

      expect(scale.resolve(0), const Color(0xFF0000FF));
      expect(scale.resolve(50), const Color(0xFF00FF00));
      expect(scale.resolve(100), const Color(0xFFFF0000));
    });
  });
}
