// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/settings/oi_table_settings.dart';

void main() {
  group('OiTableSettings', () {
    // ── Defaults ────────────────────────────────────────────────────────────

    test('default constructor produces expected defaults', () {
      const s = OiTableSettings();
      expect(s.schemaVersion, 1);
      expect(s.columnOrder, isEmpty);
      expect(s.columnVisibility, isEmpty);
      expect(s.columnWidths, isEmpty);
      expect(s.sortColumnId, isNull);
      expect(s.sortAscending, isTrue);
      expect(s.activeFilters, isEmpty);
      expect(s.pageSize, 25);
      expect(s.pageIndex, 0);
      expect(s.groupByColumnId, isNull);
      expect(s.frozenColumns, 0);
      expect(s.showStatusBar, isTrue);
    });

    // ── toJson / fromJson round-trip ────────────────────────────────────────

    test('round-trips all fields through toJson / fromJson', () {
      const original = OiTableSettings(
        schemaVersion: 2,
        columnOrder: ['a', 'b', 'c'],
        columnVisibility: {'a': true, 'b': false},
        columnWidths: {'a': 120.0, 'b': 80.5},
        sortColumnId: 'a',
        sortAscending: false,
        activeFilters: {'b': 'foo'},
        pageSize: 50,
        pageIndex: 3,
        groupByColumnId: 'c',
        frozenColumns: 2,
        showStatusBar: false,
      );
      final json = original.toJson();
      final restored = OiTableSettings.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson with missing fields uses defaults', () {
      final s = OiTableSettings.fromJson(const {});
      expect(s.schemaVersion, 1);
      expect(s.columnOrder, isEmpty);
      expect(s.sortAscending, isTrue);
      expect(s.pageSize, 25);
      expect(s.pageIndex, 0);
      expect(s.showStatusBar, isTrue);
    });

    test('toJson includes schemaVersion key', () {
      const s = OiTableSettings(schemaVersion: 3);
      final json = s.toJson();
      expect(json['schemaVersion'], 3);
    });

    test('fromJson parses columnWidths as doubles from int JSON values', () {
      final s = OiTableSettings.fromJson(const {
        'columnWidths': {'col': 100},
      });
      expect(s.columnWidths['col'], 100.0);
    });

    test('fromJson handles null maps gracefully', () {
      final s = OiTableSettings.fromJson(const {
        'columnVisibility': null,
        'columnWidths': null,
        'activeFilters': null,
        'columnOrder': null,
      });
      expect(s.columnVisibility, isEmpty);
      expect(s.columnWidths, isEmpty);
      expect(s.activeFilters, isEmpty);
      expect(s.columnOrder, isEmpty);
    });

    test('schemaVersion is preserved across round-trip', () {
      const original = OiTableSettings(schemaVersion: 5);
      final restored = OiTableSettings.fromJson(original.toJson());
      expect(restored.schemaVersion, 5);
    });

    // ── mergeWith ───────────────────────────────────────────────────────────

    test('mergeWith: empty columnOrder filled from defaults', () {
      const saved = OiTableSettings();
      const defaults = OiTableSettings(columnOrder: ['x', 'y']);
      final merged = saved.mergeWith(defaults);
      expect(merged.columnOrder, ['x', 'y']);
    });

    test('mergeWith: non-empty columnOrder preserved', () {
      const saved = OiTableSettings(columnOrder: ['a']);
      const defaults = OiTableSettings(columnOrder: ['x', 'y']);
      final merged = saved.mergeWith(defaults);
      expect(merged.columnOrder, ['a']);
    });

    test('mergeWith: empty columnVisibility filled from defaults', () {
      const saved = OiTableSettings();
      const defaults = OiTableSettings(columnVisibility: {'a': false});
      final merged = saved.mergeWith(defaults);
      expect(merged.columnVisibility, {'a': false});
    });

    test('mergeWith: null sortColumnId falls back to defaults', () {
      const saved = OiTableSettings();
      const defaults = OiTableSettings(sortColumnId: 'id');
      final merged = saved.mergeWith(defaults);
      expect(merged.sortColumnId, 'id');
    });

    test('mergeWith: non-null sortColumnId preserved', () {
      const saved = OiTableSettings(sortColumnId: 'name');
      const defaults = OiTableSettings(sortColumnId: 'id');
      final merged = saved.mergeWith(defaults);
      expect(merged.sortColumnId, 'name');
    });

    test('mergeWith: null groupByColumnId falls back to defaults', () {
      const saved = OiTableSettings();
      const defaults = OiTableSettings(groupByColumnId: 'category');
      final merged = saved.mergeWith(defaults);
      expect(merged.groupByColumnId, 'category');
    });

    test('mergeWith: empty columnWidths filled from defaults', () {
      const saved = OiTableSettings();
      const defaults = OiTableSettings(columnWidths: {'col': 120.0});
      final merged = saved.mergeWith(defaults);
      expect(merged.columnWidths, {'col': 120.0});
    });

    test('mergeWith: schemaVersion comes from saved, not defaults', () {
      const saved = OiTableSettings(schemaVersion: 2);
      const defaults = OiTableSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.schemaVersion, 2);
    });

    // ── copyWith ────────────────────────────────────────────────────────────

    test('copyWith returns identical when no args provided', () {
      const s = OiTableSettings(pageSize: 10, pageIndex: 2);
      expect(s.copyWith(), equals(s));
    });

    test('copyWith updates single field', () {
      const s = OiTableSettings();
      final updated = s.copyWith(pageSize: 50);
      expect(updated.pageSize, 50);
      expect(updated.pageIndex, 0);
    });

    test('copyWith can set sortColumnId to null explicitly', () {
      const s = OiTableSettings(sortColumnId: 'id');
      final updated = s.copyWith(sortColumnId: null);
      expect(updated.sortColumnId, isNull);
    });

    test('copyWith can set groupByColumnId to null explicitly', () {
      const s = OiTableSettings(groupByColumnId: 'cat');
      final updated = s.copyWith(groupByColumnId: null);
      expect(updated.groupByColumnId, isNull);
    });

    test('copyWith preserves sortColumnId when not specified', () {
      const s = OiTableSettings(sortColumnId: 'name');
      final updated = s.copyWith(pageSize: 10);
      expect(updated.sortColumnId, 'name');
    });

    test('copyWith updates multiple fields at once', () {
      const s = OiTableSettings();
      final updated = s.copyWith(
        pageSize: 100,
        pageIndex: 4,
        sortAscending: false,
        showStatusBar: false,
        frozenColumns: 1,
      );
      expect(updated.pageSize, 100);
      expect(updated.pageIndex, 4);
      expect(updated.sortAscending, isFalse);
      expect(updated.showStatusBar, isFalse);
      expect(updated.frozenColumns, 1);
    });

    // ── equality / hashCode ─────────────────────────────────────────────────

    test('two identical instances are equal', () {
      const a = OiTableSettings(pageSize: 10, sortColumnId: 'id');
      const b = OiTableSettings(pageSize: 10, sortColumnId: 'id');
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = OiTableSettings(pageSize: 10);
      const b = OiTableSettings(pageSize: 20);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiTableSettings(
        columnOrder: ['x'],
        columnVisibility: {'x': true},
      );
      const b = OiTableSettings(
        columnOrder: ['x'],
        columnVisibility: {'x': true},
      );
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
