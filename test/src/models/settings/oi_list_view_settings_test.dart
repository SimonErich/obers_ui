// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/settings/oi_list_view_settings.dart';

void main() {
  group('OiListViewSettings', () {
    // ── Defaults ──────────────────────────────────────────────────────────────

    test('default constructor produces expected defaults', () {
      const s = OiListViewSettings();
      expect(s.schemaVersion, 1);
      expect(s.layout, OiListViewLayout.list);
      expect(s.activeSortId, isNull);
      expect(s.activeFilters, isEmpty);
      expect(s.pageSize, isNull);
    });

    // ── toJson / fromJson round-trip ──────────────────────────────────────────

    test('round-trips all fields through toJson / fromJson', () {
      const original = OiListViewSettings(
        schemaVersion: 2,
        layout: OiListViewLayout.grid,
        activeSortId: 'name-asc',
        activeFilters: {'status': 'active', 'priority': 'high'},
        pageSize: 50,
      );
      final json = original.toJson();
      final restored = OiListViewSettings.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson with missing fields uses defaults', () {
      final s = OiListViewSettings.fromJson(const {});
      expect(s.schemaVersion, 1);
      expect(s.layout, OiListViewLayout.list);
      expect(s.activeSortId, isNull);
      expect(s.activeFilters, isEmpty);
      expect(s.pageSize, isNull);
    });

    test('toJson includes schemaVersion key', () {
      const s = OiListViewSettings(schemaVersion: 3);
      final json = s.toJson();
      expect(json['schemaVersion'], 3);
    });

    test('fromJson handles null maps gracefully', () {
      final s = OiListViewSettings.fromJson(const {
        'activeFilters': null,
      });
      expect(s.activeFilters, isEmpty);
    });

    test('fromJson handles unknown enum value gracefully', () {
      final s = OiListViewSettings.fromJson(const {
        'layout': 'carousel',
      });
      expect(s.layout, OiListViewLayout.list);
    });

    test('schemaVersion is preserved across round-trip', () {
      const original = OiListViewSettings(schemaVersion: 5);
      final restored = OiListViewSettings.fromJson(original.toJson());
      expect(restored.schemaVersion, 5);
    });

    test('round-trips null activeSortId and null pageSize', () {
      const original = OiListViewSettings();
      final json = original.toJson();
      final restored = OiListViewSettings.fromJson(json);
      expect(restored.activeSortId, isNull);
      expect(restored.pageSize, isNull);
    });

    // ── mergeWith ─────────────────────────────────────────────────────────────

    test('mergeWith: null activeSortId falls back to defaults', () {
      const saved = OiListViewSettings();
      const defaults = OiListViewSettings(activeSortId: 'name');
      final merged = saved.mergeWith(defaults);
      expect(merged.activeSortId, 'name');
    });

    test('mergeWith: non-null activeSortId preserved', () {
      const saved = OiListViewSettings(activeSortId: 'date');
      const defaults = OiListViewSettings(activeSortId: 'name');
      final merged = saved.mergeWith(defaults);
      expect(merged.activeSortId, 'date');
    });

    test('mergeWith: empty activeFilters filled from defaults', () {
      const saved = OiListViewSettings();
      const defaults = OiListViewSettings(
        activeFilters: {'status': 'active'},
      );
      final merged = saved.mergeWith(defaults);
      expect(merged.activeFilters, {'status': 'active'});
    });

    test('mergeWith: non-empty activeFilters preserved', () {
      const saved = OiListViewSettings(
        activeFilters: {'mine': 'yes'},
      );
      const defaults = OiListViewSettings(
        activeFilters: {'status': 'active'},
      );
      final merged = saved.mergeWith(defaults);
      expect(merged.activeFilters, {'mine': 'yes'});
    });

    test('mergeWith: null pageSize falls back to defaults', () {
      const saved = OiListViewSettings();
      const defaults = OiListViewSettings(pageSize: 25);
      final merged = saved.mergeWith(defaults);
      expect(merged.pageSize, 25);
    });

    test('mergeWith: non-null pageSize preserved', () {
      const saved = OiListViewSettings(pageSize: 50);
      const defaults = OiListViewSettings(pageSize: 25);
      final merged = saved.mergeWith(defaults);
      expect(merged.pageSize, 50);
    });

    test('mergeWith: schemaVersion comes from saved, not defaults', () {
      const saved = OiListViewSettings(schemaVersion: 2);
      const defaults = OiListViewSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.schemaVersion, 2);
    });

    test('mergeWith: layout comes from saved', () {
      const saved = OiListViewSettings(layout: OiListViewLayout.table);
      const defaults = OiListViewSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.layout, OiListViewLayout.table);
    });

    // ── copyWith ──────────────────────────────────────────────────────────────

    test('copyWith returns identical when no args provided', () {
      const s = OiListViewSettings(
        layout: OiListViewLayout.grid,
        activeSortId: 'name',
      );
      expect(s.copyWith(), equals(s));
    });

    test('copyWith updates single field', () {
      const s = OiListViewSettings();
      final updated = s.copyWith(layout: OiListViewLayout.grid);
      expect(updated.layout, OiListViewLayout.grid);
      expect(updated.activeSortId, isNull);
    });

    test('copyWith can set activeSortId to null explicitly', () {
      const s = OiListViewSettings(activeSortId: 'name');
      final updated = s.copyWith(activeSortId: null);
      expect(updated.activeSortId, isNull);
    });

    test('copyWith can set pageSize to null explicitly', () {
      const s = OiListViewSettings(pageSize: 25);
      final updated = s.copyWith(pageSize: null);
      expect(updated.pageSize, isNull);
    });

    test('copyWith preserves activeSortId when not specified', () {
      const s = OiListViewSettings(activeSortId: 'name');
      final updated = s.copyWith(layout: OiListViewLayout.table);
      expect(updated.activeSortId, 'name');
    });

    test('copyWith updates multiple fields at once', () {
      const s = OiListViewSettings();
      final updated = s.copyWith(
        layout: OiListViewLayout.table,
        activeSortId: 'date',
        activeFilters: {'status': 'done'},
        pageSize: 100,
      );
      expect(updated.layout, OiListViewLayout.table);
      expect(updated.activeSortId, 'date');
      expect(updated.activeFilters, {'status': 'done'});
      expect(updated.pageSize, 100);
    });

    // ── equality / hashCode ───────────────────────────────────────────────────

    test('two identical instances are equal', () {
      const a = OiListViewSettings(
        layout: OiListViewLayout.grid,
        activeSortId: 'name',
      );
      const b = OiListViewSettings(
        layout: OiListViewLayout.grid,
        activeSortId: 'name',
      );
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = OiListViewSettings(layout: OiListViewLayout.list);
      const b = OiListViewSettings(layout: OiListViewLayout.grid);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiListViewSettings(
        activeFilters: {'x': 'y'},
        pageSize: 10,
      );
      const b = OiListViewSettings(
        activeFilters: {'x': 'y'},
        pageSize: 10,
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    // ── schemaVersion ─────────────────────────────────────────────────────────

    test('schemaVersion is 1 by default', () {
      const s = OiListViewSettings();
      expect(s.schemaVersion, 1);
    });
  });
}
