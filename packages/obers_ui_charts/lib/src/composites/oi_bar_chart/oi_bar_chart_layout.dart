import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Shared category geometry for painting, labels and pointer hit testing.
class BarCategoryLayout {
  /// Resolves contiguous labelled sections without introducing fake data points.
  BarCategoryLayout({
    required Rect plot,
    required List<String?> groups,
    double? barWidth,
    double sectionSpacing = 0,
  }) {
    if (groups.isEmpty) return;
    final ranges = <({int start, int end})>[];
    var start = 0;
    while (start < groups.length) {
      var end = start + 1;
      while (end < groups.length && groups[end] == groups[start]) {
        end++;
      }
      ranges.add((start: start, end: end));
      start = end;
    }
    final gap = sectionSpacing.clamp(
      0,
      plot.width / math.max(1, ranges.length * 2),
    );
    final usable = math.max(0, plot.width - gap * (ranges.length - 1));
    var x = plot.left;
    for (final range in ranges) {
      final count = range.end - range.start;
      final width = usable * count / groups.length;
      final section = Rect.fromLTWH(x, plot.top, width, plot.height);
      final label = groups[range.start];
      if (label != null) sections.add((label: label, bounds: section));
      final step = width / count;
      final resolvedBarWidth = math
          .min(barWidth ?? step * .7 - 2, math.max(1, step - 2))
          .clamp(1, double.infinity)
          .toDouble();
      final inset = barWidth != null
          ? math.min<double>(
              8,
              math.max<double>(0, (width - resolvedBarWidth * count) / 2),
            )
          : (step - resolvedBarWidth) / 2;
      for (var i = 0; i < count; i++) {
        final left = barWidth != null
            ? count == 1
                  ? x + (width - resolvedBarWidth) / 2
                  : x +
                        inset +
                        i * (width - 2 * inset - resolvedBarWidth) / (count - 1)
            : x + step * i + inset;
        bars.add(Rect.fromLTWH(left, plot.top, resolvedBarWidth, plot.height));
        hits.add(Rect.fromLTWH(x + i * step, plot.top, step, plot.height));
      }
      x += width + gap;
    }
  }

  /// Visual bar groups, one for each data category.
  final List<Rect> bars = [];

  /// Pointer targets cover each category while excluding section gaps.
  final List<Rect> hits = [];

  /// Full section bounds, used for shared second-level labels and rules.
  final List<({String label, Rect bounds})> sections = [];

  /// Returns the category under [x], excluding the space between sections.
  int? categoryAt(double x) {
    for (var i = 0; i < hits.length; i++) {
      if (x >= hits[i].left && x < hits[i].right) return i;
    }
    return null;
  }
}
