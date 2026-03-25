import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  late OiDefaultChartController controller;

  setUp(() {
    controller = OiDefaultChartController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('OiDefaultChartController', () {
    group('selection', () {
      test('starts empty', () {
        expect(controller.selection, isEmpty);
        expect(controller.selectionState.hasSelection, isFalse);
      });

      test('select notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.select({const OiChartDataRef(seriesIndex: 0, dataIndex: 1)});

        expect(notified, isTrue);
        expect(controller.selection, hasLength(1));
        expect(controller.selectionState.hasSelection, isTrue);
      });

      test('clearSelection notifies listeners', () {
        controller.select({const OiChartDataRef(seriesIndex: 0, dataIndex: 0)});

        var notified = false;
        controller.addListener(() => notified = true);
        controller.clearSelection();

        expect(notified, isTrue);
        expect(controller.selection, isEmpty);
      });

      test('clearSelection is no-op when already empty', () {
        var notified = false;
        controller.addListener(() => notified = true);
        controller.clearSelection();
        expect(notified, isFalse);
      });
    });

    group('hover', () {
      test('starts null', () {
        expect(controller.hovered, isNull);
        expect(controller.hoverState.isHovering, isFalse);
      });

      test('hover notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.hover(const OiChartDataRef(seriesIndex: 0, dataIndex: 2));

        expect(notified, isTrue);
        expect(controller.hovered, isNotNull);
        expect(controller.hoverState.isHovering, isTrue);
      });

      test('hover with same ref does not notify', () {
        const ref = OiChartDataRef(seriesIndex: 0, dataIndex: 2);
        controller.hover(ref);

        var notified = false;
        controller.addListener(() => notified = true);
        controller.hover(ref);
        expect(notified, isFalse);
      });
    });

    group('viewport', () {
      test('starts at default zoom', () {
        expect(controller.viewportState.isZoomed, isFalse);
        expect(controller.viewportState.zoomLevel, 1.0);
      });

      test('resetZoom notifies listeners', () {
        controller.viewportState.zoomLevel = 2.0;

        var notified = false;
        controller.addListener(() => notified = true);
        controller.resetZoom();

        expect(notified, isTrue);
        expect(controller.viewportState.isZoomed, isFalse);
      });

      test('resetZoom is no-op when not zoomed', () {
        var notified = false;
        controller.addListener(() => notified = true);
        controller.resetZoom();
        expect(notified, isFalse);
      });

      test('setVisibleDomain updates state and notifies', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.setVisibleDomain(xMin: 10, xMax: 100);

        expect(notified, isTrue);
        expect(controller.viewportState.xMin, 10);
        expect(controller.viewportState.xMax, 100);
      });
    });

    group('legend', () {
      test('starts with all series visible', () {
        expect(controller.legendState.hiddenSeriesIds, isEmpty);
        expect(controller.legendState.focusedSeriesId, isNull);
      });

      test('toggleSeries hides then shows', () {
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.toggleSeries('series-1');
        expect(controller.legendState.isVisible('series-1'), isFalse);
        expect(notifyCount, 1);

        controller.toggleSeries('series-1');
        expect(controller.legendState.isVisible('series-1'), isTrue);
        expect(notifyCount, 2);
      });

      test('focusSeries toggles focus', () {
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.focusSeries('series-a');
        expect(controller.legendState.focusedSeriesId, 'series-a');
        expect(notifyCount, 1);

        // Focusing same series clears focus.
        controller.focusSeries('series-a');
        expect(controller.legendState.focusedSeriesId, isNull);
        expect(notifyCount, 2);

        // Focusing different series switches focus.
        controller.focusSeries('series-b');
        expect(controller.legendState.focusedSeriesId, 'series-b');
        expect(notifyCount, 3);
      });
    });

    group('focus', () {
      test('starts empty', () {
        expect(controller.focusState.hasFocus, isFalse);
      });
    });

    group('data lifecycle', () {
      test('setLoading notifies', () {
        var notified = false;
        controller.addListener(() => notified = true);
        controller.setLoading(loading: true);

        expect(notified, isTrue);
        expect(controller.isLoading, isTrue);
      });

      test('setLoading with same value does not notify', () {
        var notified = false;
        controller.addListener(() => notified = true);
        controller.setLoading(loading: false);
        expect(notified, isFalse);
      });

      test('setError notifies', () {
        var notified = false;
        controller.addListener(() => notified = true);
        controller.setError('Something went wrong');

        expect(notified, isTrue);
        expect(controller.error, 'Something went wrong');
      });
    });
  });
}
