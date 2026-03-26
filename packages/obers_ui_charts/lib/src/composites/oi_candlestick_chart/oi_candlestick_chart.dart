import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui_charts/src/composites/oi_candlestick_chart/oi_candlestick_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_candlestick_chart/oi_candlestick_chart_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// A candlestick (OHLC) chart for financial time-series data.
///
/// Renders one or more [OiCandlestickSeries] on a Cartesian grid. Each data
/// point is drawn as:
/// - A thin vertical wick from the session low to the session high.
/// - A filled body rectangle from open to close.
/// - Bullish candles (close >= open) use the positive chart palette color
///   (or [OiCandlestickSeries.bullColor]).
/// - Bearish candles (close < open) use the negative chart palette color
///   (or [OiCandlestickSeries.bearColor]).
///
/// The y-axis range is automatically derived from `min(low)` to `max(high)`
/// across all data points.
///
/// {@category Composites}
class OiCandlestickChart<T> extends StatefulWidget {
  /// Creates an [OiCandlestickChart].
  const OiCandlestickChart({
    required this.label,
    required this.series,
    super.key,
    this.xAxis,
    this.yAxis,
    this.showGrid = true,
    this.showLegend = true,
    this.onCandleTap,
    this.theme,
    this.interactionMode,
    this.compact,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.semanticLabel,
    this.behaviors = const [],
    this.controller,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The candlestick series to render.
  final List<OiCandlestickSeries<T>> series;

  /// Configuration for the x-axis (time or numeric).
  final OiChartAxis<dynamic>? xAxis;

  /// Configuration for the y-axis (price).
  final OiChartAxis<num>? yAxis;

  /// Whether to show grid lines. Defaults to `true`.
  final bool showGrid;

  /// Whether to show a legend when there are multiple series. Defaults to
  /// `true`.
  final bool showLegend;

  /// Callback invoked when a candle is tapped.
  ///
  /// Receives the [seriesIndex] and [candleIndex] of the nearest candle.
  final void Function(int seriesIndex, int candleIndex)? onCandleTap;

  /// Optional theme overrides.
  final OiCandlestickChartTheme? theme;

  /// Interaction mode. Defaults to [OiChartInteractionMode.auto].
  final OiChartInteractionMode? interactionMode;

  /// Whether to use compact layout. When `null`, determined by available width.
  final bool? compact;

  /// Widget shown when [series] is empty.
  final Widget? emptyState;

  /// Widget shown while data is loading.
  final Widget? loadingState;

  /// Widget shown when data loading has failed.
  final Widget? errorState;

  /// Overrides the auto-generated accessibility label.
  final String? semanticLabel;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  @override
  State<OiCandlestickChart<T>> createState() => _OiCandlestickChartState<T>();
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme
// ─────────────────────────────────────────────────────────────────────────────

/// Theme overrides for an [OiCandlestickChart].
///
/// {@category Composites}
class OiCandlestickChartTheme {
  /// Creates an [OiCandlestickChartTheme].
  const OiCandlestickChartTheme({
    this.gridColor,
    this.axisLabelColor,
    this.bullColor,
    this.bearColor,
  });

  /// Override color for grid lines.
  final Color? gridColor;

  /// Override color for axis labels.
  final Color? axisLabelColor;

  /// Global override for bullish candle color. Per-series values take
  /// precedence when provided.
  final Color? bullColor;

  /// Global override for bearish candle color. Per-series values take
  /// precedence when provided.
  final Color? bearColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class _OiCandlestickChartState<T> extends State<OiCandlestickChart<T>> {
  int? _hoveredSeriesIndex;
  int? _hoveredCandleIndex;
  int? _selectedSeriesIndex;
  int? _selectedCandleIndex;

  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  String get _effectiveLabel =>
      widget.semanticLabel ??
      (widget.label.isNotEmpty
          ? widget.label
          : 'Candlestick chart with ${widget.series.length} series');

  OiChartInteractionMode _resolveInteractionMode(BuildContext context) {
    if (widget.interactionMode != null &&
        widget.interactionMode != OiChartInteractionMode.auto) {
      return widget.interactionMode!;
    }
    final modality = OiPlatform.of(context).inputModality;
    return modality == OiInputModality.touch
        ? OiChartInteractionMode.touch
        : OiChartInteractionMode.pointer;
  }

  /// Computes the data range. The y-range uses min(low) → max(high) so the
  /// wicks are always fully visible.
  ({double minX, double maxX, double minY, double maxY}) _computeRange() {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final s in widget.series) {
      final data = s.data ?? const [];
      for (final item in data) {
        final xRaw = s.xMapper(item);
        final x = xRaw is DateTime
            ? xRaw.millisecondsSinceEpoch.toDouble()
            : (xRaw as num).toDouble();
        final low = s.lowMapper(item).toDouble();
        final high = s.highMapper(item).toDouble();
        minX = math.min(minX, x);
        maxX = math.max(maxX, x);
        minY = math.min(minY, low);
        maxY = math.max(maxY, high);
      }
    }

    if (minX == double.infinity) minX = 0;
    if (maxX == double.negativeInfinity) maxX = 1;
    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 1;

    // Add a small margin so candles don't touch the axes.
    final yPad = (maxY - minY) * 0.05;

    return (
      minX: widget.xAxis?.min ?? minX,
      maxX: widget.xAxis?.max ?? maxX,
      minY: widget.yAxis?.min ?? (minY - yPad),
      maxY: widget.yAxis?.max ?? (maxY + yPad),
    );
  }

  /// Finds the nearest candle to [position] within [hitRadius] pixels.
  ({int seriesIndex, int candleIndex})? _findNearestCandle(
    Offset position,
    Rect chartRect,
    double minX,
    double maxX,
  ) {
    const hitRadius = 24.0;
    final rangeX = maxX - minX == 0 ? 1.0 : maxX - minX;

    var bestDist = double.infinity;
    int? bestSi;
    int? bestCi;

    for (var si = 0; si < widget.series.length; si++) {
      final s = widget.series[si];
      final data = s.data ?? const [];
      for (var ci = 0; ci < data.length; ci++) {
        final item = data[ci];
        final xRaw = s.xMapper(item);
        final x = xRaw is DateTime
            ? xRaw.millisecondsSinceEpoch.toDouble()
            : (xRaw as num).toDouble();
        final px = chartRect.left + chartRect.width * (x - minX) / rangeX;
        final dist = (position.dx - px).abs();
        if (dist < hitRadius && dist < bestDist) {
          bestDist = dist;
          bestSi = si;
          bestCi = ci;
        }
      }
    }

    if (bestSi != null) {
      return (seriesIndex: bestSi, candleIndex: bestCi!);
    }
    return null;
  }

  ResolvedCandlestickSeries _resolveSeries(int index, BuildContext context) {
    final s = widget.series[index];
    final data = s.data ?? const [];
    final candles = <ResolvedCandlestick>[
      for (final item in data)
        ResolvedCandlestick(
          x: () {
            final xRaw = s.xMapper(item);
            return xRaw is DateTime
                ? xRaw.millisecondsSinceEpoch.toDouble()
                : (xRaw as num).toDouble();
          }(),
          open: s.openMapper(item).toDouble(),
          high: s.highMapper(item).toDouble(),
          low: s.lowMapper(item).toDouble(),
          close: s.closeMapper(item).toDouble(),
        ),
    ];

    final chartPalette = OiChartPalette.colors(context.colors);
    final bullColor =
        s.bullColor ?? widget.theme?.bullColor ?? chartPalette.positive;
    final bearColor =
        s.bearColor ?? widget.theme?.bearColor ?? chartPalette.negative;

    return ResolvedCandlestickSeries(
      label: s.label,
      candles: candles,
      bullColor: bullColor,
      bearColor: bearColor,
    );
  }

  bool get _isEmpty =>
      widget.series.isEmpty ||
      widget.series.every((s) => s.data == null || s.data!.isEmpty);

  @override
  Widget build(BuildContext context) {
    if (widget.loadingState != null) return widget.loadingState!;
    if (widget.errorState != null) return widget.errorState!;
    if (_isEmpty) {
      return widget.emptyState ??
          const SizedBox.shrink(key: Key('oi_candlestick_chart_empty'));
    }

    final colors = context.colors;
    final isHighContrast = OiA11y.highContrast(context);
    final reducedMotion = OiA11y.reducedMotion(context);

    return Semantics(
      label: _effectiveLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 300.0;

          if (w < _minViableWidth || h < _minViableHeight) {
            return SizedBox(
              width: w,
              height: h,
              child: Center(
                key: const Key('oi_candlestick_chart_fallback'),
                child: FittedBox(
                  child: OiLabel.caption(
                    'Chart too small',
                    color: colors.textMuted,
                  ),
                ),
              ),
            );
          }

          final isCompact = widget.compact ?? (w < _compactThreshold);
          final mode = _resolveInteractionMode(context);
          final range = _computeRange();
          final chartSize = Size(
            w,
            math.min(h, isCompact ? w * 0.6 : w * 0.75),
          );
          final chartRect = OiChartGrid.computeChartRect(
            chartSize,
            compact: isCompact,
          );

          final resolved = <ResolvedCandlestickSeries>[
            for (var i = 0; i < widget.series.length; i++)
              _resolveSeries(i, context),
          ];

          final hoverSi = reducedMotion ? null : _hoveredSeriesIndex;
          final hoverCi = reducedMotion ? null : _hoveredCandleIndex;

          // Axis labels.
          final xDiv = widget.xAxis?.divisions ?? (isCompact ? 4 : 6);
          final yDiv = widget.yAxis?.divisions ?? (isCompact ? 3 : 5);
          final rX = range.maxX - range.minX;
          final rY = range.maxY - range.minY;
          final xLabels =
              widget.xAxis?.labels ??
              List.generate(
                xDiv + 1,
                (i) => (widget.xAxis ?? const OiChartAxis()).formatValue(
                  range.minX + (rX == 0 ? 0 : rX * i / xDiv),
                ),
              );
          final yLabels =
              widget.yAxis?.labels ??
              List.generate(
                yDiv + 1,
                (i) => (widget.yAxis ?? const OiChartAxis()).formatValue(
                  range.minY + (rY == 0 ? 0 : rY * i / yDiv),
                ),
              );

          final chartWidget = SizedBox(
            key: const Key('oi_candlestick_chart_canvas'),
            width: chartSize.width,
            height: chartSize.height,
            child: CustomPaint(
              key: const Key('oi_candlestick_chart_painter'),
              size: chartSize,
              painter: OiCandlestickChartPainter(
                resolvedSeries: resolved,
                chartRect: chartRect,
                minX: range.minX,
                maxX: range.maxX,
                minY: range.minY,
                maxY: range.maxY,
                showGrid: widget.showGrid,
                gridColor: widget.theme?.gridColor ?? colors.borderSubtle,
                axisLabelColor:
                    widget.theme?.axisLabelColor ?? colors.textMuted,
                highContrast: isHighContrast,
                compact: isCompact,
                xLabels: xLabels,
                yLabels: yLabels,
                xDivisions: xDiv,
                yDivisions: yDiv,
                hoveredSeriesIndex: hoverSi,
                hoveredCandleIndex: hoverCi,
              ),
            ),
          );

          // Interaction wrapper.
          Widget interactiveChart;
          if (mode == OiChartInteractionMode.touch) {
            interactiveChart = GestureDetector(
              key: const Key('oi_candlestick_chart_touch'),
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final hit = _findNearestCandle(
                  d.localPosition,
                  chartRect,
                  range.minX,
                  range.maxX,
                );
                if (hit != null) {
                  setState(() {
                    _selectedSeriesIndex = hit.seriesIndex;
                    _selectedCandleIndex = hit.candleIndex;
                  });
                  widget.onCandleTap?.call(hit.seriesIndex, hit.candleIndex);
                }
              },
              child: chartWidget,
            );
          } else {
            interactiveChart = MouseRegion(
              key: const Key('oi_candlestick_chart_pointer'),
              onHover: (e) {
                final hit = _findNearestCandle(
                  e.localPosition,
                  chartRect,
                  range.minX,
                  range.maxX,
                );
                final si = hit?.seriesIndex;
                final ci = hit?.candleIndex;
                if (si != _hoveredSeriesIndex || ci != _hoveredCandleIndex) {
                  setState(() {
                    _hoveredSeriesIndex = si;
                    _hoveredCandleIndex = ci;
                  });
                }
              },
              onExit: (_) => setState(() {
                _hoveredSeriesIndex = null;
                _hoveredCandleIndex = null;
              }),
              child: chartWidget,
            );
          }

          // Active candle narration.
          final activeCi = _selectedCandleIndex ?? _hoveredCandleIndex;
          final activeSi = _selectedSeriesIndex ?? _hoveredSeriesIndex;
          Widget narration = const SizedBox.shrink();
          if (activeCi != null && activeSi != null) {
            final s = widget.series[activeSi];
            final data = s.data;
            if (data != null && activeCi < data.length) {
              final item = data[activeCi];
              final open = s.openMapper(item).toStringAsFixed(2);
              final high = s.highMapper(item).toStringAsFixed(2);
              final low = s.lowMapper(item).toStringAsFixed(2);
              final close = s.closeMapper(item).toStringAsFixed(2);
              final dir = s.closeMapper(item) >= s.openMapper(item)
                  ? 'up'
                  : 'down';
              narration = Semantics(
                key: const Key('oi_candlestick_chart_narration'),
                liveRegion: true,
                child: OiLabel.caption(
                  '${s.label}: O=$open H=$high L=$low C=$close ($dir)',
                  color: colors.textSubtle,
                ),
              );
            }
          }

          // Legend (shown when multiple series).
          final showLegend = widget.showLegend && widget.series.length > 1;
          final legendWidget = showLegend
              ? _CandlestickLegend(resolved: resolved)
              : null;

          if (isCompact) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                interactiveChart,
                narration,
                if (legendWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: legendWidget,
                  ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: interactiveChart),
                  if (legendWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: legendWidget,
                    ),
                ],
              ),
              narration,
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────────────────

class _CandlestickLegend extends StatelessWidget {
  const _CandlestickLegend({required this.resolved});

  final List<ResolvedCandlestickSeries> resolved;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colors.textMuted;
    return Wrap(
      key: const Key('oi_candlestick_chart_legend'),
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final s in resolved)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CandleSwatch(bullColor: s.bullColor, bearColor: s.bearColor),
              const SizedBox(width: 4),
              OiLabel.caption(s.label, color: textColor),
            ],
          ),
      ],
    );
  }
}

class _CandleSwatch extends StatelessWidget {
  const _CandleSwatch({required this.bullColor, required this.bearColor});

  final Color bullColor;
  final Color bearColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 14),
      painter: _CandleSwatchPainter(bullColor: bullColor, bearColor: bearColor),
    );
  }
}

class _CandleSwatchPainter extends CustomPainter {
  _CandleSwatchPainter({required this.bullColor, required this.bearColor});

  final Color bullColor;
  final Color bearColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a tiny bull candle on the left and a bear candle on the right.
    final halfH = size.height / 2;
    final candleW = size.width / 2 - 2;

    // Bull candle (green, left).
    canvas
      ..drawLine(
        Offset(candleW / 2, 1),
        Offset(candleW / 2, size.height - 1),
        Paint()
          ..color = bullColor
          ..strokeWidth = 1,
      )
      ..drawRect(
        Rect.fromLTWH(0, halfH - 2, candleW, 4),
        Paint()..color = bullColor,
      );

    // Bear candle (red, right).
    final rx = candleW + 4;
    canvas
      ..drawLine(
        Offset(rx + candleW / 2, 1),
        Offset(rx + candleW / 2, size.height - 1),
        Paint()
          ..color = bearColor
          ..strokeWidth = 1,
      )
      ..drawRect(
        Rect.fromLTWH(rx, halfH - 2, candleW, 4),
        Paint()..color = bearColor,
      );
  }

  @override
  bool shouldRepaint(_CandleSwatchPainter oldDelegate) =>
      oldDelegate.bullColor != bullColor || oldDelegate.bearColor != bearColor;
}
