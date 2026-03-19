// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/settings/oi_sidebar_settings.dart';

void main() {
  group('OiSidebarSettings', () {
    // ── Defaults ──────────────────────────────────────────────────────────────

    test('default constructor produces expected defaults', () {
      const s = OiSidebarSettings();
      expect(s.schemaVersion, 1);
      expect(s.mode, OiSidebarMode.full);
      expect(s.width, 260);
      expect(s.collapsedSectionIds, isEmpty);
    });

    // ── toJson / fromJson round-trip ──────────────────────────────────────────

    test('round-trips all fields through toJson / fromJson', () {
      const original = OiSidebarSettings(
        schemaVersion: 2,
        mode: OiSidebarMode.compact,
        width: 80,
        collapsedSectionIds: {'section-1', 'section-2'},
      );
      final json = original.toJson();
      final restored = OiSidebarSettings.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson with missing fields uses defaults', () {
      final s = OiSidebarSettings.fromJson(const {});
      expect(s.schemaVersion, 1);
      expect(s.mode, OiSidebarMode.full);
      expect(s.width, 260);
      expect(s.collapsedSectionIds, isEmpty);
    });

    test('toJson includes schemaVersion key', () {
      const s = OiSidebarSettings(schemaVersion: 3);
      final json = s.toJson();
      expect(json['schemaVersion'], 3);
    });

    test('fromJson handles null collapsedSectionIds gracefully', () {
      final s = OiSidebarSettings.fromJson(const {'collapsedSectionIds': null});
      expect(s.collapsedSectionIds, isEmpty);
    });

    test('fromJson handles unknown enum value gracefully', () {
      final s = OiSidebarSettings.fromJson(const {'mode': 'nonexistent'});
      expect(s.mode, OiSidebarMode.full);
    });

    test('fromJson parses width from int JSON value', () {
      final s = OiSidebarSettings.fromJson(const {'width': 200});
      expect(s.width, 200.0);
    });

    test('schemaVersion is preserved across round-trip', () {
      const original = OiSidebarSettings(schemaVersion: 5);
      final restored = OiSidebarSettings.fromJson(original.toJson());
      expect(restored.schemaVersion, 5);
    });

    // ── mergeWith ─────────────────────────────────────────────────────────────

    test('mergeWith: empty collapsedSectionIds filled from defaults', () {
      const saved = OiSidebarSettings();
      const defaults = OiSidebarSettings(collapsedSectionIds: {'nav', 'tools'});
      final merged = saved.mergeWith(defaults);
      expect(merged.collapsedSectionIds, {'nav', 'tools'});
    });

    test('mergeWith: non-empty collapsedSectionIds preserved', () {
      const saved = OiSidebarSettings(collapsedSectionIds: {'mine'});
      const defaults = OiSidebarSettings(collapsedSectionIds: {'nav', 'tools'});
      final merged = saved.mergeWith(defaults);
      expect(merged.collapsedSectionIds, {'mine'});
    });

    test('mergeWith: schemaVersion comes from saved, not defaults', () {
      const saved = OiSidebarSettings(schemaVersion: 2);
      const defaults = OiSidebarSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.schemaVersion, 2);
    });

    test('mergeWith: mode and width come from saved', () {
      const saved = OiSidebarSettings(mode: OiSidebarMode.hidden, width: 100);
      const defaults = OiSidebarSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.mode, OiSidebarMode.hidden);
      expect(merged.width, 100);
    });

    // ── copyWith ──────────────────────────────────────────────────────────────

    test('copyWith returns identical when no args provided', () {
      const s = OiSidebarSettings(mode: OiSidebarMode.compact, width: 80);
      expect(s.copyWith(), equals(s));
    });

    test('copyWith updates single field', () {
      const s = OiSidebarSettings();
      final updated = s.copyWith(mode: OiSidebarMode.hidden);
      expect(updated.mode, OiSidebarMode.hidden);
      expect(updated.width, 260);
    });

    test('copyWith updates multiple fields at once', () {
      const s = OiSidebarSettings();
      final updated = s.copyWith(
        mode: OiSidebarMode.compact,
        width: 60,
        collapsedSectionIds: {'a'},
      );
      expect(updated.mode, OiSidebarMode.compact);
      expect(updated.width, 60);
      expect(updated.collapsedSectionIds, {'a'});
    });

    test('copyWith preserves unspecified fields', () {
      const s = OiSidebarSettings(mode: OiSidebarMode.compact, width: 80);
      final updated = s.copyWith(collapsedSectionIds: {'sec'});
      expect(updated.mode, OiSidebarMode.compact);
      expect(updated.width, 80);
    });

    // ── equality / hashCode ───────────────────────────────────────────────────

    test('two identical instances are equal', () {
      const a = OiSidebarSettings(
        mode: OiSidebarMode.compact,
        collapsedSectionIds: {'s1'},
      );
      const b = OiSidebarSettings(
        mode: OiSidebarMode.compact,
        collapsedSectionIds: {'s1'},
      );
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = OiSidebarSettings();
      const b = OiSidebarSettings(width: 300);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiSidebarSettings(collapsedSectionIds: {'x'});
      const b = OiSidebarSettings(collapsedSectionIds: {'x'});
      expect(a.hashCode, equals(b.hashCode));
    });

    // ── schemaVersion ─────────────────────────────────────────────────────────

    test('schemaVersion is 1 by default', () {
      const s = OiSidebarSettings();
      expect(s.schemaVersion, 1);
    });
  });
}
