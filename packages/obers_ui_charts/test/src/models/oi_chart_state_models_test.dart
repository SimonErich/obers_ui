
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiChartSelectionState', () {
    test('empty has no selection', () {
      const state = OiChartSelectionState.empty;
      expect(state.hasSelection, isFalse);
      expect(state.selectedRefs, isEmpty);
      expect(state.mode, OiChartSelectionMode.point);
    });

    test('copyWith preserves unset fields', () {
      final now = DateTime.now();
      final state = OiChartSelectionState(
        selectedRefs: {const OiChartDataRef(seriesIndex: 0, dataIndex: 1)},
        mode: OiChartSelectionMode.series,
        timestamp: now,
      );
      final copied = state.copyWith(mode: OiChartSelectionMode.brush);
      expect(copied.selectedRefs, state.selectedRefs);
      expect(copied.mode, OiChartSelectionMode.brush);
      expect(copied.timestamp, now);
    });

    test('equality compares all fields', () {
      final now = DateTime(2026);
      final a = OiChartSelectionState(
        selectedRefs: {const OiChartDataRef(seriesIndex: 0, dataIndex: 1)},
        timestamp: now,
      );
      final b = OiChartSelectionState(
        selectedRefs: {const OiChartDataRef(seriesIndex: 0, dataIndex: 1)},
        timestamp: now,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different refs are not equal', () {
      final a = OiChartSelectionState(
        selectedRefs: {const OiChartDataRef(seriesIndex: 0, dataIndex: 1)},
      );
      final b = OiChartSelectionState(
        selectedRefs: {const OiChartDataRef(seriesIndex: 0, dataIndex: 2)},
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('OiChartHoverState', () {
    test('empty has no hover', () {
      const state = OiChartHoverState.empty;
      expect(state.isHovering, isFalse);
      expect(state.ref, isNull);
    });

    test('copyWith and equality', () {
      const ref = OiChartDataRef(seriesIndex: 1, dataIndex: 3);
      const state = OiChartHoverState(
        ref: ref,
        position: Offset(10, 20),
        seriesId: 'series-a',
      );
      final copied = state.copyWith(seriesId: 'series-b');
      expect(copied.ref, ref);
      expect(copied.seriesId, 'series-b');
      expect(state, isNot(equals(copied)));
    });
  });

  group('OiChartLegendState', () {
    test('empty has all series visible', () {
      const state = OiChartLegendState.empty;
      expect(state.isVisible('any'), isTrue);
      expect(state.hiddenSeriesIds, isEmpty);
    });

    test('isVisible returns false for hidden series', () {
      const state = OiChartLegendState(hiddenSeriesIds: {'hidden-1'});
      expect(state.isVisible('hidden-1'), isFalse);
      expect(state.isVisible('visible-1'), isTrue);
    });

    test('copyWith preserves unset fields', () {
      const state = OiChartLegendState(
        hiddenSeriesIds: {'a'},
        focusedSeriesId: 'b',
        expandedGroups: {'g1'},
      );
      final copied = state.copyWith(hiddenSeriesIds: {'c'});
      expect(copied.hiddenSeriesIds, {'c'});
      expect(copied.focusedSeriesId, 'b');
      expect(copied.expandedGroups, {'g1'});
    });

    test('equality compares sets correctly', () {
      const a = OiChartLegendState(hiddenSeriesIds: {'x', 'y'});
      const b = OiChartLegendState(hiddenSeriesIds: {'y', 'x'});
      expect(a, equals(b));
    });
  });

  group('OiChartFocusState', () {
    test('empty has no focus', () {
      const state = OiChartFocusState.empty;
      expect(state.hasFocus, isFalse);
      expect(state.showFocusRing, isFalse);
      expect(state.isNavigating, isFalse);
    });

    test('copyWith and equality', () {
      const ref = OiChartDataRef(seriesIndex: 0, dataIndex: 0);
      const state = OiChartFocusState(
        focusedRef: ref,
        showFocusRing: true,
        isNavigating: true,
      );
      expect(state.hasFocus, isTrue);
      final copied = state.copyWith(showFocusRing: false);
      expect(copied.focusedRef, ref);
      expect(copied.showFocusRing, isFalse);
      expect(copied.isNavigating, isTrue);
    });
  });
}
