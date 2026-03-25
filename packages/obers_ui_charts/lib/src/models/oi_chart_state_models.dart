import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Selection State
// ─────────────────────────────────────────────────────────────────────────────

/// The selection mode used by the chart.
///
/// {@category Models}
enum OiChartSelectionMode {
  /// Select individual data points.
  point,

  /// Select all points in a series.
  series,

  /// Select all points sharing the same domain (x) value.
  domainGroup,

  /// Drag to select a range of domain values.
  brush,
}

/// Immutable snapshot of the chart's selection state.
///
/// {@category Models}
@immutable
class OiChartSelectionState {
  /// Creates an [OiChartSelectionState].
  const OiChartSelectionState({
    this.selectedRefs = const {},
    this.mode = OiChartSelectionMode.point,
    this.timestamp,
  });

  /// An empty selection state.
  static const empty = OiChartSelectionState();

  /// The currently selected data references.
  final Set<OiChartDataRef> selectedRefs;

  /// The selection mode that produced this state.
  final OiChartSelectionMode mode;

  /// When the selection was last modified.
  final DateTime? timestamp;

  /// Whether any data elements are selected.
  bool get hasSelection => selectedRefs.isNotEmpty;

  /// Creates a copy with optionally overridden values.
  OiChartSelectionState copyWith({
    Set<OiChartDataRef>? selectedRefs,
    OiChartSelectionMode? mode,
    DateTime? timestamp,
  }) {
    return OiChartSelectionState(
      selectedRefs: selectedRefs ?? this.selectedRefs,
      mode: mode ?? this.mode,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartSelectionState &&
        setEquals(other.selectedRefs, selectedRefs) &&
        other.mode == mode &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(selectedRefs), mode, timestamp);

  @override
  String toString() =>
      'OiChartSelectionState(refs: ${selectedRefs.length}, mode: $mode)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Hover State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the chart's hover state.
///
/// {@category Models}
@immutable
class OiChartHoverState {
  /// Creates an [OiChartHoverState].
  const OiChartHoverState({this.ref, this.position, this.seriesId});

  /// An empty hover state (nothing hovered).
  static const empty = OiChartHoverState();

  /// The data reference of the hovered element, or null.
  final OiChartDataRef? ref;

  /// The widget-local position of the pointer, or null.
  final Offset? position;

  /// The id of the series being hovered, or null.
  final String? seriesId;

  /// Whether any element is currently hovered.
  bool get isHovering => ref != null;

  /// Creates a copy with optionally overridden values.
  OiChartHoverState copyWith({
    OiChartDataRef? ref,
    Offset? position,
    String? seriesId,
  }) {
    return OiChartHoverState(
      ref: ref ?? this.ref,
      position: position ?? this.position,
      seriesId: seriesId ?? this.seriesId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartHoverState &&
        other.ref == ref &&
        other.position == position &&
        other.seriesId == seriesId;
  }

  @override
  int get hashCode => Object.hash(ref, position, seriesId);

  @override
  String toString() => 'OiChartHoverState(ref: $ref, series: $seriesId)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the chart's legend state.
///
/// {@category Models}
@immutable
class OiChartLegendState {
  /// Creates an [OiChartLegendState].
  const OiChartLegendState({
    this.hiddenSeriesIds = const {},
    this.focusedSeriesId,
    this.expandedGroups = const {},
  });

  /// An empty legend state (all series visible, no focus).
  static const empty = OiChartLegendState();

  /// Series ids that are currently hidden (toggled off).
  final Set<String> hiddenSeriesIds;

  /// The id of the series that has exclusive focus, or null.
  final String? focusedSeriesId;

  /// Legend group ids that are currently expanded.
  final Set<String> expandedGroups;

  /// Whether the given [seriesId] is visible.
  bool isVisible(String seriesId) => !hiddenSeriesIds.contains(seriesId);

  /// Creates a copy with optionally overridden values.
  OiChartLegendState copyWith({
    Set<String>? hiddenSeriesIds,
    String? focusedSeriesId,
    Set<String>? expandedGroups,
  }) {
    return OiChartLegendState(
      hiddenSeriesIds: hiddenSeriesIds ?? this.hiddenSeriesIds,
      focusedSeriesId: focusedSeriesId ?? this.focusedSeriesId,
      expandedGroups: expandedGroups ?? this.expandedGroups,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartLegendState &&
        setEquals(other.hiddenSeriesIds, hiddenSeriesIds) &&
        other.focusedSeriesId == focusedSeriesId &&
        setEquals(other.expandedGroups, expandedGroups);
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(hiddenSeriesIds),
    focusedSeriesId,
    Object.hashAll(expandedGroups),
  );

  @override
  String toString() =>
      'OiChartLegendState(hidden: ${hiddenSeriesIds.length}, '
      'focused: $focusedSeriesId)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Focus State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the chart's keyboard focus state.
///
/// {@category Models}
@immutable
class OiChartFocusState {
  /// Creates an [OiChartFocusState].
  const OiChartFocusState({
    this.focusedRef,
    this.showFocusRing = false,
    this.isNavigating = false,
  });

  /// An empty focus state (no focus).
  static const empty = OiChartFocusState();

  /// The data reference of the focused element, or null.
  final OiChartDataRef? focusedRef;

  /// Whether to render a visible focus indicator.
  final bool showFocusRing;

  /// Whether the user is actively navigating with the keyboard.
  final bool isNavigating;

  /// Whether any element is focused.
  bool get hasFocus => focusedRef != null;

  /// Creates a copy with optionally overridden values.
  OiChartFocusState copyWith({
    OiChartDataRef? focusedRef,
    bool? showFocusRing,
    bool? isNavigating,
  }) {
    return OiChartFocusState(
      focusedRef: focusedRef ?? this.focusedRef,
      showFocusRing: showFocusRing ?? this.showFocusRing,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartFocusState &&
        other.focusedRef == focusedRef &&
        other.showFocusRing == showFocusRing &&
        other.isNavigating == isNavigating;
  }

  @override
  int get hashCode => Object.hash(focusedRef, showFocusRing, isNavigating);

  @override
  String toString() =>
      'OiChartFocusState(ref: $focusedRef, navigating: $isNavigating)';
}
