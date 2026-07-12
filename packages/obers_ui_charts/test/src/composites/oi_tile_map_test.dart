import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiTileMap', () {
    testWidgets('renders tiles, attribution, and markers', (tester) async {
      await tester.pumpChartApp(
        const OiTileMap(
          label: 'World',
          center: OiLatLng(48.2, 16.37),
          markers: [
            OiMapMarker(
              latitude: 48.2,
              longitude: 16.37,
              label: 'HQ',
              value: 1,
            ),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );
      // Network tiles never settle in tests; a single frame is enough.
      await tester.pump();

      expect(find.byType(OiTileMap), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // the tile grid
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
      expect(find.bySemanticsLabel('HQ'), findsOneWidget); // the marker
    });

    testWidgets('shows zoom controls only when interactive', (tester) async {
      await tester.pumpChartApp(
        const OiTileMap(label: 'World', center: OiLatLng(0, 0)),
        surfaceSize: const Size(600, 400),
      );
      await tester.pump();
      expect(find.bySemanticsLabel('Zoom in'), findsOneWidget);

      await tester.pumpChartApp(
        const OiTileMap(
          label: 'World',
          center: OiLatLng(0, 0),
          interactive: false,
        ),
        surfaceSize: const Size(600, 400),
      );
      await tester.pump();
      expect(find.bySemanticsLabel('Zoom in'), findsNothing);
    });

    testWidgets('zooming in renders a finer tile grid', (tester) async {
      await tester.pumpChartApp(
        const OiTileMap(label: 'World', center: OiLatLng(0, 0), zoom: 2),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();
      final before = tester.widgetList(find.byType(Image)).length;

      await tester.tap(find.bySemanticsLabel('Zoom in'));
      await tester.pump();
      final after = tester.widgetList(find.byType(Image)).length;

      expect(after, greaterThanOrEqualTo(before));
    });
  });
}
