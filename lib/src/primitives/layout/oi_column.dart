import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A vertical layout widget that places [children] in a [Column] with uniform
/// [gap] spacing between them.
///
/// When [collapse] is set and the current breakpoint's [OiBreakpoint.minWidth]
/// is greater than or equal to [collapse.minWidth], the widget renders as a
/// [Row] instead, with the same [gap] applied as horizontal spacing.
///
/// {@category Primitives}
class OiColumn extends StatelessWidget {
  /// Creates an [OiColumn].
  const OiColumn({
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

  /// When non-null and the current breakpoint is at or above this breakpoint,
  /// the layout expands from a [Column] into a [Row].
  final OiBreakpoint? collapse;

  @override
  Widget build(BuildContext context) {
    final shouldExpand =
        collapse != null && context.breakpoint.minWidth >= collapse!.minWidth;

    // Build the interspersed children list.
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i < children.length - 1 && gap > 0) {
        if (shouldExpand) {
          spaced.add(SizedBox(width: gap));
        } else {
          spaced.add(SizedBox(height: gap));
        }
      }
    }

    if (shouldExpand) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spaced,
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spaced,
    );
  }
}
