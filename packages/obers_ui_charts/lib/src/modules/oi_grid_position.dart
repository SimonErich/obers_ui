import 'package:flutter/foundation.dart';

/// The position and span of a panel within the [OiAnalyticsDashboard] grid.
///
/// [row] and [col] are zero-based indices. [rowSpan] and [colSpan] default to
/// 1, meaning the panel occupies a single cell. Larger spans allow a panel to
/// stretch across multiple rows or columns.
///
/// ```dart
/// OiGridPosition(row: 0, col: 0, colSpan: 2) // spans two columns in row 0
/// OiGridPosition(row: 1, col: 0, rowSpan: 2, colSpan: 3) // 2×3 block
/// ```
///
/// {@category Modules}
@immutable
class OiGridPosition {
  /// Creates an [OiGridPosition].
  const OiGridPosition({
    required this.row,
    required this.col,
    this.rowSpan = 1,
    this.colSpan = 1,
  });

  /// The zero-based row index of the panel's top-left cell.
  final int row;

  /// The zero-based column index of the panel's top-left cell.
  final int col;

  /// The number of rows the panel spans. Defaults to 1.
  final int rowSpan;

  /// The number of columns the panel spans. Defaults to 1.
  final int colSpan;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiGridPosition &&
        other.row == row &&
        other.col == col &&
        other.rowSpan == rowSpan &&
        other.colSpan == colSpan;
  }

  @override
  int get hashCode => Object.hash(row, col, rowSpan, colSpan);

  @override
  String toString() =>
      'OiGridPosition(row: $row, col: $col, rowSpan: $rowSpan, colSpan: $colSpan)';
}
