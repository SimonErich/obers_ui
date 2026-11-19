import 'dart:math' as math;

import 'package:obers_ui_charts/src/foundation/oi_linear_scale.dart';

/// A value axis whose bounds and ticks fall on round numbers.
typedef OiNiceAxis = ({double min, double max, List<double> ticks});

/// Resolves a round-number axis covering [dataMin]..[dataMax].
///
/// The ticks come from [OiLinearScale]'s nice-step logic and are evenly
/// spaced; `min` and `max` of the result are the first and last tick, so
/// the ticks can be laid out as equal divisions of the chart area.
/// [divisions] is the preferred number of gaps between ticks; the result
/// may use a different number to keep the steps round.
///
/// [pinnedMin] and [pinnedMax] are bounds the caller must keep as they are.
/// Returns `null` when no round axis starts or ends exactly on a pinned
/// bound, or when the range is not finite; the caller should then fall
/// back to plain equal divisions.
OiNiceAxis? resolveNiceAxis({
  required double dataMin,
  required double dataMax,
  required int divisions,
  double? pinnedMin,
  double? pinnedMax,
}) {
  final lo = pinnedMin ?? dataMin;
  final hi = pinnedMax ?? dataMax;
  if (!lo.isFinite || !hi.isFinite || lo > hi || divisions < 1) return null;

  final scale = OiLinearScale.fromData(
    values: [lo, hi],
    rangeMin: 0,
    rangeMax: 1,
  );
  final scaleTicks = scale.buildTicks(count: divisions + 1);
  if (scaleTicks.length < 2) return null;

  final step = scaleTicks[1].value - scaleTicks[0].value;
  if (!step.isFinite || step <= 0) return null;
  const tolerance = 1e-6;

  // Work in whole steps so the ticks stay exact multiples of the step. The
  // first and last index are computed, not searched for, so this cannot
  // loop on a step that lost its precision.
  final first = (lo / step + tolerance).floorToDouble();
  final last = (hi / step - tolerance).ceilToDouble();
  final tickCount = last - first + 1;
  // A nice step is never much smaller than the rough one; more ticks than
  // this means the arithmetic ran out of precision.
  if (!tickCount.isFinite || tickCount < 2 || tickCount > divisions * 2 + 3) {
    return null;
  }

  final min = first * step;
  final max = last * step;
  if (!min.isFinite || !max.isFinite || min >= max) return null;
  if (pinnedMin != null && (min - pinnedMin).abs() > step * tolerance) {
    return null;
  }
  if (pinnedMax != null && (max - pinnedMax).abs() > step * tolerance) {
    return null;
  }

  final ticks = [for (var i = 0; i < tickCount; i++) (first + i) * step];
  // Neighbouring ticks that collapse to the same double cannot be labelled.
  for (var i = 1; i < ticks.length; i++) {
    if (ticks[i] <= ticks[i - 1]) return null;
  }
  return (min: min, max: max, ticks: ticks);
}

/// Formats the [ticks] of a nice axis with just enough decimals to tell
/// neighbouring ticks apart.
List<String> formatNiceTicks(List<double> ticks) {
  if (ticks.length < 2) {
    return [for (final t in ticks) t.toStringAsFixed(0)];
  }
  final step = (ticks[1] - ticks[0]).abs();
  final decimals = step >= 1 || step == 0
      ? 0
      : math.min(12, -(math.log(step) / math.ln10 + 1e-9).floor());
  return [for (final t in ticks) t.toStringAsFixed(decimals)];
}
