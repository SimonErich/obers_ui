import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';

/// Internal discriminator for [OiChartSurface] presentation modes.
enum _OiChartSurfaceKind { atom, card, compact, frosted, soft }

/// A themed visual container for charts, built on [OiSurface].
///
/// [OiChartSurface] provides a consistent surface for embedding charts, with
/// presentation modes that match the visual language of OiCard, OiTable,
/// and the rest of the obers_ui library. It inherits theme tokens for
/// background, border, shadow, and halo.
///
/// Use the named factory constructors for visual presets:
/// - [OiChartSurface] (default) — card-like presentation with elevation shadow.
/// - [OiChartSurface.atom] — minimal bare surface with no chrome.
/// - [OiChartSurface.compact] — reduced padding for embedded/inline charts.
/// - [OiChartSurface.frosted] — frosted-glass backdrop blur effect.
/// - [OiChartSurface.soft] — subtle tinted background with no shadow.
///
/// {@category Components}
class OiChartSurface extends StatelessWidget {
  /// Creates a card-like [OiChartSurface] with elevation shadow.
  const OiChartSurface({
    required this.child,
    this.padding,
    this.border,
    this.gradient,
    this.halo,
    this.semanticLabel,
    super.key,
  }) : _kind = _OiChartSurfaceKind.card;

  const OiChartSurface._({
    required this.child,
    required _OiChartSurfaceKind kind,
    this.padding,
    this.border,
    this.gradient,
    this.halo,
    this.semanticLabel,
    super.key,
  }) : _kind = kind;

  /// Creates a minimal [OiChartSurface] with no border, shadow, or background.
  ///
  /// Parallels [OiChartData.atom] and [OiChartPalette.atom] for single-series
  /// charts that need a bare surface wrapper with zero visual chrome.
  /// Default padding is `EdgeInsets.zero`.
  factory OiChartSurface.atom({
    required Widget child,
    EdgeInsetsGeometry? padding,
    OiBorderStyle? border,
    OiGradientStyle? gradient,
    OiHaloStyle? halo,
    String? semanticLabel,
    Key? key,
  }) {
    return OiChartSurface._(
      kind: _OiChartSurfaceKind.atom,
      padding: padding,
      border: border,
      gradient: gradient,
      halo: halo,
      semanticLabel: semanticLabel,
      key: key,
      child: child,
    );
  }

  /// Creates a compact [OiChartSurface] with reduced padding for inline use.
  factory OiChartSurface.compact({
    required Widget child,
    EdgeInsetsGeometry? padding,
    OiBorderStyle? border,
    OiGradientStyle? gradient,
    OiHaloStyle? halo,
    String? semanticLabel,
    Key? key,
  }) {
    return OiChartSurface._(
      kind: _OiChartSurfaceKind.compact,
      padding: padding,
      border: border,
      gradient: gradient,
      halo: halo,
      semanticLabel: semanticLabel,
      key: key,
      child: child,
    );
  }

  /// Creates a frosted-glass [OiChartSurface] with a backdrop blur effect.
  ///
  /// Uses `glassBackground` and `glassBorder` theme tokens for the translucent
  /// appearance.
  factory OiChartSurface.frosted({
    required Widget child,
    EdgeInsetsGeometry? padding,
    OiBorderStyle? border,
    OiGradientStyle? gradient,
    OiHaloStyle? halo,
    String? semanticLabel,
    Key? key,
  }) {
    return OiChartSurface._(
      kind: _OiChartSurfaceKind.frosted,
      padding: padding,
      border: border,
      gradient: gradient,
      halo: halo,
      semanticLabel: semanticLabel,
      key: key,
      child: child,
    );
  }

  /// Creates a soft [OiChartSurface] with a subtle tinted background.
  ///
  /// Uses `surfaceSubtle` for the background and a theme border, with no
  /// elevation shadow.
  factory OiChartSurface.soft({
    required Widget child,
    EdgeInsetsGeometry? padding,
    OiBorderStyle? border,
    OiGradientStyle? gradient,
    OiHaloStyle? halo,
    String? semanticLabel,
    Key? key,
  }) {
    return OiChartSurface._(
      kind: _OiChartSurfaceKind.soft,
      padding: padding,
      border: border,
      gradient: gradient,
      halo: halo,
      semanticLabel: semanticLabel,
      key: key,
      child: child,
    );
  }

  /// The chart widget rendered inside the surface.
  final Widget child;

  /// Padding inside the surface.
  ///
  /// Defaults to `EdgeInsets.zero` for atom, `EdgeInsets.all(8)` for compact,
  /// and `EdgeInsets.all(16)` for card/frosted/soft.
  final EdgeInsetsGeometry? padding;

  /// Explicit border override.
  final OiBorderStyle? border;

  /// Optional background gradient. Overrides the surface fill colour.
  final OiGradientStyle? gradient;

  /// Optional halo/glow effect rendered around the surface.
  final OiHaloStyle? halo;

  /// Accessibility label for screen readers.
  final String? semanticLabel;

  final _OiChartSurfaceKind _kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color? color;
    OiBorderStyle? effectiveBorder;
    List<BoxShadow>? shadow;
    var frosted = false;

    switch (_kind) {
      case _OiChartSurfaceKind.atom:
        effectiveBorder = border;

      case _OiChartSurfaceKind.card:
        shadow = [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
        effectiveBorder = border;

      case _OiChartSurfaceKind.compact:
        effectiveBorder = border ?? context.decoration.defaultBorder;

      case _OiChartSurfaceKind.frosted:
        frosted = true;
        color = colors.glassBackground;
        effectiveBorder = border ??
            OiBorderStyle.solid(colors.glassBorder, 1);

      case _OiChartSurfaceKind.soft:
        color = colors.surfaceSubtle;
        effectiveBorder = border ?? context.decoration.defaultBorder;
    }

    final EdgeInsetsGeometry effectivePadding;
    if (padding != null) {
      effectivePadding = padding!;
    } else if (_kind == _OiChartSurfaceKind.atom) {
      effectivePadding = EdgeInsets.zero;
    } else if (_kind == _OiChartSurfaceKind.compact) {
      effectivePadding = const EdgeInsets.all(8);
    } else {
      effectivePadding = const EdgeInsets.all(16);
    }

    Widget surface = OiSurface(
      color: color,
      border: effectiveBorder,
      shadow: shadow,
      borderRadius: BorderRadius.circular(8),
      padding: effectivePadding,
      frosted: frosted,
      gradient: gradient,
      halo: halo,
      child: child,
    );

    if (semanticLabel != null) {
      surface = Semantics(label: semanticLabel, child: surface);
    }

    return surface;
  }
}
