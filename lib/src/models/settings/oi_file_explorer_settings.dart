import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// View mode for the file explorer.
///
/// {@category Models}
enum OiFileViewMode {
  /// Display files as a list.
  list,

  /// Display files as a grid.
  grid,
}

/// Field used to sort files in the explorer.
///
/// {@category Models}
enum OiFileSortField {
  /// Sort by file name.
  name,

  /// Sort by file size.
  size,

  /// Sort by last-modified date.
  modified,

  /// Sort by file type / extension.
  type,
}

/// Sort direction for ordered collections.
///
/// {@category Models}
enum OiSortDirection {
  /// Ascending order (A-Z, smallest first, oldest first).
  ascending,

  /// Descending order (Z-A, largest first, newest first).
  descending,
}

/// Settings for [OiFileExplorer] that can be persisted.
///
/// All fields have sensible defaults so that [OiFileExplorerSettings] is
/// usable without any explicit configuration.
///
/// {@category Models}
@immutable
class OiFileExplorerSettings with OiSettingsData {
  /// Creates an [OiFileExplorerSettings] with optional field overrides.
  const OiFileExplorerSettings({
    this.schemaVersion = 1,
    this.viewMode = OiFileViewMode.grid,
    this.sortField = OiFileSortField.name,
    this.sortDirection = OiSortDirection.ascending,
    this.sidebarWidth = 240,
    this.sidebarCollapsed = false,
    this.favoriteFolderIds = const [],
    this.recentPaths = const [],
  });

  /// Deserializes an [OiFileExplorerSettings] from a JSON map.
  factory OiFileExplorerSettings.fromJson(Map<String, dynamic> json) {
    return OiFileExplorerSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      viewMode: _parseEnum(
        json['viewMode'] as String?,
        OiFileViewMode.values,
        OiFileViewMode.grid,
      ),
      sortField: _parseEnum(
        json['sortField'] as String?,
        OiFileSortField.values,
        OiFileSortField.name,
      ),
      sortDirection: _parseEnum(
        json['sortDirection'] as String?,
        OiSortDirection.values,
        OiSortDirection.ascending,
      ),
      sidebarWidth: (json['sidebarWidth'] as num?)?.toDouble() ?? 240,
      sidebarCollapsed: (json['sidebarCollapsed'] as bool?) ?? false,
      favoriteFolderIds: _parseStringList(json['favoriteFolderIds']),
      recentPaths: _parseStringList(json['recentPaths']),
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// How files are displayed (list or grid).
  final OiFileViewMode viewMode;

  /// Which field to sort files by.
  final OiFileSortField sortField;

  /// Sort direction (ascending or descending).
  final OiSortDirection sortDirection;

  /// Width of the sidebar in logical pixels.
  final double sidebarWidth;

  /// Whether the sidebar is collapsed.
  final bool sidebarCollapsed;

  /// IDs of folders the user has marked as favorites.
  final List<String> favoriteFolderIds;

  /// Recently visited file paths.
  final List<String> recentPaths;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'viewMode': viewMode.name,
    'sortField': sortField.name,
    'sortDirection': sortDirection.name,
    'sidebarWidth': sidebarWidth,
    'sidebarCollapsed': sidebarCollapsed,
    'favoriteFolderIds': favoriteFolderIds,
    'recentPaths': recentPaths,
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  ///
  /// Explicit user settings are preserved; only uninitialised fields fall
  /// back to [defaults].
  OiFileExplorerSettings mergeWith(OiFileExplorerSettings defaults) {
    return OiFileExplorerSettings(
      schemaVersion: schemaVersion,
      viewMode: viewMode,
      sortField: sortField,
      sortDirection: sortDirection,
      sidebarWidth: sidebarWidth,
      sidebarCollapsed: sidebarCollapsed,
      favoriteFolderIds: favoriteFolderIds.isEmpty
          ? defaults.favoriteFolderIds
          : favoriteFolderIds,
      recentPaths: recentPaths.isEmpty ? defaults.recentPaths : recentPaths,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiFileExplorerSettings copyWith({
    int? schemaVersion,
    OiFileViewMode? viewMode,
    OiFileSortField? sortField,
    OiSortDirection? sortDirection,
    double? sidebarWidth,
    bool? sidebarCollapsed,
    List<String>? favoriteFolderIds,
    List<String>? recentPaths,
  }) {
    return OiFileExplorerSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      viewMode: viewMode ?? this.viewMode,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
      favoriteFolderIds: favoriteFolderIds ?? this.favoriteFolderIds,
      recentPaths: recentPaths ?? this.recentPaths,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiFileExplorerSettings) return false;
    return schemaVersion == other.schemaVersion &&
        viewMode == other.viewMode &&
        sortField == other.sortField &&
        sortDirection == other.sortDirection &&
        sidebarWidth == other.sidebarWidth &&
        sidebarCollapsed == other.sidebarCollapsed &&
        _listEquals(favoriteFolderIds, other.favoriteFolderIds) &&
        _listEquals(recentPaths, other.recentPaths);
  }

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    viewMode,
    sortField,
    sortDirection,
    sidebarWidth,
    sidebarCollapsed,
    Object.hashAll(favoriteFolderIds),
    Object.hashAll(recentPaths),
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

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return List<String>.from(value.whereType<String>());
    }
    return const [];
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
