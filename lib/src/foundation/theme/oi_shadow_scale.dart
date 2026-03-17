import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The shadow scale for the design system.
///
/// Provides named [List]<[BoxShadow]> values used for cards, dialogs,
/// buttons, and other elevated components. Two factory constructors are
/// provided for light and dark theme contexts.
///
/// {@category Foundation}
@immutable
class OiShadowScale {
  /// Creates an [OiShadowScale] with explicit values.
  const OiShadowScale({
    required this.none,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.glass,
  });

  /// Creates the standard light-theme shadow scale.
  ///
  /// Shadows use black with low alpha values to produce subtle depth cues
  /// on white/light surfaces.
  factory OiShadowScale.standard() {
    return const OiShadowScale(
      none: [],
      xs: [
        BoxShadow(
          color: Color(0x0D000000),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
      ],
      sm: [
        BoxShadow(
          color: Color(0x14000000),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
      md: [
        BoxShadow(
          color: Color(0x14000000),
          offset: Offset(0, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Color(0x0A000000),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
      lg: [
        BoxShadow(
          color: Color(0x14000000),
          offset: Offset(0, 8),
          blurRadius: 16,
        ),
        BoxShadow(
          color: Color(0x0A000000),
          offset: Offset(0, 4),
          blurRadius: 8,
        ),
      ],
      xl: [
        BoxShadow(
          color: Color(0x1F000000),
          offset: Offset(0, 16),
          blurRadius: 32,
        ),
        BoxShadow(
          color: Color(0x14000000),
          offset: Offset(0, 8),
          blurRadius: 16,
        ),
      ],
      glass: [BoxShadow(color: Color(0x1A000000), blurRadius: 24)],
    );
  }

  /// Creates a dark-theme adjusted shadow scale.
  ///
  /// Dark theme shadows use higher opacity to remain visible against
  /// dark backgrounds, while still providing subtle depth cues.
  factory OiShadowScale.dark() {
    return const OiShadowScale(
      none: [],
      xs: [
        BoxShadow(
          color: Color(0x29000000),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
      ],
      sm: [
        BoxShadow(
          color: Color(0x33000000),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
      md: [
        BoxShadow(
          color: Color(0x33000000),
          offset: Offset(0, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Color(0x1F000000),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
      lg: [
        BoxShadow(
          color: Color(0x33000000),
          offset: Offset(0, 8),
          blurRadius: 16,
        ),
        BoxShadow(
          color: Color(0x1F000000),
          offset: Offset(0, 4),
          blurRadius: 8,
        ),
      ],
      xl: [
        BoxShadow(
          color: Color(0x3D000000),
          offset: Offset(0, 16),
          blurRadius: 32,
        ),
        BoxShadow(
          color: Color(0x29000000),
          offset: Offset(0, 8),
          blurRadius: 16,
        ),
      ],
      glass: [BoxShadow(color: Color(0x33000000), blurRadius: 24)],
    );
  }

  /// No shadow. An empty list.
  final List<BoxShadow> none;

  /// Extra-small shadow. Subtle lift for small interactive elements.
  final List<BoxShadow> xs;

  /// Small shadow. Used for dropdowns and tooltips.
  final List<BoxShadow> sm;

  /// Medium shadow. Default for cards and inputs.
  final List<BoxShadow> md;

  /// Large shadow. Used for modals and popovers.
  final List<BoxShadow> lg;

  /// Extra-large shadow. Used for full-screen overlays and side sheets.
  final List<BoxShadow> xl;

  /// Glass shadow. Soft ambient shadow for frosted-glass surfaces.
  final List<BoxShadow> glass;

  /// Creates a copy with optionally overridden values.
  OiShadowScale copyWith({
    List<BoxShadow>? none,
    List<BoxShadow>? xs,
    List<BoxShadow>? sm,
    List<BoxShadow>? md,
    List<BoxShadow>? lg,
    List<BoxShadow>? xl,
    List<BoxShadow>? glass,
  }) {
    return OiShadowScale(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      glass: glass ?? this.glass,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiShadowScale) return false;
    if (none.length != other.none.length) return false;
    if (xs.length != other.xs.length) return false;
    if (sm.length != other.sm.length) return false;
    if (md.length != other.md.length) return false;
    if (lg.length != other.lg.length) return false;
    if (xl.length != other.xl.length) return false;
    if (glass.length != other.glass.length) return false;
    for (var i = 0; i < none.length; i++) {
      if (none[i] != other.none[i]) return false;
    }
    for (var i = 0; i < xs.length; i++) {
      if (xs[i] != other.xs[i]) return false;
    }
    for (var i = 0; i < sm.length; i++) {
      if (sm[i] != other.sm[i]) return false;
    }
    for (var i = 0; i < md.length; i++) {
      if (md[i] != other.md[i]) return false;
    }
    for (var i = 0; i < lg.length; i++) {
      if (lg[i] != other.lg[i]) return false;
    }
    for (var i = 0; i < xl.length; i++) {
      if (xl[i] != other.xl[i]) return false;
    }
    for (var i = 0; i < glass.length; i++) {
      if (glass[i] != other.glass[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(none),
    Object.hashAll(xs),
    Object.hashAll(sm),
    Object.hashAll(md),
    Object.hashAll(lg),
    Object.hashAll(xl),
    Object.hashAll(glass),
  );
}
