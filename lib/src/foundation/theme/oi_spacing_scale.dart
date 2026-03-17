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
    required this.pageGutterCompact,
    required this.pageGutterMedium,
    required this.pageGutterExpanded,
    required this.pageGutterLarge,
    required this.pageGutterExtraLarge,
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
      pageGutterCompact: 16,
      pageGutterMedium: 24,
      pageGutterExpanded: 32,
      pageGutterLarge: 40,
      pageGutterExtraLarge: 48,
    );
  }

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

  /// Page gutter at the compact breakpoint (<600dp).
  final double pageGutterCompact;

  /// Page gutter at the medium breakpoint (600–840dp).
  final double pageGutterMedium;

  /// Page gutter at the expanded breakpoint (840–1200dp).
  final double pageGutterExpanded;

  /// Page gutter at the large breakpoint (1200–1600dp).
  final double pageGutterLarge;

  /// Page gutter at the extra-large breakpoint (>1600dp).
  final double pageGutterExtraLarge;

  /// Creates a copy with optionally overridden values.
  OiSpacingScale copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? pageGutterCompact,
    double? pageGutterMedium,
    double? pageGutterExpanded,
    double? pageGutterLarge,
    double? pageGutterExtraLarge,
  }) {
    return OiSpacingScale(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      pageGutterCompact: pageGutterCompact ?? this.pageGutterCompact,
      pageGutterMedium: pageGutterMedium ?? this.pageGutterMedium,
      pageGutterExpanded: pageGutterExpanded ?? this.pageGutterExpanded,
      pageGutterLarge: pageGutterLarge ?? this.pageGutterLarge,
      pageGutterExtraLarge: pageGutterExtraLarge ?? this.pageGutterExtraLarge,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSpacingScale &&
        other.xs == xs &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl &&
        other.xxl == xxl &&
        other.pageGutterCompact == pageGutterCompact &&
        other.pageGutterMedium == pageGutterMedium &&
        other.pageGutterExpanded == pageGutterExpanded &&
        other.pageGutterLarge == pageGutterLarge &&
        other.pageGutterExtraLarge == pageGutterExtraLarge;
  }

  @override
  int get hashCode => Object.hashAll([
        xs,
        sm,
        md,
        lg,
        xl,
        xxl,
        pageGutterCompact,
        pageGutterMedium,
        pageGutterExpanded,
        pageGutterLarge,
        pageGutterExtraLarge,
      ]);
}
