import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiApp, OiThemeData;
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
/// In addition to breakpoint thresholds, the scale carries per-breakpoint
/// [pageGutters] and [contentMaxWidths] maps so that custom scales can
/// define layout tokens for every registered breakpoint.
///
/// {@category Foundation}
@immutable
class OiBreakpointScale with Iterable<OiBreakpoint> {
  /// Creates a breakpoint scale from an unsorted list.
  ///
  /// Optionally provide [pageGutters] and [contentMaxWidths] keyed by
  /// breakpoint name. Breakpoints not present in these maps will inherit
  /// from the nearest smaller breakpoint via mobile-first cascading.
  ///
  /// Throws an [ArgumentError] if no breakpoint has `minWidth == 0`.
  factory OiBreakpointScale(
    List<OiBreakpoint> breakpoints, {
    Map<String, double> pageGutters = const {},
    Map<String, double> contentMaxWidths = const {},
  }) {
    assert(breakpoints.isNotEmpty, 'At least one breakpoint is required.');
    final sorted = List<OiBreakpoint>.of(breakpoints)..sort();
    if (sorted.first.minWidth != 0) {
      throw ArgumentError(
        'The breakpoint scale must contain a breakpoint with minWidth == 0. '
        'Got smallest minWidth: ${sorted.first.minWidth}.',
      );
    }
    return OiBreakpointScale._(sorted, pageGutters, contentMaxWidths);
  }

  /// The default 5-tier scale matching Material 3 guidelines.
  factory OiBreakpointScale.standard() {
    return defaultScale;
  }

  /// Extended scale — adds `tablet` (480) and `ultraWide` (1920).
  factory OiBreakpointScale.extended() {
    return const OiBreakpointScale._(
      [
        OiBreakpoint.compact,
        OiBreakpoint('tablet', 480),
        OiBreakpoint.medium,
        OiBreakpoint.expanded,
        OiBreakpoint.large,
        OiBreakpoint.extraLarge,
        OiBreakpoint('ultraWide', 1920),
      ],
      {..._standardPageGutters, 'tablet': 16, 'ultraWide': 56},
      {
        ..._standardContentMaxWidths,
        'tablet': double.infinity,
        'ultraWide': 1600,
      },
    );
  }

  const OiBreakpointScale._(
    this.values,
    this.pageGutters,
    this.contentMaxWidths,
  );

  /// The default 5-tier scale matching Material 3 guidelines, as a const.
  ///
  /// This is the default value used by all layout widgets when no explicit
  /// scale is provided. Zero magic: no context lookup needed.
  static const OiBreakpointScale defaultScale = OiBreakpointScale._(
    OiBreakpoint.values,
    _standardPageGutters,
    _standardContentMaxWidths,
  );

  // Default page gutter values for the standard 5-tier scale.
  static const Map<String, double> _standardPageGutters = {
    'compact': 16,
    'medium': 24,
    'expanded': 32,
    'large': 40,
    'extraLarge': 48,
  };

  // Default content max-width values for the standard 5-tier scale.
  static const Map<String, double> _standardContentMaxWidths = {
    'compact': double.infinity,
    'medium': 720,
    'expanded': 960,
    'large': 1200,
    'extraLarge': 1400,
  };

  /// The sorted list of breakpoints, ascending by minWidth.
  final List<OiBreakpoint> values;

  /// Page gutter values keyed by breakpoint name.
  ///
  /// Used by [resolvePageGutter] for mobile-first resolution.
  final Map<String, double> pageGutters;

  /// Content max-width values keyed by breakpoint name.
  ///
  /// Used by [resolveContentMaxWidth] for mobile-first resolution.
  final Map<String, double> contentMaxWidths;

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
  bool contains(Object? element) => values.contains(element);

  /// Looks up a breakpoint by [name], or `null` if not found.
  OiBreakpoint? byName(String name) {
    for (final bp in values) {
      if (bp.name == name) return bp;
    }
    return null;
  }

  /// Returns the index of [bp] in the sorted values, or `-1` if not found.
  int indexOf(OiBreakpoint bp) => values.indexOf(bp);

  /// Resolves the page gutter for the given [active] breakpoint.
  ///
  /// If [active] has an explicit entry in [pageGutters], that value is
  /// returned. Otherwise walks the scale downward (mobile-first cascade)
  /// to find the nearest smaller breakpoint with a value.
  double resolvePageGutter(OiBreakpoint active) {
    if (pageGutters.containsKey(active.name)) {
      return pageGutters[active.name]!;
    }
    final idx = resolveIndex(active.minWidth);
    for (var i = idx - 1; i >= 0; i--) {
      final name = values[i].name;
      if (pageGutters.containsKey(name)) return pageGutters[name]!;
    }
    return 16;
  }

  /// Resolves the content max-width for the given [active] breakpoint.
  ///
  /// If [active] has an explicit entry in [contentMaxWidths], that value is
  /// returned. Otherwise walks the scale downward (mobile-first cascade)
  /// to find the nearest smaller breakpoint with a value.
  double resolveContentMaxWidth(OiBreakpoint active) {
    if (contentMaxWidths.containsKey(active.name)) {
      return contentMaxWidths[active.name]!;
    }
    final idx = resolveIndex(active.minWidth);
    for (var i = idx - 1; i >= 0; i--) {
      final name = values[i].name;
      if (contentMaxWidths.containsKey(name)) return contentMaxWidths[name]!;
    }
    return double.infinity;
  }

  // ── Iterable<OiBreakpoint> ───────────────────────────────────────────

  @override
  Iterator<OiBreakpoint> get iterator => values.iterator;

  // ── Registry API ──────────────────────────────────────────────────────

  /// All registered breakpoint names in ascending order of minWidth.
  List<String> get names => List.unmodifiable(values.map((b) => b.name));

  @override
  int get length => values.length;

  /// Looks up a breakpoint by [name].
  ///
  /// Throws a [StateError] if no breakpoint with the given name exists.
  /// For a nullable variant, use [byName].
  OiBreakpoint operator [](String name) {
    final bp = byName(name);
    if (bp == null) {
      throw StateError(
        'No breakpoint named "$name" in this scale. '
        'Registered: ${names.join(", ")}.',
      );
    }
    return bp;
  }

  /// Whether the scale contains a breakpoint with the given [name].
  bool containsName(String name) => byName(name) != null;

  /// Returns a name → breakpoint map of all registered breakpoints.
  ///
  /// The map preserves ascending minWidth order via insertion order.
  Map<String, OiBreakpoint> get entries =>
      Map.unmodifiable({for (final bp in values) bp.name: bp});

  /// Creates a new scale with an additional [breakpoint] registered.
  ///
  /// If a breakpoint with the same name already exists, it is replaced.
  /// Optionally provide a [pageGutter] and/or [contentMaxWidth] for the
  /// new breakpoint.
  OiBreakpointScale register(
    OiBreakpoint breakpoint, {
    double? pageGutter,
    double? contentMaxWidth,
  }) {
    final newValues = values.where((b) => b.name != breakpoint.name).toList()
      ..add(breakpoint)
      ..sort();
    final newGutters = Map<String, double>.of(pageGutters);
    if (pageGutter != null) newGutters[breakpoint.name] = pageGutter;
    final newMaxWidths = Map<String, double>.of(contentMaxWidths);
    if (contentMaxWidth != null) {
      newMaxWidths[breakpoint.name] = contentMaxWidth;
    }
    return OiBreakpointScale._(newValues, newGutters, newMaxWidths);
  }

  /// Creates a new scale with multiple additional breakpoints registered.
  ///
  /// Breakpoints with names that already exist in the scale are replaced.
  OiBreakpointScale registerAll(
    List<OiBreakpoint> breakpoints, {
    Map<String, double> pageGutters = const {},
    Map<String, double> contentMaxWidths = const {},
  }) {
    final nameSet = breakpoints.map((b) => b.name).toSet();
    final newValues = values.where((b) => !nameSet.contains(b.name)).toList()
      ..addAll(breakpoints)
      ..sort();
    return OiBreakpointScale._(
      newValues,
      {...this.pageGutters, ...pageGutters},
      {...this.contentMaxWidths, ...contentMaxWidths},
    );
  }

  /// Creates a new scale without the breakpoint named [name].
  ///
  /// The base breakpoint (minWidth == 0) cannot be removed. Throws an
  /// [ArgumentError] if you attempt to remove it, or a [StateError] if
  /// no breakpoint with [name] exists.
  OiBreakpointScale unregister(String name) {
    final bp = byName(name);
    if (bp == null) {
      throw StateError(
        'Cannot unregister "$name": no such breakpoint in this scale.',
      );
    }
    if (bp.minWidth == 0) {
      throw ArgumentError(
        'Cannot unregister the base breakpoint (minWidth == 0).',
      );
    }
    final newValues = values.where((b) => b.name != name).toList();
    final newGutters = Map<String, double>.of(pageGutters)..remove(name);
    final newMaxWidths = Map<String, double>.of(contentMaxWidths)..remove(name);
    return OiBreakpointScale._(newValues, newGutters, newMaxWidths);
  }

  /// Creates a copy of this scale with optionally overridden layout maps.
  ///
  /// The breakpoint list itself is not changed. Use [register],
  /// [unregister], or [registerAll] to modify breakpoints.
  OiBreakpointScale copyWith({
    Map<String, double>? pageGutters,
    Map<String, double>? contentMaxWidths,
  }) {
    return OiBreakpointScale._(
      values,
      pageGutters ?? this.pageGutters,
      contentMaxWidths ?? this.contentMaxWidths,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiBreakpointScale) return false;
    if (values.length != other.values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (values[i] != other.values[i]) return false;
    }
    return mapEquals(pageGutters, other.pageGutters) &&
        mapEquals(contentMaxWidths, other.contentMaxWidths);
  }

  @override
  int get hashCode => Object.hashAll([
    ...values,
    ...pageGutters.keys,
    ...pageGutters.values,
    ...contentMaxWidths.keys,
    ...contentMaxWidths.values,
  ]);

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
  const OiResponsive.breakpoints(Map<OiBreakpoint, T> map, {T? defaultValue})
    : _map = map,
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

  /// Resolves the value for the current screen breakpoint.
  ///
  /// For static values, returns the value directly without reading the
  /// widget tree. For per-breakpoint maps, reads the active breakpoint
  /// and scale from the nearest [OiTheme].
  ///
  /// **Deprecated:** Prefer [resolve] with an explicit breakpoint and scale.
  /// Resolve once at the page/layout level and pass concrete values down:
  ///
  /// ```dart
  /// final bp = context.breakpoint;
  /// final scale = context.breakpointScale;
  /// final cols = columns.resolve(bp, scale);
  /// ```
  // ignore: remove_deprecations_in_breaking_versions
  @Deprecated(
    'Use resolve(breakpoint, scale) with explicit parameters instead. '
    'Resolve the breakpoint once at the layout level and pass it down.',
  )
  T resolveFor(BuildContext context) {
    if (_map == null) return _defaultValue as T;
    return resolve(context.breakpoint, context.breakpointScale);
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

/// Convenience to create a static [OiResponsive] from an [EdgeInsetsGeometry].
///
/// {@category Foundation}
extension OiResponsiveEdgeInsetsExt on EdgeInsetsGeometry {
  /// Wraps this [EdgeInsetsGeometry] in a static [OiResponsive].
  OiResponsive<EdgeInsetsGeometry> get responsive => OiResponsive(this);
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
/// breakpoint that does not exceed width and has a provided value is used.
/// If no value is found, [fallback] is returned.
///
/// **Deprecated:** Use [OiResponsive] instead for new code.
///
/// {@category Foundation}
// ignore: remove_deprecations_in_breaking_versions
@Deprecated(
  'Use OiResponsive<T> instead. '
  'OiResponsive supports mobile-first cascading and explicit resolution '
  'via resolve(breakpoint, scale).',
)
class OiResponsiveValue<T> {
  /// Creates an [OiResponsiveValue] with per-breakpoint values.
  // ignore: remove_deprecations_in_breaking_versions
  @Deprecated('Use OiResponsive<T> instead.')
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
/// scale is resolved from the nearest [OiTheme]. A [FlutterError] is thrown
/// if no [OiTheme] ancestor is found — wrap your widget tree with [OiApp]
/// or [OiTheme] to provide one.
///
/// {@category Foundation}
extension OiResponsiveExt on BuildContext {
  double get _height => MediaQuery.sizeOf(this).height;

  /// The current viewport width in logical pixels.
  ///
  /// This is the raw width from [MediaQuery.sizeOf]. Use [breakpoint] for
  /// the resolved breakpoint at this width.
  double get viewportWidth => MediaQuery.sizeOf(this).width;

  /// The [OiBreakpointScale] from the nearest [OiTheme].
  ///
  /// Throws a [FlutterError] if no [OiTheme] ancestor is found.
  /// Wrap your widget tree with [OiApp] or [OiTheme] to provide a theme.
  OiBreakpointScale get breakpointScale => OiTheme.of(this).breakpoints;

  /// The active [OiBreakpoint] for the current screen width.
  OiBreakpoint get breakpoint => breakpointScale.resolve(viewportWidth);

  // ── Standard breakpoint checks ──────────────────────────────────────────
  // These compare by minWidth threshold so they work with custom-named
  // breakpoints that occupy the same tier as a standard breakpoint.

  /// Whether the active breakpoint occupies the compact tier (minWidth 0).
  ///
  /// Matches any breakpoint whose [OiBreakpoint.minWidth] equals
  /// [OiBreakpoint.compact]'s minWidth, regardless of its name.
  bool get isCompact => breakpoint.minWidth == OiBreakpoint.compact.minWidth;

  /// Whether the active breakpoint occupies the medium tier (minWidth 600).
  ///
  /// Matches any breakpoint whose [OiBreakpoint.minWidth] equals
  /// [OiBreakpoint.medium]'s minWidth, regardless of its name.
  bool get isMedium => breakpoint.minWidth == OiBreakpoint.medium.minWidth;

  /// Whether the active breakpoint occupies the expanded tier (minWidth 840).
  ///
  /// Matches any breakpoint whose [OiBreakpoint.minWidth] equals
  /// [OiBreakpoint.expanded]'s minWidth, regardless of its name.
  bool get isExpanded => breakpoint.minWidth == OiBreakpoint.expanded.minWidth;

  /// Whether the active breakpoint occupies the large tier (minWidth 1200).
  ///
  /// Matches any breakpoint whose [OiBreakpoint.minWidth] equals
  /// [OiBreakpoint.large]'s minWidth, regardless of its name.
  bool get isLarge => breakpoint.minWidth == OiBreakpoint.large.minWidth;

  /// Whether the active breakpoint occupies the extraLarge tier
  /// (minWidth 1600).
  ///
  /// Matches any breakpoint whose [OiBreakpoint.minWidth] equals
  /// [OiBreakpoint.extraLarge]'s minWidth, regardless of its name.
  bool get isExtraLarge =>
      breakpoint.minWidth == OiBreakpoint.extraLarge.minWidth;

  /// Whether the active breakpoint is at least as wide as
  /// [OiBreakpoint.medium] (≥600dp tier).
  bool get isMediumOrWider =>
      breakpoint.minWidth >= OiBreakpoint.medium.minWidth;

  /// Whether the active breakpoint is at least as wide as
  /// [OiBreakpoint.expanded] (≥840dp tier).
  bool get isExpandedOrWider =>
      breakpoint.minWidth >= OiBreakpoint.expanded.minWidth;

  /// Whether the active breakpoint is at least as wide as
  /// [OiBreakpoint.large] (≥1200dp tier).
  bool get isLargeOrWider => breakpoint.minWidth >= OiBreakpoint.large.minWidth;

  // ── Generic breakpoint checks ───────────────────────────────────────────

  /// Whether the active breakpoint equals [bp].
  ///
  /// Use this for custom breakpoints that don't have a dedicated getter.
  bool breakpointActive(OiBreakpoint bp) => breakpoint == bp;

  /// Whether the active breakpoint's tier is at least as wide as [bp].
  ///
  /// Compares the active breakpoint's [OiBreakpoint.minWidth] against
  /// bp.minWidth.
  bool atLeast(OiBreakpoint bp) => breakpoint.minWidth >= bp.minWidth;

  /// Resolves an [OiResponsive] for the current screen width.
  ///
  /// **Deprecated:** Prefer [OiResponsive.resolve] with an explicit breakpoint
  /// and scale. Resolve the breakpoint once at the layout level and pass
  /// concrete values down.
  // ignore: remove_deprecations_in_breaking_versions
  @Deprecated(
    'Use value.resolve(breakpoint, scale) with explicit parameters instead.',
  )
  T resolveResponsive<T>(OiResponsive<T> value) =>
      value.resolve(breakpoint, breakpointScale);

  /// Resolves a responsive value for the current viewport breakpoint.
  ///
  /// Convenience for `values.resolve(breakpoint, breakpointScale)`.
  ///
  /// ```dart
  /// final cols = context.responsive(OiResponsive.breakpoints({
  ///   OiBreakpoint.compact: 1,
  ///   OiBreakpoint.medium: 2,
  ///   OiBreakpoint.large: 4,
  /// }));
  /// ```
  T responsive<T>(OiResponsive<T> values) =>
      values.resolve(breakpoint, breakpointScale);

  /// Resolves an [OiResponsiveValue] for the current screen width.
  // ignore: remove_deprecations_in_breaking_versions
  @Deprecated(
    'Use responsive<T>(OiResponsive<T>) or '
    'OiResponsive<T>.resolve(breakpoint, scale) instead.',
  )
  T? responsiveValue<T>(OiResponsiveValue<T> value) =>
      value.resolve(viewportWidth);

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
  /// breakpoint, resolved from [OiBreakpointScale.pageGutters].
  double get pageGutter => breakpointScale.resolvePageGutter(breakpoint);

  /// The recommended maximum content width for the current breakpoint,
  /// resolved from [OiBreakpointScale.contentMaxWidths].
  double get contentMaxWidth =>
      breakpointScale.resolveContentMaxWidth(breakpoint);
}
