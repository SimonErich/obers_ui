import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A content-width constraining wrapper with optional padding and centering.
///
/// [maxWidth] and [padding] accept [OiResponsive] values so they can vary
/// across breakpoints:
///
/// ```dart
/// OiContainer(
///   breakpoint: context.breakpoint,
///   maxWidth: OiResponsive.breakpoints({
///     OiBreakpoint.compact: double.infinity,
///     OiBreakpoint.expanded: 960,
///     OiBreakpoint.large: 1200,
///   }),
///   padding: OiResponsive.breakpoints({
///     OiBreakpoint.compact: EdgeInsets.all(16),
///     OiBreakpoint.expanded: EdgeInsets.all(32),
///   }),
///   child: content,
/// )
/// ```
///
/// **Zero magic:** [breakpoint] is required so every container is
/// self-contained with explicit props. Resolve the breakpoint once at the
/// page/layout level (e.g. `context.breakpoint`) and pass it down as a
/// concrete value.
///
/// {@category Primitives}
class OiContainer extends StatelessWidget {
  /// Creates an [OiContainer].
  const OiContainer({
    required this.breakpoint,
    this.child,
    this.maxWidth,
    this.padding,
    this.centered = true,
    this.scale = OiBreakpointScale.defaultScale,
    super.key,
  });

  /// Optional maximum width for the content area in logical pixels.
  final OiResponsive<double>? maxWidth;

  /// Optional padding around [child].
  final OiResponsive<EdgeInsetsGeometry>? padding;

  /// The widget to display inside the container.
  final Widget? child;

  /// Whether to center [child] horizontally. Defaults to `true`.
  final bool centered;

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
    final resolvedMaxWidth = maxWidth?.resolve(active, resolvedScale);
    final resolvedPadding = padding?.resolve(active, resolvedScale);

    var content = child ?? const SizedBox.shrink() as Widget;

    if (resolvedPadding != null) {
      content = Padding(padding: resolvedPadding, child: content);
    }

    content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: resolvedMaxWidth ?? double.infinity),
      child: content,
    );

    if (centered) {
      content = Center(child: content);
    }

    return content;
  }
}
