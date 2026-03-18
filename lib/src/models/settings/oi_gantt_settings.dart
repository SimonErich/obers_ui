import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Settings for [OiGantt] that can be persisted.
///
/// All fields have sensible defaults so that [OiGanttSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiGanttSettings with OiSettingsData {
  /// Creates an [OiGanttSettings] with optional field overrides.
  const OiGanttSettings({
    this.schemaVersion = 1,
    this.zoomLevel = 1.0,
    this.scrollPosition = 0.0,
    this.collapsedGroups = const {},
  });

  /// Deserializes an [OiGanttSettings] from a JSON map.
  factory OiGanttSettings.fromJson(Map<String, dynamic> json) {
    return OiGanttSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      zoomLevel: (json['zoomLevel'] as num?)?.toDouble() ?? 1.0,
      scrollPosition: (json['scrollPosition'] as num?)?.toDouble() ?? 0.0,
      collapsedGroups: _parseStringSet(json['collapsedGroups']),
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Zoom level of the Gantt chart (1.0 = default).
  final double zoomLevel;

  /// Horizontal scroll position in logical pixels.
  final double scrollPosition;

  /// Set of group identifiers that are collapsed.
  final Set<String> collapsedGroups;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'zoomLevel': zoomLevel,
    'scrollPosition': scrollPosition,
    'collapsedGroups': collapsedGroups.toList(),
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  OiGanttSettings mergeWith(OiGanttSettings defaults) {
    return OiGanttSettings(
      schemaVersion: schemaVersion,
      zoomLevel: zoomLevel,
      scrollPosition: scrollPosition,
      collapsedGroups: collapsedGroups.isEmpty
          ? defaults.collapsedGroups
          : collapsedGroups,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiGanttSettings copyWith({
    int? schemaVersion,
    double? zoomLevel,
    double? scrollPosition,
    Set<String>? collapsedGroups,
  }) {
    return OiGanttSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      collapsedGroups: collapsedGroups ?? this.collapsedGroups,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiGanttSettings) return false;
    return schemaVersion == other.schemaVersion &&
        zoomLevel == other.zoomLevel &&
        scrollPosition == other.scrollPosition &&
        _setEquals(collapsedGroups, other.collapsedGroups);
  }

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    zoomLevel,
    scrollPosition,
    Object.hashAll(collapsedGroups),
  );

  // ── Private helpers ────────────────────────────────────────────────────────

  static Set<String> _parseStringSet(dynamic value) {
    if (value == null) return const {};
    if (value is List) {
      return Set<String>.from(value.whereType<String>());
    }
    return const {};
  }

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
