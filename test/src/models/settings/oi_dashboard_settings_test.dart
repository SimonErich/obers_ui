// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/settings/oi_dashboard_settings.dart';

void main() {
  group('OiDashboardCardPosition', () {
    test('toJson / fromJson round-trips', () {
      const pos = OiDashboardCardPosition(
        column: 2,
        row: 3,
        columnSpan: 2,
      );
      final json = pos.toJson();
      final restored = OiDashboardCardPosition.fromJson(json);
      expect(restored, equals(pos));
    });

    test('fromJson with missing fields uses defaults', () {
      final pos = OiDashboardCardPosition.fromJson(const {});
      expect(pos.column, 0);
      expect(pos.row, 0);
      expect(pos.columnSpan, 1);
      expect(pos.rowSpan, 1);
    });

    test('equality works correctly', () {
      const a = OiDashboardCardPosition(column: 1, row: 2);
      const b = OiDashboardCardPosition(column: 1, row: 2);
      const c = OiDashboardCardPosition(column: 1, row: 3);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiDashboardCardPosition(
        column: 1,
        row: 2,
        columnSpan: 3,
        rowSpan: 4,
      );
      const b = OiDashboardCardPosition(
        column: 1,
        row: 2,
        columnSpan: 3,
        rowSpan: 4,
      );
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('OiDashboardSettings', () {
    // ── Defaults ──────────────────────────────────────────────────────────────

    test('default constructor produces expected defaults', () {
      const s = OiDashboardSettings();
      expect(s.schemaVersion, 1);
      expect(s.cardPositions, isEmpty);
    });

    // ── toJson / fromJson round-trip ──────────────────────────────────────────

    test('round-trips all fields through toJson / fromJson', () {
      const original = OiDashboardSettings(
        schemaVersion: 2,
        cardPositions: {
          'card-1': OiDashboardCardPosition(
            column: 0,
            row: 0,
            columnSpan: 2,
          ),
          'card-2': OiDashboardCardPosition(column: 2, row: 1),
        },
      );
      final json = original.toJson();
      final restored = OiDashboardSettings.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson with missing fields uses defaults', () {
      final s = OiDashboardSettings.fromJson(const {});
      expect(s.schemaVersion, 1);
      expect(s.cardPositions, isEmpty);
    });

    test('toJson includes schemaVersion key', () {
      const s = OiDashboardSettings(schemaVersion: 3);
      final json = s.toJson();
      expect(json['schemaVersion'], 3);
    });

    test('fromJson handles null cardPositions gracefully', () {
      final s = OiDashboardSettings.fromJson(const {'cardPositions': null});
      expect(s.cardPositions, isEmpty);
    });

    test('schemaVersion is preserved across round-trip', () {
      const original = OiDashboardSettings(schemaVersion: 5);
      final restored = OiDashboardSettings.fromJson(original.toJson());
      expect(restored.schemaVersion, 5);
    });

    // ── mergeWith ─────────────────────────────────────────────────────────────

    test('mergeWith: empty cardPositions filled from defaults', () {
      const saved = OiDashboardSettings();
      const defaults = OiDashboardSettings(
        cardPositions: {'card-1': OiDashboardCardPosition(column: 0, row: 0)},
      );
      final merged = saved.mergeWith(defaults);
      expect(merged.cardPositions.length, 1);
      expect(
        merged.cardPositions['card-1'],
        const OiDashboardCardPosition(column: 0, row: 0),
      );
    });

    test('mergeWith: non-empty cardPositions preserved', () {
      const saved = OiDashboardSettings(
        cardPositions: {'card-x': OiDashboardCardPosition(column: 1, row: 1)},
      );
      const defaults = OiDashboardSettings(
        cardPositions: {'card-1': OiDashboardCardPosition(column: 0, row: 0)},
      );
      final merged = saved.mergeWith(defaults);
      expect(merged.cardPositions.length, 1);
      expect(merged.cardPositions.containsKey('card-x'), isTrue);
    });

    test('mergeWith: schemaVersion comes from saved, not defaults', () {
      const saved = OiDashboardSettings(schemaVersion: 2);
      const defaults = OiDashboardSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.schemaVersion, 2);
    });

    // ── copyWith ──────────────────────────────────────────────────────────────

    test('copyWith returns identical when no args provided', () {
      const s = OiDashboardSettings(
        cardPositions: {'c': OiDashboardCardPosition(column: 0, row: 0)},
      );
      expect(s.copyWith(), equals(s));
    });

    test('copyWith updates cardPositions', () {
      const s = OiDashboardSettings();
      final updated = s.copyWith(
        cardPositions: {
          'new': const OiDashboardCardPosition(column: 1, row: 2),
        },
      );
      expect(updated.cardPositions.length, 1);
      expect(
        updated.cardPositions['new'],
        const OiDashboardCardPosition(column: 1, row: 2),
      );
    });

    test('copyWith preserves unspecified fields', () {
      const s = OiDashboardSettings(
        schemaVersion: 3,
        cardPositions: {'a': OiDashboardCardPosition(column: 0, row: 0)},
      );
      final updated = s.copyWith(schemaVersion: 4);
      expect(updated.schemaVersion, 4);
      expect(updated.cardPositions.length, 1);
    });

    // ── equality / hashCode ───────────────────────────────────────────────────

    test('two identical instances are equal', () {
      const a = OiDashboardSettings(
        cardPositions: {'c1': OiDashboardCardPosition(column: 0, row: 0)},
      );
      const b = OiDashboardSettings(
        cardPositions: {'c1': OiDashboardCardPosition(column: 0, row: 0)},
      );
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = OiDashboardSettings(
        cardPositions: {'c1': OiDashboardCardPosition(column: 0, row: 0)},
      );
      const b = OiDashboardSettings(
        cardPositions: {'c1': OiDashboardCardPosition(column: 1, row: 0)},
      );
      expect(a, isNot(equals(b)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiDashboardSettings(
        cardPositions: {'c': OiDashboardCardPosition(column: 0, row: 0)},
      );
      const b = OiDashboardSettings(
        cardPositions: {'c': OiDashboardCardPosition(column: 0, row: 0)},
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    // ── schemaVersion ─────────────────────────────────────────────────────────

    test('schemaVersion is 1 by default', () {
      const s = OiDashboardSettings();
      expect(s.schemaVersion, 1);
    });
  });
}
