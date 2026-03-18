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
    this.scale = OiBreakpointScale.defaultScale,
    super.key,
  });

  /// Creates a flex spacer that fills available space proportionally.
  ///
  /// The [flex] factor determines how much space this spacer takes
  /// relative to other flex children. Defaults to `1`.
  ///
  /// ```dart
  /// OiSpacer.flex()           // flex: 1
  /// OiSpacer.flex(flex: 2)    // twice the space
  /// ```
  const OiSpacer.flex({
    this.flex = 1,
    super.key,
  })  : size = null,
       axis = Axis.vertical,
       breakpoint = OiBreakpoint.compact,
       scale = OiBreakpointScale.defaultScale;

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
  /// Defaults to [OiBreakpointScale.defaultScale] (the standard 5-tier scale).
  /// Zero magic: no context lookup — pass an explicit scale if you use a
  /// custom breakpoint configuration.
  final OiBreakpointScale scale;

  @override
  Widget build(BuildContext context) {
    if (flex != null) {
      return Spacer(flex: flex!);
    }

    if (size != null) {
      final active = breakpoint;
      final resolvedScale = scale;
      final resolvedSize = size!.resolve(active, resolvedScale);
      return axis == Axis.horizontal
          ? SizedBox(width: resolvedSize)
          : SizedBox(height: resolvedSize);
    }

    return const Spacer();
  }
}
