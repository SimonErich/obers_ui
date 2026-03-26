import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// A cell in the heatmap.
///
/// Identifies a grid position by [row] and [column] indices and holds
/// the numeric [value] for that cell.
class OiHeatmapCell {
  /// Creates an [OiHeatmapCell].
  const OiHeatmapCell({
    required this.row,
    required this.column,
    required this.value,
  });

  /// The zero-based row index.
  final int row;

  /// The zero-based column index.
  final int column;

  /// The numeric value of this cell.
  final double value;
}

/// A heatmap visualization showing values as colored cells in a grid.
///
/// Cells are colored on a gradient from [lowColor] to [highColor] based
/// on their value. When [showValues] is `true`, the numeric value is
/// rendered inside each cell.
///
/// Optional [rowLabels] and [columnLabels] are drawn along the left and
/// top edges respectively.
///
/// {@category Composites}
class OiHeatmap extends StatelessWidget {
  /// Creates an [OiHeatmap].
  const OiHeatmap({
    required this.cells,
    required this.label,
    super.key,
    this.rowLabels,
    this.columnLabels,
    this.minValue,
    this.maxValue,
    this.lowColor,
    this.highColor,
    this.showValues = true,
    this.onCellTap,
  });

  /// The cells to render in the grid.
  final List<OiHeatmapCell> cells;

  /// The accessibility label for the heatmap.
  final String label;

  /// Optional row labels displayed along the left edge.
  final List<String>? rowLabels;

  /// Optional column labels displayed along the top edge.
  final List<String>? columnLabels;

  /// The minimum value for color scaling. When null, derived from data.
  final double? minValue;

  /// The maximum value for color scaling. When null, derived from data.
  final double? maxValue;

  /// The color representing the lowest value. Defaults to the theme's
  /// success muted color.
  final Color? lowColor;

  /// The color representing the highest value. Defaults to the theme's
  /// error base color.
  final Color? highColor;

  /// Whether to render the numeric value inside each cell.
  ///
  /// Defaults to `true` so that color is never the sole indicator of the
  /// cell's magnitude (REQ-0025).
  final bool showValues;

  /// Called when a cell is tapped, with the tapped cell data.
  final ValueChanged<OiHeatmapCell>? onCellTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (cells.isEmpty) {
      return Semantics(
        label: label,
        child: const SizedBox.shrink(key: Key('oi_heatmap_empty')),
      );
    }

    final effectiveLow = lowColor ?? colors.success.base.withValues(alpha: 0.3);
    final effectiveHigh = highColor ?? colors.error.base;

    // Compute grid dimensions.
    var numRows = 0;
    var numCols = 0;
    var dataMin = double.infinity;
    var dataMax = double.negativeInfinity;

    for (final cell in cells) {
      numRows = math.max(numRows, cell.row + 1);
      numCols = math.max(numCols, cell.column + 1);
      dataMin = math.min(dataMin, cell.value);
      dataMax = math.max(dataMax, cell.value);
    }

    if (rowLabels != null) {
      numRows = math.max(numRows, rowLabels!.length);
    }
    if (columnLabels != null) {
      numCols = math.max(numCols, columnLabels!.length);
    }

    final effectiveMin = minValue ?? dataMin;
    final effectiveMax = maxValue ?? dataMax;

    // Build a lookup map.
    final cellMap = <(int, int), OiHeatmapCell>{};
    for (final cell in cells) {
      cellMap[(cell.row, cell.column)] = cell;
    }

    return Semantics(
      label: label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasRowLabels = rowLabels != null && rowLabels!.isNotEmpty;
          final hasColLabels = columnLabels != null && columnLabels!.isNotEmpty;
          final labelWidth = hasRowLabels ? 60.0 : 0.0;
          final labelHeight = hasColLabels ? 24.0 : 0.0;
          final availWidth = constraints.maxWidth - labelWidth;
          // Subtract 2px margin per cell (1px each side).
          final cellWidth = numCols > 0 ? (availWidth / numCols) - 2 : 40.0;
          const cellHeight = 32.0;

          return Column(
            key: const Key('oi_heatmap'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column labels.
              if (hasColLabels)
                Padding(
                  padding: EdgeInsets.only(left: labelWidth),
                  child: Row(
                    children: [
                      for (var c = 0; c < numCols; c++)
                        SizedBox(
                          width: cellWidth,
                          height: labelHeight,
                          child: Center(
                            child: OiLabel.caption(
                              c < columnLabels!.length ? columnLabels![c] : '',
                              color: colors.textMuted,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              // Rows.
              for (var r = 0; r < numRows; r++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasRowLabels)
                      SizedBox(
                        width: labelWidth,
                        height: cellHeight,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: OiLabel.caption(
                              r < rowLabels!.length ? rowLabels![r] : '',
                              color: colors.textMuted,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    for (var c = 0; c < numCols; c++)
                      _buildCell(
                        cell: cellMap[(r, c)],
                        row: r,
                        column: c,
                        width: cellWidth,
                        height: cellHeight,
                        effectiveMin: effectiveMin,
                        effectiveMax: effectiveMax,
                        lowColor: effectiveLow,
                        highColor: effectiveHigh,
                        textColor: colors.text,
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCell({
    required OiHeatmapCell? cell,
    required int row,
    required int column,
    required double width,
    required double height,
    required double effectiveMin,
    required double effectiveMax,
    required Color lowColor,
    required Color highColor,
    required Color textColor,
  }) {
    final cellColor = cell != null
        ? Color.lerp(
            lowColor,
            highColor,
            effectiveMax != effectiveMin
                ? ((cell.value - effectiveMin) / (effectiveMax - effectiveMin))
                      .clamp(0.0, 1.0)
                : 0.5,
          )!
        : lowColor.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: cell != null && onCellTap != null ? () => onCellTap!(cell) : null,
      child: Container(
        key: Key('oi_heatmap_cell_${row}_$column'),
        width: width,
        height: height,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(2),
        ),
        child: showValues && cell != null
            ? Center(
                child: OiLabel.small(
                  cell.value.toStringAsFixed(0),
                  color: textColor,
                ),
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mapper-first series (concept-aligned)
// ─────────────────────────────────────────────────────────────────────────────

/// A mapper-first heatmap series that extracts values from domain model `T`.
///
/// Heatmaps use row/column string keys rather than numeric x/y coordinates,
/// so this class does not extend `OiCartesianSeries`. Use [OiHeatmapCell]
/// for the simpler pre-mapped API.
///
/// {@category Composites}
class OiHeatmapSeriesData<T> {
  /// Creates an [OiHeatmapSeriesData].
  const OiHeatmapSeriesData({
    required this.id,
    required this.label,
    required this.data,
    required this.rowMapper,
    required this.columnMapper,
    required this.valueMapper,
  });

  /// A unique identifier for this series.
  final String id;

  /// The display name for this series.
  final String label;

  /// The domain objects, each representing one heatmap cell.
  final List<T> data;

  /// Extracts the row key (display label) from a domain object.
  final String Function(T item) rowMapper;

  /// Extracts the column key (display label) from a domain object.
  final String Function(T item) columnMapper;

  /// Extracts the numeric value that determines cell color intensity.
  final num Function(T item) valueMapper;
}
