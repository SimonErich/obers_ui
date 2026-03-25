// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/models/oi_chart_settings.dart';

void main() {
  group('OiChartSettings', () {
    // ── Defaults ────────────────────────────────────────────────────────────

    test('default constructor produces expected defaults', () {
      const s = OiChartSettings();
      expect(s.schemaVersion, 1);
      expect(s.hiddenSeriesIds, isEmpty);
      expect(s.viewportWindow, isNull);
      expect(s.selectedSeriesIndex, isNull);
      expect(s.selectedDataIndex, isNull);
      expect(s.legendExpandedGroups, isEmpty);
      expect(s.comparisonMode, OiChartComparisonMode.none);
    });

    // ── toJson / fromJson round-trip ──────────────────────────────────────

    test('round-trips all fields through toJson / fromJson', () {
      const original = OiChartSettings(
        schemaVersion: 2,
        hiddenSeriesIds: {'revenue', 'costs'},
        viewportWindow: Rect.fromLTRB(0, 0, 100, 200),
        selectedSeriesIndex: 1,
        selectedDataIndex: 5,
        legendExpandedGroups: {'group-a', 'group-b'},
        comparisonMode: OiChartComparisonMode.previousPeriod,
      );
      final json = original.toJson();
      final restored = OiChartSettings.fromJson(json);
      expect(restored.schemaVersion, original.schemaVersion);
      expect(restored.hiddenSeriesIds, original.hiddenSeriesIds);
      expect(restored.viewportWindow, original.viewportWindow);
      expect(restored.selectedSeriesIndex, original.selectedSeriesIndex);
      expect(restored.selectedDataIndex, original.selectedDataIndex);
      expect(restored.legendExpandedGroups, original.legendExpandedGroups);
      expect(restored.comparisonMode, original.comparisonMode);
    });

    test('fromJson with missing fields uses defaults', () {
      final s = OiChartSettings.fromJson(const {});
      expect(s.schemaVersion, 1);
      expect(s.hiddenSeriesIds, isEmpty);
      expect(s.viewportWindow, isNull);
      expect(s.selectedSeriesIndex, isNull);
      expect(s.selectedDataIndex, isNull);
      expect(s.legendExpandedGroups, isEmpty);
      expect(s.comparisonMode, OiChartComparisonMode.none);
    });

    test('toJson includes schemaVersion key', () {
      const s = OiChartSettings(schemaVersion: 3);
      final json = s.toJson();
      expect(json['schemaVersion'], 3);
    });

    test('fromJson handles null values gracefully', () {
      final s = OiChartSettings.fromJson(const {
        'hiddenSeriesIds': null,
        'viewportWindow': null,
        'selectedSeriesIndex': null,
        'selectedDataIndex': null,
        'legendExpandedGroups': null,
        'comparisonMode': null,
      });
      expect(s.hiddenSeriesIds, isEmpty);
      expect(s.viewportWindow, isNull);
      expect(s.selectedSeriesIndex, isNull);
      expect(s.selectedDataIndex, isNull);
      expect(s.legendExpandedGroups, isEmpty);
      expect(s.comparisonMode, OiChartComparisonMode.none);
    });

    test('schemaVersion is preserved across round-trip', () {
      const original = OiChartSettings(schemaVersion: 5);
      final restored = OiChartSettings.fromJson(original.toJson());
      expect(restored.schemaVersion, 5);
    });

    test('toJson serializes hiddenSeriesIds as list', () {
      const s = OiChartSettings(hiddenSeriesIds: {'a', 'b'});
      final json = s.toJson();
      expect(json['hiddenSeriesIds'], isA<List<dynamic>>());
      expect((json['hiddenSeriesIds'] as List).toSet(), {'a', 'b'});
    });

    test('toJson serializes viewportWindow as map', () {
      const s = OiChartSettings(
        viewportWindow: Rect.fromLTRB(10, 20, 30, 40),
      );
      final json = s.toJson();
      final vp = json['viewportWindow'] as Map<String, dynamic>;
      expect(vp['left'], 10.0);
      expect(vp['top'], 20.0);
      expect(vp['right'], 30.0);
      expect(vp['bottom'], 40.0);
    });

    test('toJson serializes comparisonMode as string name', () {
      const s = OiChartSettings(
        comparisonMode: OiChartComparisonMode.yearOverYear,
      );
      final json = s.toJson();
      expect(json['comparisonMode'], 'yearOverYear');
    });

    test('fromJson handles invalid comparisonMode gracefully', () {
      final s = OiChartSettings.fromJson(const {
        'comparisonMode': 'invalidMode',
      });
      expect(s.comparisonMode, OiChartComparisonMode.none);
    });

    test('fromJson handles incomplete viewportWindow gracefully', () {
      final s = OiChartSettings.fromJson(const {
        'viewportWindow': {'left': 10, 'top': 20},
      });
      expect(s.viewportWindow, isNull);
    });

    // ── mergeWith ─────────────────────────────────────────────────────────

    test('mergeWith: empty hiddenSeriesIds filled from defaults', () {
      const saved = OiChartSettings();
      const defaults = OiChartSettings(hiddenSeriesIds: {'a', 'b'});
      final merged = saved.mergeWith(defaults);
      expect(merged.hiddenSeriesIds, {'a', 'b'});
    });

    test('mergeWith: non-empty hiddenSeriesIds preserved', () {
      const saved = OiChartSettings(hiddenSeriesIds: {'x'});
      const defaults = OiChartSettings(hiddenSeriesIds: {'a', 'b'});
      final merged = saved.mergeWith(defaults);
      expect(merged.hiddenSeriesIds, {'x'});
    });

    test('mergeWith: null viewportWindow filled from defaults', () {
      const saved = OiChartSettings();
      const defaults = OiChartSettings(
        viewportWindow: Rect.fromLTRB(0, 0, 50, 50),
      );
      final merged = saved.mergeWith(defaults);
      expect(merged.viewportWindow, const Rect.fromLTRB(0, 0, 50, 50));
    });

    test('mergeWith: empty legendExpandedGroups filled from defaults', () {
      const saved = OiChartSettings();
      const defaults = OiChartSettings(legendExpandedGroups: {'g1'});
      final merged = saved.mergeWith(defaults);
      expect(merged.legendExpandedGroups, {'g1'});
    });

    test('mergeWith: schemaVersion comes from saved', () {
      const saved = OiChartSettings(schemaVersion: 2);
      const defaults = OiChartSettings();
      final merged = saved.mergeWith(defaults);
      expect(merged.schemaVersion, 2);
    });

    // ── copyWith ──────────────────────────────────────────────────────────

    test('copyWith returns identical when no args provided', () {
      const s = OiChartSettings(hiddenSeriesIds: {'a'});
      expect(s.copyWith(), equals(s));
    });

    test('copyWith updates single field', () {
      const s = OiChartSettings();
      final updated = s.copyWith(hiddenSeriesIds: {'series1'});
      expect(updated.hiddenSeriesIds, {'series1'});
      expect(updated.comparisonMode, OiChartComparisonMode.none);
    });

    test('copyWith updates multiple fields at once', () {
      const s = OiChartSettings();
      final updated = s.copyWith(
        hiddenSeriesIds: {'a'},
        comparisonMode: OiChartComparisonMode.baseline,
        selectedSeriesIndex: 2,
      );
      expect(updated.hiddenSeriesIds, {'a'});
      expect(updated.comparisonMode, OiChartComparisonMode.baseline);
      expect(updated.selectedSeriesIndex, 2);
    });

    test('copyWith can clear nullable fields', () {
      const s = OiChartSettings(
        viewportWindow: Rect.fromLTRB(0, 0, 100, 100),
        selectedSeriesIndex: 1,
        selectedDataIndex: 2,
      );
      final cleared = s.copyWith(
        clearViewportWindow: true,
        clearSelectedSeriesIndex: true,
        clearSelectedDataIndex: true,
      );
      expect(cleared.viewportWindow, isNull);
      expect(cleared.selectedSeriesIndex, isNull);
      expect(cleared.selectedDataIndex, isNull);
    });

    // ── equality / hashCode ───────────────────────────────────────────────

    test('two identical instances are equal', () {
      const a = OiChartSettings(
        hiddenSeriesIds: {'x'},
        comparisonMode: OiChartComparisonMode.previousPeriod,
      );
      const b = OiChartSettings(
        hiddenSeriesIds: {'x'},
        comparisonMode: OiChartComparisonMode.previousPeriod,
      );
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = OiChartSettings(hiddenSeriesIds: {'a'});
      const b = OiChartSettings(hiddenSeriesIds: {'b'});
      expect(a, isNot(equals(b)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiChartSettings(
        legendExpandedGroups: {'g'},
        selectedSeriesIndex: 3,
      );
      const b = OiChartSettings(
        legendExpandedGroups: {'g'},
        selectedSeriesIndex: 3,
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    // ── schemaVersion ─────────────────────────────────────────────────────

    test('schemaVersion is 1 by default', () {
      const s = OiChartSettings();
      expect(s.schemaVersion, 1);
    });

    // ── OiChartComparisonMode ─────────────────────────────────────────────

    test('all comparison modes are available', () {
      expect(OiChartComparisonMode.values, hasLength(4));
      expect(
        OiChartComparisonMode.values,
        contains(OiChartComparisonMode.none),
      );
      expect(
        OiChartComparisonMode.values,
        contains(OiChartComparisonMode.previousPeriod),
      );
      expect(
        OiChartComparisonMode.values,
        contains(OiChartComparisonMode.baseline),
      );
      expect(
        OiChartComparisonMode.values,
        contains(OiChartComparisonMode.yearOverYear),
      );
    });
  });
}
