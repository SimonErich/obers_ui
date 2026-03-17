// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/settings/oi_kanban_settings.dart';

void main() {
  group('OiKanbanSettings', () {
    // ── Defaults ──────────────────────────────────────────────────────────────

    test('default constructor produces expected defaults', () {
      const s = OiKanbanSettings();
      expect(s.schemaVersion, 1);
      expect(s.columnOrder, isEmpty);
      expect(s.collapsedColumnKeys, isEmpty);
    });

    // ── toJson / fromJson round-trip ──────────────────────────────────────────

    test('round-trips all fields through toJson / fromJson', () {
      const original = OiKanbanSettings(
        schemaVersion: 2,
        columnOrder: ['todo', 'doing', 'done'],
        collapsedColumnKeys: {'done'},
      );
      final json = original.toJson();
      final restored = OiKanbanSettings.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson with missing fields uses defaults', () {
      final s = OiKanbanSettings.fromJson(const {});
      expect(s.schemaVersion, 1);
      expect(s.columnOrder, isEmpty);
      expect(s.collapsedColumnKeys, isEmpty);
    });

    test('toJson includes schemaVersion key', () {
      const s = OiKanbanSettings(schemaVersion: 3);
      final json = s.toJson();
      expect(json['schemaVersion'], 3);
    });

    test('fromJson handles null values gracefully', () {
      final s = OiKanbanSettings.fromJson(const {
        'columnOrder': null,
        'collapsedColumnKeys': null,
      });
      expect(s.columnOrder, isEmpty);
      expect(s.collapsedColumnKeys, isEmpty);
    });

    test('schemaVersion is preserved across round-trip', () {
      const original = OiKanbanSettings(schemaVersion: 5);
      final restored = OiKanbanSettings.fromJson(original.toJson());
      expect(restored.schemaVersion, 5);
    });

    test('toJson serializes columnOrder as list of strings', () {
      const s = OiKanbanSettings(columnOrder: ['a', 'b']);
      final json = s.toJson();
      expect(json['columnOrder'], ['a', 'b']);
    });

    test('toJson serializes collapsedColumnKeys as list of strings', () {
      const s = OiKanbanSettings(collapsedColumnKeys: {'x', 'y'});
      final json = s.toJson();
      expect(json['collapsedColumnKeys'], isA<List<dynamic>>());
      expect(
        (json['collapsedColumnKeys'] as List).toSet(),
        {'x', 'y'},
      );
    });

    // ── mergeWith ─────────────────────────────────────────────────────────────

    test('mergeWith: empty columnOrder filled from defaults', () {
      const saved = OiKanbanSettings();
      const defaults = OiKanbanSettings(columnOrder: ['a', 'b']);
      final merged = saved.mergeWith(defaults);
      expect(merged.columnOrder, ['a', 'b']);
    });

    test('mergeWith: non-empty columnOrder preserved', () {
      const saved = OiKanbanSettings(columnOrder: ['x']);
      const defaults = OiKanbanSettings(columnOrder: ['a', 'b']);
      final merged = saved.mergeWith(defaults);
      expect(merged.columnOrder, ['x']);
    });

    test('mergeWith: empty collapsedColumnKeys filled from defaults', () {
      const saved = OiKanbanSettings();
      const defaults = OiKanbanSettings(collapsedColumnKeys: {'done'});
      final merged = saved.mergeWith(defaults);
      expect(merged.collapsedColumnKeys, {'done'});
    });

    test('mergeWith: non-empty collapsedColumnKeys preserved', () {
      const saved = OiKanbanSettings(collapsedColumnKeys: {'todo'});
      const defaults = OiKanbanSettings(collapsedColumnKeys: {'done'});
      final merged = saved.mergeWith(defaults);
      expect(merged.collapsedColumnKeys, {'todo'});
    });

    test('mergeWith: schemaVersion comes from saved, not defaults', () {
      const saved = OiKanbanSettings(schemaVersion: 2);
      const defaults = OiKanbanSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.schemaVersion, 2);
    });

    // ── copyWith ──────────────────────────────────────────────────────────────

    test('copyWith returns identical when no args provided', () {
      const s = OiKanbanSettings(columnOrder: ['a']);
      expect(s.copyWith(), equals(s));
    });

    test('copyWith updates single field', () {
      const s = OiKanbanSettings();
      final updated = s.copyWith(columnOrder: ['new']);
      expect(updated.columnOrder, ['new']);
      expect(updated.collapsedColumnKeys, isEmpty);
    });

    test('copyWith updates multiple fields at once', () {
      const s = OiKanbanSettings();
      final updated = s.copyWith(
        columnOrder: ['a', 'b'],
        collapsedColumnKeys: {'b'},
      );
      expect(updated.columnOrder, ['a', 'b']);
      expect(updated.collapsedColumnKeys, {'b'});
    });

    test('copyWith preserves unspecified fields', () {
      const s = OiKanbanSettings(
        columnOrder: ['x', 'y'],
        collapsedColumnKeys: {'y'},
      );
      final updated = s.copyWith(columnOrder: ['a']);
      expect(updated.columnOrder, ['a']);
      expect(updated.collapsedColumnKeys, {'y'});
    });

    // ── equality / hashCode ───────────────────────────────────────────────────

    test('two identical instances are equal', () {
      const a = OiKanbanSettings(
        columnOrder: ['a', 'b'],
        collapsedColumnKeys: {'b'},
      );
      const b = OiKanbanSettings(
        columnOrder: ['a', 'b'],
        collapsedColumnKeys: {'b'},
      );
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = OiKanbanSettings(columnOrder: ['a']);
      const b = OiKanbanSettings(columnOrder: ['b']);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiKanbanSettings(
        columnOrder: ['x'],
        collapsedColumnKeys: {'x'},
      );
      const b = OiKanbanSettings(
        columnOrder: ['x'],
        collapsedColumnKeys: {'x'},
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    // ── schemaVersion ─────────────────────────────────────────────────────────

    test('schemaVersion is 1 by default', () {
      const s = OiKanbanSettings();
      expect(s.schemaVersion, 1);
    });
  });
}
