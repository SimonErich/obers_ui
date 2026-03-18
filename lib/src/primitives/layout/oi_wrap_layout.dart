import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A thin wrapper around Flutter's [Wrap] widget with explicitly named fields.
///
/// [spacing] and [runSpacing] accept [OiResponsive] values so they can vary
/// across breakpoints:
///
/// ```dart
/// OiWrapLayout(
///   spacing: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 8,
///     OiBreakpoint.expanded: 16,
///   }),
///   children: [...],
/// )
/// ```
///
/// The active breakpoint can be supplied explicitly via [breakpoint] so that
/// responsive values are resolved once at the layout level and passed down as
/// concrete values. When [breakpoint] is null the widget reads the breakpoint
/// from the nearest [OiTheme] via `context.breakpoint`.
///
/// {@category Primitives}
class OiWrapLayout extends StatelessWidget {
  /// Creates an [OiWrapLayout].
  const OiWrapLayout({
    required this.children,
    this.spacing = const OiResponsive<double>(0),
    this.runSpacing = const OiResponsive<double>(0),
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.direction = Axis.horizontal,
    this.breakpoint,
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

  /// The active breakpoint, resolved at the layout level.
  ///
  /// When null, falls back to `context.breakpoint` (implicit context lookup).
  /// Prefer passing an explicit value so the widget is self-contained.
  final OiBreakpoint? breakpoint;

  @override
  Widget build(BuildContext context) {
    final active = breakpoint ?? context.breakpoint;
    final scale = context.breakpointScale;
    final resolvedSpacing = spacing.resolve(active, scale);
    final resolvedRunSpacing = runSpacing.resolve(active, scale);

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
