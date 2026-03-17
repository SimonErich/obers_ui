import 'package:flutter/widgets.dart';

/// A flexible or fixed-size spacer widget.
///
/// - When [flex] is provided, renders a [Spacer] with the given flex factor.
/// - When [size] is provided, renders a [SizedBox] of that size along [axis].
/// - When neither is provided, renders a [Spacer] with `flex: 1`.
///
/// {@category Primitives}
class OiSpacer extends StatelessWidget {
  /// Creates an [OiSpacer].
  const OiSpacer({this.size, this.flex, this.axis = Axis.vertical, super.key});

  /// Fixed size in logical pixels. Used when [flex] is null.
  final double? size;

  /// Flex factor for a flexible spacer. Takes precedence over [size].
  final int? flex;

  /// The axis along which a fixed [size] spacer expands.
  ///
  /// Ignored when [flex] is set.
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    if (flex != null) {
      return Spacer(flex: flex!);
    }

    if (size != null) {
      return axis == Axis.horizontal
          ? SizedBox(width: size)
          : SizedBox(height: size);
    }

    return const Spacer();
  }
}
