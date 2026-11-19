import 'dart:ui' show Offset;

import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_test.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_chart_datum.dart';

/// Projects normalized cartesian [data] to widget-local hit points.
///
/// The cartesian chart base does not draw series itself, so this defines
/// where a data point is taken to be:
///
/// - Numeric and [DateTime] x values are mapped linearly from the x domain
///   onto the width of the viewport's plot bounds. Any other x value is a
///   category; categories take equal bands in order of first appearance and
///   a point sits at the centre of its band.
/// - y values are mapped linearly from the y domain onto the plot height,
///   with the minimum at the bottom.
/// - A domain is the extent of the finite data unless [xMin], [xMax],
///   [yMin] or [yMax] pin a bound. A zero-width domain puts its points in
///   the middle of the plot.
/// - Zoom and pan of the [viewport] are applied.
///
/// Missing points and points with a non-finite coordinate are left out.
/// The series index of a point is the position of its series id in
/// [seriesIds].
List<OiHitPoint> projectCartesianHitPoints({
  required Map<String, List<OiChartDatum>> data,
  required List<String> seriesIds,
  required OiChartViewport viewport,
  double? xMin,
  double? xMax,
  double? yMin,
  double? yMax,
}) {
  // Categories in order of first appearance, across all series.
  final categories = <Object, int>{};
  for (final id in seriesIds) {
    for (final datum in data[id] ?? const <OiChartDatum>[]) {
      final x = datum.xRaw;
      if (x != null && x is! num && x is! DateTime) {
        categories.putIfAbsent(x, () => categories.length);
      }
    }
  }
  final isCategorical = categories.isNotEmpty;

  double? xValue(OiChartDatum datum) {
    final x = datum.xRaw;
    if (isCategorical) return categories[x]?.toDouble();
    if (x is num) return x.toDouble();
    if (x is DateTime) return x.millisecondsSinceEpoch.toDouble();
    return null;
  }

  // Resolve every drawable point to domain values first.
  final resolved = <({OiChartDataRef ref, double x, double y})>[];
  for (var si = 0; si < seriesIds.length; si++) {
    for (final datum in data[seriesIds[si]] ?? const <OiChartDatum>[]) {
      if (datum.isMissing) continue;
      final x = xValue(datum);
      final rawY = datum.yRaw;
      final y = rawY is num ? rawY.toDouble() : null;
      if (x == null || y == null || !x.isFinite || !y.isFinite) continue;
      resolved.add((
        ref: OiChartDataRef(seriesIndex: si, dataIndex: datum.index),
        x: x,
        y: y,
      ));
    }
  }
  if (resolved.isEmpty) return const [];

  var dataXMin = double.infinity;
  var dataXMax = double.negativeInfinity;
  var dataYMin = double.infinity;
  var dataYMax = double.negativeInfinity;
  for (final point in resolved) {
    if (point.x < dataXMin) dataXMin = point.x;
    if (point.x > dataXMax) dataXMax = point.x;
    if (point.y < dataYMin) dataYMin = point.y;
    if (point.y > dataYMax) dataYMax = point.y;
  }

  // A category band spans one unit around its index.
  final loX = isCategorical ? -0.5 : (xMin ?? dataXMin);
  final hiX = isCategorical ? categories.length - 0.5 : (xMax ?? dataXMax);
  final loY = yMin ?? dataYMin;
  final hiY = yMax ?? dataYMax;

  double fraction(double value, double lo, double hi) {
    final extent = hi - lo;
    return extent == 0 || !extent.isFinite ? 0.5 : (value - lo) / extent;
  }

  return [
    for (final point in resolved)
      OiHitPoint(
        position: viewport.normalizedToWidget(
          Offset(fraction(point.x, loX, hiX), 1 - fraction(point.y, loY, hiY)),
        ),
        ref: point.ref,
      ),
  ];
}

/// The hit tester of the cartesian chart base.
///
/// Holds a spatial index over the points produced by
/// [projectCartesianHitPoints]. The chart calls [update] on every build, so
/// behaviors that keep a reference to the tester always query the current
/// data and viewport.
class OiCartesianChartHitTester extends OiChartHitTester {
  final OiChartHitTestIndex _index = OiChartHitTestIndex();

  /// Rebuilds the index for the current [data] and [viewport].
  ///
  /// See [projectCartesianHitPoints] for the parameters.
  void update({
    required Map<String, List<OiChartDatum>> data,
    required List<String> seriesIds,
    required OiChartViewport viewport,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
  }) {
    _index.build(
      projectCartesianHitPoints(
        data: data,
        seriesIds: seriesIds,
        viewport: viewport,
        xMin: xMin,
        xMax: xMax,
        yMin: yMin,
        yMax: yMax,
      ),
      viewport: viewport,
    );
  }

  @override
  OiChartHitResult? hitTest(Offset position, {double tolerance = 16}) =>
      _index.hitTest(position, tolerance: tolerance);

  @override
  List<OiChartHitResult> hitTestAll(Offset position, {double tolerance = 16}) =>
      _index.hitTestAll(position, tolerance: tolerance);
}
