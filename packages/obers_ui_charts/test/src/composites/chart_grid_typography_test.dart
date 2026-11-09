import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'single axis ticks are finite and paint using the supplied typography',
    () async {
      Future<int> occupiedRows(double size) async {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        OiChartGrid.paintYLabels(
          canvas,
          const Rect.fromLTWH(90, 10, 80, 100),
          labels: ['500'],
          labelColor: const Color(0xFF000000),
          labelStyle: TextStyle(fontSize: size),
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(200, 120);
        final pixels = (await image.toByteData())!;
        var rows = 0;
        for (var y = 0; y < 120; y++) {
          for (var x = 0; x < 200; x++) {
            if (pixels.getUint8((y * 200 + x) * 4 + 3) != 0) {
              rows++;
              break;
            }
          }
        }
        image.dispose();
        picture.dispose();
        return rows;
      }

      final small = await occupiedRows(10);
      expect(small, greaterThan(0));
      expect(await occupiedRows(20), greaterThan(small));
    },
  );
}
