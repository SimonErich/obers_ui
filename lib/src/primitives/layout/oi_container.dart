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
/// {@category Primitives}
class OiContainer extends StatelessWidget {
  /// Creates an [OiContainer].
  const OiContainer({
    this.child,
    this.maxWidth,
    this.padding,
    this.centered = true,
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

  @override
  Widget build(BuildContext context) {
    final resolvedMaxWidth = maxWidth?.resolveFor(context);
    final resolvedPadding = padding?.resolveFor(context);

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
