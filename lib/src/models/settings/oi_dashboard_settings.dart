import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Position and span of a card on a dashboard grid.
///
/// {@category Models}
@immutable
class OiDashboardCardPosition {
  /// Creates a card position at [column], [row] with optional span overrides.
  const OiDashboardCardPosition({
    required this.column,
    required this.row,
    this.columnSpan = 1,
    this.rowSpan = 1,
  });

  /// Deserializes an [OiDashboardCardPosition] from a JSON map.
  factory OiDashboardCardPosition.fromJson(Map<String, dynamic> json) {
    return OiDashboardCardPosition(
      column: (json['column'] as int?) ?? 0,
      row: (json['row'] as int?) ?? 0,
      columnSpan: (json['columnSpan'] as int?) ?? 1,
      rowSpan: (json['rowSpan'] as int?) ?? 1,
    );
  }

  /// Zero-based column index of the card.
  final int column;

  /// Zero-based row index of the card.
  final int row;

  /// Number of columns the card spans.
  final int columnSpan;

  /// Number of rows the card spans.
  final int rowSpan;

  /// Serializes this position to a JSON-encodable map.
  Map<String, dynamic> toJson() => {
        'column': column,
        'row': row,
        'columnSpan': columnSpan,
        'rowSpan': rowSpan,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiDashboardCardPosition) return false;
    return column == other.column &&
        row == other.row &&
        columnSpan == other.columnSpan &&
        rowSpan == other.rowSpan;
  }

  @override
  int get hashCode => Object.hash(column, row, columnSpan, rowSpan);
}

/// Settings for [OiDashboard] that can be persisted.
///
/// All fields have sensible defaults so that [OiDashboardSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiDashboardSettings with OiSettingsData {
  /// Creates an [OiDashboardSettings] with optional field overrides.
  const OiDashboardSettings({
    this.schemaVersion = 1,
    this.cardPositions = const {},
  });

  /// Deserializes an [OiDashboardSettings] from a JSON map.
  factory OiDashboardSettings.fromJson(Map<String, dynamic> json) {
    return OiDashboardSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      cardPositions: _parseCardPositions(json['cardPositions']),
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Map of card ID to its position on the grid.
  final Map<String, OiDashboardCardPosition> cardPositions;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'cardPositions': cardPositions
            .map((key, value) => MapEntry(key, value.toJson())),
      };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  ///
  /// Explicit user settings are preserved; only uninitialised fields fall
  /// back to [defaults].
  OiDashboardSettings mergeWith(OiDashboardSettings defaults) {
    return OiDashboardSettings(
      schemaVersion: schemaVersion,
      cardPositions:
          cardPositions.isEmpty ? defaults.cardPositions : cardPositions,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiDashboardSettings copyWith({
    int? schemaVersion,
    Map<String, OiDashboardCardPosition>? cardPositions,
  }) {
    return OiDashboardSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      cardPositions: cardPositions ?? this.cardPositions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiDashboardSettings) return false;
    return schemaVersion == other.schemaVersion &&
        _mapEquals(cardPositions, other.cardPositions);
  }

  @override
  int get hashCode => Object.hash(
        schemaVersion,
        Object.hashAll(
          cardPositions.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  // ── Private helpers ────────────────────────────────────────────────────────

  static Map<String, OiDashboardCardPosition> _parseCardPositions(
    dynamic value,
  ) {
    if (value == null) return const {};
    if (value is Map) {
      return Map<String, OiDashboardCardPosition>.fromEntries(
        value.entries
            .where((e) => e.key is String && e.value is Map)
            .map(
              (e) => MapEntry(
                e.key as String,
                OiDashboardCardPosition.fromJson(
                  Map<String, dynamic>.from(e.value as Map),
                ),
              ),
            ),
      );
    }
    return const {};
  }

  static bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}
