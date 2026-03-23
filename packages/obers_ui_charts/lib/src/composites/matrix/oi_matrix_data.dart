import 'package:flutter/foundation.dart';

/// A single cell in a matrix/density chart.
@immutable
class OiMatrixCell {
  const OiMatrixCell({
    required this.row,
    required this.column,
    required this.value,
  });

  final int row;
  final int column;
  final double value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiMatrixCell &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          column == other.column &&
          value == other.value;

  @override
  int get hashCode => Object.hash(row, column, value);
}

/// Data contract for matrix/density chart types (e.g. heatmap).
class OiMatrixData {
  const OiMatrixData({
    required this.cells,
    this.rowLabels,
    this.columnLabels,
  });

  final List<OiMatrixCell> cells;
  final List<String>? rowLabels;
  final List<String>? columnLabels;

  bool get isEmpty => cells.isEmpty;

  /// Returns the minimum and maximum values across all cells.
  (double min, double max) get valueRange {
    if (cells.isEmpty) return (0, 0);
    var min = cells.first.value;
    var max = cells.first.value;
    for (final cell in cells) {
      if (cell.value < min) min = cell.value;
      if (cell.value > max) max = cell.value;
    }
    return (min, max);
  }
}
