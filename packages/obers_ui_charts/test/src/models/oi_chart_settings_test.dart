// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/models/oi_chart_settings.dart';

void main() {
  group('OiPersistedViewport', () {
    test('round-trips through toJson/fromJson', () {
      const viewport = OiPersistedViewport(
        xMin: 10,
        xMax: 100,
        yMin: 0,
        yMax: 500,
      );
      final json = viewport.toJson();
      final restored = OiPersistedViewport.fromJson(json);
      expect(restored.xMin, 10);
      expect(restored.xMax, 100);
      expect(restored.yMin, 0);
      expect(restored.yMax, 500);
      expect(restored, viewport);
    });

    test('null fields round-trip as null', () {
      const viewport = OiPersistedViewport(xMin: 5);
      final json = viewport.toJson();
      final restored = OiPersistedViewport.fromJson(json);
      expect(restored.xMin, 5);
      expect(restored.xMax, isNull);
      expect(restored.yMin, isNull);
      expect(restored.yMax, isNull);
    });
  });

  group('OiPersistedSelection', () {
    test('round-trips refs through toJson/fromJson', () {
      const selection = OiPersistedSelection(
        selectedRefs: [
          (seriesIndex: 0, dataIndex: 3),
          (seriesIndex: 1, dataIndex: 7),
        ],
      );
      final json = selection.toJson();
      final restored = OiPersistedSelection.fromJson(json);
      expect(restored.selectedRefs, hasLength(2));
      expect(restored.selectedRefs[0].seriesIndex, 0);
      expect(restored.selectedRefs[0].dataIndex, 3);
      expect(restored.selectedRefs[1].seriesIndex, 1);
      expect(restored.selectedRefs[1].dataIndex, 7);
      expect(restored.hasSelection, isTrue);
    });

    test('empty selection round-trips', () {
      const selection = OiPersistedSelection();
      expect(selection.hasSelection, isFalse);
      final json = selection.toJson();
      final restored = OiPersistedSelection.fromJson(json);
      expect(restored.hasSelection, isFalse);
    });
  });

  group('OiChartSettings', () {
    test('default constructor produces expected defaults', () {
      const s = OiChartSettings();
      expect(s.schemaVersion, 2);
      expect(s.hiddenSeriesIds, isEmpty);
      expect(s.viewport, isNull);
      expect(s.selection, isNull);
      expect(s.legendExpandedGroups, isEmpty);
      expect(s.comparisonMode, OiChartComparisonMode.none);
    });

    test('round-trips all fields through toJson / fromJson', () {
      const original = OiChartSettings(
        hiddenSeriesIds: {'revenue', 'costs'},
        viewport: OiPersistedViewport(xMin: 0, xMax: 100, yMin: 0, yMax: 200),
        selection: OiPersistedSelection(
          selectedRefs: [(seriesIndex: 1, dataIndex: 5)],
        ),
        legendExpandedGroups: {'group-a': true, 'group-b': false},
        comparisonMode: OiChartComparisonMode.previousPeriod,
      );
      final json = original.toJson();
      final restored = OiChartSettings.fromJson(json);
      expect(restored.schemaVersion, original.schemaVersion);
      expect(restored.hiddenSeriesIds, original.hiddenSeriesIds);
      expect(restored.viewport, original.viewport);
      expect(restored.selection!.selectedRefs, hasLength(1));
      expect(restored.legendExpandedGroups, original.legendExpandedGroups);
      expect(restored.comparisonMode, original.comparisonMode);
    });

    test('fromJson with missing fields uses defaults', () {
      final s = OiChartSettings.fromJson(const {});
      expect(s.schemaVersion, 2);
      expect(s.hiddenSeriesIds, isEmpty);
      expect(s.viewport, isNull);
      expect(s.selection, isNull);
    });

    test('fromJson migrates v1 viewportWindow to viewport', () {
      final s = OiChartSettings.fromJson(const {
        'schemaVersion': 1,
        'viewportWindow': {'left': 10, 'top': 0, 'right': 100, 'bottom': 200},
      });
      expect(s.schemaVersion, 2);
      expect(s.viewport, isNotNull);
      expect(s.viewport!.xMin, 10);
      expect(s.viewport!.xMax, 100);
      expect(s.viewport!.yMin, 0);
      expect(s.viewport!.yMax, 200);
    });

    test('fromJson migrates v1 selectedSeriesIndex to selection', () {
      final s = OiChartSettings.fromJson(const {
        'schemaVersion': 1,
        'selectedSeriesIndex': 2,
        'selectedDataIndex': 7,
      });
      expect(s.selection, isNotNull);
      expect(s.selection!.selectedRefs, hasLength(1));
      expect(s.selection!.selectedRefs[0].seriesIndex, 2);
      expect(s.selection!.selectedRefs[0].dataIndex, 7);
    });

    test('fromJson migrates v1 legendExpandedGroups from list to map', () {
      final s = OiChartSettings.fromJson(const {
        'schemaVersion': 1,
        'legendExpandedGroups': ['group-a', 'group-b'],
      });
      expect(s.legendExpandedGroups, {'group-a': true, 'group-b': true});
    });

    test('toJson includes schemaVersion key', () {
      const s = OiChartSettings();
      final json = s.toJson();
      expect(json['schemaVersion'], 2);
    });

    test('toJson serializes comparisonMode as string name', () {
      const s = OiChartSettings(
        comparisonMode: OiChartComparisonMode.yearOverYear,
      );
      final json = s.toJson();
      expect(json['comparisonMode'], 'yearOverYear');
    });

    test('fromJson handles invalid comparisonMode gracefully', () {
      final s = OiChartSettings.fromJson(const {'comparisonMode': 'bogusMode'});
      expect(s.comparisonMode, OiChartComparisonMode.none);
    });

    test('mergeWith: empty hiddenSeriesIds filled from defaults', () {
      const saved = OiChartSettings();
      const defaults = OiChartSettings(hiddenSeriesIds: {'cost'});
      final merged = saved.mergeWith(defaults);
      expect(merged.hiddenSeriesIds, {'cost'});
    });

    test('mergeWith: non-empty hiddenSeriesIds preserved', () {
      const saved = OiChartSettings(hiddenSeriesIds: {'revenue'});
      const defaults = OiChartSettings(hiddenSeriesIds: {'cost'});
      final merged = saved.mergeWith(defaults);
      expect(merged.hiddenSeriesIds, {'revenue'});
    });

    test('mergeWith: null viewport filled from defaults', () {
      const saved = OiChartSettings();
      const defaults = OiChartSettings(
        viewport: OiPersistedViewport(xMin: 0, xMax: 100),
      );
      final merged = saved.mergeWith(defaults);
      expect(merged.viewport?.xMin, 0);
      expect(merged.viewport?.xMax, 100);
    });

    test('copyWith returns identical when no args provided', () {
      const original = OiChartSettings();
      final copied = original.copyWith();
      expect(copied, original);
    });

    test('copyWith updates single field', () {
      const original = OiChartSettings();
      final copied = original.copyWith(hiddenSeriesIds: {'hidden'});
      expect(copied.hiddenSeriesIds, {'hidden'});
      expect(copied.comparisonMode, OiChartComparisonMode.none);
    });

    test('two identical instances are equal', () {
      const a = OiChartSettings(hiddenSeriesIds: {'a', 'b'});
      const b = OiChartSettings(hiddenSeriesIds: {'b', 'a'});
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('instances with different fields are not equal', () {
      const a = OiChartSettings(hiddenSeriesIds: {'a'});
      const b = OiChartSettings(hiddenSeriesIds: {'b'});
      expect(a, isNot(b));
    });

    test('all comparison modes are available', () {
      expect(OiChartComparisonMode.values.length, 4);
    });
  });
}
