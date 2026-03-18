import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A page-level layout wrapper that fills available space and arranges
/// [children] vertically with optional [padding] and [gap].
///
/// Use [OiPage] as the outermost layout widget to represent a full page.
/// It defaults to [MainAxisSize.max] so it expands to fill its parent,
/// but can be set to [MainAxisSize.min] for nesting inside other layouts.
///
/// [gap] and [padding] accept [OiResponsive] values so they can vary across
/// breakpoints:
///
/// ```dart
/// OiPage(
///   breakpoint: context.breakpoint,
///   padding: OiResponsive.breakpoints({
///     OiBreakpoint.compact: EdgeInsets.all(16),
///     OiBreakpoint.expanded: EdgeInsets.all(32),
///   }),
///   children: [
///     OiSection(breakpoint: bp, children: [header]),
///     OiGrid(breakpoint: bp, columns: OiResponsive(3), children: cards),
///   ],
/// )
/// ```
///
/// **Zero magic:** [breakpoint] is required so every page is self-contained
/// with explicit props. Resolve the breakpoint once at the page/layout level
/// (e.g. `context.breakpoint`) and pass it down as a concrete value.
///
/// {@category Primitives}
class OiPage extends StatelessWidget {
  /// Creates an [OiPage].
  const OiPage({
    required this.breakpoint,
    required this.children,
    this.gap = const OiResponsive<double>(0),
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.max,
    this.scale = OiBreakpointScale.defaultScale,
    super.key,
  });

  /// The spacing between children in logical pixels.
  final OiResponsive<double> gap;

  /// Optional padding around the page content.
  final OiResponsive<EdgeInsetsGeometry>? padding;

  /// The child widgets to lay out.
  final List<Widget> children;

  /// How children are aligned along the cross axis.
  ///
  /// Defaults to [CrossAxisAlignment.stretch] so children fill the page width.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much space the layout occupies along its main axis.
  ///
  /// Defaults to [MainAxisSize.max] so the page fills available height.
  /// Set to [MainAxisSize.min] for nesting inside other layout widgets.
  final MainAxisSize mainAxisSize;

  /// The active breakpoint. Required — resolve once at the layout level
  /// and pass down explicitly.
  final OiBreakpoint breakpoint;

  /// The breakpoint scale used to resolve responsive values.
  ///
  /// Defaults to [OiBreakpointScale.defaultScale] (the standard 5-tier scale).
  /// Zero magic: no context lookup — pass an explicit scale if you use a
  /// custom breakpoint configuration.
  final OiBreakpointScale scale;

  @override
  Widget build(BuildContext context) {
    final active = breakpoint;
    final resolvedScale = scale;
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

    return content;
  }
}
