import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A masonry-style layout that distributes [children] across [columns] vertical
/// columns, interleaving items by index (item 0 → column 0, item 1 → column 1,
/// …, item n → column n % columns).
///
/// [columns] and [gap] accept [OiResponsive] values so they can vary across
/// breakpoints:
///
/// ```dart
/// OiMasonry(
///   columns: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 2,
///     OiBreakpoint.expanded: 4,
///   }),
///   gap: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 8,
///     OiBreakpoint.expanded: 16,
///   }),
///   children: [...],
/// )
/// ```
///
/// {@category Primitives}
class OiMasonry extends StatelessWidget {
  /// Creates an [OiMasonry].
  const OiMasonry({
    required this.children,
    this.columns = const OiResponsive<int>(2),
    this.gap = const OiResponsive<double>(0),
    this.breakpoint,
    super.key,
  });

  /// Number of vertical columns.
  final OiResponsive<int> columns;

  /// Horizontal and vertical gap between columns / items in logical pixels.
  final OiResponsive<double> gap;

  /// The active breakpoint, resolved at the layout level.
  ///
  /// When null, falls back to `context.breakpoint` (implicit context lookup).
  final OiBreakpoint? breakpoint;

  /// The child widgets to distribute across columns.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Resolve responsive values.
        final active = breakpoint ?? context.breakpoint;
        final scale = context.breakpointScale;
        final resolvedColumns = math.max(1, columns.resolve(active, scale));
        final resolvedGap = gap.resolve(active, scale);

        final hasBoundedWidth = constraints.hasBoundedWidth;

        // Build per-column child lists.
        final cols = List.generate(resolvedColumns, (_) => <Widget>[]);
        for (var i = 0; i < children.length; i++) {
          cols[i % resolvedColumns].add(children[i]);
        }

        // When width is bounded, compute equal column widths explicitly so
        // the widget composes inside any parent (no Expanded needed).
        double? columnWidth;
        if (hasBoundedWidth) {
          final availableWidth = constraints.maxWidth;
          columnWidth = resolvedColumns <= 1
              ? availableWidth
              : (availableWidth - resolvedGap * (resolvedColumns - 1)) /
                  resolvedColumns;
        }

        // Build column widgets with vertical gap between items.
        final columnWidgets = <Widget>[];
        for (var c = 0; c < resolvedColumns; c++) {
          final items = cols[c];
          final spacedItems = <Widget>[];
          for (var i = 0; i < items.length; i++) {
            spacedItems.add(items[i]);
            if (i < items.length - 1 && resolvedGap > 0) {
              spacedItems.add(SizedBox(height: resolvedGap));
            }
          }

          Widget col = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: hasBoundedWidth
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start,
            children: spacedItems,
          );

          if (columnWidth != null) {
            col = SizedBox(width: columnWidth, child: col);
          }

          columnWidgets.add(col);
          if (c < resolvedColumns - 1 && resolvedGap > 0) {
            columnWidgets.add(SizedBox(width: resolvedGap));
          }
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columnWidgets,
        );
      },
    );
  }
}
