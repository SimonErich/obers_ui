import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A horizontal layout widget that places [children] in a [Row] with uniform
/// [gap] spacing between them.
///
/// When [collapse] is set and the current breakpoint's [OiBreakpoint.minWidth]
/// is less than or equal to [collapse.minWidth], the widget renders as a
/// [Column] instead, with the same [gap] applied as vertical spacing.
///
/// {@category Primitives}
class OiRow extends StatelessWidget {
  /// Creates an [OiRow].
  const OiRow({
    required this.children,
    this.gap = 0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.collapse,
    super.key,
  });

  /// The spacing between children in logical pixels.
  final double gap;

  /// The child widgets to lay out.
  final List<Widget> children;

  /// How children are aligned along the main axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How children are aligned along the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// When non-null and the current breakpoint is at or below this breakpoint,
  /// the layout collapses from a [Row] into a [Column].
  final OiBreakpoint? collapse;

  @override
  Widget build(BuildContext context) {
    final shouldCollapse =
        collapse != null && context.breakpoint.minWidth <= collapse!.minWidth;

    // Build the interspersed children list.
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i < children.length - 1 && gap > 0) {
        if (shouldCollapse) {
          spaced.add(SizedBox(height: gap));
        } else {
          spaced.add(SizedBox(width: gap));
        }
      }
    }

    if (shouldCollapse) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spaced,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spaced,
    );
  }
}
