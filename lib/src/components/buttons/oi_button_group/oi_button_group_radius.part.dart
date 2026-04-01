part of '../oi_button_group.dart';

/// Returns the per-position border radius for a button inside a connected
/// group. The first item gets leading corners, the last item gets trailing
/// corners, and middle items get no radius.
BorderRadius _connectedItemRadius(
  int index,
  int count,
  Axis direction,
  BorderRadius radius,
) {
  final isFirst = index == 0;
  final isLast = index == count - 1;

  if (direction == Axis.horizontal) {
    if (count == 1) return radius;
    if (isFirst) {
      return BorderRadius.only(
        topLeft: radius.topLeft,
        bottomLeft: radius.bottomLeft,
      );
    }
    if (isLast) {
      return BorderRadius.only(
        topRight: radius.topRight,
        bottomRight: radius.bottomRight,
      );
    }
    return BorderRadius.zero;
  }

  if (count == 1) return radius;
  if (isFirst) {
    return BorderRadius.only(
      topLeft: radius.topLeft,
      topRight: radius.topRight,
    );
  }
  if (isLast) {
    return BorderRadius.only(
      bottomLeft: radius.bottomLeft,
      bottomRight: radius.bottomRight,
    );
  }
  return BorderRadius.zero;
}
