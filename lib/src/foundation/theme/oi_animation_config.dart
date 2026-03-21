import 'package:flutter/cupertino.dart'
    show BackdropFilter, BoxShadow, MediaQueryData;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show BackdropFilter, BoxShadow, MediaQueryData;
import 'package:flutter/widgets.dart'
    show BackdropFilter, BoxShadow, MediaQueryData;

/// Configuration for animation durations and motion preferences.
///
/// When [reducedMotion] is true (e.g. when the user has enabled the system
/// "Reduce Motion" accessibility setting), all animated durations resolve to
/// [Duration.zero] to eliminate motion for users who are sensitive to it.
///
/// {@category Foundation}
@immutable
class OiAnimationConfig {
  /// Creates an [OiAnimationConfig] with explicit durations.
  const OiAnimationConfig({
    required this.fast,
    required this.normal,
    required this.slow,
    required this.reducedMotion,
  });

  /// Creates the standard animation configuration with typical durations.
  ///
  /// Set [reducedMotion] to true to eliminate all animations (e.g. when
  /// `MediaQuery.disableAnimations` is true).
  const OiAnimationConfig.standard({this.reducedMotion = false})
    : fast = reducedMotion ? Duration.zero : const Duration(milliseconds: 150),
      normal = reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 250),
      slow = reducedMotion ? Duration.zero : const Duration(milliseconds: 400);

  /// Fast transition duration (150ms). Used for micro-interactions.
  final Duration fast;

  /// Normal transition duration (250ms). Default for most animations.
  final Duration normal;

  /// Slow transition duration (400ms). Used for large layout changes.
  final Duration slow;

  /// When true, all durations resolve to [Duration.zero].
  ///
  /// Should mirror [MediaQueryData.disableAnimations].
  final bool reducedMotion;

  /// Creates a copy with optionally overridden values.
  OiAnimationConfig copyWith({
    Duration? fast,
    Duration? normal,
    Duration? slow,
    bool? reducedMotion,
  }) {
    return OiAnimationConfig(
      fast: fast ?? this.fast,
      normal: normal ?? this.normal,
      slow: slow ?? this.slow,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiAnimationConfig &&
        other.fast == fast &&
        other.normal == normal &&
        other.slow == slow &&
        other.reducedMotion == reducedMotion;
  }

  @override
  int get hashCode => Object.hash(fast, normal, slow, reducedMotion);
}

/// Configuration for device performance tiers.
///
/// Lower-performance devices can opt out of expensive visual effects
/// such as blur, shadows, and complex animations. Use [OiPerformanceConfig.auto]
/// to detect the tier automatically based on device capabilities.
///
/// {@category Foundation}
@immutable
class OiPerformanceConfig {
  /// Creates a [OiPerformanceConfig] with explicit settings.
  const OiPerformanceConfig({
    required this.disableBlur,
    required this.disableShadows,
    required this.reduceAnimations,
    required this.disableHalo,
    required this.animationScale,
  });

  /// High-performance configuration. All effects enabled.
  const OiPerformanceConfig.high()
    : disableBlur = false,
      disableShadows = false,
      reduceAnimations = false,
      disableHalo = false,
      animationScale = 1.0;

  /// Mid-performance configuration. Blur disabled, other effects enabled.
  const OiPerformanceConfig.mid()
    : disableBlur = true,
      disableShadows = false,
      reduceAnimations = false,
      disableHalo = false,
      animationScale = 1.0;

  /// Low-performance configuration. All expensive effects disabled.
  const OiPerformanceConfig.low()
    : disableBlur = true,
      disableShadows = true,
      reduceAnimations = true,
      disableHalo = true,
      animationScale = 0.5;

  /// Automatically selects a tier based on the current platform.
  ///
  /// On web: mid (blur is expensive in browsers).
  /// Otherwise: high.
  factory OiPerformanceConfig.auto() {
    if (kIsWeb) return const OiPerformanceConfig.mid();
    return const OiPerformanceConfig.high();
  }

  /// When true, [BackdropFilter] blur effects are not rendered.
  final bool disableBlur;

  /// When true, [BoxShadow] effects are not applied.
  final bool disableShadows;

  /// When true, animation durations are halved via [animationScale].
  final bool reduceAnimations;

  /// When true, halo/glow effects around interactive elements are suppressed.
  final bool disableHalo;

  /// Multiplier applied to all animation durations. Default is 1.0.
  final double animationScale;

  /// Creates a copy with optionally overridden values.
  OiPerformanceConfig copyWith({
    bool? disableBlur,
    bool? disableShadows,
    bool? reduceAnimations,
    bool? disableHalo,
    double? animationScale,
  }) {
    return OiPerformanceConfig(
      disableBlur: disableBlur ?? this.disableBlur,
      disableShadows: disableShadows ?? this.disableShadows,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      disableHalo: disableHalo ?? this.disableHalo,
      animationScale: animationScale ?? this.animationScale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiPerformanceConfig &&
        other.disableBlur == disableBlur &&
        other.disableShadows == disableShadows &&
        other.reduceAnimations == reduceAnimations &&
        other.disableHalo == disableHalo &&
        other.animationScale == animationScale;
  }

  @override
  int get hashCode => Object.hash(
    disableBlur,
    disableShadows,
    reduceAnimations,
    disableHalo,
    animationScale,
  );
}
