// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_layer.dart';

void main() {
  group('OiChartLayerRole', () {
    test('has all expected values', () {
      expect(OiChartLayerRole.values, hasLength(5));
      expect(OiChartLayerRole.values, containsAll([
        OiChartLayerRole.background,
        OiChartLayerRole.grid,
        OiChartLayerRole.series,
        OiChartLayerRole.annotation,
        OiChartLayerRole.overlay,
      ]));
    });
  });

  group('OiChartLayer', () {
    test('default z-order for background role is 0', () {
      final layer = OiChartLayer(
        id: 'bg',
        role: OiChartLayerRole.background,
      );
      expect(layer.zOrder, 0);
    });

    test('default z-order for grid role is 10', () {
      final layer = OiChartLayer(
        id: 'grid',
        role: OiChartLayerRole.grid,
      );
      expect(layer.zOrder, 10);
    });

    test('default z-order for series role is 20', () {
      final layer = OiChartLayer(id: 'series');
      expect(layer.zOrder, 20);
    });

    test('default z-order for annotation role is 30', () {
      final layer = OiChartLayer(
        id: 'ann',
        role: OiChartLayerRole.annotation,
      );
      expect(layer.zOrder, 30);
    });

    test('default z-order for overlay role is 40', () {
      final layer = OiChartLayer(
        id: 'ovl',
        role: OiChartLayerRole.overlay,
      );
      expect(layer.zOrder, 40);
    });

    test('custom z-order overrides role default', () {
      final layer = OiChartLayer(
        id: 'custom',
        role: OiChartLayerRole.grid,
        zOrder: 99,
      );
      expect(layer.zOrder, 99);
    });

    test('defaults to visible with full opacity', () {
      final layer = OiChartLayer(id: 'test');
      expect(layer.visible, isTrue);
      expect(layer.opacity, 1.0);
      expect(layer.clipToPlotArea, isTrue);
    });

    test('default role is series', () {
      final layer = OiChartLayer(id: 'test');
      expect(layer.role, OiChartLayerRole.series);
    });

    test('painter defaults to null', () {
      final layer = OiChartLayer(id: 'test');
      expect(layer.painter, isNull);
    });

    test('copyWith creates modified copy', () {
      final original = OiChartLayer(
        id: 'orig',
        role: OiChartLayerRole.grid,
        visible: true,
        opacity: 1.0,
      );

      final copy = original.copyWith(
        visible: false,
        opacity: 0.5,
      );

      expect(copy.id, 'orig');
      expect(copy.role, OiChartLayerRole.grid);
      expect(copy.visible, isFalse);
      expect(copy.opacity, 0.5);
    });

    test('copyWith with no changes returns equal layer', () {
      final original = OiChartLayer(id: 'test');
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('equality by value', () {
      final a = OiChartLayer(
        id: 'test',
        role: OiChartLayerRole.grid,
        zOrder: 10,
      );
      final b = OiChartLayer(
        id: 'test',
        role: OiChartLayerRole.grid,
        zOrder: 10,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when id differs', () {
      final a = OiChartLayer(id: 'a');
      final b = OiChartLayer(id: 'b');
      expect(a, isNot(equals(b)));
    });

    test('inequality when role differs', () {
      final a = OiChartLayer(
        id: 'test',
        role: OiChartLayerRole.grid,
        zOrder: 10,
      );
      final b = OiChartLayer(
        id: 'test',
        role: OiChartLayerRole.overlay,
        zOrder: 10,
      );
      expect(a, isNot(equals(b)));
    });

    test('inequality when opacity differs', () {
      final a = OiChartLayer(id: 'test', opacity: 1.0);
      final b = OiChartLayer(id: 'test', opacity: 0.5);
      expect(a, isNot(equals(b)));
    });

    test('toString contains id and role', () {
      final layer = OiChartLayer(
        id: 'grid',
        role: OiChartLayerRole.grid,
      );
      final str = layer.toString();
      expect(str, contains('grid'));
      expect(str, contains('OiChartLayerRole.grid'));
    });

    test('layers sort correctly by z-order', () {
      final layers = [
        OiChartLayer(id: 'overlay', role: OiChartLayerRole.overlay),
        OiChartLayer(id: 'bg', role: OiChartLayerRole.background),
        OiChartLayer(id: 'series', role: OiChartLayerRole.series),
        OiChartLayer(id: 'grid', role: OiChartLayerRole.grid),
        OiChartLayer(id: 'ann', role: OiChartLayerRole.annotation),
      ];
      layers.sort((a, b) => a.zOrder.compareTo(b.zOrder));

      expect(layers[0].id, 'bg');
      expect(layers[1].id, 'grid');
      expect(layers[2].id, 'series');
      expect(layers[3].id, 'ann');
      expect(layers[4].id, 'overlay');
    });

    test('clipToPlotArea can be disabled', () {
      final layer = OiChartLayer(
        id: 'tooltip',
        role: OiChartLayerRole.overlay,
        clipToPlotArea: false,
      );
      expect(layer.clipToPlotArea, isFalse);
    });
  });
}
