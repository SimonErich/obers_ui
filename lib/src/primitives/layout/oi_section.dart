import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A semantic section grouping widget that arranges [children] vertically
/// with optional [gap] spacing and [padding].
///
/// Use [OiSection] to create named regions of a page — headers, content areas,
/// or any logical group of widgets. It renders a [Semantics] container so
/// assistive technologies can announce section boundaries.
///
/// [gap] and [padding] accept [OiResponsive] values so they can vary across
/// breakpoints:
///
/// ```dart
/// OiSection(
///   breakpoint: context.breakpoint,
///   gap: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 8,
///     OiBreakpoint.expanded: 16,
///   }),
///   padding: OiResponsive.breakpoints({
///     OiBreakpoint.compact: EdgeInsets.all(16),
///     OiBreakpoint.expanded: EdgeInsets.all(32),
///   }),
///   children: [...],
/// )
/// ```
///
/// **Zero magic:** [breakpoint] is required so every section is self-contained
/// with explicit props. Resolve the breakpoint once at the page/layout level
/// (e.g. `context.breakpoint`) and pass it down as a concrete value.
///
/// {@category Primitives}
class OiSection extends StatelessWidget {
  /// Creates an [OiSection].
  const OiSection({
    required this.breakpoint,
    required this.children,
    this.gap = const OiResponsive<double>(0),
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.semanticLabel,
    this.scale,
    super.key,
  });

  /// The spacing between children in logical pixels.
  final OiResponsive<double> gap;

  /// Optional padding around the section content.
  final OiResponsive<EdgeInsetsGeometry>? padding;

  /// The child widgets to lay out.
  final List<Widget> children;

  /// How children are aligned along the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much space the layout occupies along its main axis.
  ///
  /// Defaults to [MainAxisSize.min] so the widget shrink-wraps its children,
  /// allowing it to nest freely inside other layout widgets without causing
  /// unbounded-constraint errors.
  final MainAxisSize mainAxisSize;

  /// An optional label announced by assistive technologies for this section.
  final String? semanticLabel;

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
    final resolvedGap = gap.resolve(active, resolvedScale);
    final resolvedPadding = padding?.resolve(active, resolvedScale);

    // Build the interspersed children list.
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i < children.length - 1 && resolvedGap > 0) {
        spaced.add(SizedBox(height: resolvedGap));
      }
    }

    Widget content = Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: spaced,
    );

    if (resolvedPadding != null) {
      content = Padding(padding: resolvedPadding, child: content);
    }

    return Semantics(
      container: true,
      label: semanticLabel,
      child: content,
    );
  }
}
