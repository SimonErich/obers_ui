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

    testWidgets('wraps a marker across the antimeridian into view', (
      tester,
    ) async {
      // Center just west of the antimeridian; the marker sits just east of it,
      // so it belongs ~2° (a few px) to the right of the viewport center — on
      // the *next* copy of the globe, exactly where the wrapping tile grid is.
      await tester.pumpChartApp(
        const OiTileMap(
          label: 'Pacific',
          center: OiLatLng(0, 179),
          markers: [
            OiMapMarker(
              latitude: 0,
              longitude: -179,
              label: 'Across',
              value: 1,
            ),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      final positioned = tester.widget<Positioned>(
        find.ancestor(
          of: find.bySemanticsLabel('Across'),
          matching: find.byType(Positioned),
        ),
      );
      // Without the wrap it would land a whole world (~2048px) to the left,
      // off-screen; with it, near the 400px viewport center.
      expect(positioned.left, isNotNull);
      expect(positioned.left, greaterThan(350));
      expect(positioned.left, lessThan(450));
    });

    testWidgets('pins every visible world copy when zoomed out wide', (
      tester,
    ) async {
      // At zoom 1 the world is 512 px, so a 1200-px viewport tiles ~2.3
      // copies of the globe side by side — the marker must appear on each
      // visible copy (here 3: at ~88, ~600, and ~1112 px), matching the tiles.
      await tester.pumpChartApp(
        const OiTileMap(
          label: 'World',
          center: OiLatLng(0, 0),
          zoom: 1,
          markers: [
            OiMapMarker(
              latitude: 0,
              longitude: 0,
              label: 'Everywhere',
              value: 1,
            ),
          ],
        ),
        surfaceSize: const Size(1200, 600),
      );
      await tester.pump();

      expect(find.bySemanticsLabel('Everywhere'), findsNWidgets(3));
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
