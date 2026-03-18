import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A thin wrapper around Flutter's [Wrap] widget with explicitly named fields.
///
/// [spacing] and [runSpacing] accept [OiResponsive] values so they can vary
/// across breakpoints:
///
/// ```dart
/// OiWrapLayout(
///   breakpoint: context.breakpoint,
///   spacing: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 8,
///     OiBreakpoint.expanded: 16,
///   }),
///   children: [...],
/// )
/// ```
///
/// **Zero magic:** [breakpoint] is required so every wrap layout is
/// self-contained with explicit props. Resolve the breakpoint once at the
/// page/layout level (e.g. `context.breakpoint`) and pass it down as a
/// concrete value.
///
/// {@category Primitives}
class OiWrapLayout extends StatelessWidget {
  /// Creates an [OiWrapLayout].
  const OiWrapLayout({
    required this.breakpoint,
    required this.children,
    this.spacing = const OiResponsive<double>(0),
    this.runSpacing = const OiResponsive<double>(0),
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.direction = Axis.horizontal,
    this.scale,
    super.key,
  });

  /// Horizontal gap between children along the main axis.
  final OiResponsive<double> spacing;

  /// Vertical gap between lines (runs).
  final OiResponsive<double> runSpacing;

  /// How children are aligned within each run along the main axis.
  final WrapAlignment alignment;

  /// How the runs themselves are aligned along the cross axis.
  final WrapAlignment runAlignment;

  /// How children within a run are aligned along the cross axis.
  final WrapCrossAlignment crossAxisAlignment;

  /// The primary axis along which children are laid out.
  final Axis direction;

  /// The child widgets to wrap.
  final List<Widget> children;

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
    final resolvedSpacing = spacing.resolve(active, resolvedScale);
    final resolvedRunSpacing = runSpacing.resolve(active, resolvedScale);

    return Wrap(
      spacing: resolvedSpacing,
      runSpacing: resolvedRunSpacing,
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      direction: direction,
      children: children,
    );
  }
}
