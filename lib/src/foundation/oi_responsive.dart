import 'package:flutter/widgets.dart';

/// A breakpoint defined by a minimum viewport width.
///
/// The design system ships five standard breakpoints as static constants.
/// Custom breakpoints can be created with the default constructor.
///
/// {@category Foundation}
@immutable
class OiBreakpoint implements Comparable<OiBreakpoint> {
  /// Creates a custom breakpoint with a [name] and [minWidth].
  const OiBreakpoint(this.name, this.minWidth)
      : assert(minWidth >= 0, 'minWidth must be >= 0');

  /// Compact — phones in portrait (<600dp).
  static const OiBreakpoint compact = OiBreakpoint('compact', 0);

  /// Medium — large phones / small tablets (600–840dp).
  static const OiBreakpoint medium = OiBreakpoint('medium', 600);

  /// Expanded — tablets and small desktops (840–1200dp).
  static const OiBreakpoint expanded = OiBreakpoint('expanded', 840);

  /// Large — large desktop monitors (1200–1600dp).
  static const OiBreakpoint large = OiBreakpoint('large', 1200);

  /// Extra-large — ultra-wide monitors (>1600dp).
  static const OiBreakpoint extraLarge = OiBreakpoint('extraLarge', 1600);

  /// All standard breakpoints in ascending order.
  static const List<OiBreakpoint> values = [
    compact,
    medium,
    expanded,
    large,
    extraLarge,
  ];

  /// The human-readable name of this breakpoint.
  final String name;

  /// The minimum viewport width in logical pixels at which this breakpoint
  /// activates.
  final double minWidth;

  @override
  int compareTo(OiBreakpoint other) => minWidth.compareTo(other.minWidth);

  /// Whether [width] falls within this breakpoint's range.
  bool matches(double width) => width >= minWidth;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiBreakpoint &&
        other.name == name &&
        other.minWidth == minWidth;
  }

  @override
  int get hashCode => Object.hash(name, minWidth);

  @override
  String toString() => 'OiBreakpoint($name, $minWidth)';
}

/// Vertical screen height classifications.
///
/// {@category Foundation}
enum OiHeightBreakpoint {
  /// Short screen — typically a phone in landscape (<500dp tall).
  short,

  /// Regular screen height.
  regular,

  /// Tall screen — large tablets and desktops (>900dp tall).
  tall,
}

/// A value that resolves differently at different breakpoints.
///
/// Provide values for any subset of breakpoints. When resolving, the largest
/// breakpoint that does not exceed [width] and has a provided value is used.
/// If no value is found, [fallback] is returned.
///
/// {@category Foundation}
class OiResponsiveValue<T> {
  /// Creates an [OiResponsiveValue] with per-breakpoint values.
  const OiResponsiveValue({
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    this.fallback,
  });

  /// Value at the compact breakpoint.
  final T? compact;

  /// Value at the medium breakpoint.
  final T? medium;

  /// Value at the expanded breakpoint.
  final T? expanded;

  /// Value at the large breakpoint.
  final T? large;

  /// Value at the extra-large breakpoint.
  final T? extraLarge;

  /// Fallback value when no breakpoint-specific value is defined.
  final T? fallback;

  /// Resolves the value for the given [width].
  ///
  /// Returns the value for the largest breakpoint that is active (<=width)
  /// and has a non-null value. Falls back to [fallback] if none match.
  T? resolve(double width) {
    if (width >= OiBreakpoint.extraLarge.minWidth && extraLarge != null) {
      return extraLarge;
    }
    if (width >= OiBreakpoint.large.minWidth && large != null) return large;
    if (width >= OiBreakpoint.expanded.minWidth && expanded != null) {
      return expanded;
    }
    if (width >= OiBreakpoint.medium.minWidth && medium != null) return medium;
    if (width >= OiBreakpoint.compact.minWidth && compact != null) {
      return compact;
    }
    return fallback;
  }
}

/// Extensions on [BuildContext] for responsive layout helpers.
///
/// All getters read the current [MediaQueryData.size] width.
///
/// {@category Foundation}
extension OiResponsiveExt on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;
  double get _height => MediaQuery.sizeOf(this).height;

  /// The active [OiBreakpoint] for the current screen width.
  OiBreakpoint get breakpoint {
    final width = _width;
    if (width >= OiBreakpoint.extraLarge.minWidth) {
      return OiBreakpoint.extraLarge;
    }
    if (width >= OiBreakpoint.large.minWidth) return OiBreakpoint.large;
    if (width >= OiBreakpoint.expanded.minWidth) return OiBreakpoint.expanded;
    if (width >= OiBreakpoint.medium.minWidth) return OiBreakpoint.medium;
    return OiBreakpoint.compact;
  }

  /// Whether the current breakpoint is compact.
  bool get isCompact => _width < OiBreakpoint.medium.minWidth;

  /// Whether the current breakpoint is medium.
  bool get isMedium =>
      _width >= OiBreakpoint.medium.minWidth &&
      _width < OiBreakpoint.expanded.minWidth;

  /// Whether the current breakpoint is expanded.
  bool get isExpanded =>
      _width >= OiBreakpoint.expanded.minWidth &&
      _width < OiBreakpoint.large.minWidth;

  /// Whether the current breakpoint is large.
  bool get isLarge =>
      _width >= OiBreakpoint.large.minWidth &&
      _width < OiBreakpoint.extraLarge.minWidth;

  /// Whether the current breakpoint is extra-large.
  bool get isExtraLarge => _width >= OiBreakpoint.extraLarge.minWidth;

  /// Whether the width is at least medium (>=600dp).
  bool get isMediumOrWider => _width >= OiBreakpoint.medium.minWidth;

  /// Whether the width is at least expanded (>=840dp).
  bool get isExpandedOrWider => _width >= OiBreakpoint.expanded.minWidth;

  /// Whether the width is at least large (>=1200dp).
  bool get isLargeOrWider => _width >= OiBreakpoint.large.minWidth;

  /// Resolves an [OiResponsiveValue] for the current screen width.
  T? responsive<T>(OiResponsiveValue<T> value) => value.resolve(_width);

  /// Returns one of two values based on the current breakpoint.
  ///
  /// [compact] is returned on small screens, [expanded] on larger screens.
  T adaptive<T>({required T compact, required T expanded}) {
    return isExpandedOrWider ? expanded : compact;
  }

  /// The current screen orientation.
  Orientation get orientation => MediaQuery.orientationOf(this);

  /// Whether the screen is in portrait orientation.
  bool get isPortrait => orientation == Orientation.portrait;

  /// Whether the screen is in landscape orientation.
  bool get isLandscape => orientation == Orientation.landscape;

  /// The current vertical height breakpoint.
  OiHeightBreakpoint get heightBreakpoint {
    if (_height >= 900) return OiHeightBreakpoint.tall;
    if (_height >= 500) return OiHeightBreakpoint.regular;
    return OiHeightBreakpoint.short;
  }

  /// The recommended page gutter (horizontal padding) for the current
  /// breakpoint.
  double get pageGutter {
    if (isExtraLarge) return 48;
    if (isLargeOrWider) return 40;
    if (isExpandedOrWider) return 32;
    if (isMediumOrWider) return 24;
    return 16;
  }

  /// The recommended maximum content width for the current breakpoint.
  double get contentMaxWidth {
    if (isExtraLarge) return 1400;
    if (isLargeOrWider) return 1200;
    if (isExpandedOrWider) return 960;
    if (isMediumOrWider) return 720;
    return double.infinity;
  }
}
