import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('ratio typography is independent of the supporting label', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 300,
          child: OiCapacityIndicator(
            label: 'Budget',
            value: 4,
            max: 10,
            valueLabel: '6 left',
            height: 8,
            gap: 6,
            labelStyle: TextStyle(fontSize: 12, height: 4 / 3),
            valueStyle: TextStyle(fontSize: 14, height: 10 / 7),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.text('Budget')).height, 16);
    expect(tester.getSize(find.text('6 left')).height, 20);
    expect(tester.getSize(find.byType(OiCapacityIndicator)).height, 34);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tracks paint the normal and warning colors independently', (
    tester,
  ) async {
    const normal = Color(0xff345678);
    const warning = Color(0xffbc7823);
    const boundaryKey = Key('capacity-pixels');
    await tester.pumpObers(
      const Center(
        child: RepaintBoundary(
          key: boundaryKey,
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OiCapacityIndicator(
                  label: 'Available',
                  value: 4,
                  max: 10,
                  color: normal,
                  warningColor: warning,
                  height: 8,
                  showLabel: false,
                  showValue: false,
                ),
                SizedBox(height: 12),
                OiCapacityIndicator(
                  label: 'Almost full',
                  value: 9,
                  max: 10,
                  color: normal,
                  warningColor: warning,
                  height: 8,
                  showLabel: false,
                  showValue: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundaryKey),
    );
    final origin = tester.getTopLeft(find.byKey(boundaryKey));
    final tracks = find.descendant(
      of: find.byKey(boundaryKey),
      matching: find.byType(CustomPaint),
    );
    final points = [
      for (var i = 0; i < 2; i++)
        tester.getRect(tracks.at(i)).centerLeft.translate(20, 0) - origin,
    ];
    final actual = await tester.runAsync(() async {
      final raster = await boundary.toImage();
      final bytes = (await raster.toByteData())!;
      final colors = [
        for (final point in points)
          Color.fromARGB(
            255,
            bytes.getUint8(
              (point.dy.floor() * raster.width + point.dx.floor()) * 4,
            ),
            bytes.getUint8(
              (point.dy.floor() * raster.width + point.dx.floor()) * 4 + 1,
            ),
            bytes.getUint8(
              (point.dy.floor() * raster.width + point.dx.floor()) * 4 + 2,
            ),
          ),
      ];
      raster.dispose();
      return colors;
    });
    expect(actual, [normal, warning]);
  });

  testWidgets(
    'horizontal value width does not constrain a vertical remaining label',
    (tester) async {
      final base = OiThemeData.light();
      await tester.pumpObers(
        const Center(
          child: SizedBox(
            width: 340,
            child: OiCapacityIndicator(
              label: 'Budget',
              value: 80,
              max: 1000,
              valueLabel: '€920.00 remaining',
              labelStyle: TextStyle(fontSize: 12, height: 16 / 12),
            ),
          ),
        ),
        theme: base.copyWith(
          components: base.components.copyWith(
            capacity: const OiCapacityThemeData(valueWidth: 68),
          ),
        ),
      );
      expect(tester.getSize(find.text('€920.00 remaining')).height, 16);
      expect(tester.takeException(), isNull);
    },
  );
}
