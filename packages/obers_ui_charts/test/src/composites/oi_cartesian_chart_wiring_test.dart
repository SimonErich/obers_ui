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
  });
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
