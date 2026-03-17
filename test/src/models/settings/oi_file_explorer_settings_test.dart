// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/settings/oi_file_explorer_settings.dart';

void main() {
  group('OiFileExplorerSettings', () {
    // ── Defaults ──────────────────────────────────────────────────────────────

    test('default constructor produces expected defaults', () {
      const s = OiFileExplorerSettings();
      expect(s.schemaVersion, 1);
      expect(s.viewMode, OiFileViewMode.grid);
      expect(s.sortField, OiFileSortField.name);
      expect(s.sortDirection, OiSortDirection.ascending);
      expect(s.sidebarWidth, 240);
      expect(s.sidebarCollapsed, isFalse);
      expect(s.favoriteFolderIds, isEmpty);
      expect(s.recentPaths, isEmpty);
    });

    // ── toJson / fromJson round-trip ──────────────────────────────────────────

    test('round-trips all fields through toJson / fromJson', () {
      const original = OiFileExplorerSettings(
        schemaVersion: 2,
        viewMode: OiFileViewMode.list,
        sortField: OiFileSortField.size,
        sortDirection: OiSortDirection.descending,
        sidebarWidth: 300,
        sidebarCollapsed: true,
        favoriteFolderIds: ['folder-1', 'folder-2'],
        recentPaths: ['/home/docs', '/home/images'],
      );
      final json = original.toJson();
      final restored = OiFileExplorerSettings.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson with missing fields uses defaults', () {
      final s = OiFileExplorerSettings.fromJson(const {});
      expect(s.schemaVersion, 1);
      expect(s.viewMode, OiFileViewMode.grid);
      expect(s.sortField, OiFileSortField.name);
      expect(s.sortDirection, OiSortDirection.ascending);
      expect(s.sidebarWidth, 240);
      expect(s.sidebarCollapsed, isFalse);
      expect(s.favoriteFolderIds, isEmpty);
      expect(s.recentPaths, isEmpty);
    });

    test('toJson includes schemaVersion key', () {
      const s = OiFileExplorerSettings(schemaVersion: 3);
      final json = s.toJson();
      expect(json['schemaVersion'], 3);
    });

    test('fromJson handles null lists gracefully', () {
      final s = OiFileExplorerSettings.fromJson(const {
        'favoriteFolderIds': null,
        'recentPaths': null,
      });
      expect(s.favoriteFolderIds, isEmpty);
      expect(s.recentPaths, isEmpty);
    });

    test('fromJson handles unknown enum values gracefully', () {
      final s = OiFileExplorerSettings.fromJson(const {
        'viewMode': 'unknown_mode',
        'sortField': 'badField',
        'sortDirection': 'sideways',
      });
      expect(s.viewMode, OiFileViewMode.grid);
      expect(s.sortField, OiFileSortField.name);
      expect(s.sortDirection, OiSortDirection.ascending);
    });

    test('fromJson parses sidebarWidth from int JSON value', () {
      final s = OiFileExplorerSettings.fromJson(const {'sidebarWidth': 200});
      expect(s.sidebarWidth, 200.0);
    });

    test('schemaVersion is preserved across round-trip', () {
      const original = OiFileExplorerSettings(schemaVersion: 5);
      final restored = OiFileExplorerSettings.fromJson(original.toJson());
      expect(restored.schemaVersion, 5);
    });

    // ── mergeWith ─────────────────────────────────────────────────────────────

    test('mergeWith: empty favoriteFolderIds filled from defaults', () {
      const saved = OiFileExplorerSettings();
      const defaults = OiFileExplorerSettings(favoriteFolderIds: ['a', 'b']);
      final merged = saved.mergeWith(defaults);
      expect(merged.favoriteFolderIds, ['a', 'b']);
    });

    test('mergeWith: non-empty favoriteFolderIds preserved', () {
      const saved = OiFileExplorerSettings(favoriteFolderIds: ['x']);
      const defaults = OiFileExplorerSettings(favoriteFolderIds: ['a', 'b']);
      final merged = saved.mergeWith(defaults);
      expect(merged.favoriteFolderIds, ['x']);
    });

    test('mergeWith: empty recentPaths filled from defaults', () {
      const saved = OiFileExplorerSettings();
      const defaults = OiFileExplorerSettings(recentPaths: ['/path/a']);
      final merged = saved.mergeWith(defaults);
      expect(merged.recentPaths, ['/path/a']);
    });

    test('mergeWith: non-empty recentPaths preserved', () {
      const saved = OiFileExplorerSettings(recentPaths: ['/my/path']);
      const defaults = OiFileExplorerSettings(recentPaths: ['/path/a']);
      final merged = saved.mergeWith(defaults);
      expect(merged.recentPaths, ['/my/path']);
    });

    test('mergeWith: schemaVersion comes from saved, not defaults', () {
      const saved = OiFileExplorerSettings(schemaVersion: 2);
      const defaults = OiFileExplorerSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.schemaVersion, 2);
    });

    test('mergeWith: enum values come from saved', () {
      const saved = OiFileExplorerSettings(
        viewMode: OiFileViewMode.list,
        sortField: OiFileSortField.modified,
        sortDirection: OiSortDirection.descending,
      );
      const defaults = OiFileExplorerSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.viewMode, OiFileViewMode.list);
      expect(merged.sortField, OiFileSortField.modified);
      expect(merged.sortDirection, OiSortDirection.descending);
    });

    // ── copyWith ──────────────────────────────────────────────────────────────

    test('copyWith returns identical when no args provided', () {
      const s = OiFileExplorerSettings(
        viewMode: OiFileViewMode.list,
        sidebarWidth: 300,
      );
      expect(s.copyWith(), equals(s));
    });

    test('copyWith updates single field', () {
      const s = OiFileExplorerSettings();
      final updated = s.copyWith(viewMode: OiFileViewMode.list);
      expect(updated.viewMode, OiFileViewMode.list);
      expect(updated.sortField, OiFileSortField.name);
    });

    test('copyWith updates multiple fields at once', () {
      const s = OiFileExplorerSettings();
      final updated = s.copyWith(
        viewMode: OiFileViewMode.list,
        sortField: OiFileSortField.size,
        sortDirection: OiSortDirection.descending,
        sidebarWidth: 180,
        sidebarCollapsed: true,
      );
      expect(updated.viewMode, OiFileViewMode.list);
      expect(updated.sortField, OiFileSortField.size);
      expect(updated.sortDirection, OiSortDirection.descending);
      expect(updated.sidebarWidth, 180);
      expect(updated.sidebarCollapsed, isTrue);
    });

    test('copyWith preserves unspecified fields', () {
      const s = OiFileExplorerSettings(
        viewMode: OiFileViewMode.list,
        sidebarWidth: 300,
      );
      final updated = s.copyWith(sidebarCollapsed: true);
      expect(updated.viewMode, OiFileViewMode.list);
      expect(updated.sidebarWidth, 300);
    });

    // ── equality / hashCode ───────────────────────────────────────────────────

    test('two identical instances are equal', () {
      const a = OiFileExplorerSettings(
        viewMode: OiFileViewMode.list,
        favoriteFolderIds: ['f1'],
      );
      const b = OiFileExplorerSettings(
        viewMode: OiFileViewMode.list,
        favoriteFolderIds: ['f1'],
      );
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = OiFileExplorerSettings(sidebarWidth: 240);
      const b = OiFileExplorerSettings(sidebarWidth: 300);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiFileExplorerSettings(
        favoriteFolderIds: ['x'],
        recentPaths: ['/a'],
      );
      const b = OiFileExplorerSettings(
        favoriteFolderIds: ['x'],
        recentPaths: ['/a'],
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    // ── schemaVersion ─────────────────────────────────────────────────────────

    test('schemaVersion is 1 by default', () {
      const s = OiFileExplorerSettings();
      expect(s.schemaVersion, 1);
    });
  });
}
