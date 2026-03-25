import 'package:obers_ui/obers_ui.dart';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';

/// The comparison mode active on a chart.
///
/// {@category Models}
enum OiChartComparisonMode {
  /// No comparison — standard single-period display.
  none,

  /// Overlay a previous period on the same axes.
  previousPeriod,

  /// Compare against a custom baseline.
  baseline,

  /// Year-over-year comparison.
  yearOverYear,
}

/// Persistable state for chart widgets.
///
/// Stores hidden series, viewport window, selection, legend group expanded
/// states, and the active comparison mode. Designed to be used with the
/// existing [OiSettingsDriver] / [OiSettingsMixin] architecture.
///
/// ```dart
/// const settings = OiChartSettings();
/// final updated = settings.copyWith(
///   hiddenSeriesIds: {'revenue'},
///   comparisonMode: OiChartComparisonMode.previousPeriod,
/// );
/// ```
///
/// {@category Models}
@immutable
class OiChartSettings with OiSettingsData {
  /// Creates an [OiChartSettings] with optional field overrides.
  const OiChartSettings({
    this.schemaVersion = 1,
    this.hiddenSeriesIds = const {},
    this.viewportWindow,
    this.selectedSeriesIndex,
    this.selectedDataIndex,
    this.legendExpandedGroups = const {},
    this.comparisonMode = OiChartComparisonMode.none,
  });

  /// Deserializes an [OiChartSettings] from a JSON map.
  factory OiChartSettings.fromJson(Map<String, dynamic> json) {
    return OiChartSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      hiddenSeriesIds: _parseStringSet(json['hiddenSeriesIds']),
      viewportWindow: _parseRect(json['viewportWindow']),
      selectedSeriesIndex: json['selectedSeriesIndex'] as int?,
      selectedDataIndex: json['selectedDataIndex'] as int?,
      legendExpandedGroups: _parseStringSet(json['legendExpandedGroups']),
      comparisonMode: _parseComparisonMode(json['comparisonMode']),
    );
  }

  @override
  final int schemaVersion;

  /// The set of series identifiers that have been hidden by the user
  /// (e.g. by toggling them off in the legend).
  final Set<String> hiddenSeriesIds;

  /// The persisted visible domain as a [Rect] in data coordinates.
  ///
  /// When `null`, the chart uses its default auto-fit viewport.
  final Rect? viewportWindow;

  /// The series index of the currently selected data point, or `null`.
  final int? selectedSeriesIndex;

  /// The data index of the currently selected data point, or `null`.
  final int? selectedDataIndex;

  /// The set of legend group identifiers that are in the expanded state.
  final Set<String> legendExpandedGroups;

  /// The active comparison mode.
  final OiChartComparisonMode comparisonMode;

  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'hiddenSeriesIds': hiddenSeriesIds.toList(),
    'viewportWindow': _rectToJson(viewportWindow),
    'selectedSeriesIndex': selectedSeriesIndex,
    'selectedDataIndex': selectedDataIndex,
    'legendExpandedGroups': legendExpandedGroups.toList(),
    'comparisonMode': comparisonMode.name,
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  OiChartSettings mergeWith(OiChartSettings defaults) {
    return OiChartSettings(
      schemaVersion: schemaVersion,
      hiddenSeriesIds: hiddenSeriesIds.isEmpty
          ? defaults.hiddenSeriesIds
          : hiddenSeriesIds,
      viewportWindow: viewportWindow ?? defaults.viewportWindow,
      selectedSeriesIndex: selectedSeriesIndex ?? defaults.selectedSeriesIndex,
      selectedDataIndex: selectedDataIndex ?? defaults.selectedDataIndex,
      legendExpandedGroups: legendExpandedGroups.isEmpty
          ? defaults.legendExpandedGroups
          : legendExpandedGroups,
      comparisonMode: comparisonMode,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiChartSettings copyWith({
    int? schemaVersion,
    Set<String>? hiddenSeriesIds,
    Rect? viewportWindow,
    int? selectedSeriesIndex,
    int? selectedDataIndex,
    Set<String>? legendExpandedGroups,
    OiChartComparisonMode? comparisonMode,
    bool clearViewportWindow = false,
    bool clearSelectedSeriesIndex = false,
    bool clearSelectedDataIndex = false,
  }) {
    return OiChartSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      hiddenSeriesIds: hiddenSeriesIds ?? this.hiddenSeriesIds,
      viewportWindow: clearViewportWindow
          ? null
          : (viewportWindow ?? this.viewportWindow),
      selectedSeriesIndex: clearSelectedSeriesIndex
          ? null
          : (selectedSeriesIndex ?? this.selectedSeriesIndex),
      selectedDataIndex: clearSelectedDataIndex
          ? null
          : (selectedDataIndex ?? this.selectedDataIndex),
      legendExpandedGroups: legendExpandedGroups ?? this.legendExpandedGroups,
      comparisonMode: comparisonMode ?? this.comparisonMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiChartSettings) return false;
    return schemaVersion == other.schemaVersion &&
        _setEquals(hiddenSeriesIds, other.hiddenSeriesIds) &&
        viewportWindow == other.viewportWindow &&
        selectedSeriesIndex == other.selectedSeriesIndex &&
        selectedDataIndex == other.selectedDataIndex &&
        _setEquals(legendExpandedGroups, other.legendExpandedGroups) &&
        comparisonMode == other.comparisonMode;
  }

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    Object.hashAll(hiddenSeriesIds),
    viewportWindow,
    selectedSeriesIndex,
    selectedDataIndex,
    Object.hashAll(legendExpandedGroups),
    comparisonMode,
  );

  @override
  String toString() =>
      'OiChartSettings('
      'hidden: $hiddenSeriesIds, '
      'viewport: $viewportWindow, '
      'selection: [$selectedSeriesIndex:$selectedDataIndex], '
      'legendGroups: $legendExpandedGroups, '
      'comparison: $comparisonMode)';

  // ── Private helpers ──────────────────────────────────────────────────

  static Set<String> _parseStringSet(dynamic value) {
    if (value == null) return const {};
    if (value is List) {
      return Set<String>.from(value.whereType<String>());
    }
    return const {};
  }

  static Rect? _parseRect(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      final left = (value['left'] as num?)?.toDouble();
      final top = (value['top'] as num?)?.toDouble();
      final right = (value['right'] as num?)?.toDouble();
      final bottom = (value['bottom'] as num?)?.toDouble();
      if (left != null && top != null && right != null && bottom != null) {
        return Rect.fromLTRB(left, top, right, bottom);
      }
    }
    return null;
  }

  static Map<String, dynamic>? _rectToJson(Rect? rect) {
    if (rect == null) return null;
    return {
      'left': rect.left,
      'top': rect.top,
      'right': rect.right,
      'bottom': rect.bottom,
    };
  }

  static OiChartComparisonMode _parseComparisonMode(dynamic value) {
    if (value is String) {
      for (final mode in OiChartComparisonMode.values) {
        if (mode.name == value) return mode;
      }
    }
    return OiChartComparisonMode.none;
  }

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
