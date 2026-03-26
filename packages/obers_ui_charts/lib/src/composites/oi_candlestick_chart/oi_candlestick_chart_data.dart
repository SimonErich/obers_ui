import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';

/// A single data series for a candlestick (OHLC) chart.
///
/// Extends [OiCartesianSeries] with open/high/low/close mapper functions
/// that extract the four price fields from a domain object of type [T].
///
/// The [yMapper] is set to [closeMapper] so the series participates
/// correctly in shared y-range calculations.
///
/// ```dart
/// OiCandlestickSeries<OhlcRecord>(
///   id: 'price',
///   label: 'ACME',
///   data: ohlcData,
///   xMapper: (r) => r.timestamp.millisecondsSinceEpoch.toDouble(),
///   openMapper: (r) => r.open,
///   highMapper: (r) => r.high,
///   lowMapper: (r) => r.low,
///   closeMapper: (r) => r.close,
/// )
/// ```
///
/// {@category Composites}
class OiCandlestickSeries<T> extends OiCartesianSeries<T> {
  /// Creates an [OiCandlestickSeries].
  OiCandlestickSeries({
    required super.id,
    required super.label,
    required List<T> data,
    required super.xMapper,
    required this.openMapper,
    required this.highMapper,
    required this.lowMapper,
    required this.closeMapper,
    super.visible,
    super.color,
    super.semanticLabel,
    this.bullColor,
    this.bearColor,
  }) : super(
         data: data,
         // y defaults to close for scale computation.
         yMapper: closeMapper,
       );

  /// Extracts the opening price from a domain object.
  final num Function(T item) openMapper;

  /// Extracts the high price from a domain object.
  final num Function(T item) highMapper;

  /// Extracts the low price from a domain object.
  final num Function(T item) lowMapper;

  /// Extracts the closing price from a domain object.
  final num Function(T item) closeMapper;

  /// Color override for bullish candles (close >= open). When `null`,
  /// the theme's positive chart color is used.
  final Color? bullColor;

  /// Color override for bearish candles (close < open). When `null`,
  /// the theme's negative chart color is used.
  final Color? bearColor;
}
