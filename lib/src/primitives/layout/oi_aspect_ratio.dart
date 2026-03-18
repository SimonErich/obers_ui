import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A widget that forces its [child] to a given width-to-height [ratio].
///
/// Wraps Flutter's [AspectRatio] with a named [ratio] parameter for clarity.
///
/// [ratio] accepts an [OiResponsive] value so it can vary across breakpoints:
///
/// ```dart
/// OiAspectRatio(
///   breakpoint: context.breakpoint,
///   ratio: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 4 / 3,
///     OiBreakpoint.expanded: 16 / 9,
///   }),
///   child: content,
/// )
/// ```
///
/// **Zero magic:** [breakpoint] is required so every aspect ratio is
/// self-contained with explicit props. Resolve the breakpoint once at the
/// page/layout level (e.g. `context.breakpoint`) and pass it down as a
/// concrete value.
///
/// {@category Primitives}
class OiAspectRatio extends StatelessWidget {
  /// Creates an [OiAspectRatio].
  const OiAspectRatio({
    required this.breakpoint,
    required this.ratio,
    required this.child,
    this.scale,
    super.key,
  });

  /// The width-to-height ratio (e.g. `16 / 9` for widescreen).
  ///
  /// Accepts an [OiResponsive] value so the ratio can vary across breakpoints.
  final OiResponsive<double> ratio;

  /// The widget to constrain to [ratio].
  final Widget child;

  /// The active breakpoint. Required — resolve once at the layout level
  /// and pass down explicitly.
  final OiBreakpoint breakpoint;

  /// The breakpoint scale used to resolve responsive values.
  ///
  /// When null, read from the nearest [OiTheme] via `context.breakpointScale`.
  final OiBreakpointScale? scale;

  @override
  Widget build(BuildContext context) {
    final active = breakpoint;
    final resolvedScale = scale ?? context.breakpointScale;
    final resolvedRatio = ratio.resolve(active, resolvedScale);
    return AspectRatio(aspectRatio: resolvedRatio, child: child);
  }
}
