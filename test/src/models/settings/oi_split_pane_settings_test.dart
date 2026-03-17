// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/settings/oi_split_pane_settings.dart';

void main() {
  group('OiSplitPaneSettings', () {
    // ── Defaults ──────────────────────────────────────────────────────────────

    test('default constructor produces expected defaults', () {
      const s = OiSplitPaneSettings();
      expect(s.schemaVersion, 1);
      expect(s.dividerPosition, 0.5);
      expect(s.paneCollapsed, isFalse);
    });

    // ── toJson / fromJson round-trip ──────────────────────────────────────────

    test('round-trips all fields through toJson / fromJson', () {
      const original = OiSplitPaneSettings(
        schemaVersion: 2,
        dividerPosition: 0.3,
        paneCollapsed: true,
      );
      final json = original.toJson();
      final restored = OiSplitPaneSettings.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson with missing fields uses defaults', () {
      final s = OiSplitPaneSettings.fromJson(const {});
      expect(s.schemaVersion, 1);
      expect(s.dividerPosition, 0.5);
      expect(s.paneCollapsed, isFalse);
    });

    test('toJson includes schemaVersion key', () {
      const s = OiSplitPaneSettings(schemaVersion: 3);
      final json = s.toJson();
      expect(json['schemaVersion'], 3);
    });

    test('fromJson parses dividerPosition from int JSON value', () {
      final s = OiSplitPaneSettings.fromJson(const {'dividerPosition': 1});
      expect(s.dividerPosition, 1.0);
    });

    test('schemaVersion is preserved across round-trip', () {
      const original = OiSplitPaneSettings(schemaVersion: 5);
      final restored = OiSplitPaneSettings.fromJson(original.toJson());
      expect(restored.schemaVersion, 5);
    });

    // ── mergeWith ─────────────────────────────────────────────────────────────

    test('mergeWith: values come from saved', () {
      const saved = OiSplitPaneSettings(
        dividerPosition: 0.7,
        paneCollapsed: true,
      );
      const defaults = OiSplitPaneSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.dividerPosition, 0.7);
      expect(merged.paneCollapsed, isTrue);
    });

    test('mergeWith: schemaVersion comes from saved, not defaults', () {
      const saved = OiSplitPaneSettings(schemaVersion: 2);
      const defaults = OiSplitPaneSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.schemaVersion, 2);
    });

    test('mergeWith: saved values are preserved over defaults', () {
      const saved = OiSplitPaneSettings(dividerPosition: 0.2);
      const defaults = OiSplitPaneSettings(dividerPosition: 0.8);
      final merged = saved.mergeWith(defaults);
      expect(merged.dividerPosition, 0.2);
    });

    // ── copyWith ──────────────────────────────────────────────────────────────

    test('copyWith returns identical when no args provided', () {
      const s = OiSplitPaneSettings(dividerPosition: 0.3);
      expect(s.copyWith(), equals(s));
    });

    test('copyWith updates single field', () {
      const s = OiSplitPaneSettings();
      final updated = s.copyWith(dividerPosition: 0.8);
      expect(updated.dividerPosition, 0.8);
      expect(updated.paneCollapsed, isFalse);
    });

    test('copyWith updates multiple fields at once', () {
      const s = OiSplitPaneSettings();
      final updated = s.copyWith(dividerPosition: 0.2, paneCollapsed: true);
      expect(updated.dividerPosition, 0.2);
      expect(updated.paneCollapsed, isTrue);
    });

    test('copyWith preserves unspecified fields', () {
      const s = OiSplitPaneSettings(dividerPosition: 0.7, paneCollapsed: true);
      final updated = s.copyWith(dividerPosition: 0.4);
      expect(updated.dividerPosition, 0.4);
      expect(updated.paneCollapsed, isTrue);
    });

    // ── equality / hashCode ───────────────────────────────────────────────────

    test('two identical instances are equal', () {
      const a = OiSplitPaneSettings(dividerPosition: 0.3);
      const b = OiSplitPaneSettings(dividerPosition: 0.3);
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = OiSplitPaneSettings(dividerPosition: 0.3);
      const b = OiSplitPaneSettings(dividerPosition: 0.7);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiSplitPaneSettings(dividerPosition: 0.6, paneCollapsed: true);
      const b = OiSplitPaneSettings(dividerPosition: 0.6, paneCollapsed: true);
      expect(a.hashCode, equals(b.hashCode));
    });

    // ── schemaVersion ─────────────────────────────────────────────────────────

    test('schemaVersion is 1 by default', () {
      const s = OiSplitPaneSettings();
      expect(s.schemaVersion, 1);
    });
  });
}
