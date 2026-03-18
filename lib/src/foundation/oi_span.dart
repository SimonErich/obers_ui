import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

// ---------------------------------------------------------------------------
// Sentinel value
// ---------------------------------------------------------------------------

/// Sentinel value that the grid interprets as "all columns".
const int fullSpanSentinel = -1;

// ---------------------------------------------------------------------------
// OiSpanData
// ---------------------------------------------------------------------------

/// Grid placement metadata for a child widget.
///
/// Applied via the [OiSpanExt] extension method:
/// ```dart
/// OiTextInput(label: 'Bio').span(
///   columnSpan: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 1,
///     OiBreakpoint.medium: 2,
///   }),
/// )
/// ```
///
/// {@category Foundation}
@immutable
class OiSpanData {
  /// Creates span metadata with optional responsive placement values.
  const OiSpanData({
    this.columnSpan,
    this.columnStart,
    this.columnOrder,
    this.rowSpan,
  });

  /// Full-width span — fills all columns at every breakpoint.
  static const OiSpanData full = OiSpanData(
    columnSpan: OiResponsive<int>(fullSpanSentinel),
  );

  /// How many columns this child occupies.
  ///
  /// `null` means 1 column (the default).
  /// Use [OiSpanData.full] for full-width.
  final OiResponsive<int>? columnSpan;

  /// Which column this child starts at (1-indexed).
  ///
  /// `null` means auto-placed (next available slot).
  final OiResponsive<int>? columnStart;

  /// Visual ordering within the grid row.
  ///
  /// Lower numbers render first. `null` means source order.
  final OiResponsive<int>? columnOrder;

  /// How many rows this child occupies. Default 1.
  final OiResponsive<int>? rowSpan;

  /// Resolves the column span for the given breakpoint and scale.
  ///
  /// Returns 1 when [columnSpan] is null. When the resolved value is
  /// [fullSpanSentinel], the caller should interpret it as "all columns".
  int resolveColumnSpan(OiBreakpoint bp, OiBreakpointScale scale) {
    if (columnSpan == null) return 1;
    return columnSpan!.resolve(bp, scale);
  }

  /// Resolves the column start for the given breakpoint and scale.
  ///
  /// Returns null (auto-placement) when [columnStart] is null.
  int? resolveColumnStart(OiBreakpoint bp, OiBreakpointScale scale) {
    if (columnStart == null) return null;
    return columnStart!.resolve(bp, scale);
  }

  /// Resolves the column order for the given breakpoint and scale.
  ///
  /// Returns null (source order) when [columnOrder] is null.
  int? resolveColumnOrder(OiBreakpoint bp, OiBreakpointScale scale) {
    if (columnOrder == null) return null;
    return columnOrder!.resolve(bp, scale);
  }

  /// Resolves the row span for the given breakpoint and scale.
  ///
  /// Returns 1 when [rowSpan] is null.
  int resolveRowSpan(OiBreakpoint bp, OiBreakpointScale scale) {
    if (rowSpan == null) return 1;
    return rowSpan!.resolve(bp, scale);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSpanData &&
        other.columnSpan == columnSpan &&
        other.columnStart == columnStart &&
        other.columnOrder == columnOrder &&
        other.rowSpan == rowSpan;
  }

  @override
  int get hashCode =>
      Object.hash(columnSpan, columnStart, columnOrder, rowSpan);

  @override
  String toString() => 'OiSpanData('
      'columnSpan: $columnSpan, '
      'columnStart: $columnStart, '
      'columnOrder: $columnOrder, '
      'rowSpan: $rowSpan)';
}

// ---------------------------------------------------------------------------
// OiSpan widget
// ---------------------------------------------------------------------------

/// A wrapper widget that carries [OiSpanData] for the nearest grid parent
/// to read during layout.
///
/// Prefer the [OiSpanExt.span] extension over constructing this directly.
///
/// {@category Foundation}
class OiSpan extends StatelessWidget {
  /// Creates an [OiSpan] wrapping [child] with grid placement [data].
  const OiSpan({required this.data, required this.child, super.key});

  /// The grid placement metadata.
  final OiSpanData data;

  /// The child widget to position in the grid.
  final Widget child;

  /// Returns the [OiSpanData] for [widget] if it is an [OiSpan],
  /// or null otherwise.
  static OiSpanData? maybeOf(Widget widget) {
    if (widget is OiSpan) return widget.data;
    return null;
  }

  @override
  Widget build(BuildContext context) => child;
}

// ---------------------------------------------------------------------------
// Widget extension
// ---------------------------------------------------------------------------

/// Extension on [Widget] that provides the `.span()` shorthand for
/// wrapping a widget with grid placement metadata.
///
/// {@category Foundation}
extension OiSpanExt on Widget {
  /// Wraps this widget with grid placement metadata.
  ///
  /// ```dart
  /// OiTextInput(label: 'Email').span(
  ///   columnSpan: OiResponsive.breakpoints({
  ///     OiBreakpoint.compact: 1,
  ///     OiBreakpoint.expanded: 2,
  ///   }),
  /// )
  /// ```
  Widget span({
    OiResponsive<int>? columnSpan,
    OiResponsive<int>? columnStart,
    OiResponsive<int>? columnOrder,
    OiResponsive<int>? rowSpan,
  }) {
    return OiSpan(
      data: OiSpanData(
        columnSpan: columnSpan,
        columnStart: columnStart,
        columnOrder: columnOrder,
        rowSpan: rowSpan,
      ),
      child: this,
    );
  }

  /// Shorthand: span all columns at every breakpoint.
  Widget spanFull() => OiSpan(data: OiSpanData.full, child: this);
}
