import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_layout.dart';

void main() {
  test('section spacing preserves real categories and pointer gaps', () {
    final geometry = BarCategoryLayout(
      plot: const Rect.fromLTWH(40, 8, 329, 150),
      groups: [
        for (var i = 0; i < 10; i++)
          if (i < 5) 'Week 1' else 'Week 2',
      ],
      barWidth: 18,
      sectionSpacing: 24,
    );
    expect(geometry.bars, hasLength(10));
    expect(geometry.bars.first.left, 48);
    expect(geometry.bars.first.width, 18);
    expect(geometry.bars.last.right, 361);
    expect(
      geometry.sections[1].bounds.left - geometry.sections[0].bounds.right,
      24,
    );
    for (var i = 0; i < 10; i++) {
      expect(geometry.categoryAt(geometry.bars[i].center.dx), i);
    }
    expect(geometry.categoryAt(geometry.sections[0].bounds.right + 12), isNull);
  });
  test(
    'narrow sections clamp gaps and bar width without inverted geometry',
    () {
      final geometry = BarCategoryLayout(
        plot: const Rect.fromLTWH(0, 0, 40, 50),
        groups: ['a', 'a', 'b'],
        barWidth: 18,
        sectionSpacing: 100,
      );
      expect(
        geometry.bars.every((r) => r.width > 0 && r.left >= 0 && r.right <= 40),
        isTrue,
      );
    },
  );
}
