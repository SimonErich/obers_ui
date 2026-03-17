import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A non-scrolling grid layout that arranges [children] into a fixed number
/// of equal-width columns.
///
/// Provide either [columns] for a fixed column count or [minColumnWidth] to
/// compute the column count automatically from the available width. If both
/// are omitted, a single column is used.
///
/// {@category Primitives}
class OiGrid extends StatelessWidget {
  /// Creates an [OiGrid].
  const OiGrid({
    required this.children,
    this.columns,
    this.minColumnWidth,
    this.gap = 0,
    this.rowGap,
    super.key,
  }) : assert(
         columns == null || minColumnWidth == null,
         'Provide either columns or minColumnWidth, not both.',
       );

  /// Fixed number of columns. Mutually exclusive with [minColumnWidth].
  final int? columns;

  /// Minimum column width in logical pixels used to auto-compute the column
  /// count. Mutually exclusive with [columns].
  final double? minColumnWidth;

  /// Horizontal gap between columns and (when [rowGap] is null) the vertical
  /// gap between rows, in logical pixels.
  final double gap;

  /// Vertical gap between rows. When null, [gap] is used for both axes.
  final double? rowGap;

  /// The child widgets to place in the grid.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final effectiveRowGap = rowGap ?? gap;

        // Compute column count.
        int cols;
        if (columns != null) {
          cols = columns!;
        } else if (minColumnWidth != null && minColumnWidth! > 0) {
          cols = math.max(1, (availableWidth / minColumnWidth!).floor());
        } else {
          cols = 1;
        }

        // Item width = (total width − gap * (cols − 1)) / cols
        final itemWidth = cols <= 1
            ? availableWidth
            : (availableWidth - gap * (cols - 1)) / cols;

        return Wrap(
          spacing: gap,
          runSpacing: effectiveRowGap,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
