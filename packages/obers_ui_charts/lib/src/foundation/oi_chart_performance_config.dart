import 'package:flutter/foundation.dart';

/// The rendering strategy used by the chart engine.
///
/// {@category Foundation}
enum OiChartRenderMode {
  /// Let the chart pick the best mode based on the data size and device
  /// capabilities. This is the default.
  auto,

  /// Prioritise visual fidelity — no decimation, full anti-aliasing.
  quality,

  /// A middle-ground: moderate decimation plus standard anti-aliasing.
  balanced,

  /// Prioritise frame rate — aggressive decimation, simplified geometry.
  performance,
}

/// The point-reduction algorithm applied before rendering.
///
/// {@category Foundation}
enum OiChartDecimationStrategy {
  /// No decimation — every data point is rendered.
  none,

  /// Keep only the min and max values per horizontal pixel bucket.
  minMax,

  /// Largest-Triangle-Three-Buckets — a visually-faithful down-sampling
  /// algorithm that preserves the overall shape of the line.
  lttb,

  /// The recommended default. Automatically selects between [minMax] and
  /// [lttb] depending on data density, preserving visual extrema while
  /// reducing point count relative to pixel density.
  adaptive,
}

/// Configuration that controls chart rendering performance.
///
/// Charts can accept an [OiChartPerformanceConfig] to tune the trade-off
/// between visual quality and frame rate. All fields have sensible defaults
/// so that the config is usable out-of-the-box.
///
/// ```dart
/// OiChartPerformanceConfig(
///   renderMode: OiChartRenderMode.auto,
///   decimationStrategy: OiChartDecimationStrategy.adaptive,
/// )
/// ```
///
/// {@category Foundation}
@immutable
class OiChartPerformanceConfig {
  /// Creates a performance configuration with sensible defaults.
  const OiChartPerformanceConfig({
    this.renderMode = OiChartRenderMode.auto,
    this.decimationStrategy = OiChartDecimationStrategy.adaptive,
    this.progressiveChunkSize = 500,
    this.maxInteractivePoints = 5000,
    this.cacheTextLayout = true,
    this.cachePaths = true,
    this.simplifyOffscreenGeometry = true,
  });

  /// The overall rendering strategy.
  ///
  /// In [OiChartRenderMode.auto] mode the chart inspects the data size
  /// against [maxInteractivePoints] and the device pixel ratio to choose
  /// between quality, balanced, or performance automatically.
  final OiChartRenderMode renderMode;

  /// The decimation algorithm applied to reduce point count before
  /// painting.
  ///
  /// [OiChartDecimationStrategy.adaptive] is the recommended default.
  /// It preserves visual extrema (peaks, valleys) while reducing the
  /// number of points proportional to available pixel density.
  final OiChartDecimationStrategy decimationStrategy;

  /// The number of data points processed per frame during progressive
  /// (chunked) rendering.
  ///
  /// Only relevant when the total data count exceeds
  /// [maxInteractivePoints] and the chart enters progressive mode.
  /// A larger value paints faster but may cause jank on low-end devices.
  final int progressiveChunkSize;

  /// The threshold above which charts enter progressive rendering and
  /// disable interactive hit-testing on every frame.
  ///
  /// Below this count, all interactions (hover, selection, crosshair)
  /// are evaluated against the full dataset.
  final int maxInteractivePoints;

  /// Whether to cache text painter layouts across frames.
  ///
  /// When `true`, axis labels and tooltip text are laid out once and
  /// reused until the viewport or locale changes.
  final bool cacheTextLayout;

  /// Whether to cache path objects across frames.
  ///
  /// When `true`, line/area paths are rebuilt only when data or the
  /// viewport changes rather than on every repaint.
  final bool cachePaths;

  /// Whether geometry outside the visible plot area should be
  /// simplified or skipped entirely.
  ///
  /// When `true`, off-screen segments are clipped and replaced with
  /// simplified connector segments, reducing GPU overdraw.
  final bool simplifyOffscreenGeometry;

  /// Resolves the effective render mode when [renderMode] is
  /// [OiChartRenderMode.auto].
  ///
  /// The [totalPoints] parameter is the number of raw data points
  /// across all visible series. The [devicePixelRatio] is used to
  /// estimate available pixel density.
  OiChartRenderMode resolveRenderMode({
    required int totalPoints,
    double devicePixelRatio = 1.0,
  }) {
    if (renderMode != OiChartRenderMode.auto) return renderMode;

    final effectiveThreshold = (maxInteractivePoints * devicePixelRatio)
        .round();

    if (totalPoints <= effectiveThreshold ~/ 2) {
      return OiChartRenderMode.quality;
    } else if (totalPoints <= effectiveThreshold) {
      return OiChartRenderMode.balanced;
    }
    return OiChartRenderMode.performance;
  }

  /// Resolves the effective decimation strategy based on the resolved
  /// render mode and data characteristics.
  ///
  /// When [decimationStrategy] is [OiChartDecimationStrategy.adaptive],
  /// the strategy is chosen based on data density relative to available
  /// pixel width. For fewer than 4× pixels of data, no decimation is
  /// applied. Between 4× and 20×, LTTB is used. Beyond 20×, minMax is
  /// preferred for speed.
  OiChartDecimationStrategy resolveDecimationStrategy({
    required int totalPoints,
    required double availablePixelWidth,
  }) {
    if (decimationStrategy != OiChartDecimationStrategy.adaptive) {
      return decimationStrategy;
    }

    if (availablePixelWidth <= 0) return OiChartDecimationStrategy.none;

    final density = totalPoints / availablePixelWidth;

    if (density < 4) return OiChartDecimationStrategy.none;
    if (density < 20) return OiChartDecimationStrategy.lttb;
    return OiChartDecimationStrategy.minMax;
  }

  /// Whether progressive (chunked) rendering should be enabled.
  bool shouldUseProgressiveRendering(int totalPoints) {
    return totalPoints > maxInteractivePoints;
  }

  /// Creates a copy with optionally overridden values.
  OiChartPerformanceConfig copyWith({
    OiChartRenderMode? renderMode,
    OiChartDecimationStrategy? decimationStrategy,
    int? progressiveChunkSize,
    int? maxInteractivePoints,
    bool? cacheTextLayout,
    bool? cachePaths,
    bool? simplifyOffscreenGeometry,
  }) {
    return OiChartPerformanceConfig(
      renderMode: renderMode ?? this.renderMode,
      decimationStrategy: decimationStrategy ?? this.decimationStrategy,
      progressiveChunkSize: progressiveChunkSize ?? this.progressiveChunkSize,
      maxInteractivePoints: maxInteractivePoints ?? this.maxInteractivePoints,
      cacheTextLayout: cacheTextLayout ?? this.cacheTextLayout,
      cachePaths: cachePaths ?? this.cachePaths,
      simplifyOffscreenGeometry:
          simplifyOffscreenGeometry ?? this.simplifyOffscreenGeometry,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiChartPerformanceConfig) return false;
    return renderMode == other.renderMode &&
        decimationStrategy == other.decimationStrategy &&
        progressiveChunkSize == other.progressiveChunkSize &&
        maxInteractivePoints == other.maxInteractivePoints &&
        cacheTextLayout == other.cacheTextLayout &&
        cachePaths == other.cachePaths &&
        simplifyOffscreenGeometry == other.simplifyOffscreenGeometry;
  }

  @override
  int get hashCode => Object.hash(
    renderMode,
    decimationStrategy,
    progressiveChunkSize,
    maxInteractivePoints,
    cacheTextLayout,
    cachePaths,
    simplifyOffscreenGeometry,
  );

  @override
  String toString() =>
      'OiChartPerformanceConfig('
      'renderMode: $renderMode, '
      'decimation: $decimationStrategy, '
      'chunkSize: $progressiveChunkSize, '
      'maxInteractive: $maxInteractivePoints, '
      'cacheText: $cacheTextLayout, '
      'cachePaths: $cachePaths, '
      'simplifyOffscreen: $simplifyOffscreenGeometry)';
}
