import 'package:flutter/foundation.dart';

/// An abstract filter applied to an [OiAnalyticsDashboard].
///
/// Subclass to create a specific filter type. Two concrete subtypes are
/// provided out of the box:
/// - [OiDateRangeFilter] — date range picker filter.
/// - [OiDropdownFilter] — single-select dropdown filter.
///
/// Each filter has a unique [id] and a human-readable [label] displayed
/// above the filter control.
///
/// {@category Modules}
@immutable
abstract class OiDashboardFilter {
  /// Creates an [OiDashboardFilter].
  const OiDashboardFilter({required this.id, required this.label});

  /// A unique identifier for this filter within the dashboard.
  final String id;

  /// The human-readable label displayed alongside the filter control.
  final String label;
}

/// A date range filter for [OiAnalyticsDashboard].
///
/// Allows the user to constrain the dashboard to a specific [start] and
/// [end] date. Either value may be null to indicate an open-ended range.
///
/// ```dart
/// OiDateRangeFilter(
///   id: 'period',
///   label: 'Date Range',
///   start: DateTime(2025, 1, 1),
///   end: DateTime(2025, 12, 31),
/// )
/// ```
///
/// {@category Modules}
@immutable
class OiDateRangeFilter extends OiDashboardFilter {
  /// Creates an [OiDateRangeFilter].
  const OiDateRangeFilter({
    required super.id,
    required super.label,
    this.start,
    this.end,
  });

  /// The inclusive start of the date range. Null means no lower bound.
  final DateTime? start;

  /// The inclusive end of the date range. Null means no upper bound.
  final DateTime? end;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDateRangeFilter &&
        other.id == id &&
        other.label == label &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(id, label, start, end);

  @override
  String toString() => 'OiDateRangeFilter(id: $id, start: $start, end: $end)';
}

/// A dropdown (single-select) filter for [OiAnalyticsDashboard].
///
/// Presents a list of [options] to the user. The currently chosen value
/// is stored in [selected], or null when nothing is selected.
///
/// ```dart
/// OiDropdownFilter(
///   id: 'region',
///   label: 'Region',
///   options: ['North', 'South', 'East', 'West'],
///   selected: 'North',
/// )
/// ```
///
/// {@category Modules}
@immutable
class OiDropdownFilter extends OiDashboardFilter {
  /// Creates an [OiDropdownFilter].
  const OiDropdownFilter({
    required super.id,
    required super.label,
    required this.options,
    this.selected,
  });

  /// The list of selectable option strings.
  final List<String> options;

  /// The currently selected option, or null when nothing is selected.
  final String? selected;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDropdownFilter &&
        other.id == id &&
        other.label == label &&
        other.selected == selected &&
        listEquals(other.options, options);
  }

  @override
  int get hashCode => Object.hash(id, label, selected, Object.hashAll(options));

  @override
  String toString() =>
      'OiDropdownFilter(id: $id, selected: $selected, options: $options)';
}
