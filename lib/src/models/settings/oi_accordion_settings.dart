import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Settings for [OiAccordion] that can be persisted.
///
/// All fields have sensible defaults so that [OiAccordionSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiAccordionSettings with OiSettingsData {
  /// Creates an [OiAccordionSettings] with optional field overrides.
  const OiAccordionSettings({
    this.schemaVersion = 1,
    this.expandedIndices = const {},
  });

  /// Deserializes an [OiAccordionSettings] from a JSON map.
  factory OiAccordionSettings.fromJson(Map<String, dynamic> json) {
    return OiAccordionSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      expandedIndices: _parseIntSet(json['expandedIndices']),
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Indices of sections that are currently expanded.
  final Set<int> expandedIndices;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'expandedIndices': expandedIndices.toList(),
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  OiAccordionSettings mergeWith(OiAccordionSettings defaults) {
    return OiAccordionSettings(
      schemaVersion: schemaVersion,
      expandedIndices: expandedIndices.isEmpty
          ? defaults.expandedIndices
          : expandedIndices,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiAccordionSettings copyWith({
    int? schemaVersion,
    Set<int>? expandedIndices,
  }) {
    return OiAccordionSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      expandedIndices: expandedIndices ?? this.expandedIndices,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiAccordionSettings) return false;
    return schemaVersion == other.schemaVersion &&
        _setEquals(expandedIndices, other.expandedIndices);
  }

  @override
  int get hashCode =>
      Object.hash(schemaVersion, Object.hashAll(expandedIndices));

  // ── Private helpers ────────────────────────────────────────────────────────

  static Set<int> _parseIntSet(dynamic value) {
    if (value == null) return const {};
    if (value is List) {
      return Set<int>.from(value.whereType<int>());
    }
    return const {};
  }

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
