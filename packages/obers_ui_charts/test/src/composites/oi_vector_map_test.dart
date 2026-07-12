// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// A 20°×20° square region centred on (0, 0) in lon/lat space.
const _square = OiMapRegion(
  id: 'square',
  label: 'Square',
  polygons: [
    [Offset(-10, 10), Offset(10, 10), Offset(10, -10), Offset(-10, -10)],
  ],
  value: 42,
);

Widget _map({
  List<OiMapRegion>? regions = const [_square],
  Map<String, num>? values,
  List<OiMapMarker> markers = const [],
  bool showLegend = false,
  bool showTooltip = true,
  bool enableZoom = false,
  ValueChanged<OiMapRegion>? onRegionTap,
  ValueChanged<OiMapMarker>? onMarkerTap,
}) {
  return SizedBox(
    width: 400,
    height: 200,
    child: OiVectorMap(
      label: 'Test Map',
      regions: regions,
      values: values,
      markers: markers,
      showLegend: showLegend,
      showTooltip: showTooltip,
      enableZoom: enableZoom,
      onRegionTap: onRegionTap,
      onMarkerTap: onMarkerTap,
    ),
  );
}

const _size = Size(400, 200);

void main() {
  group('OiEquirectangularProjection', () {
    const projection = OiEquirectangularProjection();

    test('projects the origin to the centre of the map', () {
      final result = projection.project(latitude: 0, longitude: 0);
      expect(result.dx, closeTo(0.5, 1e-9));
      expect(result.dy, closeTo(0.5, 1e-9));
    });

    test('maps longitude to dx and latitude to dy', () {
      expect(projection.project(latitude: 90, longitude: -180), Offset.zero);
      expect(
        projection.project(latitude: -90, longitude: 180),
        const Offset(1, 1),
      );
    });

    test('has a 2:1 aspect ratio', () {
      expect(projection.aspectRatio, 2);
    });
  });

  group('OiVectorMapGeometry', () {
    test('fitMapRect fits a 2:1 extent inside a square box', () {
      final rect = OiVectorMapGeometry.fitMapRect(const Size(200, 200), 2);
      expect(rect.width, 200);
      expect(rect.height, 100);
      expect(rect.top, 50); // vertically centred
      expect(rect.left, 0);
    });

    test('markerRadius makes area proportional to value', () {
      final small = OiVectorMapGeometry.markerRadius(
        value: 25,
        maxValue: 100,
        maxRadiusInPixels: 20,
      );
      final large = OiVectorMapGeometry.markerRadius(
        value: 100,
        maxValue: 100,
        maxRadiusInPixels: 20,
      );
      // value 25 is 1/4 of 100 → radius is 1/2 (sqrt(1/4)).
      expect(large, closeTo(20, 1e-9));
      expect(small, closeTo(10, 1e-9));
    });

    test('markerRadius clamps non-positive values to the minimum', () {
      final radius = OiVectorMapGeometry.markerRadius(
        value: 0,
        maxValue: 100,
        maxRadiusInPixels: 20,
      );
      expect(radius, 3);
    });

    test('buildMarkerPoints lands a marker at its projected offset', () {
      final points = OiVectorMapGeometry.buildMarkerPoints(
        markers: const [
          OiMapMarker(latitude: 0, longitude: 0, label: 'O', value: 1),
        ],
        projection: const OiEquirectangularProjection(),
        mapRect: OiVectorMapGeometry.fitMapRect(_size, 2),
        maxRadiusInPixels: 20,
        defaultColor: const Color(0xFF000000),
      );
      // (0, 0) lon/lat → centre of a 400×200 map.
      expect(points.single.center.dx, closeTo(200, 1e-6));
      expect(points.single.center.dy, closeTo(100, 1e-6));
    });

    test('buildRegionShapes fills valued regions from the scale and '
        'null-valued regions with the neutral color', () {
      const neutral = Color(0xFF111111);
      final scale = OiColorScale.linear(
        minColor: const Color(0xFF000000),
        maxColor: const Color(0xFFFFFFFF),
        min: 0,
        max: 100,
      );
      final shapes = OiVectorMapGeometry.buildRegionShapes(
        regions: const [
          OiMapRegion(
            id: 'valued',
            label: 'Valued',
            polygons: [
              [Offset(-1, 1), Offset(1, 1), Offset(1, -1)],
            ],
            value: 100,
          ),
          OiMapRegion(
            id: 'empty',
            label: 'Empty',
            polygons: [
              [Offset(-1, 1), Offset(1, 1), Offset(1, -1)],
            ],
          ),
        ],
        projection: const OiEquirectangularProjection(),
        mapRect: OiVectorMapGeometry.fitMapRect(_size, 2),
        colorScale: scale,
        neutralColor: neutral,
      );
      expect(shapes[0].hasValue, isTrue);
      expect(shapes[0].fillColor, const Color(0xFFFFFFFF));
      expect(shapes[1].hasValue, isFalse);
      expect(shapes[1].fillColor, neutral);
    });
  });

  group('OiWorldMap', () {
    test('exposes bundled region geometry keyed by ISO code', () {
      expect(OiWorldMap.regions, isNotEmpty);
      final germany = OiWorldMap.region('de');
      expect(germany, isNotNull);
      expect(germany!.label, 'Germany');
      expect(germany.polygons.first, isNotEmpty);
    });

    test('provides a centroid for every country', () {
      expect(OiWorldMap.centroidsByIsoCode.length, greaterThan(200));
      final centroid = OiWorldMap.centroid('JP');
      expect(centroid, isNotNull);
      // Japan sits in the northern hemisphere, east of Greenwich.
      expect(centroid!.dx, greaterThan(120)); // longitude
      expect(centroid.dy, greaterThan(25)); // latitude
    });

    test('builds a marker from an ISO code', () {
      final marker = OiWorldMap.marker(isoCode: 'FR', value: 5);
      expect(marker, isNotNull);
      expect(marker!.label, 'France');
      expect(marker.value, 5);
    });

    test('returns null for unknown ISO codes', () {
      expect(OiWorldMap.region('ZZ'), isNull);
      expect(OiWorldMap.marker(isoCode: 'ZZ', value: 1), isNull);
    });
  });

  group('OiVectorMap widget', () {
    testWidgets('renders bundled world data with values without exceptions', (
      tester,
    ) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 600,
          height: 300,
          child: OiVectorMap(
            label: 'Users by country',
            values: {'US': 1240, 'DE': 830, 'BR': 410},
          ),
        ),
      );
      expect(find.byType(OiVectorMap), findsOneWidget);
      expect(find.byKey(const Key('oi_vector_map_painter')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a custom region without exceptions', (tester) async {
      await tester.pumpChartApp(_map());
      expect(find.byKey(const Key('oi_vector_map')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('has a semantics label', (tester) async {
      await tester.pumpChartApp(_map());
      final semantics = tester.getSemantics(find.byType(OiVectorMap));
      expect(semantics.label, contains('Test Map'));
    });

    testWidgets('shows the empty state when there is nothing to draw', (
      tester,
    ) async {
      await tester.pumpChartApp(_map(regions: const []));
      expect(find.byKey(const Key('oi_vector_map_empty')), findsOneWidget);
      expect(find.byType(OiChartEmptyState), findsOneWidget);
    });

    testWidgets('fires onRegionTap for a tap inside a region', (tester) async {
      OiMapRegion? tapped;
      await tester.pumpChartApp(_map(onRegionTap: (r) => tapped = r));
      await tester.tapAt(tester.getCenter(find.byType(OiVectorMap)));
      await tester.pump();
      expect(tapped?.id, 'square');
    });

    testWidgets('fires onMarkerTap for a tap on a marker', (tester) async {
      OiMapMarker? tapped;
      await tester.pumpChartApp(
        _map(
          regions: const [],
          markers: const [
            OiMapMarker(latitude: 0, longitude: 0, label: 'Origin', value: 100),
          ],
          onMarkerTap: (m) => tapped = m,
        ),
      );
      await tester.tapAt(tester.getCenter(find.byType(OiVectorMap)));
      await tester.pump();
      expect(tapped?.label, 'Origin');
    });

    testWidgets('renders the legend when enabled', (tester) async {
      await tester.pumpChartApp(_map(showLegend: true));
      expect(find.byKey(const Key('oi_vector_map_legend')), findsOneWidget);
    });

    testWidgets('shows a tooltip on hover', (tester) async {
      await tester.pumpChartApp(_map());
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(OiVectorMap)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('oi_vector_map_tooltip')), findsOneWidget);
      expect(find.text('Square'), findsOneWidget);
    });

    testWidgets('wraps the map in an InteractiveViewer when zoom is enabled', (
      tester,
    ) async {
      await tester.pumpChartApp(_map(enableZoom: true));
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('builds no Material widgets', (tester) async {
      await tester.pumpChartApp(_map(showLegend: true));
      const materialNames = {
        'Material',
        'Scaffold',
        'MaterialButton',
        'Card',
        'InkWell',
        'AppBar',
      };
      final offenders = <String>[];
      for (final element in find.byType(OiVectorMap).evaluate()) {
        void visit(Element e) {
          final name = e.widget.runtimeType.toString();
          if (materialNames.contains(name)) offenders.add(name);
          e.visitChildren(visit);
        }

        element.visitChildren(visit);
      }
      expect(offenders, isEmpty);
    });
  });
}
