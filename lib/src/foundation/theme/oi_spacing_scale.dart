import 'package:flutter/foundation.dart';

/// The spacing scale for the design system.
///
/// Provides named spacing values used for padding, margins, and gaps
/// throughout the library. All values are in logical pixels.
///
/// {@category Foundation}
@immutable
class OiSpacingScale {
  /// Creates an [OiSpacingScale] with explicit values.
  const OiSpacingScale({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    this.base = 4,
  });

  /// Creates the standard spacing scale.
  ///
  /// Values follow a 4dp base grid with doubling progression.
  factory OiSpacingScale.standard() {
    return const OiSpacingScale(
      xs: 4,
      sm: 8,
      md: 16,
      lg: 24,
      xl: 32,
      xxl: 48,
    );
  }

  /// The grid unit every other value is a multiple of (4dp by default).
  ///
  /// Exposed so [step] can express a spacing the named ladder skips, rather
  /// than callers writing `spacing.sm + 4` — which is a magic number wearing a
  /// token's coat, and drifts the moment the ladder is retuned.
  final double base;

  /// Extra-small spacing (4dp). Used for tight component-internal gaps.
  final double xs;

  /// Small spacing (8dp). Used for element gaps and compact padding.
  final double sm;

  /// Medium spacing (16dp). Default padding and standard gaps.
  final double md;

  /// Large spacing (24dp). Section padding and generous gaps.
  final double lg;

  /// Extra-large spacing (32dp). Card padding and section separators.
  final double xl;

  /// Double extra-large spacing (48dp). Major section separators.
  final double xxl;

  /// Returns [multiplier] grid units of spacing.
  ///
  /// For the values the named ladder covers, prefer the name — `spacing.md`
  /// reads better than `spacing.step(4)`. Use this for the steps between them,
  /// most often the 12dp that sits between [sm] and [md].
  double step(int multiplier) => base * multiplier;

  /// Creates a copy with optionally overridden values.
  OiSpacingScale copyWith({
    double? base,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return OiSpacingScale(
      base: base ?? this.base,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSpacingScale &&
        other.base == base &&
        other.xs == xs &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl &&
        other.xxl == xxl;
  }

  @override
  int get hashCode => Object.hashAll([
    base,
    xs,
    sm,
    md,
    lg,
    xl,
    xxl,
  ]);
}
