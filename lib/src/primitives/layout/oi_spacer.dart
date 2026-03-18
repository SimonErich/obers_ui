import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// A flexible or fixed-size spacer widget with responsive support.
///
/// - When [flex] is provided, renders a [Spacer] with the given flex factor.
/// - When [size] is provided, renders a [SizedBox] of that size along [axis].
/// - When neither is provided, renders a [Spacer] with `flex: 1`.
///
/// [size] accepts an [OiResponsive] value so it can vary across breakpoints:
///
/// ```dart
/// OiSpacer(
///   breakpoint: context.breakpoint,
///   size: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 8,
///     OiBreakpoint.expanded: 24,
///   }),
/// )
/// ```
///
/// **Zero magic:** [breakpoint] is required so every spacer is self-contained
/// with explicit props. Resolve the breakpoint once at the page/layout level
/// (e.g. `context.breakpoint`) and pass it down as a concrete value.
///
/// {@category Primitives}
class OiSpacer extends StatelessWidget {
  /// Creates an [OiSpacer].
  const OiSpacer({
    required this.breakpoint,
    this.size,
    this.flex,
    this.axis = Axis.vertical,
    this.scale,
    super.key,
  });

  /// Fixed size in logical pixels. Used when [flex] is null.
  ///
  /// Accepts an [OiResponsive] value so size can vary across breakpoints.
  final OiResponsive<double>? size;

  /// Flex factor for a flexible spacer. Takes precedence over [size].
  final int? flex;

  /// The axis along which a fixed [size] spacer expands.
  ///
  /// Ignored when [flex] is set.
  final Axis axis;

  /// The active breakpoint. Required — resolve once at the layout level
  /// and pass down explicitly.
  final OiBreakpoint breakpoint;

  /// The breakpoint scale used to resolve responsive values.
  ///
  /// When null, read from the nearest [OiTheme] via `context.breakpointScale`.
  final OiBreakpointScale? scale;

  @override
  Widget build(BuildContext context) {
    if (flex != null) {
      return Spacer(flex: flex!);
    }

    if (size != null) {
      final active = breakpoint;
      final resolvedScale = scale ?? context.breakpointScale;
      final resolvedSize = size!.resolve(active, resolvedScale);
      return axis == Axis.horizontal
          ? SizedBox(width: resolvedSize)
          : SizedBox(height: resolvedSize);
    }

    return const Spacer();
  }
}
