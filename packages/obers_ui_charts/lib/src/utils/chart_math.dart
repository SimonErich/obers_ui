import 'dart:math' as math;

/// Clamps a zoom level to the given bounds.
double clampZoom(double zoom, {double min = 0.1, double max = 100.0}) {
  return zoom.clamp(min, max);
}

/// Computes default domain padding for a single data point.
///
/// When only one value exists, we add symmetric padding so the point
/// is visible and centered rather than spanning a zero-range domain.
double domainPaddingForSinglePoint(double value) {
  if (value == 0) return 1.0;
  return (value.abs() * 0.1).clamp(0.5, double.infinity);
}

/// Returns `true` if [value] is NaN or infinite, indicating it should
/// be treated as missing data.
bool isMissingValue(num? value) {
  if (value == null) return true;
  return value.isNaN || value.isInfinite;
}

/// Clamps [value] to the minimum positive threshold for log scales.
///
/// Negative and zero values cannot be plotted on log scales. This
/// function returns [minPositive] when [value] is <= 0.
double clampForLogScale(double value, {double minPositive = 1e-10}) {
  if (value <= 0) {
    assert(
      false,
      'Negative or zero value ($value) passed to log scale. '
      'Clamping to $minPositive.',
    );
    return minPositive;
  }
  return value;
}

/// Clamps a domain range to prevent zero extent.
///
/// When [min] == [max], expands the range symmetrically by [padding].
({double min, double max}) clampDomainRange(
  double min,
  double max, {
  double padding = 1.0,
}) {
  if (min == max) {
    return (min: min - padding, max: max + padding);
  }
  if (min > max) return (min: max, max: min);
  return (min: min, max: max);
}

/// Finds "nice" numbers for tick marks.
///
/// Returns the nearest "nice" value that is >= [value].
/// Nice values are: 1, 2, 5, 10, 20, 50, 100, etc.
double niceNumber(double value, {bool round = true}) {
  final exponent = (math.log(value) / math.ln10).floor();
  final fraction = value / math.pow(10, exponent);

  double nice;
  if (round) {
    if (fraction < 1.5) {
      nice = 1;
    } else if (fraction < 3) {
      nice = 2;
    } else if (fraction < 7) {
      nice = 5;
    } else {
      nice = 10;
    }
  } else {
    if (fraction <= 1) {
      nice = 1;
    } else if (fraction <= 2) {
      nice = 2;
    } else if (fraction <= 5) {
      nice = 5;
    } else {
      nice = 10;
    }
  }

  return nice * math.pow(10, exponent);
}
