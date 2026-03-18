import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A vertical layout widget that places [children] in a [Column] with uniform
/// [gap] spacing between them.
///
/// [gap] accepts an [OiResponsive] value so it can vary across breakpoints:
///
/// ```dart
/// OiColumn(
///   gap: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 8,
///     OiBreakpoint.expanded: 16,
///   }),
///   children: [...],
/// )
/// ```
///
/// When [collapse] is set and the active breakpoint's [OiBreakpoint.minWidth]
/// is greater than or equal to [collapse.minWidth], the widget renders as a
/// [Row] instead, with the same [gap] applied as horizontal spacing.
///
/// The active breakpoint can be supplied explicitly via [breakpoint] so that
/// responsive values are resolved once at the layout level and passed down as
/// concrete values. When [breakpoint] is null the widget reads the breakpoint
/// from the nearest [OiTheme] via `context.breakpoint`.
///
/// {@category Primitives}
class OiColumn extends StatelessWidget {
  /// Creates an [OiColumn].
  const OiColumn({
    required this.children,
    this.gap = const OiResponsive<double>(0),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.collapse,
    this.breakpoint,
    super.key,
  });

  /// The spacing between children in logical pixels.
  final OiResponsive<double> gap;

  /// The child widgets to lay out.
  final List<Widget> children;

  /// How children are aligned along the main axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How children are aligned along the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much space the layout occupies along its main axis.
  ///
  /// Defaults to [MainAxisSize.min] so the widget shrink-wraps its children,
  /// allowing it to nest freely inside other layout widgets without causing
  /// unbounded-constraint errors.
  final MainAxisSize mainAxisSize;

  /// When non-null and the active breakpoint is at or above this breakpoint,
  /// the layout expands from a [Column] into a [Row].
  final OiBreakpoint? collapse;

  /// The active breakpoint, resolved at the layout level.
  ///
  /// When null, falls back to `context.breakpoint` (implicit context lookup).
  /// Prefer passing an explicit value so the widget is self-contained.
  final OiBreakpoint? breakpoint;

  @override
  Widget build(BuildContext context) {
    final active = breakpoint ?? context.breakpoint;
    final scale = context.breakpointScale;
    final resolvedGap = gap.resolve(active, scale);
    final shouldExpand =
        collapse != null && active.minWidth >= collapse!.minWidth;

    // Build the interspersed children list.
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i < children.length - 1 && resolvedGap > 0) {
        if (shouldExpand) {
          spaced.add(SizedBox(width: resolvedGap));
        } else {
          spaced.add(SizedBox(height: resolvedGap));
        }
      }
    }

    if (shouldExpand) {
      return Row(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spaced,
      );
    }

    return Column(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spaced,
    );
  }
}
