import 'package:flutter/foundation.dart';
import 'package:obers_ui/obers_ui.dart' show OiCalendar;
import 'package:obers_ui/src/composites/scheduling/oi_calendar.dart'
    show OiCalendar;
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// View mode for the calendar.
///
/// {@category Models}
enum OiCalendarViewType {
  /// Monthly overview.
  month,

  /// Weekly view.
  week,

  /// Daily view.
  day,
}

/// Settings for [OiCalendar] that can be persisted.
///
/// All fields have sensible defaults so that [OiCalendarSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiCalendarSettings with OiSettingsData {
  /// Creates an [OiCalendarSettings] with optional field overrides.
  const OiCalendarSettings({
    this.schemaVersion = 1,
    this.viewType = OiCalendarViewType.month,
    this.collapsedCategories = const {},
  });

  /// Deserializes an [OiCalendarSettings] from a JSON map.
  factory OiCalendarSettings.fromJson(Map<String, dynamic> json) {
    return OiCalendarSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      viewType: _parseEnum(
        json['viewType'] as String?,
        OiCalendarViewType.values,
        OiCalendarViewType.month,
      ),
      collapsedCategories: _parseStringSet(json['collapsedCategories']),
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// The current calendar view type.
  final OiCalendarViewType viewType;

  /// Set of category identifiers whose events are collapsed / hidden.
  final Set<String> collapsedCategories;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'viewType': viewType.name,
    'collapsedCategories': collapsedCategories.toList(),
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  OiCalendarSettings mergeWith(OiCalendarSettings defaults) {
    return OiCalendarSettings(
      schemaVersion: schemaVersion,
      viewType: viewType,
      collapsedCategories: collapsedCategories.isEmpty
          ? defaults.collapsedCategories
          : collapsedCategories,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiCalendarSettings copyWith({
    int? schemaVersion,
    OiCalendarViewType? viewType,
    Set<String>? collapsedCategories,
  }) {
    return OiCalendarSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      viewType: viewType ?? this.viewType,
      collapsedCategories: collapsedCategories ?? this.collapsedCategories,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiCalendarSettings) return false;
    return schemaVersion == other.schemaVersion &&
        viewType == other.viewType &&
        _setEquals(collapsedCategories, other.collapsedCategories);
  }

  @override
  int get hashCode =>
      Object.hash(schemaVersion, viewType, Object.hashAll(collapsedCategories));

  // ── Private helpers ────────────────────────────────────────────────────────

  static T _parseEnum<T extends Enum>(
    String? value,
    List<T> values,
    T fallback,
  ) {
    if (value == null) return fallback;
    for (final v in values) {
      if (v.name == value) return v;
    }
    return fallback;
  }

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
