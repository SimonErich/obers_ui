import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Settings for [OiTable] that can be persisted.
///
/// All fields have sensible defaults so that [OiTableSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiTableSettings with OiSettingsData {
  /// Creates an [OiTableSettings] with optional field overrides.
  const OiTableSettings({
    this.schemaVersion = 1,
    this.columnOrder = const [],
    this.columnVisibility = const {},
    this.columnWidths = const {},
    this.sortColumnId,
    this.sortAscending = true,
    this.activeFilters = const {},
    this.pageSize = 25,
    this.pageIndex = 0,
    this.groupByColumnId,
    this.frozenColumns = 0,
    this.showStatusBar = true,
  });

  /// Deserializes an [OiTableSettings] from a JSON map.
  factory OiTableSettings.fromJson(Map<String, dynamic> json) {
    return OiTableSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      columnOrder: _parseStringList(json['columnOrder']),
      columnVisibility: _parseBoolMap(json['columnVisibility']),
      columnWidths: _parseDoubleMap(json['columnWidths']),
      sortColumnId: json['sortColumnId'] as String?,
      sortAscending: (json['sortAscending'] as bool?) ?? true,
      activeFilters: _parseStringMap(json['activeFilters']),
      pageSize: (json['pageSize'] as int?) ?? 25,
      pageIndex: (json['pageIndex'] as int?) ?? 0,
      groupByColumnId: json['groupByColumnId'] as String?,
      frozenColumns: (json['frozenColumns'] as int?) ?? 0,
      showStatusBar: (json['showStatusBar'] as bool?) ?? true,
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Column order — list of column IDs in display order.
  final List<String> columnOrder;

  /// Column visibility — map of column ID to visible flag.
  final Map<String, bool> columnVisibility;

  /// Column widths — map of column ID to width in logical pixels.
  final Map<String, double> columnWidths;

  /// Sort column ID, or `null` when there is no active sort.
  final String? sortColumnId;

  /// Whether the active sort is ascending.
  final bool sortAscending;

  /// Active filters — map of column ID to filter value string.
  final Map<String, String> activeFilters;

  /// Number of rows per page.
  final int pageSize;

  /// Zero-based index of the currently visible page.
  final int pageIndex;

  /// Column ID to group by, or `null` when grouping is disabled.
  final String? groupByColumnId;

  /// Number of columns frozen to the left side of the table.
  final int frozenColumns;

  /// Whether to show the status bar at the bottom of the table.
  final bool showStatusBar;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'columnOrder': columnOrder,
    'columnVisibility': columnVisibility,
    'columnWidths': Map<String, double>.fromEntries(columnWidths.entries),
    'sortColumnId': sortColumnId,
    'sortAscending': sortAscending,
    'activeFilters': activeFilters,
    'pageSize': pageSize,
    'pageIndex': pageIndex,
    'groupByColumnId': groupByColumnId,
    'frozenColumns': frozenColumns,
    'showStatusBar': showStatusBar,
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or null values.
  ///
  /// Explicit user settings (non-empty lists, non-null values, etc.) are
  /// preserved; only uninitialised fields fall back to [defaults].
  OiTableSettings mergeWith(OiTableSettings defaults) {
    return OiTableSettings(
      schemaVersion: schemaVersion,
      columnOrder: columnOrder.isEmpty ? defaults.columnOrder : columnOrder,
      columnVisibility: columnVisibility.isEmpty
          ? defaults.columnVisibility
          : columnVisibility,
      columnWidths: columnWidths.isEmpty ? defaults.columnWidths : columnWidths,
      sortColumnId: sortColumnId ?? defaults.sortColumnId,
      sortAscending: sortAscending,
      activeFilters: activeFilters.isEmpty
          ? defaults.activeFilters
          : activeFilters,
      pageSize: pageSize,
      pageIndex: pageIndex,
      groupByColumnId: groupByColumnId ?? defaults.groupByColumnId,
      frozenColumns: frozenColumns,
      showStatusBar: showStatusBar,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiTableSettings copyWith({
    int? schemaVersion,
    List<String>? columnOrder,
    Map<String, bool>? columnVisibility,
    Map<String, double>? columnWidths,
    Object? sortColumnId = _sentinel,
    bool? sortAscending,
    Map<String, String>? activeFilters,
    int? pageSize,
    int? pageIndex,
    Object? groupByColumnId = _sentinel,
    int? frozenColumns,
    bool? showStatusBar,
  }) {
    return OiTableSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      columnOrder: columnOrder ?? this.columnOrder,
      columnVisibility: columnVisibility ?? this.columnVisibility,
      columnWidths: columnWidths ?? this.columnWidths,
      sortColumnId: identical(sortColumnId, _sentinel)
          ? this.sortColumnId
          : sortColumnId as String?,
      sortAscending: sortAscending ?? this.sortAscending,
      activeFilters: activeFilters ?? this.activeFilters,
      pageSize: pageSize ?? this.pageSize,
      pageIndex: pageIndex ?? this.pageIndex,
      groupByColumnId: identical(groupByColumnId, _sentinel)
          ? this.groupByColumnId
          : groupByColumnId as String?,
      frozenColumns: frozenColumns ?? this.frozenColumns,
      showStatusBar: showStatusBar ?? this.showStatusBar,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiTableSettings) return false;
    return schemaVersion == other.schemaVersion &&
        _listEquals(columnOrder, other.columnOrder) &&
        _mapEquals(columnVisibility, other.columnVisibility) &&
        _mapEquals(columnWidths, other.columnWidths) &&
        sortColumnId == other.sortColumnId &&
        sortAscending == other.sortAscending &&
        _mapEquals(activeFilters, other.activeFilters) &&
        pageSize == other.pageSize &&
        pageIndex == other.pageIndex &&
        groupByColumnId == other.groupByColumnId &&
        frozenColumns == other.frozenColumns &&
        showStatusBar == other.showStatusBar;
  }

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    Object.hashAll(columnOrder),
    Object.hashAll(
      columnVisibility.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAll(
      columnWidths.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    sortColumnId,
    sortAscending,
    Object.hashAll(
      activeFilters.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    pageSize,
    pageIndex,
    groupByColumnId,
    frozenColumns,
    showStatusBar,
  );

  // ── Private helpers ────────────────────────────────────────────────────────

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return List<String>.from(value.whereType<String>());
    }
    return const [];
  }

  static Map<String, bool> _parseBoolMap(dynamic value) {
    if (value == null) return const {};
    if (value is Map) {
      return Map<String, bool>.fromEntries(
        value.entries
            .where((e) => e.key is String && e.value is bool)
            .map((e) => MapEntry(e.key as String, e.value as bool)),
      );
    }
    return const {};
  }

  static Map<String, double> _parseDoubleMap(dynamic value) {
    if (value == null) return const {};
    if (value is Map) {
      return Map<String, double>.fromEntries(
        value.entries
            .where((e) => e.key is String && e.value is num)
            .map((e) => MapEntry(e.key as String, (e.value as num).toDouble())),
      );
    }
    return const {};
  }

  static Map<String, String> _parseStringMap(dynamic value) {
    if (value == null) return const {};
    if (value is Map) {
      return Map<String, String>.fromEntries(
        value.entries
            .where((e) => e.key is String && e.value is String)
            .map((e) => MapEntry(e.key as String, e.value as String)),
      );
    }
    return const {};
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}

/// Sentinel used by [OiTableSettings.copyWith] to distinguish an explicit
/// `null` argument from "not provided".
const Object _sentinel = Object();
