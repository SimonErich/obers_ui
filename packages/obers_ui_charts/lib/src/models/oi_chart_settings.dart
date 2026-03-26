import 'package:obers_ui/obers_ui.dart' hide mapEquals;

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

// ─────────────────────────────────────────────────────────────────────────────
// OiPersistedViewport
// ─────────────────────────────────────────────────────────────────────────────

/// Typed viewport state for persistence.
///
/// Stores the visible domain window as explicit min/max values.
///
/// {@category Models}
@immutable
class OiPersistedViewport {
  /// Creates an [OiPersistedViewport].
  const OiPersistedViewport({this.xMin, this.xMax, this.yMin, this.yMax});

  /// Deserializes from a JSON map.
  factory OiPersistedViewport.fromJson(Map<String, dynamic> json) {
    return OiPersistedViewport(
      xMin: (json['xMin'] as num?)?.toDouble(),
      xMax: (json['xMax'] as num?)?.toDouble(),
      yMin: (json['yMin'] as num?)?.toDouble(),
      yMax: (json['yMax'] as num?)?.toDouble(),
    );
  }

  /// Minimum visible x-domain value, or null for auto.
  final double? xMin;

  /// Maximum visible x-domain value, or null for auto.
  final double? xMax;

  /// Minimum visible y-domain value, or null for auto.
  final double? yMin;

  /// Maximum visible y-domain value, or null for auto.
  final double? yMax;

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'xMin': xMin,
    'xMax': xMax,
    'yMin': yMin,
    'yMax': yMax,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiPersistedViewport &&
        other.xMin == xMin &&
        other.xMax == xMax &&
        other.yMin == yMin &&
        other.yMax == yMax;
  }

  @override
  int get hashCode => Object.hash(xMin, xMax, yMin, yMax);

  @override
  String toString() =>
      'OiPersistedViewport(x: [$xMin, $xMax], y: [$yMin, $yMax])';
}

// ─────────────────────────────────────────────────────────────────────────────
// OiPersistedSelection
// ─────────────────────────────────────────────────────────────────────────────

/// Typed selection state for persistence.
///
/// Stores selected data refs as serializable index pairs.
///
/// {@category Models}
@immutable
class OiPersistedSelection {
  /// Creates an [OiPersistedSelection].
  const OiPersistedSelection({this.selectedRefs = const []});

  /// Deserializes from a JSON list of maps.
  factory OiPersistedSelection.fromJson(dynamic json) {
    if (json is! List) return const OiPersistedSelection();
    final refs = <({int seriesIndex, int dataIndex})>[];
    for (final item in json) {
      if (item is Map<String, dynamic>) {
        final si = item['seriesIndex'] as int?;
        final di = item['dataIndex'] as int?;
        if (si != null && di != null) {
          refs.add((seriesIndex: si, dataIndex: di));
        }
      }
    }
    return OiPersistedSelection(selectedRefs: refs);
  }

  /// The selected data references as (seriesIndex, dataIndex) pairs.
  final List<({int seriesIndex, int dataIndex})> selectedRefs;

  /// Whether any data is selected.
  bool get hasSelection => selectedRefs.isNotEmpty;

  /// Serializes to a JSON list.
  List<Map<String, int>> toJson() => [
    for (final ref in selectedRefs)
      {'seriesIndex': ref.seriesIndex, 'dataIndex': ref.dataIndex},
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiPersistedSelection &&
        listEquals(other.selectedRefs, selectedRefs);
  }

  @override
  int get hashCode => Object.hashAll(selectedRefs);

  @override
  String toString() => 'OiPersistedSelection(refs: ${selectedRefs.length})';
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartSettings
// ─────────────────────────────────────────────────────────────────────────────

/// Persistable state for chart widgets.
///
/// Stores hidden series, viewport, selection, legend group expanded
/// states, and the active comparison mode. Designed to be used with the
/// existing [OiSettingsDriver] / [OiSettingsMixin] architecture.
///
/// {@category Models}
@immutable
class OiChartSettings with OiSettingsData {
  /// Creates an [OiChartSettings] with optional field overrides.
  const OiChartSettings({
    this.schemaVersion = 2,
    this.hiddenSeriesIds = const {},
    this.viewport,
    this.selection,
    this.legendExpandedGroups = const {},
    this.comparisonMode = OiChartComparisonMode.none,
  });

  /// Deserializes an [OiChartSettings] from a JSON map.
  factory OiChartSettings.fromJson(Map<String, dynamic> json) {
    final version = (json['schemaVersion'] as int?) ?? 1;

    // v1 migration: convert old fields to new types.
    OiPersistedViewport? viewport;
    if (json['viewport'] is Map<String, dynamic>) {
      viewport = OiPersistedViewport.fromJson(
        json['viewport'] as Map<String, dynamic>,
      );
    } else if (json['viewportWindow'] is Map<String, dynamic>) {
      // v1 format: Rect stored as {left, top, right, bottom}.
      final vw = json['viewportWindow'] as Map<String, dynamic>;
      viewport = OiPersistedViewport(
        xMin: (vw['left'] as num?)?.toDouble(),
        xMax: (vw['right'] as num?)?.toDouble(),
        yMin: (vw['top'] as num?)?.toDouble(),
        yMax: (vw['bottom'] as num?)?.toDouble(),
      );
    }

    OiPersistedSelection? selection;
    if (json['selection'] is List) {
      selection = OiPersistedSelection.fromJson(json['selection']);
    } else if (json['selectedSeriesIndex'] != null) {
      // v1 format: single index pair.
      selection = OiPersistedSelection(
        selectedRefs: [
          (
            seriesIndex: json['selectedSeriesIndex'] as int,
            dataIndex: (json['selectedDataIndex'] as int?) ?? 0,
          ),
        ],
      );
    }

    return OiChartSettings(
      schemaVersion: version < 2 ? 2 : version,
      hiddenSeriesIds: _parseStringSet(json['hiddenSeriesIds']),
      viewport: viewport,
      selection: selection,
      legendExpandedGroups: _parseBoolMap(json['legendExpandedGroups']),
      comparisonMode: _parseComparisonMode(json['comparisonMode']),
    );
  }

  @override
  final int schemaVersion;

  /// The set of series identifiers hidden by the user.
  final Set<String> hiddenSeriesIds;

  /// The persisted visible domain viewport.
  final OiPersistedViewport? viewport;

  /// The persisted selection state.
  final OiPersistedSelection? selection;

  /// Legend group expanded/collapsed states.
  ///
  /// Keys are group ids. `true` = expanded, `false` = explicitly collapsed.
  final Map<String, bool> legendExpandedGroups;

  /// The active comparison mode.
  final OiChartComparisonMode comparisonMode;

  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'hiddenSeriesIds': hiddenSeriesIds.toList(),
    'viewport': viewport?.toJson(),
    'selection': selection?.toJson(),
    'legendExpandedGroups': legendExpandedGroups,
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
      viewport: viewport ?? defaults.viewport,
      selection: selection ?? defaults.selection,
      legendExpandedGroups: legendExpandedGroups.isEmpty
          ? defaults.legendExpandedGroups
          : legendExpandedGroups,
      comparisonMode: comparisonMode,
    );
  }

  /// Returns a copy with specified fields replaced.
  OiChartSettings copyWith({
    int? schemaVersion,
    Set<String>? hiddenSeriesIds,
    OiPersistedViewport? viewport,
    OiPersistedSelection? selection,
    Map<String, bool>? legendExpandedGroups,
    OiChartComparisonMode? comparisonMode,
    bool clearViewport = false,
    bool clearSelection = false,
  }) {
    return OiChartSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      hiddenSeriesIds: hiddenSeriesIds ?? this.hiddenSeriesIds,
      viewport: clearViewport ? null : (viewport ?? this.viewport),
      selection: clearSelection ? null : (selection ?? this.selection),
      legendExpandedGroups: legendExpandedGroups ?? this.legendExpandedGroups,
      comparisonMode: comparisonMode ?? this.comparisonMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiChartSettings) return false;
    return schemaVersion == other.schemaVersion &&
        setEquals(hiddenSeriesIds, other.hiddenSeriesIds) &&
        viewport == other.viewport &&
        selection == other.selection &&
        mapEquals(legendExpandedGroups, other.legendExpandedGroups) &&
        comparisonMode == other.comparisonMode;
  }

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    // Use sum of element hashes for order-independent Set hashing.
    hiddenSeriesIds.fold<int>(0, (h, e) => h ^ e.hashCode),
    viewport,
    selection,
    legendExpandedGroups.entries.fold<int>(
      0,
      (h, e) => h ^ Object.hash(e.key, e.value),
    ),
    comparisonMode,
  );

  @override
  String toString() =>
      'OiChartSettings('
      'hidden: $hiddenSeriesIds, '
      'viewport: $viewport, '
      'selection: $selection, '
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

  static Map<String, bool> _parseBoolMap(dynamic value) {
    if (value == null) return const {};
    if (value is Map) {
      return {
        for (final entry in value.entries)
          if (entry.key is String && entry.value is bool)
            entry.key as String: entry.value as bool,
      };
    }
    // v1 migration: convert Set<String> (stored as List) to Map.
    if (value is List) {
      return {for (final item in value.whereType<String>()) item: true};
    }
    return const {};
  }

  static OiChartComparisonMode _parseComparisonMode(dynamic value) {
    if (value is String) {
      for (final mode in OiChartComparisonMode.values) {
        if (mode.name == value) return mode;
      }
    }
    return OiChartComparisonMode.none;
  }
}
