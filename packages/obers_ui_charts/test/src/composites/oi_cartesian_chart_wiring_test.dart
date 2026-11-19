import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

class _Point {
  const _Point(this.x, this.y);
  final double x;
  final double y;
}

OiCartesianSeries<_Point> _makeSeries({String id = 's1', List<_Point>? data}) {
  return OiCartesianSeries<_Point>(
    id: id,
    label: id,
    data: data ?? const [_Point(1, 10), _Point(2, 20), _Point(3, 30)],
    xMapper: (p) => p.x,
    yMapper: (p) => p.y,
  );
}

void main() {
  group('OiCartesianChart wiring', () {
    testWidgets('persistence: restores hidden series from settings', (
      tester,
    ) async {
      final controller = OiDefaultChartController();
      const settings = OiChartSettings(hiddenSeriesIds: {'s2'});

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Test',
            series: [
              _makeSeries(),
              _makeSeries(id: 's2'),
            ],
            controller: controller,
            settings: settings,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      // Settings should have been restored — s2 should be hidden.
      expect(controller.legendState.isVisible('s2'), isFalse);
      expect(controller.legendState.isVisible('s1'), isTrue);

      controller.dispose();
    });

    testWidgets(
      'persistence: a series the controller already hides stays hidden',
      (tester) async {
        final controller = OiDefaultChartController()..toggleSeries('s2');
        addTearDown(controller.dispose);
        expect(controller.legendState.isVisible('s2'), isFalse);

        await tester.pumpChartApp(
          SizedBox(
            width: 400,
            height: 300,
            child: OiCartesianChart<_Point>(
              label: 'Test',
              series: [
                _makeSeries(),
                _makeSeries(id: 's2'),
              ],
              controller: controller,
              settings: const OiChartSettings(hiddenSeriesIds: {'s2'}),
            ),
          ),
          surfaceSize: const Size(400, 300),
        );

        expect(controller.legendState.isVisible('s2'), isFalse);
        expect(controller.legendState.isVisible('s1'), isTrue);
      },
    );

    testWidgets('persistence: restores viewport from settings', (tester) async {
      final controller = OiDefaultChartController();
      const settings = OiChartSettings(
        viewport: OiPersistedViewport(xMin: 10, xMax: 50, yMin: 0, yMax: 100),
      );

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Test',
            series: [_makeSeries()],
            controller: controller,
            settings: settings,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(controller.viewportState.xMin, 10);
      expect(controller.viewportState.xMax, 50);

      controller.dispose();
    });

    testWidgets('zoom/pan round-trip via controller', (tester) async {
      final controller = OiDefaultChartController();

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Test',
            series: [_makeSeries()],
            controller: controller,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      // Zoom in.
      controller.viewportState.zoomLevel = 2.0;
      expect(controller.viewportState.isZoomed, isTrue);

      // Reset.
      controller.resetZoom();
      expect(controller.viewportState.isZoomed, isFalse);
      expect(controller.viewportState.zoomLevel, 1.0);

      controller.dispose();
    });

    testWidgets('streaming: adapter attached on mount', (tester) async {
      final streamController = StreamController<List<_Point>>();
      final source = _TestStreamingSource(streamController.stream);

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Streaming',
            series: [
              OiCartesianSeries<_Point>(
                id: 'live',
                label: 'Live',
                streamingSource: source,
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      // Chart should mount without error even with streaming source.
      expect(find.byType(OiCartesianChart<_Point>), findsOneWidget);

      await streamController.close();
    });

    group('streaming: sources swapped after mount', () {
      OiCartesianSeries<_Point> liveSeries(
        String id,
        OiStreamingDataSource<_Point>? source,
      ) {
        return OiCartesianSeries<_Point>(
          id: id,
          label: id,
          data: source == null ? const [_Point(1, 1)] : null,
          streamingSource: source,
          xMapper: (p) => p.x,
          yMapper: (p) => p.y,
        );
      }

      Future<void> pump(
        WidgetTester tester,
        List<OiCartesianSeries<_Point>> series,
      ) {
        return tester.pumpChartApp(
          SizedBox(
            width: 400,
            height: 300,
            child: OiCartesianChart<_Point>(label: 'Streaming', series: series),
          ),
          surfaceSize: const Size(400, 300),
        );
      }

      testWidgets('a replaced source is subscribed and the old one released', (
        tester,
      ) async {
        final first = StreamController<List<_Point>>();
        final second = StreamController<List<_Point>>();
        _closeLater(first);
        _closeLater(second);

        await pump(tester, [
          liveSeries('live', _TestStreamingSource(first.stream)),
        ]);
        expect(first.hasListener, isTrue);

        await pump(tester, [
          liveSeries('live', _TestStreamingSource(second.stream)),
        ]);
        expect(second.hasListener, isTrue);
        expect(first.hasListener, isFalse);
      });

      testWidgets('an unchanged source keeps its subscription', (tester) async {
        var keptListens = 0;
        final kept = StreamController<List<_Point>>(
          onListen: () => keptListens++,
        );
        final first = StreamController<List<_Point>>();
        final second = StreamController<List<_Point>>();
        _closeLater(kept);
        _closeLater(first);
        _closeLater(second);
        final keptSource = _TestStreamingSource(kept.stream);

        await pump(tester, [
          liveSeries('kept', keptSource),
          liveSeries('swapped', _TestStreamingSource(first.stream)),
        ]);
        await pump(tester, [
          liveSeries('kept', keptSource),
          liveSeries('swapped', _TestStreamingSource(second.stream)),
        ]);

        expect(second.hasListener, isTrue);
        expect(kept.hasListener, isTrue);
        expect(keptListens, 1);
      });

      testWidgets('a source added after mount is subscribed', (tester) async {
        final added = StreamController<List<_Point>>();
        _closeLater(added);

        await pump(tester, [liveSeries('live', null)]);
        await pump(tester, [
          liveSeries('live', _TestStreamingSource(added.stream)),
        ]);

        expect(added.hasListener, isTrue);
      });

      testWidgets('a removed source is released', (tester) async {
        final removed = StreamController<List<_Point>>();
        _closeLater(removed);

        await pump(tester, [
          liveSeries('live', _TestStreamingSource(removed.stream)),
        ]);
        await pump(tester, [liveSeries('live', null)]);

        expect(removed.hasListener, isFalse);
      });
    });
  });
}

/// Closes [controller] when the test ends.
///
/// The close future of a controller that was never listened to (or whose
/// listener is gone) never completes, so it must not be awaited.
void _closeLater(StreamController<List<_Point>> controller) {
  addTearDown(() => unawaited(controller.close()));
}

class _TestStreamingSource extends OiStreamingDataSource<_Point> {
  _TestStreamingSource(this._stream);

  final Stream<List<_Point>> _stream;

  @override
  Stream<List<_Point>> get dataStream => _stream;

  @override
  @override
  int get maxRetainedPoints => 100;

  @override
  Duration get updateInterval => Duration.zero;
}
