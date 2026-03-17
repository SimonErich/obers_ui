import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Controls the global corner-rounding preference.
///
/// This preference determines which [OiRadiusScale] factory is used.
/// Consumers can set this in [OiThemeData.fromBrand] to control the
/// overall look and feel of the UI.
///
/// {@category Foundation}
enum OiRadiusPreference {
  /// No rounding — sharp right-angle corners throughout.
  sharp,

  /// Moderate rounding — the default balanced look.
  medium,

  /// Fully rounded — pill-shaped buttons and cards.
  rounded,
}

/// The border-radius scale for the design system.
///
/// Provides named [BorderRadius] values used for cards, buttons, inputs,
/// dialogs, and other rounded components.
///
/// {@category Foundation}
@immutable
class OiRadiusScale {
  /// Creates an [OiRadiusScale] with explicit values.
  const OiRadiusScale({
    required this.none,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.full,
  });

  /// Creates a scale for the given [preference].
  factory OiRadiusScale.forPreference(OiRadiusPreference preference) {
    switch (preference) {
      case OiRadiusPreference.sharp:
        return const OiRadiusScale(
          none: BorderRadius.zero,
          xs: BorderRadius.zero,
          sm: BorderRadius.zero,
          md: BorderRadius.zero,
          lg: BorderRadius.zero,
          xl: BorderRadius.zero,
          full: BorderRadius.zero,
        );
      case OiRadiusPreference.medium:
        return const OiRadiusScale(
          none: BorderRadius.zero,
          xs: BorderRadius.all(Radius.circular(2)),
          sm: BorderRadius.all(Radius.circular(4)),
          md: BorderRadius.all(Radius.circular(8)),
          lg: BorderRadius.all(Radius.circular(12)),
          xl: BorderRadius.all(Radius.circular(16)),
          full: BorderRadius.all(Radius.circular(9999)),
        );
      case OiRadiusPreference.rounded:
        return const OiRadiusScale(
          none: BorderRadius.zero,
          xs: BorderRadius.all(Radius.circular(4)),
          sm: BorderRadius.all(Radius.circular(8)),
          md: BorderRadius.all(Radius.circular(12)),
          lg: BorderRadius.all(Radius.circular(20)),
          xl: BorderRadius.all(Radius.circular(24)),
          full: BorderRadius.all(Radius.circular(9999)),
        );
    }
  }

  /// No rounding. [BorderRadius.zero].
  final BorderRadius none;

  /// Extra-small radius (2–4dp).
  final BorderRadius xs;

  /// Small radius (4–8dp).
  final BorderRadius sm;

  /// Medium radius (8–12dp). Default for inputs and cards.
  final BorderRadius md;

  /// Large radius (12–20dp). Used for dialogs and panels.
  final BorderRadius lg;

  /// Extra-large radius (16–24dp). Used for prominent containers.
  final BorderRadius xl;

  /// Full (pill) radius (9999dp). Used for badges, tags, and toggle pills.
  final BorderRadius full;

  /// Creates a copy with optionally overridden values.
  OiRadiusScale copyWith({
    BorderRadius? none,
    BorderRadius? xs,
    BorderRadius? sm,
    BorderRadius? md,
    BorderRadius? lg,
    BorderRadius? xl,
    BorderRadius? full,
  }) {
    return OiRadiusScale(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiRadiusScale &&
        other.none == none &&
        other.xs == xs &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl &&
        other.full == full;
  }

  @override
  int get hashCode => Object.hash(none, xs, sm, md, lg, xl, full);
}
