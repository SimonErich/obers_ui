import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

// ---------------------------------------------------------------------------
// OiBreakpoint
// ---------------------------------------------------------------------------

/// A named breakpoint with a minimum viewport width threshold.
///
/// The design system ships five standard breakpoints as static constants.
/// Custom breakpoints can be created with the default constructor and
/// registered in the theme via [OiBreakpointScale].
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

// ---------------------------------------------------------------------------
// OiBreakpointScale
// ---------------------------------------------------------------------------

/// Defines the breakpoint scale for the entire application.
///
/// Stored in [OiThemeData.breakpoints]. Sorted automatically on creation.
/// The first entry must always have `minWidth == 0` (the base/default).
///
/// {@category Foundation}
@immutable
class OiBreakpointScale {
  /// Creates a breakpoint scale from an unsorted list.
  ///
  /// Throws an [ArgumentError] if no breakpoint has `minWidth == 0`.
  factory OiBreakpointScale(List<OiBreakpoint> breakpoints) {
    assert(breakpoints.isNotEmpty, 'At least one breakpoint is required.');
    final sorted = List<OiBreakpoint>.of(breakpoints)..sort();
    if (sorted.first.minWidth != 0) {
      throw ArgumentError(
        'The breakpoint scale must contain a breakpoint with minWidth == 0. '
        'Got smallest minWidth: ${sorted.first.minWidth}.',
      );
    }
    return OiBreakpointScale._(sorted);
  }

  const OiBreakpointScale._(this.values);

  /// The default 5-tier scale matching Material 3 guidelines.
  factory OiBreakpointScale.standard() {
    return OiBreakpointScale._(OiBreakpoint.values);
  }

  /// Extended scale — adds `tablet` (480) and `ultraWide` (1920).
  factory OiBreakpointScale.extended() {
    return OiBreakpointScale._([
      OiBreakpoint.compact,
      const OiBreakpoint('tablet', 480),
      OiBreakpoint.medium,
      OiBreakpoint.expanded,
      OiBreakpoint.large,
      OiBreakpoint.extraLarge,
      const OiBreakpoint('ultraWide', 1920),
    ]);
  }

  /// The sorted list of breakpoints, ascending by minWidth.
  final List<OiBreakpoint> values;

  /// Returns the active breakpoint for the given [width].
  ///
  /// Walks the sorted list in reverse, returning the first
  /// breakpoint whose minWidth <= width.
  OiBreakpoint resolve(double width) {
    for (var i = values.length - 1; i >= 0; i--) {
      if (values[i].minWidth <= width) return values[i];
    }
    return values.first;
  }

  /// Returns the index of the active breakpoint for the given [width].
  int resolveIndex(double width) {
    for (var i = values.length - 1; i >= 0; i--) {
      if (values[i].minWidth <= width) return i;
    }
    return 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiBreakpointScale) return false;
    if (values.length != other.values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (values[i] != other.values[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(values);

  @override
  String toString() =>
      'OiBreakpointScale(${values.map((b) => b.name).join(', ')})';
}

// ---------------------------------------------------------------------------
// OiHeightBreakpoint
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// OiResponsive<T>
// ---------------------------------------------------------------------------

/// A value that may vary across breakpoints.
///
/// There are two ways to construct it:
///
/// 1. **Static** — the same value at all breakpoints:
///    ```dart
///    OiResponsive(2)           // always 2 columns
///    ```
///
/// 2. **Per-breakpoint** — different values at different breakpoints:
///    ```dart
///    OiResponsive.breakpoints({
///      OiBreakpoint.compact: 1,
///      OiBreakpoint.medium: 2,
///      OiBreakpoint.large: 4,
///    })
///    ```
///
/// Resolution: when a breakpoint has no explicit value, it inherits
/// from the nearest smaller breakpoint that does have a value
/// (mobile-first cascading).
///
/// {@category Foundation}
@immutable
class OiResponsive<T> {
  /// A value that is the same at every breakpoint.
  const OiResponsive(this._defaultValue) : _map = null;

  /// Values keyed by breakpoint, with mobile-first cascading.
  ///
  /// The map should ideally contain a key with `minWidth == 0` (typically
  /// [OiBreakpoint.compact]) or provide a base via [defaultValue].
  const OiResponsive.breakpoints(
    Map<OiBreakpoint, T> map, {
    T? defaultValue,
  }) : _map = map,
       _defaultValue = defaultValue;

  final T? _defaultValue;
  final Map<OiBreakpoint, T>? _map;

  /// Whether this is a static (non-responsive) value.
  bool get isStatic => _map == null;

  /// Resolves the value for the given [active] breakpoint within [scale].
  ///
  /// Walks breakpoints in descending order from [active], returns
  /// the first mapped value found. Falls back to [_defaultValue].
  T resolve(OiBreakpoint active, OiBreakpointScale scale) {
    if (_map == null) return _defaultValue as T;

    // Walk backwards from the active breakpoint's index.
    final sorted = scale.values;
    final idx = scale.resolveIndex(active.minWidth);
    for (var i = idx; i >= 0; i--) {
      final bp = sorted[i];
      if (_map.containsKey(bp)) return _map[bp] as T;
    }

    return _defaultValue as T;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiResponsive<T>) return false;
    if (_defaultValue != other._defaultValue) return false;
    if (_map == null && other._map == null) return true;
    if (_map == null || other._map == null) return false;
    if (_map.length != other._map.length) return false;
    for (final entry in _map.entries) {
      if (other._map[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(_defaultValue, _map);

  @override
  String toString() {
    if (_map == null) return 'OiResponsive($_defaultValue)';
    return 'OiResponsive.breakpoints($_map, default: $_defaultValue)';
  }
}

// ---------------------------------------------------------------------------
// OiResponsive convenience extensions
// ---------------------------------------------------------------------------

/// Convenience to create a static [OiResponsive] from an [int].
///
/// ```dart
/// columns: 3.responsive,
/// ```
///
/// {@category Foundation}
extension OiResponsiveIntExt on int {
  /// Wraps this [int] in a static [OiResponsive].
  OiResponsive<int> get responsive => OiResponsive(this);
}

/// Convenience to create a static [OiResponsive] from a [double].
///
/// ```dart
/// gap: 16.0.responsive,
/// ```
///
/// {@category Foundation}
extension OiResponsiveDoubleExt on double {
  /// Wraps this [double] in a static [OiResponsive].
  OiResponsive<double> get responsive => OiResponsive(this);
}

/// Convenience to create a static [OiResponsive] from a [bool].
///
/// {@category Foundation}
extension OiResponsiveBoolExt on bool {
  /// Wraps this [bool] in a static [OiResponsive].
  OiResponsive<bool> get responsive => OiResponsive(this);
}

/// Convenience to create a breakpoint-keyed [OiResponsive] from a [Map].
///
/// ```dart
/// columns: {OiBreakpoint.compact: 1, OiBreakpoint.large: 4}.responsive,
/// ```
///
/// {@category Foundation}
extension OiResponsiveMapExt<T> on Map<OiBreakpoint, T> {
  /// Wraps this breakpoint map in an [OiResponsive.breakpoints].
  OiResponsive<T> get responsive => OiResponsive.breakpoints(this);
}

// ---------------------------------------------------------------------------
// OiResponsiveValue<T> — backward compatibility
// ---------------------------------------------------------------------------

/// A value that resolves differently at different breakpoints.
///
/// Provide values for any subset of breakpoints. When resolving, the largest
/// breakpoint that does not exceed [width] and has a provided value is used.
/// If no value is found, [fallback] is returned.
///
/// **Deprecated:** Use [OiResponsive] instead for new code.
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

// ---------------------------------------------------------------------------
// BuildContext extensions
// ---------------------------------------------------------------------------

/// Extensions on [BuildContext] for responsive layout helpers.
///
/// All getters read the current [MediaQueryData.size] width. The breakpoint
/// scale is resolved from the nearest [OiTheme] if present, otherwise
/// the standard 5-tier scale is used.
///
/// {@category Foundation}
extension OiResponsiveExt on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;
  double get _height => MediaQuery.sizeOf(this).height;

  /// The [OiBreakpointScale] from the theme, or the standard scale if no
  /// theme is present.
  OiBreakpointScale get breakpointScale {
    final theme = OiTheme.maybeOf(this);
    return theme?.breakpoints ?? OiBreakpointScale.standard();
  }

  /// The active [OiBreakpoint] for the current screen width.
  OiBreakpoint get breakpoint => breakpointScale.resolve(_width);

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

  /// Resolves an [OiResponsive] for the current screen width.
  T resolveResponsive<T>(OiResponsive<T> value) =>
      value.resolve(breakpoint, breakpointScale);

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
