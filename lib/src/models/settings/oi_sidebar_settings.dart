import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Display mode for the sidebar.
///
/// {@category Models}
enum OiSidebarMode {
  /// Sidebar is fully expanded showing labels and icons.
  full,

  /// Sidebar shows only icons.
  compact,

  /// Sidebar is not visible.
  hidden,
}

/// Settings for [OiSidebar] that can be persisted.
///
/// All fields have sensible defaults so that [OiSidebarSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiSidebarSettings with OiSettingsData {
  /// Creates an [OiSidebarSettings] with optional field overrides.
  const OiSidebarSettings({
    this.schemaVersion = 1,
    this.mode = OiSidebarMode.full,
    this.width = 260,
    this.collapsedSectionIds = const {},
  });

  /// Deserializes an [OiSidebarSettings] from a JSON map.
  factory OiSidebarSettings.fromJson(Map<String, dynamic> json) {
    return OiSidebarSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      mode: _parseEnum(
        json['mode'] as String?,
        OiSidebarMode.values,
        OiSidebarMode.full,
      ),
      width: (json['width'] as num?)?.toDouble() ?? 260,
      collapsedSectionIds: _parseStringSet(json['collapsedSectionIds']),
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Display mode of the sidebar.
  final OiSidebarMode mode;

  /// Width of the sidebar in logical pixels.
  final double width;

  /// IDs of sections that are currently collapsed.
  final Set<String> collapsedSectionIds;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'mode': mode.name,
    'width': width,
    'collapsedSectionIds': collapsedSectionIds.toList(),
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  ///
  /// Explicit user settings are preserved; only uninitialised fields fall
  /// back to [defaults].
  OiSidebarSettings mergeWith(OiSidebarSettings defaults) {
    return OiSidebarSettings(
      schemaVersion: schemaVersion,
      mode: mode,
      width: width,
      collapsedSectionIds: collapsedSectionIds.isEmpty
          ? defaults.collapsedSectionIds
          : collapsedSectionIds,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiSidebarSettings copyWith({
    int? schemaVersion,
    OiSidebarMode? mode,
    double? width,
    Set<String>? collapsedSectionIds,
  }) {
    return OiSidebarSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      mode: mode ?? this.mode,
      width: width ?? this.width,
      collapsedSectionIds: collapsedSectionIds ?? this.collapsedSectionIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiSidebarSettings) return false;
    return schemaVersion == other.schemaVersion &&
        mode == other.mode &&
        width == other.width &&
        _setEquals(collapsedSectionIds, other.collapsedSectionIds);
  }

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    mode,
    width,
    Object.hashAll(collapsedSectionIds),
  );

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
