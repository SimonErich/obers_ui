import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A content-width constraining wrapper with optional padding and centering.
///
/// [maxWidth] and [padding] accept [OiResponsive] values so they can vary
/// across breakpoints:
///
/// ```dart
/// OiContainer(
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
/// The active breakpoint can be supplied explicitly via [breakpoint] so that
/// responsive values are resolved once at the layout level and passed down as
/// concrete values. When [breakpoint] is null the widget reads the breakpoint
/// from the nearest [OiTheme] via `context.breakpoint`.
///
/// {@category Primitives}
class OiContainer extends StatelessWidget {
  /// Creates an [OiContainer].
  const OiContainer({
    this.child,
    this.maxWidth,
    this.padding,
    this.centered = true,
    this.breakpoint,
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

  /// The active breakpoint, resolved at the layout level.
  ///
  /// When null, falls back to `context.breakpoint` (implicit context lookup).
  /// Prefer passing an explicit value so the widget is self-contained.
  final OiBreakpoint? breakpoint;

  @override
  Widget build(BuildContext context) {
    final active = breakpoint ?? context.breakpoint;
    final scale = context.breakpointScale;
    final resolvedMaxWidth = maxWidth?.resolve(active, scale);
    final resolvedPadding = padding?.resolve(active, scale);

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
