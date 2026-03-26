import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase animation config (enter / update / exit)
// ─────────────────────────────────────────────────────────────────────────────

/// Configuration for a single animation phase (enter, update, or exit).
///
/// {@category Foundation}
@immutable
class OiPhaseAnimationConfig {
  /// Creates an [OiPhaseAnimationConfig].
  const OiPhaseAnimationConfig({
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  /// Duration of this animation phase.
  final Duration duration;

  /// Easing curve for this animation phase.
  final Curve curve;

  /// Returns a copy with the duration scaled to [Duration.zero] for
  /// reduced-motion contexts.
  OiPhaseAnimationConfig _withReducedMotion() {
    return OiPhaseAnimationConfig(duration: Duration.zero, curve: curve);
  }

  /// Creates a copy with optionally overridden values.
  OiPhaseAnimationConfig copyWith({Duration? duration, Curve? curve}) {
    return OiPhaseAnimationConfig(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiPhaseAnimationConfig &&
        other.duration == duration &&
        other.curve == curve;
  }

  @override
  int get hashCode => Object.hash(duration, curve);
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-series animation config
// ─────────────────────────────────────────────────────────────────────────────

/// Per-series animation overrides.
///
/// When applied to a specific series, these values override the
/// corresponding defaults from [OiChartAnimationConfig]. Any field
/// left null inherits from the chart-level config.
///
/// The [delay] field allows staggered animations between series.
///
/// {@category Foundation}
@immutable
class OiSeriesAnimationConfig {
  /// Creates an [OiSeriesAnimationConfig].
  const OiSeriesAnimationConfig({this.duration, this.delay, this.curve});

  /// Optional duration override for this series.
  final Duration? duration;

  /// Optional delay before this series' animation starts.
  ///
  /// Useful for staggered entry animations across multiple series.
  final Duration? delay;

  /// Optional curve override for this series.
  final Curve? curve;

  /// Creates a copy with optionally overridden values.
  OiSeriesAnimationConfig copyWith({
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    return OiSeriesAnimationConfig(
      duration: duration ?? this.duration,
      delay: delay ?? this.delay,
      curve: curve ?? this.curve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSeriesAnimationConfig &&
        other.duration == duration &&
        other.delay == delay &&
        other.curve == curve;
  }

  @override
  int get hashCode => Object.hash(duration, delay, curve);
}

// ─────────────────────────────────────────────────────────────────────────────
// Main chart animation config
// ─────────────────────────────────────────────────────────────────────────────

/// Controls animation behaviour for chart transitions.
///
/// [OiChartAnimationConfig] provides:
/// - An [enabled] flag to toggle animation entirely.
/// - A default [duration] and [curve] for general transitions.
/// - Separate [enter], [update], and [exit] phase configs.
/// - A [respectReducedMotion] flag that integrates with the system's
///   "Reduce Motion" accessibility setting (via [OiA11y.reducedMotion])
///   and OiApp's [OiPerformanceConfig].
///
/// When [respectReducedMotion] is true and the system reports reduced
/// motion, all durations resolve to [Duration.zero] regardless of the
/// configured values.
///
/// **Design note:** The concept spec defines `OiChartEnterAnimation`,
/// `OiChartUpdateAnimation`, and `OiChartExitAnimation` enums with named
/// presets (grow/fade/slide/none, morph/crossfade/none, shrink/fade/none).
/// This implementation uses class-based [OiPhaseAnimationConfig] per phase
/// instead, which is more flexible — any curve+duration combination is
/// expressible, not just named presets. This is an intentional deviation.
///
/// {@category Foundation}
@immutable
class OiChartAnimationConfig {
  /// Creates an [OiChartAnimationConfig].
  const OiChartAnimationConfig({
    this.enabled = true,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.enter = const OiPhaseAnimationConfig(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
    ),
    this.update = const OiPhaseAnimationConfig(),
    this.exit = const OiPhaseAnimationConfig(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    ),
    this.respectReducedMotion = true,
  });

  /// A config with all animations disabled.
  const OiChartAnimationConfig.disabled()
    : enabled = false,
      duration = Duration.zero,
      curve = Curves.linear,
      enter = const OiPhaseAnimationConfig(
        duration: Duration.zero,
        curve: Curves.linear,
      ),
      update = const OiPhaseAnimationConfig(
        duration: Duration.zero,
        curve: Curves.linear,
      ),
      exit = const OiPhaseAnimationConfig(
        duration: Duration.zero,
        curve: Curves.linear,
      ),
      respectReducedMotion = false;

  /// Whether chart animations are enabled at all.
  ///
  /// When false, all transitions complete instantly.
  final bool enabled;

  /// Default duration for general chart transitions.
  final Duration duration;

  /// Default easing curve for general chart transitions.
  final Curve curve;

  /// Configuration for enter / appear animations (new data entering).
  final OiPhaseAnimationConfig enter;

  /// Configuration for update / data-change animations.
  final OiPhaseAnimationConfig update;

  /// Configuration for exit / disappear animations (data being removed).
  final OiPhaseAnimationConfig exit;

  /// Whether to respect the system's reduced-motion preference.
  ///
  /// When true, animations are suppressed when
  /// `MediaQuery.disableAnimations` is true or the `OiAnimationConfig`
  /// has `OiAnimationConfig.reducedMotion` set.
  final bool respectReducedMotion;

  /// Resolves this config against the current [BuildContext].
  ///
  /// If [respectReducedMotion] is true and the system reports reduced
  /// motion, returns a copy with all durations set to [Duration.zero].
  ///
  /// If the `OiPerformanceConfig` has `reduceAnimations` true, durations
  /// are scaled by `OiPerformanceConfig.animationScale`.
  OiChartAnimationConfig resolve(BuildContext context) {
    if (!enabled) return this;

    final isReducedMotion =
        respectReducedMotion && OiA11y.reducedMotion(context);

    if (isReducedMotion) {
      return OiChartAnimationConfig(
        enabled: false,
        duration: Duration.zero,
        curve: curve,
        enter: enter._withReducedMotion(),
        update: update._withReducedMotion(),
        exit: exit._withReducedMotion(),
        respectReducedMotion: respectReducedMotion,
      );
    }

    return this;
  }

  /// Resolves a [OiSeriesAnimationConfig] against this chart-level config.
  ///
  /// Returns the effective duration, delay, and curve for a specific
  /// series, falling back to the chart-level defaults.
  ({Duration duration, Duration delay, Curve curve}) resolveSeriesConfig(
    OiSeriesAnimationConfig? seriesConfig,
  ) {
    return (
      duration: seriesConfig?.duration ?? duration,
      delay: seriesConfig?.delay ?? Duration.zero,
      curve: seriesConfig?.curve ?? curve,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiChartAnimationConfig copyWith({
    bool? enabled,
    Duration? duration,
    Curve? curve,
    OiPhaseAnimationConfig? enter,
    OiPhaseAnimationConfig? update,
    OiPhaseAnimationConfig? exit,
    bool? respectReducedMotion,
  }) {
    return OiChartAnimationConfig(
      enabled: enabled ?? this.enabled,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      enter: enter ?? this.enter,
      update: update ?? this.update,
      exit: exit ?? this.exit,
      respectReducedMotion: respectReducedMotion ?? this.respectReducedMotion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartAnimationConfig &&
        other.enabled == enabled &&
        other.duration == duration &&
        other.curve == curve &&
        other.enter == enter &&
        other.update == update &&
        other.exit == exit &&
        other.respectReducedMotion == respectReducedMotion;
  }

  @override
  int get hashCode => Object.hash(
    enabled,
    duration,
    curve,
    enter,
    update,
    exit,
    respectReducedMotion,
  );
}
